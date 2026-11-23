# Fichero de arranque del terminal del examen (bash --rcfile lib/rc.sh).
# Igual que el de la prueba (registra cada comando), pero `comprobar` sólo avisa y aparece `entregar`.

[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

export HISTFILE="$PRUEBA_DIR/.prueba/historial"
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=
unset HISTIGNORE HISTTIMEFORMAT
shopt -s histappend
_examen_guardar() {
  if [ -d "$PRUEBA_DIR/.prueba" ]; then
    history -a
    printf '%(%s)T\n' -1 >> "$PRUEBA_DIR/.prueba/marcas"
  elif [ -z "${_EXAMEN_AVISADO:-}" ]; then
    _EXAMEN_AVISADO=1
    echo "La carpeta del examen ($PRUEBA_DIR) ya no existe. Avisa al profesor."
  fi
}
PROMPT_COMMAND=_examen_guardar

PS1="\[\e[1;41;97m\] EXAMEN N${PRUEBA_NIVEL} \[\e[0m\] \[\e[1;34m\]\w\[\e[0m\] \$ "

mision()    { bash "$EXAMEN_SH" mision "$PRUEBA_NIVEL"; }
comprobar() {
  echo
  printf '\e[1;33m%s\e[0m\n' "⚠  ESTO ES UN EXAMEN: aquí comprobar no funciona."
  echo "   Nadie te va a decir qué está bien y qué no. TÚ eres responsable de comprobar por tu"
  echo "   cuenta que cada paso está hecho: mira con ls, cat, tree, head, grep… lo que has creado."
  echo "   Cuando lo tengas todo revisado, escribe:  entregar"
  echo
}
entregar()  { history -a; bash "$EXAMEN_SH" _entregar "$PRUEBA_NIVEL" && exit 0; }
reiniciar() {
  echo "Reiniciar BORRA todo tu trabajo del examen y lo prepara de nuevo (el reloj NO vuelve a cero)."
  read -r -p "Escribe REINICIAR para confirmar: " c
  [ "$c" = "REINICIAR" ] || { echo "Cancelado."; return; }
  # el reloj sigue: se guardan el inicio y las marcas de tiempo y se reponen después de preparar
  local ini marcas; ini="$(cat "$PRUEBA_DIR/.prueba/inicio" 2>/dev/null)"; marcas="$(cat "$PRUEBA_DIR/.prueba/marcas" 2>/dev/null)"
  cd "$HOME" || return
  bash "$EXAMEN_SH" _reiniciar "$PRUEBA_NIVEL" && {
    [ -n "$ini" ] && echo "$ini" > "$PRUEBA_DIR/.prueba/inicio"
    [ -n "$marcas" ] && printf '%s\n' "$marcas" > "$PRUEBA_DIR/.prueba/marcas"
    history -c; cd "$PRUEBA_DIR" || return; echo "Examen preparado de nuevo."; }
}
conexion()  { bash "$EXAMEN_SH" conexion; }
salir()     { exit; }

cd "$PRUEBA_DIR" || return
