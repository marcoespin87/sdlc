# Hooks sugeridos (guardarraíles deterministas, solo repositorio local)

Las skills son instrucciones; **un hook es una regla que se cumple siempre**, aunque el agente se confunda o la sesión sea nueva. Las skills ya hacen todo lo que escribe en git a través de `sdd-git.sh`, que valida las reglas del ciclo; los hooks cierran la puerta contra **saltarse el script**. **No se instalan solos**: configurarlos con la skill `update-config` (o a mano en `.claude/settings.json`), revisando la sintaxis vigente de tu versión de Claude Code.

| Hook | Evento | Qué hace | Por qué |
|---|---|---|---|
| **Git de escritura solo vía script** | `PreToolUse` sobre `Bash` | Si el comando contiene `git switch`, `git checkout`, `git add`, `git commit`, `git merge`, `git branch`, `git tag`, `git worktree`, `git reset`, `git rebase`, `git stash`, `git clean`, `git restore`, `git cherry-pick`, `git revert` o `git init` **y no es una llamada a `sdd-git.sh`**, bloquear y explicar | Hace cumplir "el agente no arma comandos de escritura de git" |
| **Nada contra remotos** | `PreToolUse` sobre `Bash` | Si el comando contiene `git push`, `git pull`, `git fetch`, `git remote`, `git clone` o `gh `, bloquear siempre | Hace cumplir "las skills solo trabajan en el repo local; publicar es manual" |
| Lint del spec al guardar | `PostToolUse` sobre `Edit`/`Write` de `docs/specs/*.md` y `docs/plan-*.md` | Ejecutar `bash .claude/skills/_shared/scripts/sdd-lint.sh` y devolver los errores | Corrige el formato en el momento, no en la verificación |
| Spec antes que código | `PreToolUse` sobre `Edit`/`Write` en las carpetas de código (`backend/app`, `frontend/src`) | Si la rama no tiene un commit con trailer `SDD-Fase: propuesta`, bloquear | Hace cumplir la regla 3.1 de forma mecánica |
| Pruebas al cerrar un turno de aplicación | `Stop` | Opcional: correr las pruebas rápidas del módulo tocado y avisar si fallan | Evita llegar a la verificación con código roto |

Las **lecturas** de git (`status`, `diff`, `log`, `show`, `rev-parse`, `branch --list`, `for-each-ref`) no se bloquean: el agente las necesita para informar.

## Boceto de los dos primeros hooks

Lógica (script bash que lee el comando del evento y decide):

```bash
#!/usr/bin/env bash
# Pseudocódigo: adaptar la lectura del evento a tu versión de Claude Code.
cmd="$CLAUDE_TOOL_INPUT"            # el comando que se va a ejecutar

# 1) Nada contra remotos
if echo "$cmd" | grep -Eq '(^|[;&| ])(git (push|pull|fetch|remote|clone)|gh )'; then
  echo "Bloqueado: las skills trabajan solo en el repositorio local. Publicar es manual." >&2
  exit 2
fi

# 2) Git de escritura solo vía sdd-git.sh
if echo "$cmd" | grep -Eq '(^|[;&| ])git (switch|checkout|add|commit|merge|branch|tag|worktree|reset|rebase|stash|clean|restore|cherry-pick|revert|init)\b'; then
  # Se permite si es una lectura disfrazada de subcomando (branch --list, tag -l, etc.)
  if echo "$cmd" | grep -Eq 'git (branch|tag)( |$)(--list|-l|--merged|--no-merged|-a|-v|--show-current)'; then exit 0; fi
  # Los comandos que llama el propio script no pasan por aquí (se ejecutan dentro de sdd-git.sh)
  echo "Bloqueado: las escrituras en git pasan por .claude/skills/_shared/scripts/sdd-git.sh (ver ramas-y-commits.md §0)." >&2
  exit 2                              # código que indica bloqueo con mensaje al agente
fi
exit 0
```

> Notas importantes:
> - El nombre de las variables de entorno del evento y el código de salida de bloqueo **dependen de la versión**; verificarlos en la documentación de hooks antes de activar. Probar primero en un repositorio de prueba.
> - Un hook de `PreToolUse` se evalúa sobre lo que el agente **invoca**. Las llamadas internas que hace `sdd-git.sh` (por ejemplo `git commit`) no son comandos del agente y no pasan por el hook.
> - La coincidencia por expresión regular no es un análisis completo de shell: un comando muy rebuscado podría esquivarla. Es una barrera práctica, no una garantía criptográfica. El script `sdd-git.sh` es la garantía de las reglas; el hook solo evita el desvío.

## Orden de adopción sugerido

1. Lint del spec al guardar (riesgo bajo, valor alto).
2. Bloquear comandos de remoto y git de escritura fuera del script.
3. Spec antes que código (el más estricto: activarlo cuando el equipo ya domine el ciclo).
