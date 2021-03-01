module UserInterface where
import Oraculo
import Data.Map as Map
import Prelude

showOptions :: [String] -> String
showOptions = foldl1 concat
    where concat first second =  first ++ " / " ++ second

optionsList :: Opciones -> [String]
optionsList options = Prelude.map fst (Map.toList options)

requestRespose :: [String] -> String -> String -> IO String
requestRespose options question prediction = do
    putStrLn $ "Cual es la respuesta a\"" ++ question ++ "\" para " ++  prediction ++ "?"
    getValidOption options

requestQuestion :: String -> IO String
requestQuestion correctPrediction = do
    putStrLn $ "Que pregunta distingue a " ++ correctPrediction
                ++ " de las otras opciones?"
    getLine

requestCorrectPrediction :: IO String
requestCorrectPrediction = do
    putStrLn "He fallado! Cuál era la respuesta correcta?"
    getLine

getValidOption :: [String] -> IO String
getValidOption options = do
    option <- getLine
    case option of
        "ninguna" -> do
            putStrLn "\"ninguna\" no es admisible, vuelve a intentar"
            getValidOption options
        _ -> if option `elem` options then (do
                 putStrLn "Ya existe una respuesta con ese nombre."
                 getValidOption options) else (do
                 return option)


getValidResponse :: [String] -> IO String
getValidResponse options = do
    response <- getLine
    if response `elem` options then return response else (do
        putStrLn "Ha ingresado una opcion incorrecta, vuelve a intentar"
        getValidResponse options)

requestValidPrediction :: IO String
requestValidPrediction = do
    putStrLn "He fallado! Cuál era la respuesta correcta?"
    getLine