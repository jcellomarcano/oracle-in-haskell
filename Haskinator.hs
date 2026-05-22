import System.IO ()
import System.Exit ( exitSuccess )
import System.Directory (doesFileExist)
import Prelude
import Data.Map as Map
import Oracle
import UserInterface
import Predictions

-- | Exit the application with a friendly message
exitApp :: IO Oracle
exitApp = do
    putStrLn "Thank you for using Haskinator. See you soon!"
    exitSuccess

exitInit :: IO ()
exitInit = do
    putStrLn "Thank you for using Haskinator. See you soon!"
    exitSuccess

-- | Prompt the user for an initial prediction and construct a new Oracle
createOracle :: IO Oracle
createOracle = do
    putStrLn "Insert a prediction:"
    newOracle <$> getLine

main :: IO ()
main = do
    putStrLn "***********************"
    putStrLn "Welcome to Haskinator"
    putStrLn "Select an option to perform:"
    menu Nothing

-- | Main interactive menu loop
menu :: Maybe Oracle -> IO ()
menu (Just oracle) = do
    putStrLn . unlines $ Prelude.map concatNums choices
    choice <- getLine
    newOracleState <- case validate choice of
        Just 1 -> createOracle
        Just 2 -> doPrediction oracle
        Just 3 -> persistOracle oracle
        Just 4 -> loadOracle
        Just 5 -> crucialQuestion oracle
        Just 6 -> showStatsAndTree oracle
        Just 7 -> exitApp
        Nothing -> do
            putStrLn "Invalid option."
            return oracle
    if choice /= "7"
        then do
            putStrLn ""
            menu (Just newOracleState)
        else
            putStrLn ""
  where
    concatNums (i, s) = show i ++ ": " ++ s

menu Nothing = do
    putStrLn . unlines $ Prelude.map concatNums choices
    choice <- getLine
    case validate choice of
        Just 1  -> do
            newOracleState <- createOracle
            menu (Just newOracleState)
        Just 4  -> do
            newOracleState <- loadOracle
            menu (Just newOracleState)
        Just 7  -> exitInit
        Nothing -> do
            putStrLn "Invalid option."
            menu Nothing
        _ -> do
            putStrLn "No oracle loaded."
            menu Nothing
  where
    concatNums (i, s) = show i ++ ": " ++ s

-- | Validates if the selected menu option is within range
validate :: String -> Maybe Int
validate s = isValid (reads s)
  where
    isValid []            = Nothing
    isValid ((n, _):_)
        | outOfBounds n   = Nothing
        | otherwise       = Just n
    outOfBounds n         = n < 1 || n > length choices

-- | The list of menu choices in English
choices :: [(Int, String)]
choices = zip [1.. ]
    [ "Create a new oracle"
    , "Predict"
    , "Persist"
    , "Load"
    , "Consult crucial question"
    , "Show Oracle Statistics & Tree"
    , "Exit"
    ]

-- | Saves the current oracle state to a file
persistOracle :: Oracle -> IO Oracle
persistOracle oracle = do
    putStrLn "Enter the file name to save the oracle: "
    filename <- getLine
    writeFile filename (show oracle)
    putStrLn "Oracle saved successfully."
    return oracle

-- | Loads an oracle state from a file
loadOracle :: IO Oracle
loadOracle = do
    putStrLn "Enter the file name of the oracle to load: "
    filename <- getLine
    exist <- doesFileExist filename
    if exist
        then do
            str <- readFile filename
            case readMaybe str of
                Just oracle -> do
                    putStrLn "Oracle loaded successfully."
                    return oracle
                Nothing -> do
                    error "Error: Could not parse oracle from file."
        else do
            error "Error: File does not exist."

-- | Helper to parse a string representation of a type
readMaybe :: (Read a) => String -> Maybe a
readMaybe s = case reads s of
    [(x, "")] -> Just x
    _         -> Nothing

-- | Prompt for two predictions and display the crucial question distinguishing them
crucialQuestion :: Oracle -> IO Oracle
crucialQuestion oracle = do
    putStrLn "Enter the first prediction:"
    p1 <- getLine
    putStrLn "Enter the second prediction:"
    p2 <- getLine
    case getCrucialQuestion p1 p2 oracle of
        Left err -> do
            putStrLn $ "Error: " ++ err
        Right (q, o1, o2) -> do
            putStrLn $ "The crucial question is: \"" ++ q ++ "\""
            putStrLn $ "For \"" ++ p1 ++ "\", the option is: \"" ++ o1 ++ "\""
            putStrLn $ "For \"" ++ p2 ++ "\", the option is: \"" ++ o2 ++ "\""
    return oracle

-- | Display statistics and pretty ASCII visualization of the oracle
showStatsAndTree :: Oracle -> IO Oracle
showStatsAndTree oracle = do
    putStrLn "=== Oracle Statistics ==="
    putStrLn $ "Total Questions:   " ++ show (countQuestions oracle)
    putStrLn $ "Total Predictions: " ++ show (countPredictions oracle)
    putStrLn $ "Maximum Depth:     " ++ show (maxDepth oracle)
    putStrLn ""
    putStrLn "=== Oracle Tree Visualization ==="
    putStr (prettyPrintOracle oracle)
    return oracle
