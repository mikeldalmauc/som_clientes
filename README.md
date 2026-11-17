# Sistemas Operativos Monopuesto · aplicaciones del alumno

Lo que se ejecuta en la máquina de cada alumno (Linux Mint, Arch o un contenedor). El servidor
del ranking, su instalación y su despliegue viven en el repo del servidor
(`server_isard_som`, privado).

| Carpeta | Qué es | Empezar por |
|---|---|---|
| `prueba_comandos/` | Pruebas de comandos cronometradas (speedrun del terminal) que envían la marca al ranking de la clase | `prueba_comandos/LEEME.md` |
| `examen_comandos/` | Examen de comandos. De momento sólo comprueba que el equipo llega al servidor de resultados (`examen conexion`); el examen se publica el día de la prueba | `examen_comandos/LEEME.md` |
| `juego comandos/` | La Mazmorra de los Comandos: juego de terminal para aprender Linux, con certificado verificable | `juego comandos/LEEME.md` |

Relación con el servidor: `prueba_comandos/config.env` lleva `SERVIDOR_URL` (la dirección del
ranking) y `CLAVE`, que debe coincidir con la `CLAVE` del `ranking/.env` del servidor. Lo mismo
`examen_comandos/config.env` con `apps/examen-comandos/.env`.

Los scripts se ejecutan en Linux: `.gitattributes` fuerza finales de línea LF aunque se editen en
Windows. Las notas del profesor (`prueba_comandos/docs/`) y los datos de cada alumno están en
`.gitignore` y no se suben.
