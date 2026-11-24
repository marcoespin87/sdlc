#!/usr/bin/env bash
# sdd-estado.sh — dónde está el ciclo SDD, leyendo SOLO el repositorio local (git + docs/).
# Uso: bash sdd-estado.sh [raíz-del-proyecto]
# Solo lee. No modifica nada, no usa red y no mira remotos: lo que haya en un remoto se ignora.
# La interpretación (qué fase sigue) la hace el agente con la skill sdd-estado.

SDD_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { echo "ERROR no existe $ROOT"; exit 1; }

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "GIT: no es un repositorio git. El ciclo SDD usa git como registro de estado: ejecutar 'git init' (con OK del usuario)."
  exit 0
fi

# ---- Tronco de integración (lógica compartida con sdd-git.sh) ----
. "$SDD_DIR/sdd-comun.sh"
sdd_resolver_tronco
if [ -n "$tronco" ] && ! git show-ref --verify --quiet "refs/heads/$tronco"; then
  echo "AVISO: el tronco declarado '$tronco' no existe como rama local."
fi
actual=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
echo "TRONCO: ${tronco:-(no detectado)}  [origen: ${origen_tronco:-n/a}]"
[ -n "$release" ] && [ "$release" != "$tronco" ] && echo "RAMA_DE_RELEASES: $release"
if [ "$origen_tronco" = "primera rama local conocida" ]; then
  otras=$(for c in develop main master; do [ "$c" != "$tronco" ] && git show-ref --verify --quiet "refs/heads/$c" && echo -n "$c "; done)
  [ -n "$otras" ] && echo "AVISO: existen también $otras y no hay tronco declarado. Declarar cuál integra los cambios: git config sdd.tronco <rama>  o  docs/arquitectura.md → 'Tronco de integración'."
fi
echo "RAMA_ACTUAL: $actual"
echo "MODO: solo repositorio local (sin remotos, sin push, sin PR)"

# ---- Árbol de trabajo ----
sucios=$(git status --porcelain | wc -l | tr -d ' ')
echo "ARBOL_DE_TRABAJO: $sucios archivo(s) con cambios sin commitear"
[ "$sucios" -gt 0 ] && git status --porcelain | head -15 | sed 's/^/  /'

# ---- Todas las ramas locales frente al tronco ----
echo "RAMAS_LOCALES:  (rama · adelante/atrás respecto a $tronco · estado)"
if [ -n "$tronco" ] && git show-ref --verify --quiet "refs/heads/$tronco"; then
  git for-each-ref --format='%(refname:short)' refs/heads | while read -r r; do
    [ "$r" = "$tronco" ] && continue
    ahead=$(git rev-list --count "$tronco..$r" 2>/dev/null)
    behind=$(git rev-list --count "$r..$tronco" 2>/dev/null)
    if [ "${ahead:-0}" -eq 0 ]; then est="mergeada o sin cambios propios"
    elif [ "${behind:-0}" -gt 0 ]; then est="abierta; ATRASADA $behind commit(s) (conviene actualizarla con el tronco)"
    else est="abierta y al día"; fi
    marca=" "; [ "$r" = "$actual" ] && marca="*"
    echo "  $marca $r · +${ahead:-0}/-${behind:-0} · $est"
  done
fi

# ---- Fase de la rama actual, según los trailers SDD de sus commits ----
if [ -n "$tronco" ] && [ "$actual" != "$tronco" ] && [ "$actual" != "HEAD" ] && git show-ref --verify --quiet "refs/heads/$tronco"; then
  echo "FASES_EN_ESTA_RAMA:"
  fases=$(git log "$tronco..HEAD" --format='%(trailers:key=SDD-Fase,valueonly,separator=%x2C)' | tr ',' '\n' | sed 's/ //g' | grep . | sort -u | tr '\n' ' ')
  echo "  trailers SDD-Fase presentes: ${fases:-(ninguno)}"
  casos=$(git log "$tronco..HEAD" --format='%(trailers:key=SDD-Caso,valueonly)' | grep . | sort -u | tr '\n' ' ')
  echo "  SDD-Caso: ${casos:-(sin dato)}"
  hus=$(git log "$tronco..HEAD" --format='%(trailers:key=SDD-HU,valueonly)' | grep . | sort -u | tr '\n' ' ')
  [ -n "$hus" ] && echo "  SDD-HU: $hus"
  echo "  commits de la rama:"
  git log "$tronco..HEAD" --format='    %h %s' | head -15
  case " $fases " in
    *" verificacion "*) echo "PISTA: verificación registrada; falta el OK humano de cierre y el merge local al tronco." ;;
    *" aplicacion "*)   echo "PISTA: hay código aplicado; siguiente fase: verificación." ;;
    *" propuesta "*)    echo "PISTA: propuesta aprobada y commiteada; siguiente fase: aplicación." ;;
    *)                  echo "PISTA: la rama no tiene commit de propuesta; revisar si el delta del spec está sin aprobar (git diff docs/specs/)." ;;
  esac
else
  echo "PISTA: estás en el tronco o en HEAD suelto. Un cambio nuevo empieza con la exploración; no se codifica en el tronco."
fi

# ---- Specs y planes ----
echo "SPECS:"
if ls docs/specs/spec-*.md >/dev/null 2>&1; then
  for f in docs/specs/spec-*.md; do
    est=$(grep -m1 '^\*\*Estado:\*\*' "$f" | sed 's/\*\*Estado:\*\* //; s/ · .*//')
    echo "  $(basename "$f")  [${est:-sin estado}]  $(wc -l < "$f" | tr -d ' ') líneas"
  done
else
  echo "  (no hay specs: Caso 1 o Caso 5)"
fi
echo "PLANES:"
if ls docs/plan-*.md >/dev/null 2>&1; then
  for p in docs/plan-*.md; do
    est=$(grep -m1 '^\*\*Estado:\*\*' "$p" | sed 's/\*\*Estado:\*\* //')
    echo "  $(basename "$p")  [${est:-sin estado}]"
  done
else
  echo "  (no hay planes)"
fi

# ---- Versiones (tags locales) ----
ultimo=$(git describe --tags --abbrev=0 2>/dev/null)
echo "ULTIMA_VERSION: ${ultimo:-(sin tags locales)}"
if [ -n "$ultimo" ] && [ -n "$tronco" ]; then
  echo "CAMBIOS_DESDE_ULTIMA_VERSION: $(git rev-list --count "$ultimo..$tronco") commits en $tronco"
fi
exit 0
