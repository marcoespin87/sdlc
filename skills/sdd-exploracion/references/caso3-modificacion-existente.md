# Caso 3 — Modificación de un requerimiento ya existente

El comportamiento que cambia ya está descrito en un spec.

**Antes de seguir, confirmar que es realmente esto y no un Caso 2 disfrazado:** si lo pedido
es puramente aditivo — el spec ya existe, pero lo que ya describe sigue siendo cierto sin
ningún matiz después del cambio (ej. agregar un filtro/campo opcional que no altera nada de lo
que había) — es **Caso 2** (subcapacidad nueva sobre spec existente), no este archivo. Ver
`references/caso2-funcionalidad-nueva.md` y el árbol de decisión del Paso 3 de `SKILL.md`.

## Qué hacer

1. Ubicar, dentro del spec de la capacidad, la porción puntual que el pedido afecta — no releer el spec entero como si fuera nuevo, sino identificar exactamente qué sección de Comportamiento/Invariantes/Decisiones está en juego.
2. Determinar de entrada si el pedido es:
   - Un cambio de **comportamiento observable** (lo que el usuario/sistema ve cambia) → esto es un Caso 3 "pleno": va a tocar Comportamiento del spec.
   - El **fix colateral** de un bug confirmado en la Fase 0 → sigue siendo Caso 3: el comportamiento correcto ya está escrito en el spec y lo que cambia es el código. Decir qué fixes colaterales quedan pendientes.
   - Un cambio de **implementación únicamente**, con el comportamiento observable idéntico → sigue siendo Caso 3, pero el spec solo se va a tocar en Decisiones + Referencias (regla 3.2). No confundir esto con Caso 4 (Caso 4 es migración de *lenguaje/stack completo*, no un cambio de implementación puntual dentro del mismo lenguaje).
3. Identificar qué invariante(s) existentes toca el pedido. Si el pedido implica romper un invariante ya escrito, señalarlo explícitamente — la metodología exige declarar esto, no descubrirlo recién en Aplicación.
4. Pensar (sin resolverlo todavía: en `/sdd-propuesta` se vuelve criterio de aceptación y en `/sdd-verificacion` se comprueba) qué otras partes del sistema podrían depender del comportamiento actual y verse afectadas — empezando por las specs que figuran como "Usada por" en *Referencias*.

## Qué dejar como resumen de salida

- Problema/necesidad, en 2-3 frases, incluyendo qué es lo que cambia respecto a lo que el spec describe hoy.
- **Caso:** 3 (modificación de un requerimiento existente).
- **Delta tentativo:** MODIFICADO (o ELIMINADO si el pedido es sacar algo que existía).
- **¿Toca el Comportamiento del spec, o solo Decisiones/Referencias?** — decirlo explícitamente, ya condiciona todo lo que sigue. Es exactamente lo que se va a escribir primero en `/sdd-propuesta`, y lo que el revisor va a aprobar o rechazar antes del código: si el delta que se escriba ahí toca *Comportamiento* cuando acá se dijo que no, se rechaza en ese gate.
- Las **specs relacionadas** que dependen de lo que cambia.
- El resultado de la **verificación de división** (Paso 5 del SKILL, extensión de las skills). Este Caso es donde más rinde: si la subcapacidad que se va a modificar cumple los cinco criterios, conviene recomendar la división **antes** de modificarla — la modificación se hace sobre un spec chico y su diff queda mucho más fácil de revisar. La decisión igual es del usuario.
- Invariantes existentes que toca, y si alguno se rompe deliberadamente.

## Qué NO hacer en esta fase

- No reemplazar la porción del spec todavía — se reemplaza en `/sdd-propuesta`, antes del código.
- No asumir que "cambiar cómo se resuelve por dentro" es automáticamente "no toca el spec" — solo lo es si el comportamiento observable no cambia ni un poco. Ante la duda, tratarlo como cambio de Comportamiento.
