#!/usr/bin/env bash
# sdd-comun.sh — funciones compartidas por sdd-estado.sh y sdd-git.sh. Se carga con `source`, no se ejecuta.
# Solo repositorio local: nada de aquí toca remotos.

# Resuelve el tronco de integración y la rama de releases. Deja las variables:
#   tronco  origen_tronco  release
# Prioridad: 1) git config sdd.tronco  2) "Tronco de integración: <rama>" en docs/arquitectura.md
#            3) la primera rama local que exista entre develop, main, master, trunk
sdd_resolver_tronco() {
  tronco=""; origen_tronco=""; release=""
  local c
  c=$(git config --get sdd.tronco 2>/dev/null)
  [ -n "$c" ] && tronco="$c" && origen_tronco="git config sdd.tronco"
  if [ -z "$tronco" ] && [ -f docs/arquitectura.md ]; then
    c=$(grep -m1 -iE '^[-* ]*Tronco de integraci(o|ó)n[*]*:' docs/arquitectura.md | sed -E 's/^[^:]*:[*[:space:]]*//; s/[`*]//g; s/[[:space:]].*$//')
    [ -n "$c" ] && tronco="$c" && origen_tronco="docs/arquitectura.md"
  fi
  if [ -z "$tronco" ]; then
    for c in develop main master trunk; do
      git show-ref --verify --quiet "refs/heads/$c" && { tronco="$c"; origen_tronco="primera rama local conocida"; break; }
    done
  fi
  release=$(git config --get sdd.release 2>/dev/null)
  if [ -z "$release" ] && [ -f docs/arquitectura.md ]; then
    release=$(grep -m1 -iE '^[-* ]*Rama de releases?[*]*:' docs/arquitectura.md | sed -E 's/^[^:]*:[*[:space:]]*//; s/[`*]//g; s/[[:space:]].*$//')
  fi
}

# Registro de aprobaciones humanas citadas por el agente. Vive dentro de .git (no se versiona).
sdd_log_aprobacion() {
  local f; f="$(git rev-parse --git-dir)/sdd-aprobaciones.log"
  printf '%s | %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$*" >> "$f"
}
