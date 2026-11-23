#!/usr/bin/env bash
# =============================================================================
#  Examen de comandos · Sistemas Operativos Monopuesto (SMR 1.º)
#  Como prueba_comandos, pero SIN comprobar: nadie te dice si vas bien. Se entrega una vez.
#  Uso:  examen ORDEN [NIVEL]      (o: bash examen.sh ORDEN [NIVEL])
#  Para tener la orden `examen` en cualquier carpeta, una vez:  bash instalar.sh
#
#    iniciar   N   prepara el examen del nivel N y abre su terminal
#    continuar N   vuelve a entrar en un examen empezado (el reloj sigue)
#    estado        muestra en qué punto está cada nivel
#    conexion      comprueba que llegas al servidor de resultados (no entrega nada)
#    mision    N   imprime el enunciado del nivel N
#    borrar    N   elimina todo lo del examen del nivel N (sólo si te lo pide el profesor)
#    ayuda         esta ayuda
#
#  Dentro del terminal del examen tienes:  mision · entregar · conexion · reiniciar · salir
# =============================================================================
set -u

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PRUEBA_RAIZ="$AQUI"
NIVELES_DIR="$(cd "$AQUI/../prueba_comandos/lib" 2>/dev/null && pwd)" \
  || { echo "ERROR: no encuentro ../prueba_comandos/lib (el examen usa los niveles de la prueba)." >&2; exit 1; }
export NIVELES_DIR
# Las funciones comunes de la prueba (colores, nombre, tiempo, predicados…) y, encima, lo propio del examen
# shellcheck source=../prueba_comandos/lib/comun.sh
source "$NIVELES_DIR/comun.sh"
# shellcheck source=lib/examen.sh
source "$AQUI/lib/examen.sh"

orden="${1:-ayuda}"
nivel="${2:-}"

case "$orden" in
  iniciar)    requiere_nivel "$nivel"; cargar_nivel "$nivel"
              ya_entregado "$nivel" && exit 1
              if [ -d "$(dir_nivel "$nivel")" ]; then
                aviso "Ya has empezado el examen del nivel $nivel. Para seguir:  $PRUEBA_CMD continuar $nivel"
                exit 1
              fi
              pedir_nombre
              preparar_examen "$nivel" && entrar_examen "$nivel" ;;
  continuar)  requiere_nivel "$nivel"; cargar_nivel "$nivel"
              ya_entregado "$nivel" && exit 1
              [ -d "$(dir_nivel "$nivel")" ] || { error "No has empezado el examen del nivel $nivel. Usa: $PRUEBA_CMD iniciar $nivel"; exit 1; }
              entrar_examen "$nivel" ;;
  borrar)     requiere_nivel "$nivel"; cargar_nivel "$nivel"
              read -r -p "Vas a BORRAR el examen del nivel $nivel. Escribe BORRAR para confirmar: " c
              [ "$c" = "BORRAR" ] || { echo "Cancelado."; exit 0; }
              limpiar_nivel "$nivel"; rm -f "$DATOS_ALUMNO/.examen_entregado_$nivel"; ok "Examen del nivel $nivel eliminado." ;;
  estado)     estado_examen ;;
  conexion)   probar_conexion ;;
  mision)     requiere_nivel "$nivel"; cargar_nivel "$nivel"; mision_examen "$nivel" ;;
  # --- órdenes internas (las llama el terminal del examen) ---
  _entregar)  requiere_nivel "$nivel"; cargar_nivel "$nivel"; entregar_examen "$nivel" ;;
  _reiniciar) requiere_nivel "$nivel"; cargar_nivel "$nivel"; reiniciar_examen "$nivel" ;;
  ayuda|-h|--help|*) sed -n '2,18p' "$0" | sed 's/^# \{0,2\}//' ;;
esac
