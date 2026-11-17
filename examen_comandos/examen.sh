#!/usr/bin/env bash
# =============================================================================
#  Examen de comandos · Sistemas Operativos Monopuesto (SMR 1.º)
#  El examen se publica aquí el día de la prueba. Hasta entonces sólo hay una orden:
#  la que comprueba que tu equipo llega al servidor de resultados.
#  Uso:  examen ORDEN      (o: bash examen.sh ORDEN)
#  Para tener la orden `examen` en cualquier carpeta, una vez:  bash instalar.sh
#
#    conexion      comprueba que llegas al servidor de resultados (no entrega nada)
#    ayuda         esta ayuda
# =============================================================================
set -u

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PRUEBA_RAIZ="$AQUI"
NIVELES_DIR="$(cd "$AQUI/../prueba_comandos/lib" 2>/dev/null && pwd)" \
  || { echo "ERROR: no encuentro ../prueba_comandos/lib (el examen usa las funciones de la prueba)." >&2; exit 1; }
export NIVELES_DIR
# Las funciones comunes de la prueba (colores, configuración…) y, encima, lo propio del examen
# shellcheck source=../prueba_comandos/lib/comun.sh
source "$NIVELES_DIR/comun.sh"
# shellcheck source=lib/examen.sh
source "$AQUI/lib/examen.sh"

orden="${1:-ayuda}"

case "$orden" in
  conexion)   probar_conexion ;;
  # --- el resto de órdenes llega con el examen, el día de la prueba ---
  iniciar|continuar|estado|mision|borrar)
              aviso "El examen todavía no está aquí: se publica el día de la prueba."
              echo  "  Ese día lo traes con:   cd \"$(dirname "$AQUI")\" && git pull"
              echo  "  Hoy puedes comprobar que llegas al servidor:   $PRUEBA_CMD conexion"
              exit 1 ;;
  ayuda|-h|--help|*) sed -n '2,11p' "$0" | sed 's/^# \{0,2\}//' ;;
esac
