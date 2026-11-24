# Convenciones de archivos — SDD Spec-Anchored (v2: ciclo de vida completo)

Rutas, nombres y reglas que las skills (`sdd-exploracion`, `sdd-propuesta`, `sdd-aplicacion`, `sdd-verificacion`, y las de ciclo de vida `sdd-estado`, `sdd-ramas`, `sdd-entrega`, `sdd-hotfix`, `sdd-arquitectura`) deben usar siempre, en cualquier proyecto.

**Qué agrega la v2 sobre la v1** (el resto de este archivo es igual, salvo donde se indica): ramas y commits con trailers (`ramas-y-commits.md`), criterios `CA-NN` con pruebas primero y matriz de trazabilidad (`criterios-y-pruebas.md`), definición de terminado, seguridad, entrega y reversión (`entrega.md`), plantilla del reporte de merge (`plantilla-reporte.md`), mapa del ciclo (`ciclo-de-vida.md`), guardarraíles (`hooks-ejemplo.md`) y scripts deterministas (`scripts/sdd-lint.sh`, `scripts/sdd-estado.sh`). Base: `metodologia-sdd-spec-anchored_v4.md`. No inventar variantes por proyecto: si un proyecto ya tiene una convención distinta y establecida (por ejemplo `docs/design/` en vez de `docs/specs/`), respetarla y no forzar la migración a mitad de un cambio — pero si el proyecto no tiene nada todavía, usar exactamente lo de abajo.

## Regla 3.1 — Specs primero: leer antes de proponer, escribir antes de codificar

1. **Leer antes de proponer.** Al iniciar cualquier cambio, leer el spec de la capacidad afectada **y los relacionados** (ver "Dependencias entre specs") antes de proponer nada.
2. **Escribir antes de codificar.** El delta del spec se escribe en `/sdd-propuesta` y se aprueba **antes** de escribir código. Ese delta es la instrucción acotada del agente que construye: *Invariantes*, *Límites y defaults*, *Modos de falla* y *Fuera de alcance* son los límites que de otro modo habría que repetir en cada prompt.
3. **Si al construir aparece algo que el spec no previó,** detenerse, proponer el ajuste del spec, pedir OK y recién entonces seguir. No se codifica alrededor del spec.
4. **Un cambio sin delta de comportamiento** (regla 3.2) no es excepción: ahí "spec primero" es escribir primero la entrada de *Decisiones*, las *Referencias* y el criterio de paridad.

**Excepciones, solo dos:**

- **Fase 0 del Caso 5:** el código existe primero por definición.
- **Spike descartable:** código para averiguar si algo es posible. No se mergea; lo que sobreviva entra por el ciclo normal.

**AS-BUILT y spec primero, sin contradicción.** En `main` el spec describe lo que corre. En una rama describe el **objetivo del cambio**, escrito antes que el código; el merge es lo que lo vuelve AS-BUILT. Si lo construido quedó por debajo del delta, `/sdd-verificacion` **recorta el spec** antes de cerrar: nunca llega a `main` texto de algo que no existe.

## Specs

- Un spec por capacidad, nunca un spec central único.
- Ruta: `docs/specs/spec-<capacidad>.md`, con `<capacidad>` en kebab-case (ej. `spec-autenticacion.md`, `spec-carrito-compras.md`).
- **Criterio de tamaño de una capacidad** (regla de estas skills; la v4 no fija uno): si dos comportamientos casi siempre cambian juntos y comparten los mismos invariantes, van en el mismo spec; si pueden evolucionar por separado, van en specs separados. Si el proyecto ya tiene un spec que cubre varios comportamientos relacionados, no partirlo en specs sueltos a mitad de camino sin que sea una decisión explícita — eso rompe la trazabilidad.
- Formato fijo: ver `plantilla-spec.md` en esta misma carpeta. No te apartes del formato, ni siquiera para "simplificar".
- Índice: `docs/specs/README.md`, con una tabla `Capacidad → Spec` (v4) más la columna *Spec padre* (extensión de las skills, ver "Specs hijos"). Se actualiza en `/sdd-propuesta` cada vez que nace un spec nuevo (Caso 1, Caso 2), en la Fase 0 (Caso 5), y cada vez que se divide uno.
- **Quién escribe el spec:** `/sdd-propuesta` (el delta, antes del código), la Fase 0 de `/sdd-exploracion` (Caso 5), `/sdd-aplicacion` **solo** para un ajuste por descubrimiento con OK explícito, y `/sdd-verificacion` **solo** para recortar lo que no se construyó.

### Specs hijos (una subcapacidad con spec propio)

> **Extensión de las skills.** La división de specs no forma parte de la metodología v4: es una regla adicional que estas skills aplican. Todo lo de esta sub-sección y `verificacion-division.md` se lee con esa aclaración.

- Ruta: la misma carpeta plana, con el prefijo del padre — `docs/specs/spec-<padre>-<subcapacidad>.md` (ej. `spec-reservas-recurrentes.md`). **No se usan carpetas por dominio.**
- La relación se escribe en **cuatro lugares, todos obligatorios**: el nombre del archivo, la columna *Spec padre* del índice, `Referencias` de ambos specs (diciendo **por qué** se relacionan) y una `Decisión` fechada en ambos.
- **Un solo nivel:** un hijo no tiene hijos. Si un hijo necesita dividirse, la parte nueva queda como hermana del mismo padre.
- Cuándo nace un hijo, con qué criterios y en qué fase se recomienda: `verificacion-division.md` en esta misma carpeta. **El agente recomienda; el usuario aprueba o niega** — nunca se divide un spec por iniciativa propia.
- Una división aprobada se aplica en `/sdd-propuesta`, que es la fase que escribe specs, en un commit propio que no toca código.

## Dependencias entre specs

Al escribir el delta del spec, leer el índice y declarar qué otras capacidades toca el cambio o de cuáles depende. Regla corta: **el spec registra dependencias resueltas y sus efectos; el plan (o el chat, si no hay plan) registra las que están por resolver; *Decisiones* registra cómo se resolvieron cuando condicionaron el diseño.**

| Lo que se encontró | Dónde va |
|---|---|
| Dependencia confirmada y estable (consume o es consumida por otra capacidad) | *Referencias*: `Depende de: spec-X (§Contrato)` / `Usada por: spec-Y`. Recíproco en la otra spec |
| Consecuencia observable de esa dependencia (si X cae esto falla en abierto; hereda el timeout de X) | *Modos de falla* o *Límites y defaults* de esta capacidad |
| Dependencia o riesgo por evaluar | Decisión abierta: en *Pendientes de decisión* del plan, o en el chat si no hay plan. **Bloquea el gate de `/sdd-propuesta`**. El spec nunca guarda "por evaluar" |
| Riesgo resuelto que condicionó el diseño | *Decisiones*, fechada, con porqué. Si se evaporó sin condicionar nada, no deja rastro |
| Conflicto con un invariante de otra spec | Se detiene la Propuesta: se rediseña el cambio, o la otra spec cambia en el mismo cambio (o en uno previo). Decisión fechada en las dos |
| Algo que esta capacidad no cubre porque lo hace otra | *Fuera de alcance*, con el puntero a la otra spec |

## Planes — regla de proporción (regla 3.3)

- **El plan existe solo si el cambio lo necesita:** se crea si el cambio tiene **fases, alternativas o decisiones abiertas**. Si no tiene ninguna, no se crea: el delta del spec *es* el plan, y el diff del spec más los criterios de aceptación es la propuesta. *"Si documentar el cambio toma más que hacerlo, sobra documento, no cambio."*
- **Criterios de aceptación, siempre**, concretos y verificables (regla 3.4), escritos antes del código, **con identificador `CA-NN` y método de verificación** (ver `criterios-y-pruebas.md`): **en el plan si hay plan; si no, en el cuerpo del commit de propuesta** (`plantilla-reporte.md`). El reporte de `/sdd-verificacion` va en el mensaje del commit de merge; no hay pull request (el repo es solo local).
- Un cambio chico queda en: leer el spec → crear la rama → escribir el delta → aprobar y commitear el delta → pruebas en rojo → código → verificar → mergear. Dos artefactos (spec y reporte de merge), un gate humano antes de codificar y otro al mergear.

Cuando hay plan:

- Uno por cambio (o uno por familia de cambios en fases, con un plan padre).
- Ruta: `docs/plan-<tema>-<fecha>.md`, con `<tema>` en kebab-case y `<fecha>` en formato `YYYY-MM-DD` (la fecha en que nace el plan, no se actualiza si el plan se retoca después).
- El plan **no duplica el delta del spec**: lo referencia. El delta está escrito en `docs/specs/`, y el plan dice qué sección se escribió o reemplazó.
- El plan es transitorio: no se archiva, se **destila**. Como el delta del spec ya se escribió en Propuesta, destilar en `/sdd-verificacion` significa confirmar que el spec describe exactamente lo construido (recortando lo que no se hizo) y marcar el plan `destilado`. En un plan con fases, cada fase alimenta el spec en su propio cambio (su rama y su merge) y el plan pasa a `destilado` recién al cerrar la última.
- Formato: ver `plantilla-plan.md` en esta misma carpeta.

## Documento de arquitectura y convenciones

- Es **un solo documento por proyecto** (más uno por subproyecto si es un monorepo con varios subproyectos independientes) — nunca dos documentos con el mismo contenido.
- Si el proyecto ya tiene un archivo de contexto **con contenido de arquitectura** que la herramienta de IA carga sola al iniciar sesión (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, o instrucciones de proyecto equivalentes), ESE archivo es el documento de arquitectura — completarlo ahí, no crear `docs/arquitectura.md` aparte.
- **Un archivo de contexto generado por una herramienta, sin contenido de arquitectura, no cuenta como documento de arquitectura.** Ejemplo real: Next.js 16 escribe `AGENTS.md` y `CLAUDE.md` solo, con un aviso sobre su propia versión, y los reescribe en cada `next dev`. En ese caso crear `docs/arquitectura.md` y agregar al archivo de contexto una línea que enlace a él, sin borrar lo que escribió la herramienta.
- Si el proyecto no tiene ninguno de esos archivos, crear `docs/arquitectura.md` y, si la herramienta usada sí soporta un archivo de contexto propio, hacer que ese archivo solo enlace a `docs/arquitectura.md` en vez de duplicar el contenido.
- Contenido mínimo: patrón arquitectónico, límites entre servicios/módulos, invariantes transversales (concurrencia, seguridad, portabilidad del entorno), restricciones del entorno, comandos útiles (cómo correr, testear, lintear, buildear y medir), **flujo de trabajo** (nombre del tronco, convención de ramas y commits, estrategia de merge, protecciones del repo — `ramas-y-commits.md`), **despliegue y reversión** (cómo se publica, cómo se vuelve atrás — `entrega.md`) e **ADRs** (`docs/adr/`). Incluir la instrucción de la regla 3.1 ("leer el spec antes de proponer, escribir el delta del spec antes de codificar"), para que se aplique en cada sesión sin depender de que alguien la recuerde.
- Se crea en `/sdd-propuesta` de un Caso 1 (antes del código), o en la Fase 0 de un Caso 5. Después, solo se actualiza mediante un **cambio dedicado a arquitectura**: la skill `/sdd-arquitectura` (rama `arq/`, ADR numerado en `docs/adr/`) — nunca como efecto lateral de un cambio funcional. En la v1 este cambio no tenía skill; en la v2 sí.

## Ramas, commits y estado (v2)

- **Un cambio = una rama** (`<tipo>/<capacidad>-<slug>`), creada desde el tronco al inicio de `/sdd-propuesta`. El tronco no recibe commits directos. Detalle, nombres, commits, trailers y merge: `ramas-y-commits.md`.
- **El delta del spec aprobado se commitea** (en la rama de cambio) apenas se aprueba el gate de `/sdd-propuesta`: es el punto fijo contra el que se verifica y la prueba de que "el spec fue primero". Esto reemplaza la regla de la v1 de dejarlo sin commitear hasta el cierre.
- **El estado del ciclo vive en git** (rama + trailers `SDD-*` + tags), no en la conversación: `scripts/sdd-estado.sh`.
- El tronco se lee del repositorio local (`git config sdd.tronco`, `docs/arquitectura.md` o la primera rama local conocida entre `develop`, `main`, `master`); nunca se asume. Las skills trabajan solo con el repositorio local: sin push, pull ni remotos.

## Regla de precedencia

Cuando dos documentos se contradicen: `spec` > documento de arquitectura > memoria de sesión, apuntes o docs históricos sueltos.
