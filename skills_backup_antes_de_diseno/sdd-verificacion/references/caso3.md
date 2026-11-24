# Caso 3 — Verificación y fusión

La verificación más exigente de los 4 Casos: nuevo comportamiento (o paridad, si fue solo cambio de implementación) **+** impacto en todo lo que dependía de lo anterior.

## Qué verificar

- Si la Propuesta declaró cambio de Comportamiento: que el comportamiento nuevo sea exactamente el descrito en la porción reemplazada del spec, incluidos los casos borde.
- Si la Propuesta declaró paridad (solo cambio de implementación): comparar entradas → salidas contra el comportamiento anterior, no solo leer el código nuevo y asumir que es equivalente.
- **Si fue el fix colateral de un bug de la Fase 0:** que el código cumpla exactamente el ítem del spec aprobado en la Fase 0. Al cerrar, si no quedan otros fixes colaterales pendientes de esa Fase 0, `Estado` del spec pasa a `desplegado`.
- Cada dependiente identificado en `/sdd-exploracion`/`/sdd-propuesta` (incluidas las specs relacionadas en *Referencias*): confirmar que sigue funcionando, o que su ajuste (si lo hubo) también está cubierto y probado.
- **Que el spec final sea coherente con el Caso.** Si la Propuesta decía "solo Decisiones/Referencias" y el spec final toca `Comportamiento`, es una discrepancia. Como el diff del spec ya se revisó en Propuesta, esto solo puede haber pasado por un ajuste en `/sdd-aplicacion`: revisar si ese ajuste tuvo OK explícito y si de verdad era un ajuste, o si el cambio terminó siendo más grande de lo que la Propuesta preveía.
