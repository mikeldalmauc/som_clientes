# Examen de comandos

Funciona como la prueba que ya conoces (`prueba_comandos`): un terminal con reloj, una lista de
pasos y tu trabajo en carpetas de verdad. Pero **es un examen**, y cambian tres cosas:

1. **No hay `comprobar`.** Nadie te dice qué está bien y qué no. Si escribes `comprobar`, sólo
   verás un aviso. **Tú eres responsable de comprobar por tu cuenta** que cada paso está hecho:
   mira con `ls`, `cat`, `tree`, `head`, `grep`… lo que has creado.
2. **Se entrega una sola vez.** Cuando lo tengas todo revisado, escribe `entregar`. Después no
   puedes cambiar nada.
3. **La nota no la ves tú.** Se calcula al entregar (10 × pasos bien hechos / pasos totales) y
   la ve el profesor.

El examen del 1.er trimestre (`examen iniciar 1`) tiene 18 pasos de todo lo dado en Linux:
carpetas, escribir y leer ficheros, copiar, mover y borrar con comodines, explorar el sistema,
`nano`, `sudo` y procesos. Cada alumno tiene sus propios datos. Dura **1 h 30 min** y puedes usar
internet y tus apuntes.

## Antes de empezar

En tu máquina virtual, dentro de la carpeta `som_clientes` que ya tienes:

```bash
cd ~/som_clientes
git pull                       # trae el examen
cd examen_comandos
bash instalar.sh               # instala la orden `examen` (sin sudo)
```

Abre un terminal nuevo y comprueba que llegas al servidor de resultados:

```bash
examen conexion       # debe decir «El servidor responde» y «La clave es correcta»
```

Tu nombre se pide la primera vez y queda en `config.local.env`.
**Escríbelo bien, con nombre y apellido**: es lo que verá el profesor.

## Cómo se hace

```bash
examen iniciar 1      # prepara ~/examen_nivel1 y abre el terminal del examen
```

El terminal del examen tiene el aviso rojo `EXAMEN N1`. Dentro tienes:

| Orden | Qué hace |
|---|---|
| `mision` | Muestra el enunciado (también está en `MISION.md`) |
| `entregar` | Entrega el examen. Pide escribir `ENTREGAR` para confirmar. Sólo una vez |
| `reiniciar` | Borra tu trabajo y prepara el examen de nuevo. El reloj **no** vuelve a cero |
| `conexion` | Comprueba que llegas al servidor de resultados. No entrega nada |
| `salir` | Sale sin entregar. Vuelves con `examen continuar 1` |

Fuera del terminal del examen: `examen estado` te dice si has entregado.

## Si algo falla

- **`El servidor no ha aceptado la entrega`**: escribe `conexion` para ver qué falla, espera un momento y vuelve a escribir `entregar`.
  Si sigue fallando, avisa al profesor: te dirá que subas a Moodle el fichero que indica el
  mensaje (está en `examen_comandos/resultados/`).
- **`Ya entregaste…`**: sólo se puede entregar una vez. Si te has equivocado, habla con el
  profesor.
- **Nunca uses `sudo` para lanzar el examen.** El examen te pide la contraseña él solo cuando un
  paso la necesita.

## Para el profesor

- La dirección del servidor y la clave están en `config.env` (`SERVIDOR_URL`, `CLAVE`) y el
  nombre del examen en `EXAMEN`. Cambia `EXAMEN` para cada convocatoria.
- Las notas, con el detalle de cada paso y los comandos de cada alumno, se ven en
  `http://IP-DEL-SERVIDOR/examen-comandos/` con la clave de profesor (repo del servidor,
  `apps/examen-comandos/`).
- Para permitir que un alumno entregue otra vez: borra su entrega en la web y, en su equipo,
  `examen borrar N`.
- El nivel 1 del examen está en `niveles/nivel1.sh` (propio del examen). Si un nivel no está en
  `niveles/`, se usa el de la práctica (`../prueba_comandos/lib/nivelN.sh`).
