module Oraculo where
import qualified Data.Map as Map

data Opciones = Map String Oraculo

data Oraculo = Prediction String 
            | Question  String Opciones
            deriving(Show, Read)
