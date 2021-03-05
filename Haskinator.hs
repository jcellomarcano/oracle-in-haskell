import System.IO ()
import System.Exit ( exitSuccess )
import System.Directory (doesFileExist)
import Prelude
import Data.Map as Map
import Oraculo
import UserInterface
import Predictions

exit :: IO Oraculo
exit = do {putStrLn "Gracias por usar Haskinator. Nos vemos pronto!"; exitSuccess }

exitINIT :: IO()
exitINIT = do {putStrLn "Gracias por usar Haskinator. Nos vemos pronto!"; exitSuccess }

createOracle :: IO Oraculo
createOracle = do
        putStrLn "Inserta una predicción"
        crearOraculo <$> getLine

main :: IO ()
main = do
        putStrLn "***********************"
        putStrLn "Bienvenido a Haskinator"
        putStrLn "Selecciona la opción a realizar:"
        menu Nothing


menu :: Maybe Oraculo -> IO ()
menu (Just oracle) = do
        putStrLn . unlines $ Prelude.map concatNums choices
        choice <- getLine
        new_oracle <- case validate choice of
            Just 1 -> createOracle
            Just 2 -> doPrediction oracle
            Just 3 -> persistOracle oracle
            Just 4 -> chargeOracle
            Just 5 -> crucialQuestion
            Just 6 -> exit
            Nothing -> do {putStrLn "Opción inválida"; return oracle}
        if choice /= "6"
            then do
                putStrLn ""
                menu (Just new_oracle)
            else
                putStrLn ""
   where concatNums (i, s) = show i ++ ": " ++ s
menu Nothing = do
        putStrLn . unlines $ Prelude.map concatNums choices
        choice <- getLine
        case validate choice of
            Just 1  -> do
                new_instance <- createOracle
                menu (Just new_instance)
            Just 4  -> do
                new_instance <- chargeOracle
                menu (Just new_instance)
            Just 6  -> exitINIT
            Nothing -> do {putStrLn "Opción inválida"; menu Nothing}
            _ -> do {putStrLn "No hay oráculo cargado"; menu Nothing}
   where concatNums (i, s) = show i ++ ": " ++ s


validate :: String -> Maybe Int
validate s = isValid (reads s)
   where isValid []            = Nothing
         isValid ((n, _):_)
               | outOfBounds n = Nothing
               | otherwise     = Just n
         outOfBounds n = n < 1 || n > length choices

choices :: [(Int, String)]
choices = zip [1.. ] [
    "Crear un oráculo nuevo"
    , "Predecir"
    , "Persistir"
    , "Cargar"
    , "Consultar pregunta crucial"
    , "Salir"
    ]

-- execute :: Int -> IO ()
-- execute n = doExec $ filter (\(i, _) -> i == n) choices
--    where doExec ((_, (_,f)):_) = f

persistOracle :: Oraculo -> IO Oraculo
persistOracle oracle = do
                        putStrLn "Coloca el nombre de archivo en donde se guardará el oráculo: "
                        filename <- getLine
                        writeFile filename (show oracle)
                        return oracle

readMaybe :: (Read a) => String -> Maybe a
readMaybe s = case reads s of
                [(x, "")] -> Just x
                _         -> Nothing

cargar :: IO Oraculo
cargar = do
        putStrLn "Introduzca el archivo a leer."
        archivo <- getLine
        s <- readFile archivo
        return $ oraculo s
    where
        oraculo s = read s :: Oraculo

chargeOracle :: IO Oraculo
chargeOracle = do
                putStrLn "Coloca el nombre del archivo en donde se encuentra el oráculo: "
                filename <- getLine
                exist <- doesFileExist filename
                if exist then do
                        str <- readFile filename
                        return $ oracle str
                else
                    error "El archivo no existe."

                where
                    oracle str = read str :: Oraculo

--------Module Prediction


-- requestQuestion :: Oraculo -> IO Oraculo
-- requestQuestion = 


------------Modulo Interact

crucialQuestion :: IO Oraculo
crucialQuestion = error  "Función no disponible por los momentos :("




foo = undefined
