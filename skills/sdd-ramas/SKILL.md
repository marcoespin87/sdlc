---
name: sdd-ramas
description: Use when the user asks to plan, list, create or order branches from the specs and plans of the project (mapa de ramas, que ramas necesito, ramas por fase, M0 a M4), or when a plan has several pending phases. Derives one local branch per plan phase or capability in dependency order (sequential, stacked or parallel with git worktrees) from docs/specs and docs/plan-*, and creates them only after approval. Local only; never publishes.
argument-hint: [opcional: ruta a un plan, o nombre de una capacidad, para acotar el mapa]
---

# sdd-ramas — Mapa de ramas desde los specs y los planes

Convierte lo que ya está escrito (índice de specs, dependencias entre capacidades, fases de los planes) en un **mapa de ramas ordenado**, y las crea cuando el usuario lo aprueba. Resuelve el caso de "tengo un plan con M0 a M4, o varios specs, ¿qué ramas abro y en qué orden?".

No escribe specs ni código. No reemplaza el Paso 0 de `/sdd-propuesta`, que crea la rama de **un** cambio: esta skill prepara el panorama de **varios** y deja sus nombres coherentes.

Leer `../_shared/ramas-y-commits.md` (nombres, apiladas, worktrees) y `../_shared/convenciones.md` antes de proponer nada.

> **Git solo por script.** Toda escritura en git (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree) se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`, nunca con `git switch`, `git add`, `git commit`, `git merge`, `git branch` o `git tag` armados a mano. El script simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`; los subcomandos sensibles exigen `--aprobado "<cita del OK del usuario>"`. No hay comandos de remoto: nada de push, pull, PR ni `gh`. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente. Detalle en `../_shared/ramas-y-commits.md` §0.

## Paso 1 — Reunir las fuentes

1. `bash ../_shared/scripts/sdd-estado.sh`: tronco, ramas abiertas y su fase.
2. `docs/specs/README.md` y las **Referencias** de cada spec ("Depende de / Usada por") para construir el grafo de dependencias.
3. Los planes `docs/plan-*.md` con `Estado: en desarrollo`: su *Mapa de ramas* si ya lo trae, y sus fases pendientes.
4. Si `$ARGUMENTS` acota (un plan o una capacidad), limitarse a eso.
5. **Si hay paquetes de diseño:** las HU de la columna *Historias* del índice y las dependencias del WBS de cada `docs/design/HU-0NN/06_PLAN_CONSTRUCCION_WBS.md` (`bloqueada_por`) o del plan que las adoptó.

Sin specs ni planes: no hay de dónde derivar. Decirlo y sugerir `/sdd-exploracion`.

## Paso 2 — Derivar el mapa

Una rama por **fase de plan** o, sin plan, por **cambio pendiente de una capacidad**. Para cada una, calcular:

| Campo | Cómo se obtiene |
|---|---|
| Nombre | `<tipo>/<capacidad>-<slug>` según `ramas-y-commits.md` §2 (tipo por Caso: `init`, `feat`, `change`, `migrate`…) |
| Depende de | Otra rama del mapa si la fase o capacidad figura como "Depende de" en las Referencias, o la fase anterior del plan |
| Spec(s) | Los specs que escribe o toca |
| Caso y delta | Del plan o de la Exploración |
| Estado | pendiente / rama abierta / mergeada (según git) |
| Forma | **secuencial** (nace del tronco tras mergear la anterior), **apilada** (nace de la anterior porque necesita su código sin mergear) o **paralela** (independiente; un `git worktree` aparte) |

Reglas de ordenamiento:

- Orden topológico por dependencia; empates se resuelven por riesgo (lo más aislado primero, como en la migración módulo por módulo).
- **Apilar solo cuando sea imprescindible**: cada apilada obliga a rebasar al mergear la anterior. Si dos fases no comparten código, son paralelas.
- Conflictos previsibles (el índice `README.md`, las *Referencias* cruzadas): marcarlos y proponer que las ramas que añaden filas al índice se mergeen una por una.
- Una rama por propósito: si una fase mezcla dos capacidades, proponer partirla (decisión del usuario).
- **Una rama por HU:** varias HU de una misma capacidad son ramas sucesivas sobre el mismo spec (secuenciales, o apiladas solo si una necesita el código de otra); una HU que abarca dos capacidades se parte en dos.
- Ciclos de dependencia: **detenerse y reportarlos**; es un problema de diseño de los specs, no del mapa.

## Paso 3 — Presentar el mapa

Mostrar una tabla y un diagrama breve, por ejemplo:

```
tronco ──┬─ init/mvp-datos-sinteticos (specs + arquitectura + plan)
         ├─ feat/m0-esqueleto
         │     └─ feat/m1a-motor-determinista   (apilada: usa el esqueleto)
         └─ feat/m1b-nucleo-relacional           (paralela; worktree)
```

| Rama | Depende de | Forma | Spec(s) | Estado |
|---|---|---|---|---|

Indicar el **orden de merge** y qué ramas pueden trabajarse en paralelo. Si el plan no tiene la sección *Mapa de ramas*, ofrecer añadirla (es un cambio de documentación: va en la rama de la propuesta correspondiente, no se escribe acá sin OK).

## Paso 4 — Crear las ramas (solo con aprobación)

Pedir aprobación del mapa. Con ella, y **por cada rama** que el usuario quiera abrir ahora (no es necesario abrir todas):

1. Si el árbol de trabajo está sucio, detenerse (el script también lo rechaza). **Sin `git pull`**: se trabaja con lo que hay en el repositorio local.
2. `bash ../_shared/scripts/sdd-git.sh crear-rama <tipo> <capacidad> <slug> [--base <rama>] [--worktree <dir>]` sin `--ejecutar` (simula y valida el nombre), mostrar el resultado y repetir con `--ejecutar` tras el OK. Para las paralelas, `--worktree ../wt-<slug>`. Las ramas apiladas usan `--base <rama anterior>`.
3. **No hacer push** ni nada contra remotos: publicar es manual del desarrollador.

Dejar escrito en la respuesta, para cada rama creada, **la skill con la que se empieza** (normalmente `/sdd-exploracion`, o `/sdd-propuesta` si el Caso ya está claro).

## Paso 5 — Mantener el mapa

Cuando una rama se mergea, el mapa cambia: la apilada sobre ella debe rebasarse y la siguiente puede abrirse. `/sdd-estado` muestra el estado actual; volver a correr esta skill reconcilia el mapa con git. Ofrecer actualizar la columna *Estado* del *Mapa de ramas* del plan en la rama correspondiente.

## Lo que esta skill NO hace

- No crea issues, hitos ni PR, y no usa remotos (el repo es solo local).
- No borra ramas ni worktrees sin OK.
- No decide el Caso ni escribe specs.

## Referencias

- `../_shared/ramas-y-commits.md` — nombres, apiladas, worktrees, autorizaciones.
- `../_shared/plantilla-plan.md` — sección *Mapa de ramas*.
- `../_shared/convenciones.md` — dependencias entre specs, índice.
- `../_shared/scripts/sdd-estado.sh`.
