---
name: sdd-entrega
description: Use when the user asks to publish a version, cut a release, generate a changelog, tag, or deploy what is already merged into the integration trunk (release, version, changelog, tag, desplegar). Computes the semantic version from the deltas of the merged changes, drafts the changelog from commits and spec decisions, creates a local tag after approval, follows the documented deployment, runs smoke checks and records the rollback target. Never pushes.
argument-hint: [opcional: versión objetivo si el usuario ya la decidió, p. ej. 0.3.0]
---

# sdd-entrega — Fase 5: Entrega

La v1 termina en el merge. Esta fase cubre lo que sigue: **qué versión sale, qué cambió, cómo se publica, cómo se comprueba y cómo se vuelve atrás.** Todo se deriva de los specs, los criterios y el historial; no se inventa.

Leer `../_shared/entrega.md` (versionado, changelog, pasos, reversión) y `../_shared/ramas-y-commits.md` §4 (qué acciones piden OK). Las rutas `../_shared/` son relativas a la carpeta de esta skill.

> **Git solo por script.** Toda escritura en git (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree) se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`, nunca con `git switch`, `git add`, `git commit`, `git merge`, `git branch` o `git tag` armados a mano. El script simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`; los subcomandos sensibles exigen `--aprobado "<cita del OK del usuario>"`. No hay comandos de remoto: nada de push, pull, PR ni `gh`. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente. Detalle en `../_shared/ramas-y-commits.md` §0.

## Paso 1 — Precondiciones

Correr `bash ../_shared/scripts/sdd-estado.sh` y `bash ../_shared/scripts/sdd-lint.sh`. Debe cumplirse **todo**; si algo falla, decirlo y detenerse:

- Se está en el **tronco**, actualizado, con el árbol de trabajo limpio.
- Hay cambios mergeados desde el último tag (`CAMBIOS_DESDE_ULTIMA_VERSION`). Si no, no hay nada que entregar.
- `sdd-lint.sh` sin errores.
- Las pruebas, el lint y los tipos **locales** del tronco, completos, en verde (corrida local; no se depende de un CI remoto).
- Ningún spec `en desarrollo` por un cambio que **sí** se mergeó (señal de un cierre incompleto).

## Paso 2 — Calcular la versión

Listar los cambios desde el último tag (`git log <tag>..HEAD`, y los trailers `SDD-Caso`, `SDD-Fase`, `SDD-Spec`). Para cada uno determinar su **delta** (AGREGADO / MODIFICADO / ELIMINADO / NULO) desde el plan o el commit de propuesta, y aplicar la tabla de `entrega.md` §4. La versión es el **mayor efecto** de los cambios. En `0.x`, un cambio MAJOR se publica como MINOR. Si no hay tag previo, proponer `0.1.0` (o la versión que el usuario indique en `$ARGUMENTS`).

Mostrar la tabla *cambio → delta → efecto* y la versión resultante. **No usar la versión sin OK.**

## Paso 3 — Changelog

Generar la entrada del release en formato *Keep a Changelog* con las secciones **Agregado / Cambiado / Corregido / Eliminado / Seguridad**, a partir de:

- Commits `feat`, `fix`, `change`, `perf`, `refactor` (con alcance = capacidad).
- Las **Decisiones** fechadas nuevas de los specs desde el último tag (`git diff <tag>..HEAD -- docs/specs/`).
- Los ajustes aprobados (`SDD-Ajuste: aprobado`) y los hotfixes.

Cada línea apunta al spec o al commit de merge. Se redacta para quien usa el sistema, no para quien lo construyó. **Mostrarla y esperar edición o OK.** No inventar entradas que no estén respaldadas en el historial.

## Paso 4 — Commit de versión y tag (con OK)

Con la versión y el changelog aprobados:

1. Actualizar el archivo de versión del proyecto (el que `docs/arquitectura.md` indique; si no lo dice, preguntar) y `CHANGELOG.md`.
2. Commit con `bash ../_shared/scripts/sdd-git.sh commit --tipo chore --capacidad release --asunto "vX.Y.Z" --fase entrega --archivos <archivo de versión> CHANGELOG.md [--atribucion "<línea del entorno>"]`, primero simulando y luego con `--ejecutar`. Es la **única** excepción a "no se commitea en el tronco". `--caso` no hace falta: el script usa `entrega`.
3. **Si el proyecto declara una rama de releases distinta del tronco de integración** (`sdd-estado.sh` muestra `RAMA_DE_RELEASES`; p. ej. `develop` → `master`): escribir el changelog aprobado en un archivo temporal y correr `sdd-git.sh merge <tronco> --destino <release> --capacidad release --asunto "vX.Y.Z" --cuerpo-archivo <changelog> --aprobado "<cita del OK>"` (simula; con `--ejecutar` tras el OK). El script solo admite el tronco de integración como origen. Después, `sdd-git.sh cambiar <tronco> --ejecutar` para volver. Sin rama de releases, el tag va sobre el tronco.
4. **Tag anotado local**: `sdd-git.sh tag vX.Y.Z --mensaje-archivo <changelog> --aprobado "<cita del OK>"` (simula) y con `--ejecutar` tras el OK. El script solo acepta SemVer, solo en el tronco o la rama de releases y no admite tags repetidos. **No se hace `git push --tags`**: publicar el tag es manual del desarrollador.

## Paso 5 — Despliegue

Seguir **solo** lo que `docs/arquitectura.md` documente en "Despliegue" (por ejemplo `docker compose up -d --build`, variables de entorno requeridas, orden de pasos).

- Si el despliegue no está documentado, **no inventarlo**: proponer documentarlo en un cambio aparte (`/sdd-arquitectura`) y dejar el release publicado hasta el tag.
- Antes de desplegar: confirmar que existe el **respaldo** de los datos persistentes y la versión de vuelta (Paso 7).
- Cada comando que modifique un entorno compartido o de producción pide OK explícito.

## Paso 6 — Humo posterior al despliegue

Correr la comprobación de salud documentada y los criterios marcados `smoke` de los specs/planes del release. Registrar el resultado (fecha, entorno, versión, pasó o falló). Si falla: **no seguir adelante**, aplicar la reversión (Paso 7) si afecta a usuarios, y abrir `/sdd-hotfix` para la causa.

## Paso 7 — Reversión

Dejar escrito en el cierre, para este release:

- La **versión de vuelta** (tag anterior).
- El comando o procedimiento para volver (por ejemplo, volver a desplegar el tag anterior).
- Qué pasa con los **datos persistentes** si el release tocó el esquema o los formatos: respaldo, migración hacia atrás o "irreversible" con su justificación.
- Los **interruptores** de configuración que apagan una función sin redeploy.

## Paso 8 — Cerrar

- Planes: si el release cierra la última fase de un plan, confirmar que está `destilado`. Hitos o issues: no se crean (el repo es solo local).
- Decir en una línea qué quedó entregado, la versión y dónde está el changelog.

## Lo que esta skill NO hace

- No publica nada: ni push, ni release en plataformas. Versión, tag local y despliegue piden OK explícito.
- No cambia specs ni código (solo versión y changelog).
- No inventa pasos de despliegue que el proyecto no tenga documentados.

## Referencias

- `../_shared/entrega.md` — versionado semántico, changelog, reversión.
- `../_shared/ramas-y-commits.md` — autorizaciones, protecciones.
- `../_shared/scripts/sdd-estado.sh`, `../_shared/scripts/sdd-lint.sh`.
