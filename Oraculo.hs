module Oraculo where
import qualified Data.Map as Map
import Data.Maybe ( fromJust )

type Opciones = Map.Map String Oraculo

data Oraculo = Prediccion String
            | Pregunta String Opciones
            deriving(Show, Read, Eq)

--Funcion de construcción

crearOraculo :: String -> Oraculo
crearOraculo = Prediccion

pregunta :: Oraculo -> String
pregunta (Pregunta preg _) = preg
pregunta _              = error "No ha ingresado una PREGUNTA"

prediccion :: Oraculo -> String
prediccion (Prediccion predic) = predic
prediccion _              = error "No ha ingresado una PREDICCION"

opciones :: Oraculo -> Opciones
opciones (Pregunta _ opci) = opci
opciones _              = error "No ha ingresado una Pregunta "

respuesta :: Oraculo -> String -> Oraculo
respuesta (Pregunta _ preg) y =
    case Map.lookup y preg of
        Just resp -> resp
        Nothing  -> error "RESPUESTA invalida"

respuesta _ _= error "No ha ungresado una PREGUNTA"

ramificar :: [String] -> [Oraculo] -> String -> Oraculo
ramificar ops orac preg = Pregunta preg ( Map.fromList ( zip ops orac))







