#!/usr/bin/env bash
# Lo propio del examen, encima de prueba_comandos/lib/comun.sh. No se ejecuta directamente.
# Diferencias con la prueba: carpeta ~/examen_nivelN, `comprobar` no dice nada (sólo avisa), y
# `entregar` corrige en silencio y manda la nota al servidor del examen. El alumno no ve la nota.

dir_nivel() { echo "$HOME/examen_nivel$1"; }
# Si el examen trae su propio nivel (niveles/nivelN.sh) se usa ese; si no, el de la prueba de práctica.
cargar_nivel() { # shellcheck disable=SC1090
  if [ -f "$PRUEBA_RAIZ/niveles/nivel$1.sh" ]; then source "$PRUEBA_RAIZ/niveles/nivel$1.sh"
  else source "$NIVELES_DIR/nivel$1.sh"; fi; }
if [ "$(command -v examen 2>/dev/null)" ] && grep -qs "$PRUEBA_RAIZ/examen.sh" "$(command -v examen)"; then PRUEBA_CMD="examen"; else PRUEBA_CMD="bash examen.sh"; fi
EXAMEN=""
ORDENES_EXAMEN='mision|comprobar|entregar|reiniciar|salir|exit|clear|history|estado'

marca_entregado() { echo "$DATOS_ALUMNO/.examen_entregado_$1"; }   # fuera de la carpeta: sobrevive a reiniciar
ya_entregado() {
  local f; f="$(marca_entregado "$1")"
  [ -f "$f" ] || return 1
  aviso "Ya entregaste el examen del nivel $1 ($(cat "$f")). Si es un error, habla con el profesor."
  return 0
}

mision_examen() {
  "nivel${1}_mision" | sed \
    -e 's#~/prueba_nivel#~/examen_nivel#g' \
    -e 's/carpeta de la prueba/carpeta del examen/g' \
    -e 's/^# NIVEL/# EXAMEN · NIVEL/' \
    -e '/^Cuando creas que has terminado, ejecuta `comprobar`/c\
ESTO ES UN EXAMEN: no hay `comprobar`. Comprueba tú cada paso (ls, cat, tree…) y, al acabar, `entregar`.' \
    -e '/^Puntuación:/c\
Nota: 10 × pasos bien hechos / pasos totales. Sólo puedes entregar UNA vez.'
}

preparar_examen() {
  local n="$1" d; d="$(dir_nivel "$n")"
  titulo "Preparando el examen del nivel $n"
  # Deja el sistema limpio (usuarios, servicios, /etc/hosts…): si quedan restos de la prueba de práctica,
  # algunos pasos saldrían hechos sin hacer nada.
  "nivel${n}_limpiar" "$d" >/dev/null
  mkdir -p "$(dir_estado "$n")"
  "nivel${n}_preparar" "$d" || { error "No se ha podido preparar el examen del nivel $n."; return 1; }
  mision_examen "$n" > "$d/MISION.md"
  date +%s > "$(dir_estado "$n")/inicio"
  : > "$(dir_estado "$n")/historial"
  : > "$(dir_estado "$n")/marcas"
  ok "Listo. Carpeta de trabajo: $d"
}

reiniciar_examen() {
  local n="$1" r
  r="$(cat "$(dir_estado "$n")/reinicios" 2>/dev/null || echo 0)"
  limpiar_nivel "$n" && preparar_examen "$n" && echo $((r + 1)) > "$(dir_estado "$n")/reinicios"
}

entrar_examen() {
  local n="$1"
  titulo "EXAMEN · Nivel $n · El reloj está en marcha"
  echo "Órdenes especiales:  ${C_CIAN}mision${C_FIN} (enunciado) · ${C_CIAN}entregar${C_FIN} · ${C_CIAN}reiniciar${C_FIN} · ${C_CIAN}salir${C_FIN}"
  echo "${C_AMAR}En el examen no hay comprobar: tú eres responsable de revisar que todo está bien.${C_FIN}"
  echo "El enunciado también está en MISION.md"
  echo
  PRUEBA_NIVEL="$n" PRUEBA_DIR="$(dir_nivel "$n")" EXAMEN_SH="$PRUEBA_RAIZ/examen.sh" \
    bash --rcfile "$PRUEBA_RAIZ/lib/rc.sh" -i
  ya_entregado "$n" >/dev/null || { echo; echo "Has salido del examen del nivel $n SIN ENTREGAR. Vuelve con:  $PRUEBA_CMD continuar $n"; }
}

# ---------- corrección silenciosa ----------
# Sustituye a paso() de comun.sh: apunta el resultado de cada paso sin enseñarlo.
PASOS_JSON=""
paso() {
  local desc="$1" r=false; shift
  PASOS_TOTAL=$((PASOS_TOTAL+1))
  if "$@" >/dev/null 2>&1; then PASOS_OK=$((PASOS_OK+1)); r=true; fi
  PASOS_JSON="${PASOS_JSON}{\"paso\":\"$(printf '%s' "$desc" | json_escapar)\",\"ok\":$r},"
}

entregar_examen() {
  local n="$1" d e t ncmd nota fecha json fich resp comandos usos reinicios hora codigo
  d="$(dir_nivel "$n")"; e="$(dir_estado "$n")"
  export PRUEBA_NIVEL_ACTUAL="$n"
  ya_entregado "$n" && return 0
  [ -d "$d" ] || { error "No hay un examen del nivel $n preparado."; return 1; }
  echo
  echo "${C_AMAR}Vas a ENTREGAR el examen del nivel $n. Sólo se puede entregar UNA vez:${C_FIN}"
  echo "después no podrás cambiar nada. ¿Has comprobado tú todos los pasos?"
  read -r -p "Escribe ENTREGAR para confirmar: " c
  [ "$c" = "ENTREGAR" ] || { echo "No se ha entregado. Sigue trabajando."; return 1; }

  cargar_config
  [ -n "$NOMBRE_ALUMNO" ] || pedir_nombre
  PASOS_OK=0; PASOS_TOTAL=0; PASOS_JSON=""
  "nivel${n}_comprobar" "$d" >/dev/null      # sudo puede pedir la contraseña (va a la terminal, no a stdout)
  read -r t _ < <(tiempo_prueba "$n")
  ncmd="$(grep -vE "^\s*\$|^\s*($ORDENES_EXAMEN)\s*\$" "$e/historial" | wc -l | tr -d ' ')"
  usos="$(grep -cE '^\s*comprobar\s*$' "$e/historial")"
  reinicios="$(cat "$e/reinicios" 2>/dev/null || echo 0)"
  nota="$(awk -v a="$PASOS_OK" -v b="$PASOS_TOTAL" 'BEGIN{ printf "%.1f", (b ? 10*a/b : 0) }')"
  fecha="$(date -Iseconds)"
  comandos="$(grep -vE "^\s*\$|^\s*($ORDENES_EXAMEN)\s*\$" "$e/historial" \
              | while IFS= read -r l; do printf '"%s",' "$(printf '%s' "$l" | json_escapar)"; done)"
  json=$(printf '{"examen":"%s","nombre":"%s","nivel":%s,"nota":%s,"pasos_ok":%s,"pasos_total":%s,"pasos":[%s],"tiempo_s":%s,"num_comandos":%s,"usos_comprobar":%s,"reinicios":%s,"fecha":"%s","usuario":"%s","equipo":"%s","comandos":[%s]}' \
         "$(printf '%s' "$EXAMEN" | json_escapar)" "$(printf '%s' "$NOMBRE_ALUMNO" | json_escapar)" "$n" "$nota" \
         "$PASOS_OK" "$PASOS_TOTAL" "${PASOS_JSON%,}" "$t" "$ncmd" "$usos" "$reinicios" "$fecha" \
         "$(id -un | json_escapar)" "$(hostname 2>/dev/null | json_escapar)" "${comandos%,}")

  # Copia local por si falla el servidor (codificada: no es para leerla, es para entregarla en Moodle)
  mkdir -p "$RESULTADOS" 2>/dev/null
  fich="$RESULTADOS/examen_nivel${n}_$(date +%Y%m%d_%H%M%S).txt"
  printf '%s' "$json" | base64 -w0 > "$fich" 2>/dev/null

  if [ "$ENVIAR" != "si" ] || [ -z "$SERVIDOR_URL" ]; then
    aviso "Envío desactivado o sin SERVIDOR_URL en config.env. Entrega en Moodle el fichero $fich"; return 1
  fi
  command -v curl >/dev/null || { aviso "No tienes curl. Entrega en Moodle el fichero $fich"; return 1; }
  resp="$(curl -sS -m 15 -w '\n%{http_code}' -X POST "$SERVIDOR_URL/api/entregas" \
          -H 'Content-Type: application/json' -H "X-Clave: $CLAVE" --data-binary "$json" 2>&1)"
  codigo="$(printf '%s' "$resp" | tail -n1)"; resp="$(printf '%s' "$resp" | sed '$d')"
  if [ "$codigo" = "201" ] && printf '%s' "$resp" | grep -q '"ok":true'; then
    hora="$(date '+%d/%m/%Y %H:%M')"
    echo "entregado el $hora" > "$(marca_entregado "$n")"
    echo
    ok "${C_VERDE}Examen del nivel $n ENTREGADO el $hora.${C_FIN}"
    echo "  La nota la verá tu profesor. Ya puedes cerrar el terminal."
    return 0
  elif [ "$codigo" = "409" ]; then
    echo "entregado antes (el servidor ya lo tenía)" > "$(marca_entregado "$n")"
    aviso "El servidor dice que ya habías entregado este examen. Si es un error, habla con el profesor."
    return 0
  else
    aviso "El servidor no ha aceptado la entrega ($SERVIDOR_URL): ${resp:-sin respuesta}"
    echo "  Vuelve a escribir ${C_CIAN}entregar${C_FIN} en un momento. Si sigue fallando, entrega en Moodle: $fich"
    return 1
  fi
}

estado_examen() {
  local n d
  cargar_config
  titulo "Estado del examen · ${NOMBRE_ALUMNO:-(sin nombre)}"
  for n in 1 2 3; do
    d="$(dir_nivel "$n")"
    if [ -f "$(marca_entregado "$n")" ]; then echo "  Nivel $n: ${C_VERDE}$(cat "$(marca_entregado "$n")")${C_FIN}"
    elif [ -d "$d" ]; then read -r t _ < <(tiempo_prueba "$n"); echo "  Nivel $n: ${C_AMAR}en curso, sin entregar${C_FIN} ($(formato_tiempo "$t"))"
    else echo "  Nivel $n: ${C_GRIS}sin empezar${C_FIN}"
    fi
  done
}

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
