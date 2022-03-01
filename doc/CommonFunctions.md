# Common Functions

## check_os

Comprueba el puerto 445 y hace un ping a la máquina. Dependiendo del resultado, determina si detrás hay:

- un **Windows encendido** (responde el puerto 445),
- un **GNU/Linux encendido** (no responde el 445 pero sí el ping)
- **nada**, la maquina está apagada (no responde a ninguno).

Variables de entrada:

`$MAQUINA --> Donde espera encontrar el FQDN o la IP.`

Valores devueltos:

- 0       --> Apagada
- 1       --> Windows
- 2       --> GNU/Linux
- [Otro]  --> Mensaje de error

 Ejemplos de llamada:

- `RESULTADO=$(check_os 192.168.1.1)`
- `RESULTADO=$(check_os www.google.es)`

---

## is_on_windows

Comprueba si una máquina Windows está encendida o apagada.

Variables de entrada:
`$MAQUINA --> Donde espera encontrar el FQDN o la IP.`

 Valores devueltos:

- 0       --> Apagada
- 1       --> Encendida
- [Otro]  --> Mensaje de error

 Ejemplos de llamada:

- `RESULTADO=$(is_on_windows 192.168.1.1)`
- `RESULTADO=$(is_on_windows www.google.es)`

---

## is_on_linux

Comprueba si una máquina Linux está encendida o apagada.

Variables de entrada:
`$MAQUINA --> Donde espera encontrar el FQDN o la IP.`

Valores devueltos:

- 0       --> Apagada
- 1       --> Encendida
- [Otro]  --> Mensaje de error

Ejemplos de llamada:

- `RESULTADO=$(is_on_linux 192.168.1.1)`
- `RESULTADO=$(is_on_linux www.google.es)`

