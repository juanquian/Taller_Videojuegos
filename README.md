# San José: El Archivo Perdido

## Descripción del juego

**San José: El Archivo Perdido** es un videojuego 2D desarrollado en **PICO-8** utilizando **Lua**.

El juego trata sobre un estudiante de informática que, a pocas horas de defender su proyecto final, pierde el pendrive donde tenía guardado su trabajo. A partir de ese momento, debe recorrer distintos escenarios inspirados en San José de Mayo para intentar recuperarlo antes de que se termine el tiempo.

Durante el recorrido, el jugador debe avanzar por diferentes zonas, enfrentar enemigos, hablar con personajes importantes y derrotar jefes que le dan pistas sobre el paradero del pendrive.

## Objetivo principal

El objetivo del juego es **recuperar el pendrive antes de la defensa final**.

Para lograrlo, el jugador debe recorrer los escenarios, sobrevivir a los enemigos, derrotar al placero y finalmente vencer al jefe del gimnasio, quien tiene el pendrive.

## Historia

El protagonista descubre que perdió su pendrive con el archivo del proyecto. Al recordar su recorrido, sospecha que pudo haberlo perdido en la plaza.

Primero sale de su cuarto y pasa por la calle principal, donde se encuentra con estudiantes hostiles. Luego llega a la plaza y habla con el placero, quien revela que el pendrive terminó en manos del jefe del gimnasio.

Finalmente, el jugador debe llegar al gimnasio, enfrentar al jefe final y recuperar el pendrive para poder llegar a tiempo a la defensa.

## Condición de victoria

El jugador gana si:

- Llega al gimnasio.
- Derrota al jefe final.
- Recupera el pendrive.

Al ganar, aparece una pantalla de victoria indicando que el pendrive fue recuperado y que la defensa sigue viva.

## Condiciones de derrota

El jugador pierde si:

- Se queda sin vidas.
- Se termina el tiempo límite.

El juego cuenta con una pantalla de derrota que indica el motivo por el cual se perdió la partida.

## Controles

- **Flechas:** mover al personaje.
- **X:** golpear o disparar.
- **X + abajo:** defenderse.
- **Flecha arriba:** saltar durante el combate contra el jefe del gimnasio.
- **Z / X:** avanzar diálogos, comenzar o reiniciar.

## Mecánicas principales

El juego utiliza mecánicas simples adaptadas a las limitaciones de PICO-8.

El jugador puede:

- Moverse por los escenarios.
- Atacar enemigos cercanos.
- Disparar durante los combates contra jefes.
- Defenderse usando X + abajo.
- Saltar en el combate final para esquivar la embestida del jefe del gimnasio.
- Cambiar de mapa al avanzar por el recorrido.
- Perder vida al recibir daño.
- Ganar o perder según el tiempo y la vida disponible.

## Sistema de mapas

El juego está dividido en cuatro escenarios principales:

- **Cuarto del estudiante:** punto inicial de la historia.
- **Calle principal:** zona de avance y primer combate contra estudiantes.
- **Plaza:** lugar donde se perdió originalmente el pendrive.
- **Gimnasio:** escenario final donde se encuentra el jefe del gym.

El recorrido del juego es lineal:

```txt
Cuarto → Calle → Plaza → Gimnasio → Final
