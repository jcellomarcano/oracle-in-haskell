module Main where

import Oracle
import qualified Data.Map as Map
import System.Exit (exitFailure, exitSuccess)
import Control.Exception (evaluate, try, SomeException)

assertEqual :: (Eq a, Show a) => String -> a -> a -> IO ()
assertEqual name expected actual
    | expected == actual = putStrLn $ "  [OK] " ++ name
    | otherwise = do
        putStrLn $ "  [FAIL] " ++ name
        putStrLn $ "    Expected: " ++ show expected
        putStrLn $ "    Actual:   " ++ show actual
        exitFailure

assertError :: String -> IO a -> IO ()
assertError name action = do
    res <- try (action >>= evaluate)
    case res of
        Left err -> do
            let _ = err :: SomeException
            putStrLn $ "  [OK] " ++ name
        Right _ -> do
            putStrLn $ "  [FAIL] " ++ name ++ " (expected an error but none was thrown)"
            exitFailure

main :: IO ()
main = do
    putStrLn "Running Oracle Unit Tests..."
    
    -- Test newOracle
    let o1 = newOracle "cat"
    assertEqual "newOracle creates a Prediction" (Prediction "cat") o1
    assertEqual "getPrediction returns string" "cat" (getPrediction o1)
    assertError "getQuestion on Prediction throws error" (return $ getQuestion o1)
    assertError "getOptions on Prediction throws error" (return $ getOptions o1)

    -- Test branch
    let o2 = newOracle "dog"
        qNode = branch ["No", "Yes"] [o1, o2] "Does it bark?"
    
    assertEqual "getQuestion on Question node" "Does it bark?" (getQuestion qNode)
    assertEqual "getOptions size is 2" 2 (Map.size (getOptions qNode))
    assertEqual "getBranch for 'No' is cat" o1 (getBranch qNode "No")
    assertEqual "getBranch for 'Yes' is dog" o2 (getBranch qNode "Yes")
    assertError "getBranch for invalid option throws error" (return $ getBranch qNode "Maybe")
    assertError "getPrediction on Question throws error" (return $ getPrediction qNode)

    -- Test findPaths
    assertEqual "findPaths on Prediction" [[]] (findPaths "cat" o1)
    assertEqual "findPaths on Prediction (not found)" [] (findPaths "dog" o1)
    assertEqual "findPaths on Question node (cat)" [[("Does it bark?", "No")]] (findPaths "cat" qNode)
    assertEqual "findPaths on Question node (dog)" [[("Does it bark?", "Yes")]] (findPaths "dog" qNode)

    -- Test getCrucialQuestion
    let o3 = newOracle "parrot"
        qNode2 = branch ["No", "Yes"] [qNode, o3] "Is it a bird?"
        -- qNode2 structure:
        -- Question "Is it a bird?"
        --   "No" -> Question "Does it bark?"
        --             "No" -> Prediction "cat"
        --             "Yes" -> Prediction "dog"
        --   "Yes" -> Prediction "parrot"

    assertEqual "getCrucialQuestion cat vs dog" (Right ("Does it bark?", "No", "Yes")) (getCrucialQuestion "cat" "dog" qNode2)
    assertEqual "getCrucialQuestion cat vs parrot" (Right ("Is it a bird?", "No", "Yes")) (getCrucialQuestion "cat" "parrot" qNode2)
    assertEqual "getCrucialQuestion same predictions" (Left "The two predictions are the same. Please provide different predictions.") (getCrucialQuestion "cat" "cat" qNode2)
    assertEqual "getCrucialQuestion not found" (Left "Prediction 'fish' was not found in the oracle.") (getCrucialQuestion "fish" "cat" qNode2)

    -- Test statistics helpers
    assertEqual "countPredictions qNode2" 3 (countPredictions qNode2)
    assertEqual "countQuestions qNode2" 2 (countQuestions qNode2)
    assertEqual "maxDepth qNode2" 2 (maxDepth qNode2)

    -- Test PathMap and cached LCA lookup
    let pathMap = buildPathMap qNode2
    assertEqual "buildPathMap size is 3" 3 (Map.size pathMap)
    assertEqual "getCrucialQuestionCached cat vs dog" (Right ("Does it bark?", "No", "Yes")) (getCrucialQuestionCached "cat" "dog" pathMap)
    assertEqual "getCrucialQuestionCached cat vs parrot" (Right ("Is it a bird?", "No", "Yes")) (getCrucialQuestionCached "cat" "parrot" pathMap)

    putStrLn "All Unit Tests Passed!"
    exitSuccess
