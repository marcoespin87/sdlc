# Caso 2 — Aplicación del cambio

Código nuevo, guiado por la sección nueva (o el spec nuevo) que ya se escribió y aprobó en `/sdd-propuesta`, sin tocar el comportamiento existente.

## Qué construir

- La funcionalidad nueva, integrada con lo existente según el enfoque técnico aprobado (en el plan, o en el cuerpo del commit de propuesta si no hay plan) (reusar componentes existentes en vez de duplicar).
- **Exactamente** lo que describe la sección del spec:
  - el *Contrato* tal como está (rutas, códigos, campos);
  - los topes de *Límites y defaults*;
  - lo que dice *Modos de falla* sobre qué pasa cuando algo no se puede completar;
  - y nada de lo que figura en *Fuera de alcance*.
- **No tocar el spec.** Ni la sección nueva ni las que describen lo que ya había. Si al construir aparece algo que la sección no previó, seguir el Paso 4 del SKILL: detenerse, proponer el ajuste y pedir OK.

## Verificación propia (antes de pasar a `/sdd-verificacion`)

Confirmar a mano que lo que ya existía se sigue comportando exactamente igual que antes de este cambio — no dejar esto solo para la fase de Verificación formal; si algo se rompió, es más barato notarlo acá.
