#!/usr/bin/env bash
# sdd-git.sh — ÚNICA puerta de las skills SDD para ESCRIBIR en git. Solo repositorio local.
#
# El agente NO arma comandos de escritura de git a mano (switch -c, add, commit, merge, branch -d, tag,
# worktree): llama a este script. Así las reglas del ciclo se cumplen por código y no por memoria.
# Las lecturas (status, diff, log, show) sí pueden hacerse directamente; para el estado, usar sdd-estado.sh.
#
# Garantías (todas verificadas aquí, no en la prosa de las skills):
#   - No existe ningún subcomando de remoto (push/pull/fetch/remote). Nunca se usa la red.
#   - Todo subcomando que escribe SIMULA por defecto y solo ejecuta con --ejecutar.
#   - Nunca se usa --no-verify, --force, reset --hard ni reescritura de historia.
#   - Se rechaza commitear en el tronco (salvo `chore(release)` de entrega) y mergear sin verificación.
#   - Un commit de propuesta solo puede tocar docs/ (el código no entra antes del spec aprobado).
#   - Los commits llevan formato Conventional Commits y trailers SDD-*.
#   - Merge, borrado de rama, tag y ajuste de spec exigen --aprobado "<cita de la aprobación humana>",
#     que queda registrada en .git/sdd-aprobaciones.log.
#
# Códigos de salida: 0 ok/simulación · 2 regla violada (RECHAZADO) · 3 conflicto de merge (se aborta solo) · 64 uso.
# Requiere bash 4+ (arreglos asociativos). Uso: bash sdd-git.sh ayuda

export GIT_TERMINAL_PROMPT=0
SDD_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SDD_DIR/sdd-comun.sh"

die()   { echo "RECHAZADO: $*" >&2; exit 2; }
uso()   { echo "USO: $*" >&2; exit 64; }
info()  { echo "$*"; }

SUB="${1:-ayuda}"; [ $# -gt 0 ] && shift
POS=(); ARCHIVOS=(); EJECUTAR=0; AJUSTE=0
declare -A A
while [ $# -gt 0 ]; do
  case "$1" in
    --ejecutar) EJECUTAR=1 ;;
    --ajuste)   AJUSTE=1 ;;
    --raiz)     shift; A[raiz]="${1:-}" ;;
    --archivos) shift
                while [ $# -gt 0 ] && [[ "$1" != --* ]]; do ARCHIVOS+=("$1"); shift; done
                continue ;;
    --*)        k="${1#--}"; shift; A[$k]="${1:-}" ;;
    *)          POS+=("$1") ;;
  esac
  shift
done

[ -n "${A[raiz]:-}" ] && { cd "${A[raiz]}" 2>/dev/null || die "no existe la raíz ${A[raiz]}"; }
git rev-parse --git-dir >/dev/null 2>&1 || die "no es un repositorio git (git init requiere OK humano y se hace a mano)"
RAIZ="$(git rev-parse --show-toplevel)"; cd "$RAIZ" || die "no se pudo entrar a $RAIZ"

sdd_resolver_tronco
[ -n "$tronco" ] || die "no se pudo determinar el tronco de integración (declarar: git config sdd.tronco <rama>)"
git show-ref --verify --quiet "refs/heads/$tronco" || die "el tronco '$tronco' no existe como rama local"
ACTUAL="$(git rev-parse --abbrev-ref HEAD)"

limpio()   { [ -z "$(git status --porcelain)" ]; }
existe()   { git show-ref --verify --quiet "refs/heads/$1"; }
fases_de() { git log "$tronco..$1" --format='%(trailers:key=SDD-Fase,valueonly,separator=%x2C)' 2>/dev/null | tr ',' '\n' | sed 's/ //g' | grep . | sort -u | tr '\n' ' '; }
tiene_fase() { case " $(fases_de "$1") " in *" $2 "*) return 0 ;; *) return 1 ;; esac; }
simular()  { [ "$EJECUTAR" -eq 1 ] && return 1; echo "SIMULACION (no se ejecutó nada; repetir con --ejecutar tras el OK correspondiente):"; return 0; }
exigir_aprobacion() { [ -n "${A[aprobado]:-}" ] || die "$SUB exige --aprobado \"<cita textual de la aprobación del usuario>\""; }
kebab()    { echo "$1" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; }

TIPOS_RAMA="init feat change refactor fix migrate baseline arq spec hotfix"
TIPOS_COMMIT="spec docs test feat fix refactor perf chore merge"

case "$SUB" in
# --------------------------------------------------------------------------------------------------
ayuda|-h|--help)
cat <<'EOF'
sdd-git.sh — escritura en git para las skills SDD (solo local; simula salvo --ejecutar)

  tronco                                        Muestra el tronco de integración resuelto
  crear-rama <tipo> <capacidad> <slug> [--base R] [--worktree DIR] [--ejecutar]
  cambiar <rama> [--ejecutar]                   git switch con árbol limpio
  commit --tipo T --capacidad C --asunto "..." --fase F --caso N --archivos a b c
         [--cuerpo-archivo F] [--spec S] [--plan P] [--ca "CA-01,CA-02"] [--hu "HU-001,HU-002"]
         [--ajuste --aprobado "..."] [--atribucion "Co-Authored-By: ..."] [--ejecutar]
  actualizar-rama [--ejecutar]                  Mergea el tronco en la rama actual (sin rebase)
  merge <rama> [--destino R] --capacidad C --caso N --asunto "..." --cuerpo-archivo F --aprobado "..." [--ejecutar]
  borrar-rama <rama> --aprobado "..." [--ejecutar]
  tag <vX.Y.Z> --mensaje-archivo F --aprobado "..." [--ejecutar]
  worktree <rama> <directorio> [--ejecutar]

Tipos de rama:   init feat change refactor fix migrate baseline arq spec hotfix
Tipos de commit: spec docs test feat fix refactor perf chore
Fases:           propuesta aplicacion verificacion entrega     Casos: 1 2 3 4 5 arq hotfix entrega rapida
EOF
exit 0 ;;

# --------------------------------------------------------------------------------------------------
tronco)
  info "TRONCO: $tronco  [origen: $origen_tronco]"; [ -n "$release" ] && info "RAMA_DE_RELEASES: $release"; exit 0 ;;

# --------------------------------------------------------------------------------------------------
crear-rama)
  [ ${#POS[@]} -eq 3 ] || uso "crear-rama <tipo> <capacidad> <slug> [--base R] [--worktree DIR] [--ejecutar]"
  tipo="${POS[0]}"; cap="${POS[1]}"; slug="${POS[2]}"
  echo " $TIPOS_RAMA " | grep -q " $tipo " || die "tipo de rama '$tipo' inválido (válidos: $TIPOS_RAMA)"
  kebab "$cap"  || die "la capacidad debe estar en kebab-case minúsculas sin acentos: '$cap'"
  kebab "$slug" || die "el slug debe estar en kebab-case minúsculas sin acentos: '$slug'"
  nombre="$tipo/$cap-$slug"
  [ ${#nombre} -le 60 ] || die "el nombre '$nombre' supera 60 caracteres"
  base="${A[base]:-$tronco}"
  existe "$base"   || die "la rama base '$base' no existe"
  existe "$nombre" && die "la rama '$nombre' ya existe"
  limpio || die "el árbol de trabajo tiene cambios sin commitear; llevarlos a su rama o resolverlos antes"
  info "RAMA: $nombre  (base: $base)"
  simular && exit 0
  if [ -n "${A[worktree]:-}" ]; then
    [ ! -e "${A[worktree]}" ] || die "el directorio del worktree ya existe: ${A[worktree]}"
    git worktree add -b "$nombre" "${A[worktree]}" "$base" >/dev/null || die "falló git worktree add"
    info "OK rama creada en el worktree ${A[worktree]}"
  else
    git switch -c "$nombre" "$base" >/dev/null 2>&1 || die "falló git switch -c"
    info "OK rama creada y activa: $nombre"
  fi
  sdd_log_aprobacion "crear-rama $nombre base=$base ${A[aprobado]:+aprobado='${A[aprobado]}'}"
  exit 0 ;;

# --------------------------------------------------------------------------------------------------
cambiar)
  [ ${#POS[@]} -eq 1 ] || uso "cambiar <rama> [--ejecutar]"
  existe "${POS[0]}" || die "la rama '${POS[0]}' no existe"
  limpio || die "el árbol de trabajo tiene cambios sin commitear; no se cambia de rama arrastrando trabajo ajeno"
  info "CAMBIAR: $ACTUAL → ${POS[0]}"
  simular && exit 0
  git switch "${POS[0]}" >/dev/null 2>&1 || die "falló git switch"
  info "OK rama activa: ${POS[0]}"; exit 0 ;;

# --------------------------------------------------------------------------------------------------
commit)
  for r in tipo capacidad asunto fase; do [ -n "${A[$r]:-}" ] || uso "commit exige --$r (ver: sdd-git.sh ayuda)"; done
  [ -z "${A[caso]:-}" ] && [ "${A[fase]}" = "entrega" ] && A[caso]="entrega"
  [ -n "${A[caso]:-}" ] || uso "commit exige --caso (1 2 3 4 5 arq hotfix; en la fase entrega es opcional)"
  [ ${#ARCHIVOS[@]} -gt 0 ] || uso "commit exige --archivos <ruta ...> (nunca se commitea 'todo')"
  tipo="${A[tipo]}"; cap="${A[capacidad]}"; asunto="${A[asunto]}"; fase="${A[fase]}"; caso="${A[caso]}"
  echo " $TIPOS_COMMIT " | grep -q " $tipo " || die "tipo de commit '$tipo' inválido (válidos: $TIPOS_COMMIT)"
  [ "$tipo" = "merge" ] && die "los commits de merge se hacen con el subcomando merge"
  echo " propuesta aplicacion verificacion entrega " | grep -q " $fase " || die "fase '$fase' inválida"
  echo " 1 2 3 4 5 arq hotfix entrega rapida " | grep -q " $caso " || die "caso '$caso' inválido (1 2 3 4 5 arq hotfix entrega rapida)"
  kebab "$cap" || die "la capacidad debe estar en kebab-case: '$cap'"
  case "$asunto" in *.) die "el asunto no lleva punto final" ;; esac
  cabecera="$tipo($cap): $asunto"
  [ ${#cabecera} -le 72 ] || die "la primera línea mide ${#cabecera} caracteres (máximo 72): '$cabecera'"

  # Dónde se puede commitear
  if [ "$ACTUAL" = "$tronco" ] || { [ -n "$release" ] && [ "$ACTUAL" = "$release" ]; }; then
    { [ "$fase" = "entrega" ] && [ "$tipo" = "chore" ]; } || die "no se commitea en el tronco/rama de releases ($ACTUAL). Crear una rama de cambio con crear-rama. (Única excepción: chore de la fase entrega)"
  fi
  [ "$ACTUAL" != "HEAD" ] || die "HEAD suelto (detached): cambiar a una rama primero"

  # Reglas de fase
  case "$fase" in
    propuesta)
      for f in "${ARCHIVOS[@]}"; do
        case "$f" in docs/*|CLAUDE.md|AGENTS.md) ;; *) die "un commit de propuesta solo puede tocar docs/ (spec, plan, ADR, arquitectura); '$f' es código u otro archivo" ;; esac
      done ;;
    aplicacion)
      if [ "$caso" != "hotfix" ] && [ "$caso" != "rapida" ]; then
        tiene_fase "$ACTUAL" propuesta || die "la rama '$ACTUAL' no tiene commit de propuesta aprobado (SDD-Fase: propuesta): primero la propuesta, después el código"
      fi
      if [ "$tipo" = "spec" ]; then
        [ "$AJUSTE" -eq 1 ] || die "un commit 'spec' en fase aplicacion es un ajuste por descubrimiento: exige --ajuste y --aprobado"
        exigir_aprobacion
      fi ;;
    verificacion)
      if [ "$caso" != "hotfix" ]; then tiene_fase "$ACTUAL" aplicacion || die "no hay commits de aplicación en '$ACTUAL': nada que verificar"; fi
      for f in "${ARCHIVOS[@]}"; do case "$f" in docs/*) ;; *) die "un commit de verificación solo toca docs/ (recorte de spec, estado, plan); '$f' no" ;; esac; done ;;
    entrega) [ "$tipo" = "chore" ] || die "la fase entrega solo admite commits chore(release)" ;;
  esac
  [ "$AJUSTE" -eq 1 ] && { [ "$fase" = "aplicacion" ] && [ "$tipo" = "spec" ] || die "--ajuste solo aplica a un commit spec en fase aplicacion"; }

  # Vía rápida: cambios menores SIN efecto observable. Límites duros, verificados aquí.
  if [ "$caso" = "rapida" ]; then
    [ "$fase" = "aplicacion" ] || die "la vía rápida solo usa la fase aplicacion"
    echo " docs chore refactor test " | grep -q " $tipo " || die "la vía rápida solo admite commits docs, chore, refactor o test (sin comportamiento nuevo)"
    [ ${#ARCHIVOS[@]} -le 5 ] || die "la vía rápida admite hasta 5 archivos por commit; esto es un cambio para el ciclo completo"
    total=0
    for f in "${ARCHIVOS[@]}"; do
      case "$f" in docs/specs/*|docs/plan-*|docs/adr/*|docs/arquitectura.md) die "la vía rápida no toca specs, planes ni arquitectura ('$f'): eso va por el ciclo completo" ;; esac
      if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
        l=$(git diff HEAD --numstat -- "$f" | awk '{a+=$1; b+=$2} END {print a+b+0}')
      else
        l=$(wc -l < "$f" 2>/dev/null | tr -d ' '); l=${l:-0}
      fi
      total=$((total + l))
    done
    [ "$total" -le 40 ] || die "la vía rápida admite hasta 40 líneas cambiadas por commit (aquí: $total): usar el ciclo completo"
  fi

  # El índice debe estar vacío: solo entra lo que se lista
  git diff --cached --quiet || die "hay archivos ya preparados (staged) fuera de este commit; vaciar el índice antes (git restore --staged)"
  for f in "${ARCHIVOS[@]}"; do
    case "$f" in /*|*..*) die "ruta no permitida: '$f' (relativa a la raíz, sin '..')" ;; esac
    [ -e "$f" ] || git ls-files --error-unmatch "$f" >/dev/null 2>&1 || die "no existe ni está versionado: '$f'"
  done
  [ -n "${A[cuerpo-archivo]:-}" ] && { [ -f "${A[cuerpo-archivo]}" ] || die "no existe el archivo del cuerpo: ${A[cuerpo-archivo]}"; }

  # Lint de specs y planes si el commit los toca
  toca_docs=0; for f in "${ARCHIVOS[@]}"; do case "$f" in docs/specs/*|docs/plan-*) toca_docs=1 ;; esac; done
  if [ "$toca_docs" -eq 1 ]; then
    salida=$(bash "$SDD_DIR/sdd-lint.sh" "$RAIZ") || { echo "$salida" | grep '^ERROR' >&2; die "sdd-lint.sh reporta errores: corregirlos antes de commitear specs o planes"; }
  fi

  # Historias de usuario (paquete de diseño): formato y acta DoR firmada antes del commit de propuesta
  if [ -n "${A[hu]:-}" ]; then
    echo "${A[hu]}" | grep -Eq '^HU-[0-9A-Za-z-]+( *, *HU-[0-9A-Za-z-]+)*$' || die "--hu debe ser una o varias historias: \"HU-001\" o \"HU-001,HU-002\" (recibido: ${A[hu]})"
    if [ "$fase" = "propuesta" ]; then
      for hu in $(echo "${A[hu]}" | tr ',' ' '); do
        acta="docs/design/$hu/00_ACTA_APROBACION_DOR.md"
        if [ -f "$acta" ] && grep -q '\[ \] Aprobado' "$acta"; then
          die "el acta DoR de $hu ($acta) tiene firmas sin aprobar ([ ] Aprobado): el Gate 1 exige todos los roles antes del commit de propuesta"
        fi
      done
    fi
  fi

  # Mensaje
  msg="$(mktemp)"; trap 'rm -f "$msg"' EXIT
  { echo "$cabecera"; echo
    [ -n "${A[cuerpo-archivo]:-}" ] && { cat "${A[cuerpo-archivo]}"; echo; }
    echo "SDD-Caso: $caso"; echo "SDD-Fase: $fase"
    [ -n "${A[spec]:-}" ] && echo "SDD-Spec: ${A[spec]}"
    [ -n "${A[plan]:-}" ] && echo "SDD-Plan: ${A[plan]}"
    [ -n "${A[hu]:-}" ]   && echo "SDD-HU: ${A[hu]}"
    [ -n "${A[ca]:-}" ]   && echo "SDD-CA: ${A[ca]}"
    [ "$AJUSTE" -eq 1 ]   && echo "SDD-Ajuste: aprobado"
    [ -n "${A[atribucion]:-}" ] && echo "${A[atribucion]}"
  } > "$msg"
  info "COMMIT en '$ACTUAL':"; sed 's/^/  | /' "$msg"; info "ARCHIVOS: ${ARCHIVOS[*]}"
  simular && exit 0
  git add -A -- "${ARCHIVOS[@]}" || die "falló git add"
  git diff --cached --quiet && die "no hay cambios en los archivos indicados"
  git commit --cleanup=whitespace -F "$msg" >/dev/null || { git restore --staged -- "${ARCHIVOS[@]}" 2>/dev/null; die "falló git commit (¿un hook lo rechazó? se arregla la causa, no se omite el hook)"; }
  [ "$AJUSTE" -eq 1 ] && sdd_log_aprobacion "ajuste-spec $ACTUAL '$asunto' aprobado='${A[aprobado]}'"
  info "OK commit $(git rev-parse --short HEAD) en $ACTUAL"; exit 0 ;;

# --------------------------------------------------------------------------------------------------
actualizar-rama)
  [ "$ACTUAL" != "$tronco" ] || die "ya estás en el tronco"
  limpio || die "el árbol de trabajo tiene cambios sin commitear"
  atras=$(git rev-list --count "$ACTUAL..$tronco")
  info "ACTUALIZAR: '$ACTUAL' está atrasada $atras commit(s) respecto a '$tronco' (se mergea el tronco en la rama; sin rebase)"
  [ "$atras" -gt 0 ] || { info "OK ya está al día"; exit 0; }
  simular && exit 0
  if ! git merge --no-edit "$tronco" >/dev/null 2>&1; then git merge --abort >/dev/null 2>&1; echo "CONFLICTO: se abortó el merge; resolverlo a mano con el usuario" >&2; exit 3; fi
  info "OK rama actualizada"; exit 0 ;;

# --------------------------------------------------------------------------------------------------
merge)
  [ ${#POS[@]} -eq 1 ] || uso "merge <rama> --capacidad C --caso N --asunto \"...\" --cuerpo-archivo F --aprobado \"...\" [--ejecutar]"
  rama="${POS[0]}"
  for r in capacidad caso asunto; do [ -n "${A[$r]:-}" ] || uso "merge exige --$r"; done
  existe "$rama" || die "la rama '$rama' no existe"
  destino="${A[destino]:-$tronco}"
  existe "$destino" || die "la rama destino '$destino' no existe"
  [ "$rama" != "$destino" ] || die "no se mergea una rama consigo misma"
  limpio || die "el árbol de trabajo tiene cambios sin commitear"
  # ¿Rama de vía rápida? Todos sus commits llevan SDD-Caso: rapida y nada más.
  total_commits=$(git rev-list --count "$tronco..$rama" 2>/dev/null)
  casos_rama=$(git log "$tronco..$rama" --format='%(trailers:key=SDD-Caso,valueonly)' 2>/dev/null | grep . | sort -u | tr '\n' ' ')
  con_caso=$(git log "$tronco..$rama" --format='%(trailers:key=SDD-Caso,valueonly)' 2>/dev/null | grep -c .)
  RAPIDA=0; [ "$casos_rama" = "rapida " ] && [ "${total_commits:-0}" -eq "${con_caso:-1}" ] && RAPIDA=1
  if [ "$destino" = "$tronco" ]; then
    # Caso normal: una rama de cambio verificada entra al tronco de integración
    [ "$(git rev-list --count "$tronco..$rama")" -gt 0 ] || die "'$rama' no tiene commits nuevos respecto a '$tronco'"
    if [ "$RAPIDA" -eq 1 ]; then
      lin=$(git diff --numstat "$tronco...$rama" | awk '{s+=$1+$2} END {print s+0}')
      arch=$(git diff --numstat "$tronco...$rama" | wc -l | tr -d ' ')
      { [ "$lin" -le 80 ] && [ "$arch" -le 8 ]; } || die "la rama de vía rápida acumula $lin líneas en $arch archivos (máx. 80 y 8): usar el ciclo completo"
    else
      tiene_fase "$rama" verificacion || die "'$rama' no tiene commit de verificación (SDD-Fase: verificacion): primero la verificación y el gate humano"
    fi
    [ "$(git rev-list --count "$rama..$tronco")" -eq 0 ] || die "'$rama' está atrasada respecto a '$tronco': ejecutar actualizar-rama estando en ella y reverificar"
  elif [ -n "$release" ] && [ "$destino" = "$release" ]; then
    # Entrega: solo el tronco de integración puede entrar a la rama de releases
    [ "$rama" = "$tronco" ] || die "a la rama de releases ('$release') solo entra el tronco de integración ('$tronco'), no '$rama'"
    [ "$(git rev-list --count "$release..$tronco")" -gt 0 ] || die "'$release' ya contiene todo '$tronco': nada que entregar"
  else
    die "destino '$destino' no permitido: solo el tronco de integración ('$tronco') o la rama de releases declarada"
  fi
  [ -f "${A[cuerpo-archivo]:-/nada}" ] || die "merge exige --cuerpo-archivo con el reporte de verificación (plantilla-reporte.md)"
  kebab "${A[capacidad]}" || die "capacidad inválida"
  cabecera="merge(${A[capacidad]}): ${A[asunto]}"; [ ${#cabecera} -le 72 ] || die "la primera línea mide ${#cabecera} (máx. 72)"
  msg="$(mktemp)"; trap 'rm -f "$msg"' EXIT
  { echo "$cabecera"; echo; cat "${A[cuerpo-archivo]}"; echo
    echo "SDD-Caso: ${A[caso]}"; echo "SDD-Fase: $([ "$destino" = "$tronco" ] && echo verificacion || echo entrega)"
    [ -n "${A[atribucion]:-}" ] && echo "${A[atribucion]}"; } > "$msg"
  info "MERGE: '$rama' → '$destino' con --no-ff"; git log --oneline "$destino..$rama" | sed 's/^/  /'; git diff --stat "$destino...$rama" | tail -1 | sed 's/^/  /'
  simular && exit 0
  exigir_aprobacion
  orig="$ACTUAL"
  git switch "$destino" >/dev/null 2>&1 || die "no se pudo pasar a '$destino'"
  if ! git merge --no-ff -F "$msg" "$rama" >/dev/null 2>&1; then
    git merge --abort >/dev/null 2>&1; git switch "$orig" >/dev/null 2>&1
    echo "CONFLICTO: se abortó el merge y se volvió a '$orig'; resolver a mano con el usuario" >&2; exit 3
  fi
  sdd_log_aprobacion "merge $rama -> $destino aprobado='${A[aprobado]}'"
  info "OK merge $(git rev-parse --short HEAD) en $destino (rama activa: $destino; la rama '$rama' sigue existiendo)"; exit 0 ;;

# --------------------------------------------------------------------------------------------------
borrar-rama)
  [ ${#POS[@]} -eq 1 ] || uso "borrar-rama <rama> --aprobado \"...\" [--ejecutar]"
  rama="${POS[0]}"
  existe "$rama" || die "la rama '$rama' no existe"
  [ "$rama" != "$tronco" ] || die "no se borra el tronco"
  { [ -n "$release" ] && [ "$rama" = "$release" ]; } && die "no se borra la rama de releases"
  [ "$rama" != "$ACTUAL" ] || die "no se borra la rama activa"
  git merge-base --is-ancestor "$rama" "$tronco" || die "'$rama' NO está mergeada en '$tronco': borrarla perdería commits"
  git worktree list --porcelain | grep -q "branch refs/heads/$rama$" && die "'$rama' tiene un worktree activo"
  info "BORRAR RAMA LOCAL: $rama (mergeada en $tronco)"
  simular && exit 0
  exigir_aprobacion
  git branch -d "$rama" >/dev/null 2>&1 || die "falló git branch -d"
  sdd_log_aprobacion "borrar-rama $rama aprobado='${A[aprobado]}'"; info "OK rama borrada"; exit 0 ;;

# --------------------------------------------------------------------------------------------------
tag)
  [ ${#POS[@]} -eq 1 ] || uso "tag <vX.Y.Z> --mensaje-archivo F --aprobado \"...\" [--ejecutar]"
  nombre="${POS[0]}"
  echo "$nombre" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$' || die "el tag debe ser vMAJOR.MINOR.PATCH (SemVer): '$nombre'"
  { [ "$ACTUAL" = "$tronco" ] || { [ -n "$release" ] && [ "$ACTUAL" = "$release" ]; }; } || die "los tags se crean en el tronco o en la rama de releases, no en '$ACTUAL'"
  limpio || die "el árbol de trabajo tiene cambios sin commitear"
  git rev-parse -q --verify "refs/tags/$nombre" >/dev/null && die "el tag '$nombre' ya existe"
  [ -f "${A[mensaje-archivo]:-/nada}" ] || die "tag exige --mensaje-archivo (el changelog aprobado)"
  info "TAG LOCAL anotado: $nombre sobre $(git rev-parse --short HEAD) en $ACTUAL (no se publica)"
  simular && exit 0
  exigir_aprobacion
  git tag -a "$nombre" -F "${A[mensaje-archivo]}" || die "falló git tag"
  sdd_log_aprobacion "tag $nombre aprobado='${A[aprobado]}'"; info "OK tag $nombre creado (solo local)"; exit 0 ;;

# --------------------------------------------------------------------------------------------------
worktree)
  [ ${#POS[@]} -eq 2 ] || uso "worktree <rama> <directorio> [--ejecutar]"
  existe "${POS[0]}" || die "la rama '${POS[0]}' no existe"
  [ ! -e "${POS[1]}" ] || die "el directorio ya existe: ${POS[1]}"
  info "WORKTREE: ${POS[0]} → ${POS[1]}"
  simular && exit 0
  git worktree add "${POS[1]}" "${POS[0]}" >/dev/null 2>&1 || die "falló git worktree add (¿la rama ya está activa en otro árbol?)"
  info "OK worktree creado"; exit 0 ;;

# --------------------------------------------------------------------------------------------------
push|pull|fetch|remote|clone|gh)
  die "'$SUB' no existe: las skills trabajan solo con el repositorio local. Publicar es manual del desarrollador." ;;
*)
  uso "subcomando desconocido '$SUB'. Ver: sdd-git.sh ayuda" ;;
esac
