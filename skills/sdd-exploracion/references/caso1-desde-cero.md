# Caso 1 — Desde cero

No hay sistema ni specs todavía. Casi no hay nada previo que contrastar — la Exploración acá es liviana a propósito.

## Qué hacer

1. Confirmar que efectivamente no hay nada: ni `docs/specs/`, ni código relevante, ni documento de arquitectura.
2. No inventar requisitos que el usuario no pidió. Trabajar solo con la idea/necesidad que dio en `$ARGUMENTS` (o lo que responda si se le preguntó).
3. Si la idea es vaga ("necesitamos un sistema de X"), no tratar de adivinar el alcance completo en esta fase — eso es trabajo de `/sdd-propuesta`. Acá alcanza con entender el problema de negocio a alto nivel.
4. Identificar, a partir de la idea, qué capacidades tendría sentido separar (no hace falta ser exhaustivo ni definitivo — es una sugerencia inicial que `/sdd-propuesta` va a confirmar o ajustar).

## Qué dejar como resumen de salida

- Problema/necesidad de negocio, en 2-3 frases.
- **Caso:** 1 (desde cero).
- **Delta tentativo:** 100% del sistema.
- **Invariantes que restringen:** ninguno todavía (no hay nada previo) — dejarlo explícito en vez de omitir la sección.
- **Verificación de división** (extensión de las skills): no aplica — no hay spec que medir, y sin historia de cambios el criterio "cambia sola" no se puede cumplir. Las subcapacidades nacen como secciones; dividir se evalúa recién cuando el spec crezca. Decirlo en una línea en vez de omitirlo.
- Un camino sugerido: qué capacidades separarías y cómo se relacionarían entre sí ("pedidos es consumida por historial"), sin comprometerse a esa lista.
- Recordar que en `/sdd-propuesta` se van a escribir, **antes del código**, los specs de cada capacidad y el documento de arquitectura.

## Qué NO hacer en esta fase

- No definir stack todavía (eso se decide o confirma en `/sdd-propuesta`).
- No crear ningún archivo — ni siquiera `docs/specs/README.md` vacío. Specs, índice y documento de arquitectura nacen en `/sdd-propuesta`, antes del código.
