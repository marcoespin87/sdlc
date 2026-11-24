---
name: sdd-estado
description: Use at the start of any session or task that involves the repository, and whenever you need to know the current local branch, the integration trunk, the open change branches, which SDD phase comes next, or whether specs and plans are consistent (donde estoy, que sigue, estado del repo, retomar el trabajo). Read-only: reads the local git repository and docs/ with a script; never writes, commits, switches branches or touches remotes.
argument-hint: [opcional: nombre de la rama o capacidad a revisar]
---

# sdd-estado — ¿Dónde estoy en el ciclo?

Skill de **solo lectura**. Reconstruye el estado del ciclo desde el repositorio, no desde la memoria de la conversación, y dice qué hacer a continuación. Sirve para retomar una sesión nueva, para saber qué ramas hay abiertas y para detectar un ciclo mal cerrado.

> **Git solo por script.** Toda escritura en git (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree) se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`, nunca con `git switch`, `git add`, `git commit`, `git merge`, `git branch` o `git tag` armados a mano. El script simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`; los subcomandos sensibles exigen `--aprobado "<cita del OK del usuario>"`. No hay comandos de remoto: nada de push, pull, PR ni `gh`. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente. Detalle en `../_shared/ramas-y-commits.md` §0.

## Paso 1 — Correr el script

```bash
bash ../_shared/scripts/sdd-estado.sh          # estado del ciclo
bash ../_shared/scripts/sdd-lint.sh            # salud de specs, índice y planes
```

Las rutas son relativas a la carpeta de esta skill. Leer ambas salidas completas. Si `$ARGUMENTS` nombra una rama, preguntar antes de cambiar de rama: **esta skill no hace `checkout`**, solo informa (y puede sugerir `git switch`).

## Paso 2 — Interpretar (tabla de decisión)

| Lo que muestra el script | Significa | Siguiente paso |
|---|---|---|
| Estás en el tronco, sin ramas de cambio | Nada en curso | Cambio nuevo: `/sdd-exploracion` |
| Estás en el tronco, hay ramas de cambio abiertas | Trabajo en curso en otras ramas | Preguntar cuál retomar; `sdd-git.sh cambiar <rama> --ejecutar` (árbol limpio) |
| Rama sin commit `SDD-Fase: propuesta`, con cambios en `docs/specs/` | Propuesta sin aprobar | Volver a `/sdd-propuesta` (Paso 9, el gate) |
| Rama con `SDD-Fase: propuesta` y sin `aplicacion` | Spec aprobado, falta construir | `/sdd-aplicacion` |
| Rama con `aplicacion` y sin `verificacion` | Construido, sin verificar | `/sdd-verificacion` |
| Rama con `verificacion`, sin mergear | Falta el OK humano o el merge | Terminar el Paso 6–7 de `/sdd-verificacion` |
| Tronco con cambios desde el último tag | Hay algo que publicar | `/sdd-entrega` |
| Spec `en desarrollo` sin rama que lo explique | Ciclo mal cerrado o Fase 0 pendiente | Revisar: ¿Fase 0 sin terminar? ¿rama borrada antes de tiempo? |
| Plan `en desarrollo` con fases pendientes | Quedan fases por construir | `/sdd-ramas` para ver el mapa y la siguiente rama |
| Árbol de trabajo sucio fuera de una rama de cambio | Cambios sin dueño | Decidir con el usuario: llevarlos a una rama o descartarlos (no descartar sin OK) |
| `sdd-lint.sh` con ERROR | Specs/índice/plan fuera de formato | Corregirlos en la fase que corresponda |

## Paso 3 — Responder en corto

Entregar siempre, en este orden y sin más de ~15 líneas:

1. **Dónde estás:** tronco, rama actual, su Caso y su fase (según los trailers).
2. **Qué hay abierto:** ramas de cambio, planes con fases pendientes, specs `en desarrollo`.
3. **Qué sigue:** la skill exacta (`/sdd-…`) y por qué.
4. **Alertas:** cambios sin commitear, lint con errores, rama atrasada respecto al tronco, trabajo sin dueño.

Si falta información que solo el usuario tiene (por ejemplo, si una rama quedó abandonada), preguntarlo; no inventar el estado.

## Lo que esta skill NO hace

- No crea ramas, no commitea, no cambia de rama, no corrige specs, no usa remotos.
- No decide el Caso de un cambio nuevo (eso es `/sdd-exploracion`).

## Referencias

- `../_shared/ciclo-de-vida.md` — mapa de skills.
- `../_shared/ramas-y-commits.md` — trailers `SDD-*` que se leen.
- `../_shared/scripts/sdd-estado.sh`, `../_shared/scripts/sdd-lint.sh`.
