module Oraculo where
import qualified Data.Map as Map

type Opciones = Map.Map String Oraculo

data Oraculo = Prediccion String
            | Pregunta String Opciones
            deriving(Show, Read)

--Funcion de construcción

crearOraculo :: String -> Oraculo
crearOraculo = Prediccion

-- pregunta :: Oraculo -> String
-- pregunta x = if x == Pregunta then show x else "error" 

-- chequePregunta :: String -> Oraculo -> Bool
-- chequePregunta str(Pregunta x) =


