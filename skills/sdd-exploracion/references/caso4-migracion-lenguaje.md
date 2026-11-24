# Caso 4 — Migración de lenguaje

Se reescribe el sistema (o una porción) en otro lenguaje/stack, sin cambiar comportamiento.

## Qué hacer

1. Leer **todos** los specs del sistema (o de la porción a migrar) como un inventario de lo que tiene que seguir funcionando igual — no solo el que parece más relacionado con el pedido.
2. Confirmar con el usuario que efectivamente el objetivo es paridad de comportamiento, no una oportunidad para "de paso" cambiar algo. Si en la conversación aparece algo tipo "y aprovechemos para cambiar X", separarlo: eso es un Caso 3 aparte, con su propio ciclo, no parte de esta migración.
3. Identificar los módulos/capacidades que existen hoy, para que `/sdd-propuesta` pueda armar el orden de migración módulo por módulo (o, si el sistema tiene una sola capacidad grande, fase por fase dentro de ella — ver nota abajo).
4. Notar qué specs tienen invariantes que dependen de detalles del lenguaje/stack actual (ej. tipos, concurrencia) — esos son los puntos de mayor riesgo de la migración y hay que señalarlos.

5. Correr la verificación de división (extensión de las skills) sobre cada spec del inventario. Si alguno activa los disparadores y cumple los cinco criterios, **recomendar dividirlo antes de empezar a migrar**, nunca durante: cada spec hijo pasa a ser un módulo de migración con su propio ciclo. Si el usuario la niega, la migración sigue con el spec tal como está.

**Nota sobre sistemas con una sola capacidad:** si todo el sistema vive en un único spec (no hay múltiples capacidades separadas), "módulo por módulo" en la práctica se traduce en fases por endpoint/función dentro de esa capacidad. Decirlo así en el resumen de salida para que `/sdd-propuesta` no fuerce una división en módulos que no existen.

## Qué dejar como resumen de salida

- Alcance de la migración: todo el sistema, o una porción puntual.
- **Caso:** 4 (migración de lenguaje).
- **Delta tentativo:** NULO — ningún comportamiento observable cambia.
- Inventario de specs/capacidades involucradas, y el resultado de la verificación de división sobre cada uno (si se recomendó dividir antes de migrar y qué respondió el usuario).
- Puntos de riesgo identificados (invariantes atados a detalles del lenguaje/stack actual).
- Qué se va a escribir en el spec en `/sdd-propuesta`, antes del código: solo la *Decisión* fechada de migración y las *Referencias* nuevas. *Comportamiento* e *Invariantes* no se tocan.

## Qué NO hacer en esta fase

- No elegir el lenguaje/librerías de destino todavía si el usuario no lo trajo ya decidido — eso es `/sdd-propuesta`.
- No empezar a escribir tests de caracterización todavía — se diseñan en `/sdd-propuesta` a partir de cada spec.
