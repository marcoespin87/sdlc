# Caso 1 — Verificación y fusión

No hay nada previo que pueda romperse — validar solo contra los criterios recién propuestos, capacidad por capacidad.

## Qué verificar

- Cada capacidad construida cumple sus criterios de aceptación.
- **Dirección 2, capacidad por capacidad:** cada spec describe exactamente lo que se construyó. En un Caso 1 es donde más texto de sobra suele quedar, porque los specs se escribieron para todo el sistema de una vez: recortar lo que no se construyó.
- `docs/specs/README.md` lista todas las capacidades construidas, sin faltantes ni sobrantes (una capacidad que no se construyó sale del índice o, si hay plan, queda como fase futura en el plan).
- El documento de arquitectura existe y tiene el contenido mínimo (patrón, invariantes transversales, comandos, instrucción de la regla 3.1).

## Al cerrar

Este es el primer cambio del proyecto. Confirmar que índice, specs y documento de arquitectura quedaron consistentes entre sí antes de cerrar (y de destilar el plan, si lo hay).
