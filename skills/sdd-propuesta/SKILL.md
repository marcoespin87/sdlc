---
name: sdd-propuesta
description: Use right after sdd-exploracion confirmed the Case, or when the user asks to write, review or approve the spec, the acceptance criteria or the plan of a change. Creates the local change branch from the integration trunk, writes the spec delta and numbered criteria (CA-NN, each with a verification method), runs the spec linter, asks for the human approval gate and commits the approved spec as the fixed reference before any code is written. Not for changes whose proposal is already approved on the current branch (that is sdd-aplicacion).
argument-hint: [instrucción completa del cambio a construir; opcional si ya se dio en /sdd-exploracion]
---

# sdd-propuesta — Fase 2: Propuesta de cambio

Segunda fase del ciclo y la que concentra el gate humano principal. Convertir la Exploración confirmada + la instrucción del usuario en lo siguiente, escrito **antes de tocar código** y **dentro de una rama de cambio**:

1. **La rama del cambio**, creada desde el tronco.
2. **El delta del spec**, escrito en `docs/specs/`.
3. **Los criterios de aceptación** `CA-NN`, concretos, cada uno con su método de verificación.
4. **El plan, solo si hace falta** (regla 3.3): si el cambio tiene fases, alternativas o decisiones abiertas. Si no, el delta del spec *es* el plan y los criterios van en el cuerpo del commit de propuesta.
5. **El commit de propuesta**: una vez aprobado, el spec queda commiteado como punto fijo contra el que se construye y se verifica.

Es la regla 3.1: *leer antes de proponer, escribir antes de codificar*. No tocar código en esta fase.

Leer `../_shared/convenciones.md`, `../_shared/plantilla-spec.md`, `../_shared/ramas-y-commits.md` y `../_shared/criterios-y-pruebas.md` antes de escribir nada (y `../_shared/plantilla-plan.md` si el cambio tiene plan). Las rutas `../_shared/` son relativas a la carpeta de esta skill.

> **Git solo por script.** Toda escritura en git (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree) se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`, nunca con `git switch`, `git add`, `git commit`, `git merge`, `git branch` o `git tag` armados a mano. El script simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`; los subcomandos sensibles exigen `--aprobado "<cita del OK del usuario>"`. No hay comandos de remoto: nada de push, pull, PR ni `gh`. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente. Detalle en `../_shared/ramas-y-commits.md` §0.

## Paso 0 — Estado de git y rama del cambio

1. Correr `bash ../_shared/scripts/sdd-estado.sh` y leer el resultado.
2. **Si ya hay una rama de cambio con trailer `SDD-Fase: propuesta` sobre esta capacidad**, no crear otra: es una propuesta en curso. Retomarla (¿falta aprobar el gate? ¿se están pidiendo cambios?).
3. **Si el árbol de trabajo tiene cambios ajenos** al cambio, detenerse: llevarlos a su propia rama o guardarlos antes de seguir. No mezclar.
4. **Si se está en el tronco**, proponer la rama según `ramas-y-commits.md` §2 (`<tipo>/<capacidad>-<slug>`, tipo según el Caso) y **esperar el OK del usuario**. Luego `bash ../_shared/scripts/sdd-git.sh crear-rama <tipo> <capacidad> <slug>` (simula), mostrar el resultado y repetir con `--ejecutar`. El script parte del tronco de integración y rechaza un árbol sucio.
5. Pedir **una sola autorización** para este cambio: *"¿puedo hacer commits locales en esta rama mientras dure el cambio?"* (`ramas-y-commits.md` §4). El merge, el borrado de ramas y los tags se piden aparte, cada vez. Nada se hace contra remotos.
6. Sin repositorio git: decirlo y pedir al usuario que ejecute él `git init` (el agente no lo hace); no seguir sin él: el estado del ciclo vive en git. Las skills trabajan solo con el repositorio local; los remotos, si existen, se ignoran.

## Paso 1 — Recuperar o re-derivar el Caso

Si en esta misma conversación ya corrió `/sdd-exploracion`, usar el Caso, delta tentativo, invariantes, specs relacionadas y dependencias por evaluar que dejó. Si esta es una sesión nueva sin ese contexto:

1. Leer el estado de git del Paso 0: los trailers `SDD-Caso` de los commits de la rama.
2. Buscar el spec `en desarrollo` más reciente en `docs/specs/`, o el plan sin destilar más reciente en `docs/`.
3. Si no hay nada claro, **no adivinar el Caso** — decirle al usuario que falta la Exploración y ofrecer correr `/sdd-exploracion` primero, o pedirle que confirme el Caso directamente.

**Caso 5:** si la Fase 0 de la capacidad todavía no terminó (spec candidato en `en desarrollo` sin revisión humana cerrada), no seguir: la Fase 0 se cierra primero en `/sdd-exploracion`. Si la revisión terminó pero quedan **fixes colaterales** pendientes (spec `en desarrollo`), el único cambio que entra es uno de esos fixes (Caso 3); el resto espera a que el spec quede `desplegado`. Una vez `desplegado`, este cambio entra como Caso 2 o Caso 3.

**Cambio de arquitectura:** si lo pedido modifica la forma transversal del sistema, no es esta skill: ir a `/sdd-arquitectura`.

## Paso 2 — Reunir la instrucción completa

`$ARGUMENTS` (o lo que el usuario aporte en el chat) debe describir **qué construir o cambiar**, no solo la idea general que ya dio en Exploración. Si faltan detalles necesarios (mockups, stack a usar, nombres, prioridades), preguntarlos ahora — no en `/sdd-aplicacion`.

## Paso 3 — Cargar la rama del Caso

Ir a `references/caso1.md`, `caso2.md`, `caso3.md` o `caso4.md` según el Caso confirmado en el Paso 1. (El Caso 5, una vez que su Fase 0 terminó, entra acá como Caso 2 o Caso 3 — no existe `references/caso5.md`.) Cada archivo dice qué delta del spec escribir, qué criterios corresponden (y qué contiene el plan, si lo hay) para ese Caso, y qué preguntas abiertas son típicas de él.

## Paso 4 — Resolver decisiones abiertas con el usuario

Antes de escribir nada definitivo, preguntar explícitamente cualquier decisión que le corresponda a un humano: stack (si no está fijado), nombres, alcance, prioridades entre alternativas, **qué pasa en los casos borde** (qué se hace cuando algo choca, falla o excede un tope).

- **Las dependencias o riesgos "por evaluar"** que dejó la Exploración son decisiones abiertas como cualquier otra. Se registran como decisiones abiertas — en *Pendientes de decisión* del plan, o en el chat si no hay plan — y **bloquean el gate** del Paso 9 mientras no se resuelvan.
- **Un conflicto con un invariante de otra spec** detiene la Propuesta: o se rediseña el cambio, o la otra spec cambia en este mismo cambio (o en uno previo), con decisión fechada en las dos.
- No decidir estas cosas por el usuario ni dejarlas como "TBD". **La respuesta de cada decisión que afecta comportamiento se escribe en el spec** (en *Límites y defaults*, *Modos de falla*, *Invariantes* o *Fuera de alcance*), no solo en el plan ni solo en el chat.
- **Reversión** (v2): si el cambio toca datos persistentes o es difícil de deshacer, preguntar ahora cómo se revierte (`entrega.md` §5). La respuesta va a los criterios y a el cuerpo del commit de propuesta.

## Paso 5 — Escribir el delta del spec

Escribir el delta directamente en `docs/specs/spec-<capacidad>.md`, siguiendo `plantilla-spec.md` y la tabla de la regla 3.2 que está al final de ese archivo para decidir qué secciones tocar:

- **Comportamiento:** la sección nueva o la porción reemplazada, organizada en las sub-secciones que apliquen (*Alcance*, *Contrato*, *Flujo*, *Límites y defaults*, *Modos de falla*, *Arquitectura propia*).
- **Invariantes**, **Fuera de alcance**, **Decisiones** (fechada, con porqué) y **Referencias**, incluidas las dependencias confirmadas ("Depende de / Usada por"), recíprocas en la otra spec.
- **Spec que nace** (Caso 1, o capacidad nueva en Caso 2): crearlo completo con `Estado: en desarrollo` y agregar su fila en `docs/specs/README.md`.
- **Cambio sin delta de comportamiento** (regla 3.2): escribir **solo** la entrada de *Decisiones* y las *Referencias*. *Comportamiento* queda intacto, palabra por palabra. El criterio de paridad va con los criterios de aceptación (Paso 6).
- **No tocar** las secciones del spec que describen lo que no cambia.
- **Revisar las cuatro secciones que acotan al agente** (*Invariantes*, *Límites y defaults*, *Modos de falla*, *Fuera de alcance*): si el cambio agrega comportamiento y el delta no dice nada en ninguna de ellas, casi seguro está incompleto.
- **No escribir estados transitorios** en el spec ("implementación a medias", "todavía sin endpoint"): eso va en el plan o en el mensaje del commit.

**Si hay una división de spec aprobada** (extensión de las skills, ver `../_shared/verificacion-division.md`): aplicarla **antes** de escribir el delta, en un commit propio (`sdd-git.sh commit --tipo spec --capacidad <cap> --asunto "dividir …" --fase propuesta`) que no toca código ni contiene el delta.

## Paso 6 — Criterios de aceptación y plan (regla de proporción)

**Criterios de aceptación, siempre:** con identificador `CA-NN`, condición observable y **método de verificación** (automática con la ruta prevista de la prueba, medición con umbral, o manual con pasos) — formato y tipos que casi siempre faltan en `../_shared/criterios-y-pruebas.md` §1. Nunca "funciona bien". Son los que `/sdd-verificacion` va a usar después; si quedan vagos acá, la verificación no tiene con qué trabajar.

**Cobertura del spec:** comprobar que **cada ítem nuevo de *Contrato*, *Límites y defaults* y *Modos de falla*** tiene al menos un criterio, y cada invariante nuevo, uno que intenta violarlo. Un ítem sin criterio es un hueco: agregarlo ahora.

Van **en el plan si hay plan; si no, en el cuerpo del commit de propuesta** (`plantilla-reporte.md`).

**¿Hace falta plan?** Crear `docs/plan-<tema>-<fecha>.md` (fecha de hoy) **solo** si el cambio tiene **fases, alternativas o decisiones abiertas** (regla 3.3). Si no tiene ninguna, no crear plan: el diff del spec más los criterios es la propuesta, y el enfoque técnico, si hace falta explicarlo, va con los criterios en el cuerpo del commit de propuesta.

Si hay plan, seguir `plantilla-plan.md` al pie de la letra. El plan incluye:

- **Caso** y **Delta** explícitos (AGREGADO / MODIFICADO / ELIMINADO / NULO / 100%).
- **Delta del spec escrito:** qué spec y qué secciones se escribieron en el Paso 5, **referenciado, no copiado**.
- **Mapa de ramas** (una rama por fase; ver `/sdd-ramas`).
- **Tareas de código**, cada una con los `CA-NN` que cubre. Escribir el spec no es una tarea: ya está hecho.
- **Criterios de aceptación** `CA-NN` y la tabla de **Trazabilidad** (la completa `/sdd-verificacion`).
- **Pendientes de decisión**: vacío para poder aprobar.
- Si el cambio es grande, fases dentro del mismo plan (regla 3.3) — cada fase sigue siendo un cambio acotado, con su rama, que se aplica y verifica por separado.

**Si el cambio es una fase de un plan padre que ya existe** (plan `en desarrollo` con fases pendientes): **no crear otro plan**. Usar ese, decir qué fase se propone, escribir el delta del spec de esa fase y tomar sus criterios del plan (ajustándolos ahí si hace falta, dentro del mismo gate). La rama de la fase es la que figura en su *Mapa de ramas*.

Si no hay plan, dejar igual explícitos en la respuesta, para el gate: **Caso**, **Delta**, qué se escribió en el spec y los **criterios de aceptación**.

## Paso 7 — Verificación de división sobre el spec con el delta escrito

Extensión de las skills (no está en la metodología v4). Correr `../_shared/verificacion-division.md` sobre el spec **tal como quedó con el delta escrito**. Los disparadores de tamaño y de subcapacidades los mide `bash ../_shared/scripts/sdd-lint.sh` (Paso 8); los cinco criterios los evalúa el agente.

- Si `/sdd-exploracion` ya recomendó una división y el usuario la aprobó, ya se aplicó en el Paso 5, antes del delta.
- Si el usuario la negó, dejar la decisión fechada en `Decisiones` del spec, como parte del delta.
- Si el delta activa un disparador que antes no estaba, evaluar los cinco criterios y **recomendar**, preguntándole al usuario antes del gate. Si aprueba, aplicar la división y reescribir el delta sobre el spec dividido.
- Si no se recomienda dividir, reportarlo en una línea y **no registrar nada en el spec**.

## Paso 8 — Lint determinista

Correr `bash ../_shared/scripts/sdd-lint.sh` desde la raíz del proyecto. **Cero errores** para presentar el gate: formato de la línea de Estado, secciones y orden, invariantes con su porqué, decisiones con fecha, índice coherente, nombre del plan. Los AVISO se leen y se comentan, no bloquean. Corregir antes de pedir la aprobación: es trabajo mecánico que no debe consumir la atención del revisor.

## Paso 9 — Gate: aprobación humana del diff del spec (+ plan, si existe)

Este es el **gate humano principal del ciclo**. Mostrar:

1. **El diff del spec** (`git diff docs/specs/`, o el texto completo si el spec nació en esta fase).
2. Los criterios de aceptación `CA-NN`. Si hay plan, el plan completo o un resumen fiel de sus puntos clave: delta, mapa de ramas, criterios, decisiones tomadas.
3. El resultado del Paso 7 y del Paso 8.
4. La rama propuesta o creada, y el plan de reversión si aplica.

Pedir **aprobación explícita**, con esta consigna para quien revisa: *"mira el diff del spec y dime si describe lo que queremos construir"*. No avanzar a `/sdd-aplicacion` sin ese OK — no asumirlo por silencio ni por un cambio de tema. Mientras haya decisiones abiertas (en el plan o en el chat), no se puede aprobar.

**Si el revisor pide cambios**, se corrigen en el spec (y en el plan, si existe), se vuelve a correr el lint y se vuelve a mostrar el diff. Es el momento más barato para corregir: todavía no hay código escrito.

## Paso 10 — Commit de propuesta (solo tras el OK del gate)

Con el OK del Paso 9 y la autorización de commits locales del Paso 0:

1. Verificar con `git status` que solo están los archivos de la propuesta: specs, índice, plan, arquitectura si nacieron. **Ningún código** (el script lo rechaza: un commit de propuesta solo admite rutas bajo `docs/`).
2. Commit `spec(<capacidad>): <delta en imperativo>` con los trailers `SDD-Caso`, `SDD-Fase: propuesta`, `SDD-Spec`, `SDD-Plan` (si hay) y `SDD-CA` (la lista de criterios), más las líneas de atribución que indique el entorno. Formato en `../_shared/ramas-y-commits.md` §3.
3. Ese commit es el **punto fijo** del spec aprobado. Todo ajuste posterior del spec es un commit distinto, con OK explícito (`/sdd-aplicacion` Paso 4).
4. **Nada de push ni de PR**: el repo es solo local. El registro del cambio es el historial: el commit de propuesta lleva los criterios `CA-NN` en su cuerpo y el reporte de verificación irá en el commit de merge.

## Cerrar la fase

Confirmar que el delta quedó commiteado en la rama, el hash del commit de propuesta y dónde quedaron los criterios (plan o cuerpo del commit de propuesta). **Con el gate aprobado y el commit hecho, la siguiente skill (`sdd-aplicacion`) se invoca sola**, salvo que el usuario pida detenerse: construirá **acotada por ese spec**, pruebas primero, sin reescribirlo.

## Referencias

- `../_shared/convenciones.md` — regla 3.1, dependencias entre specs, planes, ramas.
- `../_shared/plantilla-spec.md` — formato del spec, sub-secciones, regla 3.2.
- `../_shared/plantilla-plan.md` — solo si el cambio tiene plan.
- `../_shared/ramas-y-commits.md` — rama, commits, trailers, autorizaciones.
- `../_shared/criterios-y-pruebas.md` — criterios `CA-NN`, tipos que faltan, cobertura.
- `../_shared/plantilla-reporte.md` — cuerpo del commit de propuesta.
- `../_shared/verificacion-division.md` — extensión de las skills (Paso 7).
- `../_shared/scripts/sdd-lint.sh`, `../_shared/scripts/sdd-estado.sh`.
- `references/caso1.md` — desde cero
- `references/caso2.md` — funcionalidad nueva
- `references/caso3.md` — modificación de un requerimiento existente
- `references/caso4.md` — migración de lenguaje
