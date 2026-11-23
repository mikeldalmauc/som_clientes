#!/usr/bin/env bash
# EXAMEN · 1.er trimestre · Linux: comandos y ficheros, explorar el sistema, procesos, nano y sudo.
# Distinto de la prueba de práctica. Cada alumno tiene sus propios datos (fecha, nombres, números),
# guardados en .prueba/valores, para que no sirva copiar del de al lado.

_e1_valores() { local f; f="$(dir_estado 1)/valores"; [ -f "$f" ] && source "$f"; }

nivel1_preparar() {
  local d="$1" e="$1/.prueba" i n
  mkdir -p "$e/bin" "$d/entrada/plantillas/logos" "$d/entrada/vacia" "$d/basura/viejo"

  # --- valores de este alumno ---
  local DIA=$(( RANDOM % 28 + 1 )) MES=$(( RANDOM % 12 + 1 ))
  local FECHA; FECHA="$(printf '%02d/%02d/2026' "$DIA" "$MES")"
  local LINEAS=$(( RANDOM % 140 + 120 ))
  local WIFI; WIFI="$(printf '%03d' $(( RANDOM % 900 + 100 )))"
  local SUENO=$(( RANDOM % 9000 + 21000 ))
  local CONSUMIDOR; CONSUMIDOR="consumidor_$(( RANDOM % 900 + 100 ))"
  printf 'FECHA=%q\nLINEAS=%q\nWIFI=%q\nSUENO=%q\nCONSUMIDOR=%q\n' "$FECHA" "$LINEAS" "$WIFI" "$SUENO" "$CONSUMIDOR" > "$e/valores"

  # --- ficheros de partida ---
  local servicios=(red disco cups ssh cron usb sonido)
  for i in $(seq 1 "$LINEAS"); do
    printf '2026-11-%02d %02d:%02d %s: evento %d\n' $(( i % 28 + 1 )) $(( i % 24 )) $(( i * 7 % 60 )) "${servicios[$(( i % 7 ))]}" "$i"
  done > "$d/entrada/registro.log"
  for i in 1 2 3; do printf 'JPEG-%s\n' "$i" > "$d/entrada/foto$i.jpg"; done
  printf 'PNG\n' > "$d/entrada/plano.png"
  for i in $(seq 1 12); do printf 'factura %s\n' "$i" > "$d/entrada/factura$i.pdf"; done
  printf 'WIFI-%s-%s\n' "$WIFI" "$RANDOM" > "$d/entrada/.clave_wifi_$WIFI"
  printf 'Estimado cliente:\n' > "$d/entrada/plantillas/carta.txt"
  printf 'FACTURA N.º\n'       > "$d/entrada/plantillas/factura.txt"
  printf 'logo azul\n'         > "$d/entrada/plantillas/logos/logo1.txt"
  printf 'logo rojo\n'         > "$d/entrada/plantillas/logos/logo2.txt"
  printf '[oficina]\nnombre=zornotza\nmodo=lento\nidioma=es\n' > "$d/entrada/config.ini"
  for i in a b; do echo "basura" > "$d/basura/$i.tmp"; done
  echo "vieja" > "$d/basura/viejo/c.tmp"

  # --- un proceso que hay que terminar: una copia de sleep con otro nombre ---
  cp "$(command -v sleep)" "$e/bin/$CONSUMIDOR"
  nohup setsid "$e/bin/$CONSUMIDOR" 50000 >/dev/null 2>&1 &
  return 0
}

nivel1_limpiar() {
  local d="$1" e="$1/.prueba"
  if [ -f "$e/valores" ]; then
    ( source "$e/valores"
      pkill -x "$CONSUMIDOR" 2>/dev/null
      pkill -f "^sleep $SUENO\$" 2>/dev/null )
  fi
  if grep -q 'oficina\.local' /etc/hosts 2>/dev/null; then
    echo "Retirando la línea oficina.local de /etc/hosts (pide sudo)…"
    sudo sed -i '/oficina\.local/d' /etc/hosts
  fi
  return 0
}

nivel1_mision() {
  local FECHA="??" LINEAS="" WIFI="" SUENO="?????" CONSUMIDOR="consumidor_???"
  _e1_valores
cat <<EOF2
# EXAMEN · 1.er trimestre · Linux

Trabaja SIEMPRE dentro de la carpeta del examen (~/examen_nivel1). Al empezar tienes:
  entrada/   basura/        (mira también lo que está OCULTO)
Las rutas que aparecen abajo son relativas a ~/examen_nivel1. Cuando un paso dice «SOLO el dato»,
el fichero tiene que tener eso y nada más. No cierres la ventana del terminal hasta entregar.

## A · Carpetas
 1. Con UN SOLO comando, crea dentro de  oficina/  las carpetas de los tres departamentos
    (direccion, ventas, tecnicos) y, dentro de CADA UNO, las carpetas  documentos  y  archivo .
 2. Con UN SOLO comando, crea los ficheros vacíos  clientes1.txt … clientes5.txt
    dentro de  oficina/ventas/documentos/ .

## B · Escribir y leer ficheros
 3. Sin abrir ningún editor, crea  oficina/direccion/documentos/acta.txt  con estas tres líneas:
        Reunión de dirección
        Fecha: $FECHA
        Asistentes: 3
 4. ¿Cuántas líneas tiene  entrada/registro.log ? Guarda SOLO el número en
    oficina/tecnicos/documentos/lineas.txt .
 5. Guarda las 5 ÚLTIMAS líneas de  entrada/registro.log  en  oficina/tecnicos/documentos/ultimas.txt .
 6. En  entrada/  hay un fichero OCULTO. Cópialo, con el mismo nombre, a  oficina/direccion/archivo/ .

## C · Copiar, mover, renombrar y borrar
 7. Mueve TODAS las fotos .jpg de  entrada/  a  oficina/ventas/archivo/  con un comodín.
    plano.png se queda en entrada/.
 8. COPIA a  oficina/direccion/archivo/  las facturas de UNA cifra (factura1.pdf … factura9.pdf),
    pero NO factura10, 11 ni 12. Hazlo con un comodín, en un solo comando.
 9. Copia la carpeta  entrada/plantillas , con todo lo que tiene dentro, a  oficina/tecnicos/archivo/ .
10. Cambia el nombre de  oficina/ventas/documentos/clientes5.txt  a  clientes_vip.txt .
11. Borra la carpeta  basura/  entera y la carpeta vacía  entrada/vacia  (esta, con el comando
    que SOLO borra carpetas vacías).

## D · Explorar el sistema
12. Crea  oficina/tecnicos/documentos/sistema.txt  con cuatro líneas, SOLO el dato en cada una:
        línea 1: tu nombre de usuario
        línea 2: el nombre del equipo
        línea 3: tu shell, tal y como aparece en tu línea de /etc/passwd
        línea 4: la ruta completa del programa whoami (pregúntaselo al sistema)
13. Guarda en  oficina/tecnicos/documentos/usuario.txt  SOLO la línea de  /etc/passwd  de tu usuario.
14. Ejecuta  ls /no_existe . Guarda SOLO su código de salida en  oficina/tecnicos/documentos/codigo.txt .
15. Con nano, edita  entrada/config.ini  y cambia  modo=lento  por  modo=rapido .
16. Añade al final de  /etc/hosts  la línea      127.0.0.1 oficina.local
    (necesitas sudo, y  sudo echo ... >> fichero  NO funciona).

## E · Procesos
17. Lanza en SEGUNDO PLANO el comando  sleep $SUENO  y guarda SOLO su PID en
    oficina/tecnicos/documentos/pid.txt . Déjalo funcionando: no lo termines.
18. En el sistema hay un proceso llamado  $CONSUMIDOR  que no debería estar ahí. Búscalo y termínalo.

Nota: 10 × pasos bien hechos / 18. Sólo puedes entregar UNA vez.
EOF2
}

nivel1_comprobar() {
  local d="$1" o="$1/oficina" FECHA LINEAS WIFI SUENO CONSUMIDOR u
  _e1_valores; u="$(id -un)"
  local t="$o/tecnicos/documentos"
  paso "1. oficina/{direccion,ventas,tecnicos}/{documentos,archivo}" \
       bash -c "for a in direccion ventas tecnicos; do for b in documentos archivo; do [ -d '$o/'\$a/\$b ] || exit 1; done; done"
  paso "2. clientes1…clientes5 en ventas/documentos" \
       bash -c "for i in 1 2 3 4; do [ -f '$o/ventas/documentos/clientes'\$i.txt ] || exit 1; done; [ -f '$o/ventas/documentos/clientes5.txt' ] || [ -f '$o/ventas/documentos/clientes_vip.txt' ]"
  paso "3. acta.txt con las tres líneas exactas" \
       contenido_es "$o/direccion/documentos/acta.txt" "$(printf 'Reunión de dirección\nFecha: %s\nAsistentes: 3' "$FECHA")"
  paso "4. lineas.txt con el número de líneas de registro.log ($LINEAS)" \
       contenido_limpio_es "$t/lineas.txt" "$LINEAS"
  paso "5. ultimas.txt con las 5 últimas líneas de registro.log" \
       bash -c "[ \"\$(cat '$t/ultimas.txt' 2>/dev/null)\" = \"\$(tail -n 5 '$d/entrada/registro.log')\" ]"
  paso "6. el fichero oculto .clave_wifi_$WIFI copiado a direccion/archivo" \
       bash -c "cmp -s '$d/entrada/.clave_wifi_$WIFI' '$o/direccion/archivo/.clave_wifi_$WIFI'"
  paso "7. las tres .jpg en ventas/archivo, ninguna en entrada, plano.png en entrada" \
       bash -c "for i in 1 2 3; do [ -f '$o/ventas/archivo/foto'\$i.jpg ] && [ ! -e '$d/entrada/foto'\$i.jpg ] || exit 1; done; [ -f '$d/entrada/plano.png' ] && [ ! -e '$o/ventas/archivo/plano.png' ]"
  paso "8. factura1…9 copiadas a direccion/archivo, sin la 10-12; las 12 siguen en entrada" \
       bash -c "for i in 1 2 3 4 5 6 7 8 9; do [ -f '$o/direccion/archivo/factura'\$i.pdf ] || exit 1; done; for i in 10 11 12; do [ ! -e '$o/direccion/archivo/factura'\$i.pdf ] || exit 1; done; [ \$(ls '$d/entrada/'factura*.pdf | wc -l) -eq 12 ]"
  paso "9. plantillas copiada entera a tecnicos/archivo (y sigue en entrada)" \
       bash -c "diff -r '$d/entrada/plantillas' '$o/tecnicos/archivo/plantillas'"
  paso "10. clientes5.txt renombrado a clientes_vip.txt" \
       bash -c "[ -f '$o/ventas/documentos/clientes_vip.txt' ] && [ ! -e '$o/ventas/documentos/clientes5.txt' ]"
  paso "11. basura/ y entrada/vacia borradas (vacia con rmdir)" \
       bash -c "[ ! -e '$d/basura' ] && [ ! -e '$d/entrada/vacia' ] && grep -qE '(^|[ ;&|])rmdir( |\$)' '$d/.prueba/historial'"
  paso "12. sistema.txt: usuario, equipo, shell y ruta de whoami" \
       bash -c "s='$t/sistema.txt'; [ \"\$(sed -n 1p \"\$s\" | tr -d ' \r')\" = '$u' ] && [ \"\$(sed -n 2p \"\$s\" | tr -d ' \r')\" = \"\$(hostname)\" ] && [ \"\$(sed -n 3p \"\$s\" | tr -d ' \r')\" = \"\$(grep '^$u:' /etc/passwd | cut -d: -f7)\" ] && case \"\$(sed -n 4p \"\$s\" | tr -d ' \r')\" in /usr/bin/whoami|/bin/whoami) true;; *) false;; esac"
  paso "13. usuario.txt con tu línea de /etc/passwd" \
       bash -c "[ \"\$(sed '/^\$/d' '$t/usuario.txt' 2>/dev/null)\" = \"\$(grep '^$u:' /etc/passwd)\" ]"
  paso "14. codigo.txt con el código de salida de ls /no_existe (2)" \
       contenido_limpio_es "$t/codigo.txt" "2"
  paso "15. config.ini con modo=rapido, editado con nano" \
       bash -c "grep -qx 'modo=rapido' '$d/entrada/config.ini' && ! grep -q 'modo=lento' '$d/entrada/config.ini' && grep -qE '(^|[ ;&|])nano( |\$)' '$d/.prueba/historial'"
  paso "16. /etc/hosts con 127.0.0.1 oficina.local" \
       bash -c "grep -qE '^127\.0\.0\.1[[:space:]]+oficina\.local[[:space:]]*\$' /etc/hosts"
  paso "17. sleep $SUENO funcionando y su PID en pid.txt" \
       bash -c "p=\"\$(tr -d ' \r\n' < '$t/pid.txt' 2>/dev/null)\"; [ -n \"\$p\" ] && ps -o args= -p \"\$p\" 2>/dev/null | grep -qx 'sleep $SUENO'"
  paso "18. el proceso $CONSUMIDOR terminado" \
       bash -c "! pgrep -x '$CONSUMIDOR' >/dev/null && grep -qE '(^|[ ;&|])(kill|killall|pkill)( |\$)' '$d/.prueba/historial'"
}
