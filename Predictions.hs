module Predictions where

import Oracle
import Data.Map as Map ( insert )
import Prelude
import UserInterface

-- | Execute prediction navigation starting from the current Oracle node
doPrediction :: Oracle -> IO Oracle
doPrediction (Prediction predVal) = makePrediction (Prediction predVal)
doPrediction (Question qText opts) = processQuestion (Question qText opts)

-- | Handles reaching a Prediction node: proposes prediction and handles success/failure
makePrediction :: Oracle -> IO Oracle
makePrediction oracle = do
    putStrLn $ "Prediction: " ++ getPrediction oracle
    putStrLn "Is it correct? Yes/No"
    x <- getLine
    case x of
        "Yes" -> return oracle
        "No"  -> failedPrediction oracle
        _     -> do
            putStrLn "Please answer Yes or No."
            makePrediction oracle

-- | Handles reaching a Question node: asks the question and handles path navigation
processQuestion :: Oracle -> IO Oracle
processQuestion oracle = do
    putStrLn $ getQuestion oracle
    putStrLn $ showOptions allowedOptions
    userOption <- getValidResponse ("none" : allowedOptions)
    case userOption of
        "none" -> do
            correctPrediction <- requestValidPrediction
            opt <- requestResponse allowedOptions (getQuestion oracle) correctPrediction
            return (insertPred opt (newOracle correctPrediction) oracle)
        opt -> do
            subOracle <- doPrediction (getBranch oracle opt)
            return (insertPred opt subOracle oracle)
  where
    allowedOptions = optionsList $ getOptions oracle

-- | Handles a failed prediction: requests correct answer, distinguishing question, and options
failedPrediction :: Oracle -> IO Oracle
failedPrediction oracle = do
    correctPrediction <- requestValidPrediction
    question <- requestQuestion correctPrediction
    correctPredOpt <- requestResponse [] question correctPrediction
    oraclePredictionOpt <- requestResponse [correctPredOpt] question (getPrediction oracle)
    return (branch [oraclePredictionOpt, correctPredOpt]
                   [oracle, newOracle correctPrediction]
                   question)

-- | Insert/Update a branch under a Question node
insertPred :: String -> Oracle -> Oracle -> Oracle
insertPred option prediction (Question quest opts) = Question quest (Map.insert option prediction opts)
insertPred _ _ _ = error "Predictions.insertPred: Not a Question node"
