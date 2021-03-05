# :crystal_ball: :sparkles: Oracle in Haskell
 
Este programa representa los poderes de adivinación de Haskinator.

## :star: ¿Cómo usarlo?

```shell
make
./Haskinator
```

Tiene las siguientes opciones:

- Crear un oráculo nuevo: Si esta opción es seleccionada, se pide al usuario una predicción y se almacena la misma como la única predicción del oráculo.

- Predecir: Si esta opción es seleccionada, se comienza el proceso de predicción:

    - Si el oráculo es una pregunta, se plantea dicha pregunta al usuario y se le presenta el conjunto de respuestas posibles a la misma.

    - Tomando en cuenta la respuesta del usuario, que puede ser únicamente una de las respuestas presentadas o ninguna, se navega al sub–oráculo correspondiente.

    - Si el usuario responde ninguna, debe pedírsele al usuario la opción que él esperaba y la respuesta correcta.

    - Al alcanzar una predicción (o si el oráculo inicial era una predicción) se le propone la misma al usuario.

    - El usuario puede entonces decidir si la predicción es acertada. De serlo, se termina la acción. De no serlo, debe pedírsele al usuario:

        - La respuesta correcta.
        - Una pregunta que la distinga de la predicción hecha.
        - La opción que lleva a la respuesta deseada.
        - La opción que corresponde a la respuesta incorrecta (la que arrojó Haskinator).

        Usando esta nueva información, debe incorporarse la nueva pregunta al oráculo.

- Persistir: Si esta opción es seleccionada, pide un nombre de archivo al usuario y luego se debe
almacenar la información del oráculo construido en el archivo suministrado.

- Cargar: Si esta opción es seleccionada, pide un nombre de archivo al usuario y luego se debe
cargar la información al oráculo desde el archivo suministrado.

- Consultar pregunta crucial: Si esta opción es seleccionada, se deben pedir dos cadenas de caracteres
al usuario.

    - Si alguna de las dos no tiene una predicción correspondiente en el oráculo, entonces la consulta es inválida.

    - Si ambas se encuentran como predicciones en el oráculo, se debe imprimir la pregunta crucial que llevaría a decidir eventualmente por una predicción o la otra (si se analiza el oráculo como un árbol, vendría a ser el ancestro en común más bajo), además de la opción correspondiente para cada una de las predicciones involucradas.

- Salir: Permite salir del menú de opciones y terminar la ejecución del programa.

## :mag: Sobre la implementación

Para la implementación de este proyecto se decidió crear 4 módulos. El de Haskinator.hs y el Oraculo.hs, que son los que se pedían inicialmente en el enunciado y se agregaron los módulos de UserInterface.hs y Predictions.hs, en donde en el primero se implementan las funciones relacionadas a las predicciones que tengan que ver directamente con preguntas y respuestas con el usuario, y en Predictions se encuentran las funciones un poco más generales para predecir y revisar si alguna predicción es fallida. Por su parte en Haskinator está el main del programa que llama a las demás funciones, y en Oraculo están todas las funciones referentes a la construcción del mismo, como por ejemplo crearOraculo, pregunta, prediccion, ramificar, etc.

### :mega: Nota

Por cuestiones de tiempo no se pudo implementar correctamente la función de consultar pregunta crucial.

## :zap: Integrantes
:man: Jesús Alejandro Marcano 12-10359

:woman: María Fernanda Magallanes 13-10787