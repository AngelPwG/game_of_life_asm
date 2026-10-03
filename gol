los neightbors se van a calcular asi morro:
	para una random que este en el medio
	digamos que la posicion esta esta en r14
	primero tendriamos que ir a la casilla que esta arriba a la izquierda de ella
	ya que seria la que tendria menor indice, esto se haria
	restandole al valor de indice actual el tamaño del tablero mas 1
	r14 - (tamaño tablero + 1)
	al estar en esa posicion, pues ya simplemente se verifica si esta vivo o muerto
	y se pasa a la siguiente casilla, que este caso seria literal la siguiente, luego la que sigue
	asi ya tendriamos las casillas de arriba
	---
	.#.
	...

	nos faltarian las de los lados y las de abajo
	para la delos lados simplemento volvemos a agarrar el valor de el indice actual y le restamos, luego le sumamos 2
	---
	-#-
	...
	solo quedarian los de abajo, y ya por ultima se le suma a la ultima casilla en la que estuvo que en este caso seria la actual + 1, se le suma el tamaño del tablero - 2, asi estando en la casilla inferior izquierda, y se repite el proceso de la primera parte
	---
	-#-
	---

	ahora para una celula que esta en algun limite ya sea horizontal o vertical, simplemente tendriamos que ver el indice y aplicarle el modulo del tamaño del tablero, eso funcionaria con el limite superior e izquierdo ya que inician en 0, sin embargo si queremos hacer lo mismo con el limite derecho e inferior, el modulo nos daria 1, ya que el indice de esos limites es el tamaño del tablero menos 1, otra cosa que podemos hacer seria simplemente ver si el indice es igual a 0 o a el tamaño del tablero

	0 1 2 3 
	4 5 6 7
	8 9 10 11
	12 13 14 15

	limite izquierdo -> indice % tamaño del tablero  == 0
	limite derecho -> indice % tamaño del tablero == tamaño del tablero - 1
	limite superior -> indice >= 0 && indice < tamaño del tablero
	limite inferior -> indice >= tamaño del tablero * (tamaño del tablero - 1)

	ahora la cosa, el programa tiene que calcular los vecinos con el mismo tablero para todas las celulas, por tanto ocuparia dos tablero, una con las celulas que cambian, y otra con la copia de la anterior gen
	cuando una gen acaba de evolucionar, se copiaria toda la informacion dela gen que cambia a la copia, y asi la gen que cambia podria tener a todas las celulas viendo la misma copia que se acaba de copiar

r9 -> indice de la celula actual
r10 -> numero de vecinos de la celula actual
r11 -> puntero absoluto en el tablero real
r12 -> puntero relativo al tablero real en el tablero copia
r13 -> puntero con el que se verificara el estado de los vecinos
r15 -> puntero al character

Parte 2 - Movimiento del cursor y edicion de las celulas antes de la simulacion

Antes del loop de Game of Life va a haver un modo de edicion donde vas a poder seleccionar las celulas que empiezan vivas utilizando las vim motions.

El flujo seria

_start -> configurar terminal -> inicializar tablero -> editor_loop -> ocultar cursor -> main_loop -> restaurar la terminal, mostrar cursor -> exit

La terminal se tiene que configurar porque de normal la terminal trabaja en modo canonico, que significa basicamente que para que el programa sepa que teclas presionas necesitas presionar enter despues de cada tecla, aparte de que imprime las teclas que presionas.
Para recibir las teclas (h, j, k, l, SPACE, q, ENTER) necesito desactivar ICANON y ECHO el flujo que tiene que llevar esta parte seria:

guardar configuracion de la terminal actual -> desactivar ICANON y ECHO -> comenzar editor

al salir del programa se restaurara la configuracion original

El tablero comieza vacio, utilizare r9 como indice de la celda seleccionada
r9 = 0

El cursor iniciara en el index 0, arriba a la izquierda
El indice funcionara de una manera similar a como se maneja al verificar los vecinos.
No puede salir de 0 - 255
porque el tablero es de 16x16

El programa al iniciar entra en un ciclo:

editor_loop: esperar tecla -> que tecla fue -> ejecuta accion -> vuelve a esperar tecla

las teclas validas serian
h -> izquierda
j -> abajo
k -> arriba
l -> derecha
SPACE -> toggle celula (muerto -><- vivo)
ENTER -> comenzar simulacion
q -> salir

H - izquierda
Antes de mover con H hay que comprobar que la celda no este en la primera columna, se hace igual que en al verificar vecinos:

indice % 16 == 0

si esta en el borde izquierdo no hace nada

si si se puede mover r9 -= 1

y movemos fisicamente el cursor de la terminal a la izquierda

ANSI:
\x1b[D

L - derecha
Comprobamos si el indice esta en la ultima columna:
indice % 16 == 15

si esta en el borde no hace nada
si si se puede mover r9 += 1
ANSI:
\x1b[C

J - abajo
La ultima fila comienza en 240 asi que si index >= 240 no se puede mover porque esta en la ultima fila
si no esta en la ultima fila: r9 += 16
ANSI:
\x1b[B

K - arriba
La primera fila va de 0 - 15 asi que si index < 16 no se puede mover
si no esta en la primera fila: r9 -= 16
ANSI:
\x1b[A

El indice en r9 y el cursor visual deben moverse juntos

SPACE - toggle
CUando se presione espacio, el estado de la celula en el indice actual, cambia:
1 -> 0
0 -> 1
Despues se imprime el nuevo caracter en la posicion actual
la terminal al imprimir un caracter pasa el cursor al siguiente caracter, asi que debemos usar el ANSI escape code de back: \x1b[D

El flujo seria
SPACE -> obtener grid[r9] -> toggle 0 <-> 1 -> actualizar grid[r9] -> imprimir '.' o '#'-> \x1b[D -> seguir esperando input

ENTER - inicia Game of Life
cuando se presione enter
jmp main_loop
aunque antes de eso se oculta el cursor de la terminal con el ANSI:
\x1b[?25l

Q - salir

para salir simplemente se:
restaura la configuracion de terminal -> mostrar cursor -> limpiar la pantalla -> exit
