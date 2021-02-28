import System.IO 

crearOraculo :: String -> String
crearOraculo x = x

exit :: IO()
exit = do {putStrLn "Gracias por usar Haskinator. Nos vemos pronto!"; return ()}

createOracle :: IO()
createOracle = do
        putStrLn "Inserta una predicción"
        prediction <- getLine
        putStrLn (crearOraculo prediction)

chargeOracle :: IO()
chargeOracle = do
        handle <- openFile "example.txt" ReadMode  
        contents <- hGetContents handle  
        putStr contents  
        hClose handle 

main :: IO ()
main = do  
        putStrLn "***********************"
        putStrLn "Bienvenido a Haskinator"
        putStrLn "Selecciona la opción a realizar:"
        menu


menu :: IO ()
menu = do
        putStrLn . unlines $ map concatNums choices
        choice <- getLine
        case validate choice of
            Just n  -> execute . read $ choice
            Nothing -> putStrLn "Intenta de nuevo"
        if choice /= "6"
            then do
                putStrLn ""
                menu
            else
                putStrLn ""
   where concatNums (i, (s, _)) = show i ++ ": " ++ s

validate :: String -> Maybe Int
validate s = isValid (reads s)
   where isValid []            = Nothing
         isValid ((n, _):_) 
               | outOfBounds n = Nothing
               | otherwise     = Just n
         outOfBounds n = (n < 1) || (n > length choices)

choices :: [(Int, (String, IO ()))]
choices = zip [1.. ] [
    ("Crear un oráculo nuevo", createOracle)
    , ("Predecir", foo)
    , ("Persistir", foo)
    , ("Cargar", chargeOracle)
    , ("Consultar pregunta crucial", foo)
    , ("Salir", exit)
    ]

execute :: Int -> IO ()
execute n = doExec $ filter (\(i, _) -> i == n) choices
   where doExec ((_, (_,f)):_) = f

foo = undefined
bar = undefined