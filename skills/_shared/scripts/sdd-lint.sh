#!/usr/bin/env bash
# sdd-lint.sh — comprobaciones deterministas del formato de specs, índice y planes.
# Uso: bash sdd-lint.sh [raíz-del-proyecto]      (por defecto: directorio actual)
# Salida: una línea por hallazgo:  ERROR|AVISO  archivo[:línea]  mensaje
# Código de salida: 1 si hay algún ERROR, 0 si no. Los AVISO no bloquean.
# Mide solo lo que `plantilla-spec.md`, `convenciones.md` y `verificacion-division.md` piden y se puede
# comprobar sin criterio humano. Lo que requiere juicio (¿este invariante es correcto?) no se mide aquí.

ROOT="${1:-.}"
SPECS="$ROOT/docs/specs"

chequear() {
  if [ ! -d "$SPECS" ]; then
    echo "AVISO  docs/specs  no existe (Caso 1 o Caso 5: todavía no hay specs que medir)"
    return
  fi

  # ---------- Índice ----------
  local indice="$SPECS/README.md" f b rel
  if [ ! -f "$indice" ]; then
    echo "ERROR  docs/specs/README.md  falta el índice Capacidad → Spec → Spec padre"
  else
    for f in "$SPECS"/spec-*.md; do
      [ -e "$f" ] || continue
      b=$(basename "$f")
      grep -q "$b" "$indice" || echo "ERROR  docs/specs/README.md  el spec $b no figura en el índice"
    done
    for ref in $(grep -o 'spec-[A-Za-z0-9_-]*\.md' "$indice" | sort -u); do
      [ -f "$SPECS/$ref" ] || echo "ERROR  docs/specs/README.md  el índice nombra $ref pero el archivo no existe"
    done
    # Paquetes de diseño por historia: cada HU con paquete debe figurar en el índice (columna Historias)
    if [ -d "$ROOT/docs/design" ]; then
      local d hu
      for d in "$ROOT"/docs/design/HU-*/; do
        [ -d "$d" ] || continue
        hu=$(basename "$d")
        grep -q "$hu" "$indice" || echo "AVISO  docs/specs/README.md  la $hu tiene paquete de diseño pero no figura en la columna Historias del índice"
      done
    fi
  fi

  # ---------- Cada spec ----------
  for f in "$SPECS"/spec-*.md; do
    [ -e "$f" ] || continue
    b=$(basename "$f"); rel="docs/specs/$b"
    local lineas est real esperado subcaps
    lineas=$(wc -l < "$f" | tr -d ' ')

    est=$(grep -m1 -n '^\*\*Estado:\*\*' "$f")
    if [ -z "$est" ]; then
      echo "ERROR  $rel  falta la línea '**Estado:** ... · **Última revisión:** AAAA-MM-DD'"
    elif ! echo "$est" | grep -Eq '\*\*Estado:\*\* (desplegado|parcial|en desarrollo) · \*\*Última revisión:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}'; then
      echo "ERROR  $rel:${est%%:*}  la línea de Estado no cumple el formato (valores: desplegado | parcial | en desarrollo; separador '·'; fecha AAAA-MM-DD)"
    fi

    esperado="Propósito Comportamiento Invariantes Decisiones Fuera de alcance Referencias"
    real=$(grep -E '^## ' "$f" | sed 's/^## //; s/ (no negociables)//' | tr '\n' ' ' | sed 's/ $//')
    for sec in "Propósito" "Comportamiento" "Invariantes" "Decisiones" "Fuera de alcance" "Referencias"; do
      echo "$real" | grep -q "$sec" || echo "ERROR  $rel  falta la sección '## $sec'"
    done
    [ "$real" = "$esperado" ] || echo "AVISO  $rel  los encabezados de primer nivel difieren de la plantilla (orden o nombres): '$real'"

    # Invariantes: cada ítem lleva su porqué (un ítem puede ocupar varias líneas)
    awk -v rel="$rel" '
      function cierra() { if (item != "" && item !~ /Porqué/) print "ERROR  " rel ":" ln "  invariante sin \"Porqué\": " substr(item, 1, 70); item = "" }
      /^## Invariantes/ { en = 1; next }
      /^## /            { cierra(); en = 0 }
      en && /^- /       { cierra(); item = $0; ln = NR; next }
      en && /^[ ]+[^ ]/ && item != "" { item = item " " $0; next }
      END               { cierra() }
    ' "$f"

    # Decisiones: cada ítem lleva fecha
    awk -v rel="$rel" '
      /^## Decisiones/ { en = 1; next }
      /^## /           { en = 0 }
      en && /^- / && $0 !~ /^- [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]:/ { print "ERROR  " rel ":" NR "  decisión sin fecha AAAA-MM-DD: " substr($0, 1, 70) }
    ' "$f"

    # Estados transitorios (no van en un spec)
    grep -n -i -E 'pendiente de deploy|a medias|todav(i|í)a (sin|no)|hoy el c(o|ó)digo no|arreglo pendiente' "$f" | while IFS= read -r t; do
      echo "AVISO  $rel:${t%%:*}  posible estado transitorio (va en el plan o en el mensaje del commit): $(echo "${t#*:}" | cut -c1-90)"
    done

    # Referencias al paquete de diseño: las rutas docs/design/... citadas deben existir
    grep -oE 'docs/design/[A-Za-z0-9_./-]+' "$f" | sed 's/[.,;]*$//' | sort -u | while IFS= read -r d; do
      [ -e "$ROOT/$d" ] || echo "ERROR  $rel  referencia $d pero la ruta no existe"
    done

    # Disparadores de división (verificacion-division.md)
    if [ "$lineas" -ge 500 ]; then
      echo "AVISO  $rel  $lineas líneas (≥500): tamaño excedido, evaluar la división con prioridad"
    elif [ "$lineas" -ge 400 ]; then
      echo "AVISO  $rel  $lineas líneas (≥400): evaluar los cinco criterios de verificacion-division.md"
    fi
    subcaps=$(awk '/^## Comportamiento/ {en=1; next} /^## / {en=0} en && /^### / {n++} END {print n+0}' "$f")
    [ "$subcaps" -gt 6 ] && echo "AVISO  $rel  $subcaps subcapacidades en Comportamiento (>6): disparador de división"
  done

  # ---------- Planes ----------
  local p
  for p in "$ROOT"/docs/plan-*.md; do
    [ -e "$p" ] || continue
    b=$(basename "$p")
    echo "$b" | grep -Eq '^plan-[a-z0-9-]+-[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' \
      || echo "ERROR  docs/$b  el nombre debe ser plan-<tema-en-kebab>-AAAA-MM-DD.md"
    for sec in "Contexto" "Delta" "Delta del spec escrito" "Tareas" "Criterios de aceptación" "Pendientes de decisión"; do
      grep -q "^## $sec" "$p" || echo "ERROR  docs/$b  falta la sección '## $sec'"
    done
    grep -Eq '^\*\*Estado:\*\* (en desarrollo|destilado)' "$p" || echo "ERROR  docs/$b  falta '**Estado:** en desarrollo | destilado'"
    grep -q 'CA-[0-9][0-9]' "$p" || echo "AVISO  docs/$b  los criterios de aceptación no llevan identificador CA-NN (trazabilidad criterio → prueba)"
  done
}

salida=$(chequear)
[ -n "$salida" ] && echo "$salida"
n=$(echo "$salida" | grep -c '^ERROR')
if [ "$n" -gt 0 ]; then echo "--- $n error(es)"; exit 1; fi
echo "--- sin errores"
exit 0
