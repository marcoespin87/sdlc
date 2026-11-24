---
name: sdd-aplicacion
description: Use when the current local change branch has an approved spec commit (trailer SDD-Fase: propuesta) and code must be written: right after the proposal gate is approved, or when the user says implementar, construir, codificar or seguir con el cambio. Builds test-first (failing test, then code) in small commits bounded by the spec; stops and asks if the code discovers something the spec did not foresee. Refuses to run on the integration trunk or without an approved spec.
argument-hint: [opcional: ruta al plan si hay más de uno sin aplicar]
---

# sdd-aplicacion — Fase 3: Aplicación del cambio

Tercera fase del ciclo. Construir el cambio **guiado por el spec que ya se escribió, se aprobó y se commiteó en `/sdd-propuesta`**. El spec no es algo que esta fase produce: es la instrucción que esta fase recibe.

Regla 3.1: *escribir antes de codificar*. El delta del spec ya existe; acá se codifica dentro de sus límites. **Esta fase no reescribe el spec**, salvo un ajuste por descubrimiento que el usuario aprueba explícitamente (Paso 4).

Leer `../_shared/convenciones.md`, `../_shared/plantilla-spec.md`, `../_shared/ramas-y-commits.md` y `../_shared/criterios-y-pruebas.md` antes de tocar nada. Las rutas `../_shared/` son relativas a la carpeta de esta skill.

> **Git solo por script.** Toda escritura en git (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree) se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`, nunca con `git switch`, `git add`, `git commit`, `git merge`, `git branch` o `git tag` armados a mano. El script simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`; los subcomandos sensibles exigen `--aprobado "<cita del OK del usuario>"`. No hay comandos de remoto: nada de push, pull, PR ni `gh`. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente. Detalle en `../_shared/ramas-y-commits.md` §0.

## Paso 1 — Ubicar rama, spec aprobado, criterios y plan

1. Correr `bash ../_shared/scripts/sdd-estado.sh`. **Debe haber una rama de cambio con un commit de propuesta** (trailer `SDD-Fase: propuesta`). Si estás en el tronco, o la rama no tiene ese commit, **detenerse**: la Propuesta no terminó; volver a `/sdd-propuesta`. No se codifica en el tronco ni sobre un spec sin aprobar.
2. **El plan**, si lo hay: la ruta de `$ARGUMENTS`, o el `docs/plan-*.md` más reciente con `Estado: en desarrollo`. Si hay más de uno, preguntar cuál. Si tiene fases, construir **solo la fase de esta rama** (la del *Mapa de ramas*); si no queda claro cuál es, preguntar.
3. **El delta del spec**: las secciones que nombra "Delta del spec escrito" del plan, o, sin plan, el contenido del commit de propuesta (`git show <hash>`).
4. **Los criterios `CA-NN`**: en el plan si lo hay; si no, en el cuerpo del commit de propuesta o en la conversación. En una sesión nueva sin plan, pedírselos al usuario — no construir contra criterios inventados.
5. Confirmar que el **árbol de trabajo está limpio** (o que lo sucio es de este mismo cambio). Si hay cambios ajenos, detenerse.
6. Confirmar que existe la **autorización de commits locales** (Paso 0 de `/sdd-propuesta`); si la sesión es nueva, volver a pedirla una vez.

## Paso 2 — Cargar la rama del Caso

El plan (o el trailer `SDD-Caso` del commit de propuesta) indica el Caso. Ir a `references/caso1.md`, `caso2.md`, `caso3.md` o `caso4.md` según corresponda (Caso 5 ya resuelto en `/sdd-exploracion` entra como Caso 2 o Caso 3 acá también).

## Paso 3 — Leer el spec como instrucción acotada y construir, pruebas primero

Antes de escribir código, leer del spec de la capacidad las **cuatro secciones que acotan al agente**:

- **Invariantes:** lo que el código nunca puede violar.
- **Límites y defaults:** topes, valores por defecto y qué pasa al excederlos.
- **Modos de falla:** cómo tiene que comportarse el código cuando algo falla.
- **Fuera de alcance:** lo que **no** hay que construir, aunque parezca natural agregarlo.

Después, **por cada tarea del plan** (o por unidad coherente de trabajo, sin plan):

1. **Prueba primero.** Escribir la(s) prueba(s) de los `CA-NN` que cubre la tarea, con el identificador en el nombre o en un marcador (`criterios-y-pruebas.md` §2). Correrlas y **ver que fallan por la razón correcta**. Commit con `bash ../_shared/scripts/sdd-git.sh commit --tipo test --capacidad <cap> --asunto "…" --fase aplicacion --caso <n> --ca "CA-01" --archivos <pruebas> --ejecutar` (el script rechaza este commit si la rama no tiene el commit de propuesta).
2. **Código mínimo** para que pasen. Commit con `sdd-git.sh commit --tipo feat|fix|refactor --capacidad <cap> --asunto "…" --fase aplicacion --caso <n> --ca "…" --archivos <archivos de la tarea> --ejecutar`. Se listan solo los archivos de esta tarea; el script nunca commitea "todo".
3. **Refactorizar** con las pruebas en verde, si hace falta, en commit aparte.
4. Marcar la tarea como hecha en el plan.

Commits pequeños, que compilen y pasen lo que antes pasaba. Mientras se construye:

- Reusar código y patrones existentes del proyecto en vez de reinventar — mirar cómo están hechas capacidades vecinas antes de escribir algo nuevo.
- El contrato, los topes y las respuestas de error tienen que coincidir **exactamente** con lo que dice el spec: mismos códigos, mismos límites, mismo comportamiento ante fallas. El spec es la referencia, no una sugerencia.
- No construir nada que el spec no describa. Si parece útil agregar algo, es un cambio aparte (otra rama).
- No tocar archivos fuera del alcance del cambio. Un archivo ajeno que "hay que arreglar de paso" es otro cambio.
- Excepciones a "pruebas primero": configuración, plantillas, documentación y spikes descartables. Decirlo en el commit.

## Paso 4 — Si el código descubre algo que el spec no previó

Pasa: un caso borde que nadie contempló, un límite que no se puede cumplir, una dependencia que no estaba declarada, una contradicción entre dos secciones del spec.

**Detenerse. No codificar alrededor del spec.**

1. Explicar al usuario qué se descubrió y por qué el spec no alcanza.
2. Proponer el ajuste concreto del spec: qué sección y con qué texto.
3. **Pedir OK explícito.** Sin ese OK, no se toca el spec y no se sigue construyendo esa parte.
4. Con el OK: aplicar el ajuste al spec **en su propio commit**: `sdd-git.sh commit --tipo spec --capacidad <cap> --asunto "ajuste: …" --fase aplicacion --caso <n> --ajuste --aprobado "<cita del OK del usuario>" --archivos <spec> --ejecutar` (deja `SDD-Ajuste: aprobado` y registra la aprobación). Registrarlo además en "Ajustes durante la construcción" del plan si lo hay (qué se descubrió, qué se ajustó, quién lo aprobó). Recién entonces seguir construyendo.

Si el ajuste cambia algo sustancial del cambio (el delta, un invariante, los criterios de aceptación), no es un ajuste: es volver a `/sdd-propuesta` con un nuevo commit de propuesta.

**Nunca reescribir el spec en silencio para que coincida con lo que se construyó.** Es exactamente el error que la regla "spec primero" existe para evitar. El commit separado hace que el ajuste sea visible en el historial.

## Paso 5 — Verificación de división, solo si hubo ajuste

Extensión de las skills (no está en la metodología v4). Solo si en el Paso 4 se ajustó el spec: correr `../_shared/verificacion-division.md` sobre el spec ajustado.

**Esta fase nunca divide specs**, ni siquiera con aprobación: la división se aplica en `/sdd-propuesta`, que es la fase que escribe specs. Si se activa un disparador, terminar el cambio como estaba planeado y **avisarlo en el cierre** para que se evalúe en la próxima Exploración.

## Paso 6 — Gate: pruebas, lint y spec en verde

Correr lo que el proyecto use (buscarlo en `docs/arquitectura.md` bajo "Comandos útiles", o en `package.json`, `Makefile`, `pyproject.toml`): formato/lint, tipos, pruebas del módulo tocado **y de sus dependientes**, y `bash ../_shared/scripts/sdd-lint.sh`. No dar la fase por terminada si algo falla.

- Si el proyecto no tiene alguno de estos comandos todavía, decirlo explícitamente y proponer crearlo como tarea (no omitirlo en silencio).
- **Todos los `CA-NN` automáticos** deben tener ya una prueba pasando. Los manuales y de medición se ejecutan en `/sdd-verificacion`.
- Si hay plan, marcar como hechas las tareas completadas.

## Cerrar la fase

Mostrar al usuario un resumen de:

- Qué se construyó y los commits de la rama (`git log <tronco>..HEAD --oneline`).
- **Si el spec se tocó o no.** Lo normal es "el spec no se tocó en esta fase". Si hubo ajustes por descubrimiento, listarlos con su aprobación y su commit.
- La cobertura de criterios: qué `CA-NN` ya tienen prueba pasando y cuáles quedan para la verificación.
- El resultado de la verificación de división, si corrió.
- El resultado de las pruebas, el lint y `sdd-lint.sh`.

Indicar que el siguiente paso es la verificación (se encadena sola, ver `../_shared/ciclo-de-vida.md`). **No mergear al tronco**: el merge pide OK aparte (`ramas-y-commits.md` §4). **Nada se hace contra remotos**: publicar es manual del desarrollador.

## Referencias

- `../_shared/convenciones.md` — regla 3.1 y quién escribe el spec.
- `../_shared/plantilla-spec.md` — secciones que acotan al agente.
- `../_shared/ramas-y-commits.md` — commits, trailers, autorizaciones.
- `../_shared/criterios-y-pruebas.md` — pruebas primero, marcado de `CA-NN`, gates.
- `../_shared/verificacion-division.md` — extensión de las skills (Paso 5).
- `../_shared/scripts/sdd-estado.sh`, `../_shared/scripts/sdd-lint.sh`.
- `references/caso1.md`
- `references/caso2.md`
- `references/caso3.md`
- `references/caso4.md`
