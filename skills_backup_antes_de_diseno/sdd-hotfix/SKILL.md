---
name: sdd-hotfix
description: Use when the user reports a bug, failure or regression in something that already works (falla, bug, error, se rompio, no funciona como dice el spec) where the spec is correct and the code does not meet it. Reproduces it with a failing test first, applies the smallest fix on a hotfix branch, runs reduced but never skipped gates and merges locally. If the spec itself is wrong, redirects to sdd-exploracion as Case 3.
argument-hint: [descripción del fallo observado: qué pasó, dónde, cómo reproducirlo]
---

# sdd-hotfix — Bug en lo que ya corre

Camino corto para un fallo **en producción o en el tronco** donde el spec describe lo correcto y el código no lo cumple. Mantiene lo no negociable del método (el spec manda, hay prueba, hay gate humano) y recorta lo que no aplica (no hay delta de spec que redactar).

Leer `../_shared/convenciones.md`, `../_shared/ramas-y-commits.md` y `../_shared/criterios-y-pruebas.md`. Las rutas `../_shared/` son relativas a la carpeta de esta skill.

> **Git solo por script.** Toda escritura en git (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree) se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`, nunca con `git switch`, `git add`, `git commit`, `git merge`, `git branch` o `git tag` armados a mano. El script simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`; los subcomandos sensibles exigen `--aprobado "<cita del OK del usuario>"`. No hay comandos de remoto: nada de push, pull, PR ni `gh`. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente. Detalle en `../_shared/ramas-y-commits.md` §0.

## Paso 1 — Entender y clasificar

1. Pedir (o leer de `$ARGUMENTS`) lo observado: qué pasó, qué se esperaba, cómo reproducirlo, desde cuándo, a quién afecta, en qué versión.
2. Ubicar **qué dice el spec** sobre ese comportamiento (el spec de la capacidad y sus relacionadas). Citar el ítem.
3. Clasificar, y **decirlo al usuario antes de seguir**:

| Hallazgo | Es | Qué hacer |
|---|---|---|
| El spec dice X, el código hace Y | **Bug** (código ≠ spec) | Seguir en esta skill |
| El spec no dice nada de este caso | **Hueco del spec** | Es una funcionalidad no prevista: `/sdd-exploracion` (Caso 2 o 3) |
| El spec dice algo que no es lo que se necesita | **Spec equivocado** | `/sdd-exploracion` como Caso 3; no se arregla con un hotfix |
| El fallo es de infraestructura, datos o configuración | **Operación** | Corregir en el entorno; documentar la causa; sin cambio de código si no lo requiere |
| Se necesita cambiar la forma transversal | **Arquitectura** | `/sdd-arquitectura` |

Un hotfix **nunca cambia el comportamiento descrito por el spec**. Si lo necesita, no es un hotfix.

## Paso 2 — Contener primero, si hace falta

Si el fallo afecta a usuarios ahora: ¿hay un interruptor de configuración que apague la función? ¿se puede volver al tag anterior (`entrega.md` §5)? Proponer la contención **antes** del arreglo, con OK del usuario. Contener no es arreglar.

## Paso 3 — Rama y reproducción

1. Rama con `bash ../_shared/scripts/sdd-git.sh crear-rama hotfix <capacidad> <slug> [--base <rama>] --ejecutar` (primero simulando). Por defecto nace del tronco de integración; con un modelo de dos ramas, `--base <rama de releases>` la crea desde producción. Al terminar entra al tronco con `sdd-git.sh merge`; llevarlo a la rama de releases es el flujo de `/sdd-entrega`. Si el tronco tiene cambios sin entregar y se necesita publicar solo el arreglo, eso lo resuelve el desarrollador a mano (el script no cherry-pickea).
2. **Prueba de regresión primero:** una prueba que reproduce el fallo y **falla por la razón correcta**. Se llama `CA-HF-01` (o el siguiente) y cita el ítem del spec que viola. Commit con `sdd-git.sh commit --tipo test --capacidad <cap> --asunto "reproduce <fallo>" --fase aplicacion --caso hotfix --ca CA-HF-01 --archivos <prueba> --ejecutar`.
3. Si el fallo **no se puede reproducir** automáticamente, no tocar el código todavía: reunir más datos (registros, versión, entradas) o escribir una reproducción manual con pasos exactos y dejarla como criterio manual.

## Paso 4 — Arreglo mínimo

- El cambio **más pequeño** que hace pasar la prueba y no rompe lo demás. Sin refactors, sin "de paso".
- Respetar los invariantes, límites y modos de falla del spec.
- Si al arreglar aparece algo que el spec no previó, **detenerse**: es un descubrimiento (como en `/sdd-aplicacion` Paso 4). Proponer el ajuste y pedir OK; si es sustancial, abandonar el hotfix y abrir un Caso 3.
- Commit con `sdd-git.sh commit --tipo fix --capacidad <cap> --asunto "<qué>" --fase aplicacion --caso hotfix --ca CA-HF-01 --archivos <archivos> --ejecutar`.

## Paso 5 — Gates reducidos (no omitidos)

| Se corre | Se difiere |
|---|---|
| La prueba de regresión, las pruebas del módulo y de sus dependientes, lint y tipos | La suite completa de integración, si es lenta, **pero se corre completa en local antes de mergear** |
| `sdd-lint.sh` | Verificación con contexto limpio (se ofrece igual si el cambio supera ~100 líneas) |
| Escaneo de secretos y revisión de dependencias si se tocaron | — |

Reportar al usuario: qué falló, la causa raíz en una frase, el cambio, la prueba, el resultado de los gates y el riesgo de regresión.

## Paso 6 — Gate humano y merge

Mostrar el diff y el reporte. **Pedir OK explícito** para el merge local (`ramas-y-commits.md` §4 y §5) y mergear con `bash ../_shared/scripts/sdd-git.sh merge <rama> --capacidad <cap> --caso hotfix --asunto "…" --cuerpo-archivo <reporte> --aprobado "<cita del OK>"` (simula; `--ejecutar` tras el OK). No mergear con pruebas en rojo. Nada se hace contra remotos: publicar es manual del desarrollador.

## Paso 7 — Publicar y cerrar el ciclo

1. `/sdd-entrega` con versión **PATCH**. Si hay urgencia, el humano puede pedir publicar el tag de inmediato; el changelog igual se escribe.
2. Si el fallo **escapó** porque el spec no tenía un criterio para ese caso (un modo de falla no previsto, un límite sin probar), proponer registrarlo: una *Decisión* fechada en el spec y el criterio permanente que ahora lo cubre. Eso sí es un cambio de spec y va por `/sdd-propuesta`.
3. **Post-mortem corto** (5 líneas) en `docs/postmortems/AAAA-MM-DD-<slug>.md`: qué falló, por qué no lo detectaron las pruebas, qué prueba o criterio nuevo lo cubre ahora, cómo se evita la clase de error. Se commitea con `sdd-git.sh commit --tipo docs --capacidad <cap> --asunto "post-mortem del hotfix" --fase verificacion --caso hotfix --archivos docs/postmortems/<archivo> --ejecutar`: **es el commit de verificación que el script exige para mergear** (un hotfix no toca el spec, así que necesita este documento).

## Lo que esta skill NO hace

- No cambia el spec (salvo la *Decisión* del Paso 7.2, por el camino normal).
- No agrega funcionalidades ni refactoriza.
- No mergea ni publica sin OK.
- No usa `--no-verify` ni se salta comprobaciones: un hotfix urgente sigue pasando por las pruebas.

## Referencias

- `../_shared/ramas-y-commits.md` — rama `hotfix/`, commits, autorizaciones.
- `../_shared/criterios-y-pruebas.md` — prueba de regresión primero.
- `../_shared/entrega.md` — reversión, PATCH, gates.
- `../_shared/scripts/sdd-lint.sh`.
