import System.IO
import System.Exit
import System.Directory (doesFileExist)
import Oraculo

exit :: IO Oraculo
exit = do {putStrLn "Gracias por usar Haskinator. Nos vemos pronto!"; return ()}

createOracle :: IO Oraculo
createOracle = do
        putStrLn "Inserta una predicción"
        prediction <- getLine
        crearOraculo prediction

main :: IO ()
main = do
        putStrLn "***********************"
        putStrLn "Bienvenido a Haskinator"
        putStrLn "Selecciona la opción a realizar:"
        menu Nothing


menu :: Maybe Oraculo -> IO ()
menu (Just oracle) = do
        putStrLn . unlines $ map concatNums choices
        choice <- getLine
        new_oracle <- case validate choice of
            Just 1 -> createOracle
            Just 2 -> foo
            Just 3 -> persistOracle oracle
            Just 4 -> chargeOracle
            Just 5 -> foo
            Just 6 -> do {putStrLn "Gracias por usar Haskinator. Nos vemos pronto!"; exitSuccess}
            Nothing -> do {putStrLn "Opción inválida"; return oracle}
        if choice /= "6"
            then do
                putStrLn ""
                menu (Just new_oracle)
            else
                putStrLn ""
   where concatNums (i, (s)) = show i ++ ": " ++ s
menu Nothing = do
        putStrLn . unlines $ map concatNums choices
        choice <- getLine
        case validate choice of
            Just 1  -> do
                new_instance <- createOracle
                menu (Just new_instance)
            Just 4  -> do
                new_instance <- foo
                menu (Just new_instance)
            Just 6  -> do {putStrLn "Gracias por usar Haskinator. Nos vemos pronto!"; exitSuccess}
            Nothing -> do {putStrLn "Opción inválida"; menu Nothing}
            _ -> do {putStrLn "No hay oráculo cargado"; menu Nothing}
   where concatNums (i, (s)) = show i ++ ": " ++ s


validate :: String -> Maybe Int
validate s = isValid (reads s)
   where isValid []            = Nothing
         isValid ((n, _):_) 
               | outOfBounds n = Nothing
               | otherwise     = Just n
         outOfBounds n = (n < 1) || (n > length choices)

choices :: [(Int, (String))]
choices = zip [1.. ] [
    ("Crear un oráculo nuevo")
    , ("Predecir")
    , ("Persistir")
    , ("Cargar")
    , ("Consultar pregunta crucial")
    , ("Salir")
    ]

-- execute :: Int -> IO ()
-- execute n = doExec $ filter (\(i, _) -> i == n) choices
--    where doExec ((_, (_,f)):_) = f

persistOracle :: Oraculo -> IO()
persistOracle oracle = do
                        putStrLn "Coloca el nombre de archivo en donde se guardará el oráculo: "
                        filename <- getLine
                        writeFile filename (show oracle)
                        return ()

readMaybe :: (Read a) => String -> Maybe a
readMaybe s = case reads s of
                [(x, "")] -> Just x
                _         -> Nothing

{- chargeOracle :: IO ()
chargeOracle = do
                putStrLn "Coloca el nombre del archivo en donde se encuentra el oráculo: "
                filename <- getLine
                existe <- doesFileExist filename
                if existe
                    then do 
                        oraculo <- readFile filename
                        let resp = readMaybe oraculo
                        if resp == Nothing
                            then do
                                putStrLn "El contenido del archivo no contiene un oraculo valido."
                                return Nothing
                            else return resp
                else do
                    putStrLn "El archivo no existe."
                    return Nothing -}

foo = undefined
bar = undefined