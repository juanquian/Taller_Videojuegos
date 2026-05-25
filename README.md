# San José: El Archivo Perdido

## Descripción del juego

**San José: El Archivo Perdido** es un videojuego 2D desarrollado en **PICO-8** utilizando **Lua**.

El juego trata sobre un estudiante de informática que, a pocas horas de defender su proyecto final, pierde el pendrive donde tenía guardado todo su trabajo. A partir de ese momento, debe recorrer distintos escenarios inspirados en San José de Mayo para intentar recuperarlo antes de que sea demasiado tarde.

El jugador deberá avanzar por diferentes zonas, esquivar obstáculos, enfrentarse a enemigos y derrotar bosses que le darán pistas sobre el paradero del pendrive.

## Objetivo principal

El objetivo del juego es recuperar el pendrive antes de que se termine el tiempo disponible.

### Condición de victoria

- Derrotar al boss final.
- Recuperar el pendrive perdido.

### Condiciones de derrota

- Perder toda la vida.
- Que se termine el tiempo límite.

## Mecánicas principales

El juego utiliza mecánicas simples, pensadas para adaptarse a las limitaciones de PICO-8 y mantener una jugabilidad clara.

El jugador puede:

- Moverse lateralmente.
- Saltar.
- Atacar enemigos.
- Interactuar con elementos del escenario.
- Cambiar de mapa al llegar a determinadas zonas.

## Sistema de mapas

El juego está dividido en varios escenarios. Cada mapa representa una parte distinta del recorrido del protagonista.

### Mapas implementados o planificados

- Cuarto del estudiante.
- Calle o recorrido principal.
- Plaza Artigas.
- Gimnasio.
- Kiosco / zona final.

El primer mapa funciona como una zona inicial más estática, mientras que los mapas siguientes permiten mayor desplazamiento  .  
Al llegar al final de ciertos mapas, el jugador pasa al siguiente escenario.

## Sistema de combate

El jugador cuenta con ataques básicos utilizando objetos cotidianos.

### Ataques del jugador

- **Golpe de puño:** ataque corto para enemigos cercanos.
- **Golpe con mochila:** ataque con un poco más de alcance.
- **Mate:** habilidad especial que puede mejorar temporalmente el rendimiento del jugador.

## Enemigos

Durante el recorrido aparecen enemigos básicos que dificultan el avance del jugador.

### Tipos de enemigos

- Estudiante enfurecido.
- NPC hostil callejero.
- Empleado enojado.

Cada enemigo tendrá comportamientos simples, como moverse por el escenario y atacar cuando el jugador se acerque.

## Bosses

Los bosses funcionan como puntos importantes de progreso dentro del juego.  
Al derrotar a cada boss, el jugador obtiene una nueva pista sobre dónde puede estar el pendrive.

### Bosses planificados

- Boss 1: Placero.
- Boss 2: Empleado loco.
- Boss final: Vendedor enfurecido.

Cada boss tendrá más vida que los enemigos comunes y una dificultad mayor.

## Estilo visual

El juego utiliza un estilo pixel art simple, respetando la paleta de colores y las limitaciones propias de PICO-8.

Se busca representar una versión simplificada y humorística de San José de Mayo, usando escenarios urbanos, calles, plazas y lugares cotidianos.

## Motor y lenguaje

- **Motor:** PICO-8
- **Lenguaje:** Lua
- **Estilo:** Juego 2D de acción con vista lateral

 

## Estado actual del desarrollo

Actualmente se está trabajando en:

- Movimiento del personaje principal.
- Definición de límites de movimiento por mapa.
- Cambio entre escenarios.
- Diseño de mapas utilizando tiles.
- Organización del código en funciones. 

## Integrantes

- Juan Aparicio Quian 