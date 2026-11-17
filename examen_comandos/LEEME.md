# Examen de comandos

El examen se publica en esta carpeta **el día de la prueba**. Hasta entonces sirve para una sola
cosa: comprobar que tu equipo llega al **servidor de resultados**, que es donde se entregará.

Hazlo antes del examen: si tu equipo no llega al servidor, mejor saberlo hoy que ese día.

## Comprueba la conexión

En tu máquina virtual, con la carpeta `som_clientes` que ya tienes de las pruebas de comandos:

```bash
cd ~/som_clientes
git pull                              # trae esta carpeta
bash examen_comandos/examen.sh conexion
```

Si no tienes `som_clientes`, descárgalo primero (sin `sudo`):

```bash
cd ~
git clone https://github.com/mikeldalmauc/som_clientes
```

Tiene que salir esto:

```text
✔ El servidor responde.
✔ La clave es correcta: las entregas llegarán.
```

La comprobación no entrega ni guarda nada: repítela las veces que quieras.

## Deja instalada la orden `examen` (opcional)

Así el día de la prueba no pierdes tiempo:

```bash
cd ~/som_clientes/examen_comandos
bash instalar.sh               # sin sudo
```

Abre un terminal nuevo y ya puedes escribir `examen conexion` desde cualquier carpeta.

## Si algo falla

| Mensaje | Qué hacer |
|---|---|
| `No hay respuesta` | Tu equipo no llega al servidor. Comprueba que la máquina virtual está en la red del aula y prueba el `ping` que te indica el mensaje. Si no contesta, avisa al profesor |
| `No tienes curl` | Instálalo y repite: `sudo apt install curl` (Mint) o `sudo pacman -S curl` (Arch) |
| `El servidor responde, pero no es el del examen` | Avisa al profesor y dile el código que sale entre paréntesis |
| `El servidor no acepta la CLAVE` | Avisa al profesor |
| `examen: orden no encontrada` tras `bash instalar.sh` | Abre un terminal nuevo (o `source ~/.bashrc`) |
| `git pull` da `Permiso denegado` | Clonaste con `sudo` y la carpeta es de root: `sudo chown -R $USER:$USER ~/som_clientes` |

## El día del examen

```bash
cd ~/som_clientes
git pull                       # trae el examen
```

Y sigue las instrucciones que encontrarás aquí mismo.

## Para el profesor

- La dirección del servidor y la clave están en `config.env` (`SERVIDOR_URL`, `CLAVE`). La clave
  debe coincidir con `CLAVE` de `apps/examen-comandos/.env` en el repo del servidor.
- `conexion` pregunta al servidor por `/api/salud` y `/api/clave`: no crea ninguna entrega.
- El examen completo está en el repo del servidor (`examen_cliente/`); su `LEEME.md` dice cómo
  subirlo aquí el día de la prueba.
