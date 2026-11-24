# Plantilla del spec — formato fijo (sección 2 de la metodología v4)

Copiar esta estructura literal para cada `docs/specs/spec-<capacidad>.md`. No agregar ni quitar secciones de primer nivel (`##`), no reordenarlas.

```markdown
# Spec: <Nombre de la capacidad>

**Estado:** desplegado | parcial | en desarrollo · **Última revisión:** YYYY-MM-DD

## Propósito
<Qué problema resuelve y para quién (2-5 líneas).>

## Comportamiento
<Convención de estas skills (la v4 no la pide): si el spec supera las 100 líneas, empezar con una línea que liste sus
subcapacidades — "Subcapacidades: Reservar · Listar por día · Cancelar" — y
recién después el detalle. No es una sección nueva: es la primera línea de
esta misma sección.>

### Alcance
<Qué cubre, quién lo usa (roles), en qué modos/ambientes aplica.>

### Contrato
<Endpoints / eventos / comandos / pantallas en su forma OBSERVABLE: método,
ruta, quién lo puede invocar, código de respuesta, campos de entrada y salida
con su significado. La forma exacta (tipos, JSON Schema) va en Referencias.>

### Flujo
<Qué pasa, en qué orden, qué dispara qué, estados.>

### Límites y defaults
<Topes, timeouts, presupuestos, valores por defecto y qué pasa al excederlos.>

### Modos de falla
<Fail-open / fail-closed, reintentos, qué ve el usuario cuando algo falla.>

### Arquitectura propia
<(Opcional) Solo lo específico de ESTA capacidad. Lo transversal va en el
documento de arquitectura.>

## Invariantes (no negociables)
- **<Nombre del invariante>:** <qué no puede pasar>. *(Porqué: <la razón —
  esto es lo que evita que una sesión futura "optimice" algo que fue una
  decisión deliberada>.)*

## Decisiones
- YYYY-MM-DD: <decisión tomada> — *Porqué: <motivo>.*

## Fuera de alcance
- <Qué se decidió NO hacer (y por qué, si no es obvio).>

## Referencias
- <Si este spec es hijo de otro: "Spec padre: `spec-<padre>.md` — <qué usa de
  él y por qué se relacionan>". Si tiene hijos: "Specs hijos:" y una línea por
  hijo con de qué depende.>
- Dependencias:
  - Depende de: `spec-<X>.md` (§Contrato) — <qué consume>
  - Usada por: `spec-<Y>.md` — <quién la consume>
- Historias: `HU-0NN` — <qué parte del comportamiento aporta cada una> *(si la capacidad nace de historias de usuario)*
- Diseño: `docs/design/HU-0NN/03_OPENAPI_CONTRATO.json`, `.../02_SCHEMA_DDL.sql`, `.../04_UI_ESPECIFICACION_4_ESTADOS.md` *(forma exacta; el spec no la copia)*
- Código: `<ruta al archivo o módulo principal>`
- Tests: `<ruta a los tests que cubren esta capacidad, si existen>`
- <Otras referencias en forma EXACTA: tipos, migraciones, endpoints, docs>
```

## Las sub-secciones de Comportamiento

Son **recomendadas, no obligatorias**: una capacidad sin API no tiene *Contrato*, una sin topes no tiene *Límites y defaults*. Si una sub-sección no aplica, se omite — no se deja vacía ni con "N/A".

Lo obligatorio es que, **si la información existe, viva en la sub-sección que le corresponde** y no repartida en prosa. Es lo que hace que un lector (humano o LLM) encuentre el contrato o los límites sin leer el spec completo.

Errores de ubicación frecuentes:

| Está escrito en… | Pero es… | Va en… |
|---|---|---|
| *Invariantes*: "una serie tiene entre 2 y 13 ocurrencias" | Un tope configurable, no una regla de negocio innegociable | *Límites y defaults* |
| *Comportamiento*, mezclado con el contrato: "si ninguna ocurrencia se puede crear, responde 409" | Qué pasa cuando algo falla | *Modos de falla* |
| *Comportamiento*: "rechaza si dura menos de 15 minutos" | Un tope | *Límites y defaults* (y en *Invariantes* solo si hay una razón de negocio para que nunca cambie) |

## Regla del contrato — forma observable vs forma exacta

El spec describe el contrato en su **forma observable**: método, ruta, rol que lo puede invocar, código de respuesta, campos de entrada y salida *con su significado* (en prosa o tabla). La **forma exacta** (el tipo TypeScript, el JSON Schema, la migración) se **referencia** en *Referencias*, no se copia. Así el spec se lee solo, y el código sigue siendo la verdad del tipo: si el tipo cambia sin cambiar el significado, el spec no se toca.

```markdown
### Contrato
| Operación | Quién | Respuesta | Entrada / salida |
|---|---|---|---|
| `POST /api/reservas` | cualquiera | 201 + reserva | Entrada: sala, fecha, horario, responsable, motivo. Salida: la reserva confirmada. |
| `DELETE /api/reservas/:id` | cualquiera | 200 + reserva | Salida: la reserva con estado cancelada. |
Tipos exactos: ver Referencias → `backend/src/tipos.ts` (`Reserva`).
```

## Las secciones que acotan al agente

*Invariantes*, *Límites y defaults*, *Modos de falla* y *Fuera de alcance* son los límites dentro de los cuales construye `/sdd-aplicacion`. Por eso se escriben en `/sdd-propuesta`, **antes del código**, y no después. Un delta del spec que no tiene nada en estas cuatro secciones, en un cambio que agrega comportamiento, casi siempre está incompleto: revisar si de verdad no hay topes, fallas ni exclusiones.

## Dónde va cada cosa

Regla corta: **spec = lo que corre y es observable de UNA capacidad; arquitectura = lo transversal a todas; plan = lo que todavía no corre.**

| Información | Spec | Plan | Doc. arquitectura |
|---|---|---|---|
| Qué hace la capacidad y para quién | Propósito / Alcance | Contexto (antes de existir) | — |
| Contrato de endpoints / eventos / pantallas | Contrato (observable) + Referencias (exacto) | Propuesta de contrato | — |
| Límites, timeouts, defaults, presupuestos | Límites y defaults | Valores propuestos | Solo si son globales |
| Qué pasa cuando falla | Modos de falla | — | Política general |
| Reglas que no se pueden romper | Invariantes (de la capacidad) | Invariantes nuevos propuestos | Invariantes transversales |
| Por qué se hizo así y no de otra forma | Decisiones (fechadas) | Alternativas evaluadas y descartadas | Decisiones de arquitectura |
| Lo que se decidió no hacer | Fuera de alcance | Fases futuras / pendientes | — |
| Stack, lenguajes, frameworks | Solo si es propio de la capacidad (Arquitectura propia) | Enfoque técnico | **Sí** (fuente principal) |
| Comandos de build / deploy / validación | Referencias (enlace) | — | **Sí** |
| Tareas, estimaciones | — | **Sí** | — |
| Criterios de aceptación | — (se destilan a Comportamiento) | **Sí** (si no hay plan: cuerpo del commit de propuesta; el reporte de verificación va en el commit de merge) | — |
| Estado transitorio ("pendiente de deploy", "implementación a medias") | — | Sí (o en el mensaje del commit) | — |
| Forma exacta del contrato, del modelo de datos o de la UI (paquete de diseño) | Referencias (ruta en `docs/design/`) | Propuesta de contrato | — |
| Dependencia con otra capacidad (confirmada) | Referencias ("Depende de / Usada por") + efecto en Modos de falla o Límites | — | — |
| Dependencia o riesgo por evaluar | — | Pendientes de decisión, o en el chat si no hay plan (bloquea el gate) | — |

## Specs relacionados: cómo se escribe la relación padre-hijo

> **Extensión de las skills**, no forma parte de la metodología v4 — ver `convenciones.md`.

Cuando una subcapacidad pasa a tener su propio spec (ver `verificacion-division.md`), la relación se escribe en `Referencias` y `Decisiones` de **ambos** specs. El formato del spec no cambia: no se agregan secciones ni líneas de encabezado.

**En el hijo** (`spec-reservas-recurrentes.md`):

```markdown
## Referencias
- Spec padre: `spec-reservas.md` — cada ocurrencia se crea con la validación de
  disponibilidad del padre; cancelar una ocurrencia usa la cancelación del padre.
- Código: `src/reservas/recurrentes/`
```

**En el padre** (`spec-reservas.md`):

```markdown
## Referencias
- Specs hijos:
  - `spec-reservas-recurrentes.md` — series de reservas; depende de Reservar y Cancelar.
  - `spec-reservas-checkin.md` — check-in y liberación por no-show; depende de Cancelar.
- Código: `src/reservas/`
```

**En `Decisiones`, en los dos specs:**

```markdown
## Decisiones
- 2026-09-16: se separa Reservas recurrentes en `spec-reservas-recurrentes.md` —
  *Porqué: criterios cumplidos 1, 2, 3, 4 y 5 (disparador: spec de 430 líneas).*
```

Un invariante que aplica al padre y al hijo se escribe **completo, con su porqué, en los dos** — nunca como referencia al otro spec: cada spec tiene que entenderse solo.

## Reglas de formato que se violan seguido — prestar atención especial

- La línea de **Estado** usa el separador `·` (punto medio) entre el valor de Estado y "Última revisión" — **no** `|`. El `|` solo aparece, si aparece, separando los *valores posibles* de Estado (`desplegado | parcial | en desarrollo`), nunca reemplazando al `·`.
- **Estado** va avanzando así: un spec que nace en `/sdd-propuesta` (o en la Fase 0) arranca en `en desarrollo`; pasa a `parcial` cuando hay fases implementadas pero no todas; pasa a `desplegado` cuando el comportamiento descrito ya corre completo en `main` (o, en la Fase 0, cuando termina la revisión humana y se cerraron los fixes colaterales de los bugs confirmados). Un spec que ya estaba `desplegado` y recibe una sección nueva no cambia su Estado por eso.
- Cada invariante lleva su "porqué" — un invariante sin porqué es una regla que el siguiente agente va a cuestionar y probablemente romper.
- Cada decisión lleva fecha — sin fecha no se puede saber si sigue vigente o si una decisión posterior la reemplazó.
- **Qué NO va en un spec:** checklists paso a paso (van en scripts o en la automatización local), estados transitorios tipo "pendiente de deploy" o "se agregó el campo pero todavía no hay endpoint" (van en el plan o en el mensaje del commit), o cualquier detalle que el código exprese mejor (firmas, tipos) — eso se referencia, no se duplica.
- **No registrar en `Decisiones` evaluaciones que no llevaron a nada** (por ejemplo, "se evaluó dividir y no se cumplen los criterios"). Solo se registra una división aprobada, o una recomendada que el usuario negó.

## Bug confirmado en la Fase 0 (Caso 5)

Cuando la revisión humana de la Fase 0 confirma que un comportamiento inferido es un bug (v4, Caso 5: *"se corrige el spec para describir el comportamiento correcto y el bug se arregla en un MR separado"*):

- *Comportamiento* describe el comportamiento **correcto**, completo y verificable. Ejemplo: *"No se puede cancelar una reserva cuya reunión ya empezó (`horaInicio` menor o igual a la hora actual del servidor): responde 409 y la reserva sigue `CONFIRMADA`."*
- **Sin aclaraciones del tipo "hoy el código no lo cumple" ni "arreglo pendiente":** son estados transitorios y no van en un spec. El bug se lista fuera del spec, como fix colateral pendiente (en el cuerpo del commit de propuesta del baseline, o en el mensaje de su commit).
- El arreglo es un cambio propio, separado del baseline (rama de fix colateral, Caso 3): corrige el código para que cumpla lo que el spec ya dice.
- `Estado` del spec: `en desarrollo` mientras haya fixes colaterales pendientes; `desplegado` cuando se cierra el último. Así, cuando el spec queda validado, lo que dice es cierto.

## Reglas para decidir qué sección tocar (regla 3.2)

El delta se escribe en `/sdd-propuesta`, antes del código.

| El cambio... | Toca spec en |
|---|---|
| Agrega una **capacidad** nueva (no hay spec todavía) | Todo el spec (nace, `Estado: en desarrollo`) |
| Agrega una **subcapacidad** nueva a una capacidad que ya tiene spec | Comportamiento (sección nueva dentro del spec existente, con sus sub-secciones que apliquen). Solo nace un spec hijo si se cumplen los cinco criterios de `verificacion-division.md` **y** el usuario lo aprueba |
| Cambia lo que el usuario/sistema observa (API, UI, mensajes, tiempos) | Comportamiento (+ Invariantes/Decisiones si aplica) |
| Agrega un invariante o decisión que restringe cambios futuros | Invariantes o Decisiones |
| Elimina una capacidad | Comportamiento (se quita) + Fuera de alcance |
| Agrega o cambia una dependencia con otra capacidad | Referencias ("Depende de / Usada por") en ambas specs + su efecto en Modos de falla o Límites |
| Cambia la implementación pero el comportamiento observable es idéntico | Solo Decisiones + Referencias |
| Es un refactor interno sin efecto observable, o una actualización de dependencias sin cambio de comportamiento | No toca el spec |
