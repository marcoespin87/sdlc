# Caso 2 — Funcionalidad nueva sobre un sistema existente

Ya existe sistema + specs. Se agrega algo que no existía — no reemplaza ni modifica ningún
comportamiento actual. Dos variantes, según si la capacidad afectada ya tiene spec o no:

- **Capacidad nueva:** no hay spec para ella todavía. El spec nace en `/sdd-propuesta`, antes
  del código.
- **Subcapacidad nueva dentro de una capacidad ya existente:** el spec de esa capacidad ya
  existe (ejemplo de la propia metodología, sección 7: agregar un filtro por estado al
  historial, que ya tenía `spec-historial.md`). En `/sdd-propuesta` no nace un spec — se le
  escribe una sección nueva al que ya hay. La excepción está abajo, en "¿Sección o spec hijo?".

En ambas variantes el delta es AGREGADO y el criterio de "no choca con nada existente" (abajo)
es el mismo. No asumir que "el spec ya existe" empuja esto a Caso 3 — lo que importa es si lo
que el spec **ya describe hoy** sigue siendo cierto sin matices después del cambio.

## Qué hacer

1. Leer los specs relevantes:
   - Si es capacidad nueva: los specs **vecinos** — de capacidades relacionadas que podrían
     compartir invariantes, datos o interfaz con lo nuevo.
   - Si es subcapacidad dentro de una capacidad existente: el spec **de esa misma capacidad**
     (para confirmar que lo pedido de verdad no toca nada de lo que ya describe) + los vecinos
     si aplica.
2. Listar las **specs relacionadas** (Paso 2 del SKILL): con qué capacidades se va a relacionar
   lo nuevo — si consume algo, si otra lo va a consumir, o si puede chocar con un invariante
   de otra.
3. Confirmar explícitamente que lo pedido no choca con ningún invariante existente en esos
   specs. Si choca, decirlo ahora — puede que en realidad sea un Caso 3 disfrazado (si para
   agregar esto hay que romper o reinterpretar un invariante ya escrito, o si el comportamiento
   ya documentado deja de cumplirse sin usar lo nuevo, es una modificación, no un agregado
   puro).
4. Leer el documento de arquitectura para confirmar que la nueva capacidad encaja con el
   patrón/arquitectura ya establecidos (no proponer un patrón distinto sin que sea una decisión
   consciente y señalada).
5. **Anticipar las decisiones abiertas** que `/sdd-propuesta` va a tener que resolver antes de
   escribir el delta: sobre todo qué pasa cuando lo nuevo choca con lo existente o se completa a
   medias. No resolverlas acá: nombrarlas.

## ¿Sección o spec hijo? (solo en la variante "subcapacidad nueva")

Extensión de las skills (no está en la metodología v4). Por defecto, **sección** dentro de
`Comportamiento` del spec existente. Para que nazca como spec hijo tienen que cumplirse los cinco
criterios de `verificacion-division.md` y aprobarlo el usuario. Ojo con dos de ellos en una
subcapacidad que todavía no existe:

- **Criterio 3 (cambia sola):** no hay historia de cambios todavía, así que **no se cumple**. En
  la práctica, una subcapacidad nueva casi siempre nace como sección y recién se separa más
  adelante, cuando el historial de cambios demuestra que evoluciona sola.
- **Criterio 5 (tamaño):** se estima a partir de lo que el usuario está pidiendo; si la
  estimación no llega a 150 líneas, no se cumple.

Si no se recomienda dividir, decirlo en una línea. No va nada al spec por eso.

## Qué dejar como resumen de salida

- Problema/necesidad, en 2-3 frases.
- **Caso:** 2 (funcionalidad nueva).
- **Delta tentativo:** AGREGADO.
- **Dónde se va a escribir el delta en `/sdd-propuesta`:** "sección nueva en
  `spec-<capacidad>.md`" o "nace `spec-<capacidad-nueva>.md`", y qué sub-secciones se esperan
  (normalmente *Contrato*, *Límites y defaults* y *Modos de falla*).
- **Specs relacionadas**, una línea cada una, y las dependencias o riesgos por evaluar.
- **Decisiones abiertas anticipadas** (punto 5).
- El resultado de la **verificación de división** (Paso 5 del SKILL).
- **Invariantes que restringen:** los citados de los specs leídos, con su "porqué".
- Confirmación de que no hay conflicto con nada existente (o la advertencia si la hay).

## Qué NO hacer en esta fase

- No escribir el spec (nuevo, o la sección nueva sobre uno existente) todavía — se escribe en
  `/sdd-propuesta`, antes del código, y se aprueba ahí.
- No resolver las decisiones abiertas por el usuario.
- No decidir el enfoque técnico completo — eso es `/sdd-propuesta`.
