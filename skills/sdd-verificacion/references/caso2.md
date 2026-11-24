# Caso 2 — Verificación y fusión

Lo nuevo + no-regresión de lo existente + el spec describe exactamente lo nuevo.

## Qué verificar

- Los criterios de aceptación de la funcionalidad nueva.
- Que las capacidades vecinas identificadas en `/sdd-exploracion` (specs relacionadas) se sigan comportando exactamente igual que antes de este cambio — probarlas puntualmente, no asumir que "como no las tocamos, están bien".
- **Dirección 2 sobre la sección nueva:** si lo construido hace menos de lo que dice la sección (por ejemplo, el spec promete un tope, un modo de falla o una operación que el código no implementa), recortar la sección. Lo que no se hizo queda en el plan si lo hay, o se descarta.
- Que las secciones que describían lo que ya existía **no cambiaron** desde antes de la Propuesta.
- Que el spec nuevo (si nació uno) haya entrado al índice `docs/specs/README.md`, con su columna *Spec padre* llena si nació como spec hijo.
