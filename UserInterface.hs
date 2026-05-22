module UserInterface where

import Oracle
import Data.Map as Map
import Prelude

-- | Format a list of option strings separated by slashes.
-- Safer fallback if the list is empty.
showOptions :: [String] -> String
showOptions [] = ""
showOptions xs = foldl1 (\first second -> first ++ " / " ++ second) xs

-- | Retrieve the options as a list of strings
optionsList :: Options -> [String]
optionsList options = Prelude.map fst (Map.toList options)

-- | Prompt the user for the option key that leads to the correct prediction
requestResponse :: [String] -> String -> String -> IO String
requestResponse forbiddenOptions question prediction = do
    putStrLn $ "What is the response to \"" ++ question ++ "\" for \"" ++ prediction ++ "\"?"
    getValidOption forbiddenOptions

-- | Ask the user for a question that distinguishes the correct prediction
requestQuestion :: String -> IO String
requestQuestion correctPrediction = do
    putStrLn $ "What question distinguishes \"" ++ correctPrediction ++ "\" from the other options?"
    getLine

-- | Prompt the user for the correct prediction when the oracle failed
requestCorrectPrediction :: IO String
requestCorrectPrediction = do
    putStrLn "I have failed! What was the correct prediction?"
    getLine

-- | Read user input for a new option key, ensuring it's not "none" or already used
getValidOption :: [String] -> IO String
getValidOption forbiddenOptions = do
    option <- getLine
    case option of
        "none" -> do
            putStrLn "\"none\" is not allowed, please try again."
            getValidOption forbiddenOptions
        _ -> if option `elem` forbiddenOptions then do
                 putStrLn "An option with that name already exists. Please try again."
                 getValidOption forbiddenOptions
             else
                 return option

-- | Read user input until they select one of the allowed options
getValidResponse :: [String] -> IO String
getValidResponse allowedOptions = do
    response <- getLine
    if response `elem` allowedOptions
        then return response
        else do
            putStrLn "Invalid option selected, please try again."
            getValidResponse allowedOptions

-- | Prompt the user for the correct prediction (alias / helper)
requestValidPrediction :: IO String
requestValidPrediction = requestCorrectPrediction