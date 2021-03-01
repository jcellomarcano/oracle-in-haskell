module Predictions where
import Oraculo
import Data.Map as Map ( insert )
import Prelude
import UserInterface

doPrediction :: Oraculo -> IO Oraculo
doPrediction (Prediccion pred) = makePrediction (Prediccion pred) -- error de typo 
doPrediction (Pregunta str opci) = makePregunta (Pregunta str opci)

makePrediction :: Oraculo -> IO Oraculo
makePrediction oracle = do
    putStrLn $ "Prediccion: " ++ prediccion oracle
    putStrLn "¿Es verdadera? Si/No"
    x <- getLine
    case x of
        "Si" -> return oracle
        "No" -> predicctionFailed oracle

makePregunta :: Oraculo -> IO Oraculo
makePregunta oracle = do
        putStrLn $ pregunta oracle
        putStrLn $ showOptions lista
        userOption <- getValidResponse ("ninguna": optionsList (opciones oracle))
        case userOption of
            "ninguna" -> do
                correctPrediction <- requestValidPrediction
                opcion <- requestRespose lista (pregunta oracle) correctPrediction
                return (insertPred opcion (crearOraculo correctPrediction) oracle)
            opcion -> do
                subOraculo <- doPrediction (respuesta oracle opcion)
                return (insertPred opcion subOraculo oracle)
    where
        lista = optionsList $ opciones oracle

failedPrediction :: Oraculo -> IO Oraculo
failedPrediction oracle = do
    correctPrediction <- requestValidPrediction
    question <- requestQuestion correctPrediction
    correctPredOpt  <- requestRespose [] question correctPrediction
    oraclePredictionOpt   <- requestRespose [correctPredOpt] question (prediccion oracle)
    return ( ramificar  [oraclePredictionOpt, correctPredOpt]
                        [oracle, crearOraculo correctPrediction]
                        question )



insertPred :: String -> Oraculo -> Oraculo -> Oraculo
insertPred option prediction (Pregunta quest opt) = Pregunta quest (insert option prediction opt)
insertPred _ _ _ = error "No he recibido una pregunta oraculo"

predicctionFailed :: Oraculo -> IO Oraculo
predicctionFailed oracle = do
    prediccionCorrecta <- requestValidPrediction
    question <- requestQuestion prediccionCorrecta
    correctPredOpt  <- requestRespose [] question prediccionCorrecta
    oraclePredictionOpt   <- requestRespose [correctPredOpt] question (prediccion oracle)
    return ( ramificar  [oraclePredictionOpt, correctPredOpt]
                        [oracle, crearOraculo prediccionCorrecta]
                        question )
