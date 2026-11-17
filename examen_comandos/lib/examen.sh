#!/usr/bin/env bash
# Lo propio del examen, encima de prueba_comandos/lib/comun.sh. No se ejecuta directamente.
# De momento sólo trae la comprobación de la conexión: el resto llega con el examen, el día de la prueba.

if [ "$(command -v examen 2>/dev/null)" ] && grep -qs "$PRUEBA_RAIZ/examen.sh" "$(command -v examen)"; then PRUEBA_CMD="examen"; else PRUEBA_CMD="bash examen.sh"; fi
EXAMEN=""

# Comprueba, sin entregar nada, que el servidor de resultados responde y acepta la clave.
probar_conexion() {
  local cod host
  cargar_config
  titulo "Conexión con el servidor de resultados"
  echo "  Servidor: ${SERVIDOR_URL:-(vacío)}"
  [ -n "$SERVIDOR_URL" ] || { error "Falta SERVIDOR_URL en config.env."; return 1; }
  [ "$ENVIAR" = "si" ] || aviso "ENVIAR no es \"si\" en config.env: al entregar NO se mandará nada."
  command -v curl >/dev/null || { error "No tienes curl. Instálalo: sudo apt install curl"; return 1; }
  host="${SERVIDOR_URL#*://}"; host="${host%%[:/]*}"
  cod="$(curl -s -o /dev/null -m 8 -w '%{http_code}' "$SERVIDOR_URL/api/salud")"
  case "$cod" in
    200) ok "El servidor responde." ;;
    000) error "No hay respuesta. ¿Estás conectado a la red del aula? Prueba:  ping -c 2 $host" ; return 1 ;;
    *)   error "El servidor responde, pero no es el del examen (código $cod). Revisa SERVIDOR_URL."; return 1 ;;
  esac
  cod="$(curl -s -o /dev/null -m 8 -w '%{http_code}' -H "X-Clave: $CLAVE" "$SERVIDOR_URL/api/clave")"
  case "$cod" in
    200) ok "La clave es correcta: las entregas llegarán." ;;
    401) error "El servidor no acepta la CLAVE de config.env. Avisa al profesor."; return 1 ;;
    *)   error "No se ha podido comprobar la clave (código $cod). Avisa al profesor."; return 1 ;;
  esac
  echo "  Nombre con el que entregarás: ${NOMBRE_ALUMNO:-(se te pedirá al empezar)}"
}
