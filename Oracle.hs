module Oracle where

import qualified Data.Map as Map

type Options = Map.Map String Oracle

data Oracle = Prediction String
            | Question String Options
            deriving (Show, Read, Eq)

-- | Constructor helper for initial predictions
newOracle :: String -> Oracle
newOracle = Prediction

-- | Retrieve the text of a Question node
getQuestion :: Oracle -> String
getQuestion (Question q _) = q
getQuestion _              = error "Oracle: Not a Question node"

-- | Retrieve the text of a Prediction node
getPrediction :: Oracle -> String
getPrediction (Prediction p) = p
getPrediction _              = error "Oracle: Not a Prediction node"

-- | Retrieve the options map of a Question node
getOptions :: Oracle -> Options
getOptions (Question _ opts) = opts
getOptions _                 = error "Oracle: Not a Question node"

-- | Retrieve the branch corresponding to a selected option
getBranch :: Oracle -> String -> Oracle
getBranch (Question _ opts) opt =
    case Map.lookup opt opts of
        Just sub -> sub
        Nothing  -> error $ "Oracle: Invalid option '" ++ opt ++ "'"
getBranch _ _ = error "Oracle: Not a Question node"

-- | Create a Question node branching into multiple sub-oracles
branch :: [String] -> [Oracle] -> String -> Oracle
branch keys subOracles q = Question q (Map.fromList (zip keys subOracles))

-- | Find all paths from the root to a prediction target.
-- Each path is represented as a list of (Question, OptionChosen) pairs.
findPaths :: String -> Oracle -> [[(String, String)]]
findPaths target (Prediction predVal)
    | target == predVal = [[]]
    | otherwise         = []
findPaths target (Question qText opts) =
    [ (qText, opt) : path
    | (opt, subOracle) <- Map.toList opts
    , path <- findPaths target subOracle
    ]

-- | Find the Lowest Common Ancestor (LCA) question and the diverging options.
-- Returns: Just (CrucialQuestion, OptionForP1, OptionForP2)
findLCA :: [(String, String)] -> [(String, String)] -> Maybe (String, String, String)
findLCA [] _ = Nothing
findLCA _ [] = Nothing
findLCA ((q1, o1):xs) ((q2, o2):ys)
    | q1 == q2 && o1 == o2 = findLCA xs ys
    | q1 == q2             = Just (q1, o1, o2)
    | otherwise            = Nothing

-- | Determine the crucial question that distinguishes two predictions
getCrucialQuestion :: String -> String -> Oracle -> Either String (String, String, String)
getCrucialQuestion p1 p2 oracle
    | p1 == p2 = Left "The two predictions are the same. Please provide different predictions."
    | otherwise =
        case (findPaths p1 oracle, findPaths p2 oracle) of
            ([], _) -> Left $ "Prediction '" ++ p1 ++ "' was not found in the oracle."
            (_, []) -> Left $ "Prediction '" ++ p2 ++ "' was not found in the oracle."
            (path1:_, path2:_) ->
                case findLCA path1 path2 of
                    Just (q, o1, o2) -> Right (q, o1, o2)
                    Nothing -> Left $ "Could not find a crucial question. The predictions might not diverge."

-- | Caching structure mapping each prediction to its query path
type PathMap = Map.Map String [(String, String)]

-- | Construct a cache of all prediction paths in the Oracle tree.
buildPathMap :: Oracle -> PathMap
buildPathMap oracle = go [] oracle
  where
    go pathAccum (Prediction predVal) = Map.singleton predVal (reverse pathAccum)
    go pathAccum (Question qText opts) =
        Map.unions [ go ((qText, opt) : pathAccum) subOracle
                   | (opt, subOracle) <- Map.toList opts ]

-- | Determine the crucial question distinguishing two predictions using a cached PathMap
getCrucialQuestionCached :: String -> String -> PathMap -> Either String (String, String, String)
getCrucialQuestionCached p1 p2 pathMap
    | p1 == p2 = Left "The two predictions are the same. Please provide different predictions."
    | otherwise =
        case (Map.lookup p1 pathMap, Map.lookup p2 pathMap) of
            (Nothing, _) -> Left $ "Prediction '" ++ p1 ++ "' was not found in the oracle."
            (_, Nothing) -> Left $ "Prediction '" ++ p2 ++ "' was not found in the oracle."
            (Just path1, Just path2) ->
                case findLCA path1 path2 of
                    Just (q, o1, o2) -> Right (q, o1, o2)
                    Nothing -> Left $ "Could not find a crucial question. The predictions might not diverge."

-- | Generate a beautiful, indented ASCII tree layout of the Oracle tree.
prettyPrintOracle :: Oracle -> String
prettyPrintOracle = unlines . go "" ""
  where
    go :: String -> String -> Oracle -> [String]
    go indent nodePrefix (Prediction predVal) =
        [indent ++ nodePrefix ++ "Prediction: " ++ predVal]
    go indent nodePrefix (Question qText opts) =
        (indent ++ nodePrefix ++ "Question: " ++ qText) : processChildren (Map.toList opts)
      where
        processChildren [] = []
        processChildren [(opt, child)] =
            go (indent ++ "    ") ("└── " ++ opt ++ " ➔ ") child
        processChildren ((opt, child):cs) =
            go (indent ++ "│   ") ("├── " ++ opt ++ " ➔ ") child ++ processChildren cs

-- | Count the total number of Prediction nodes in the Oracle tree.
countPredictions :: Oracle -> Int
countPredictions (Prediction _) = 1
countPredictions (Question _ opts) = sum [ countPredictions child | child <- Map.elems opts ]

-- | Count the total number of Question nodes in the Oracle tree.
countQuestions :: Oracle -> Int
countQuestions (Prediction _) = 0
countQuestions (Question _ opts) = 1 + sum [ countQuestions child | child <- Map.elems opts ]

-- | Calculate the maximum depth of the Oracle tree.
maxDepth :: Oracle -> Int
maxDepth (Prediction _) = 0
maxDepth (Question _ opts)
    | Map.null opts = 1
    | otherwise     = 1 + maximum [ maxDepth child | child <- Map.elems opts ]

