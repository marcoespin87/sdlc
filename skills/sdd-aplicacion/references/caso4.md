# Caso 4 — Aplicación del cambio

Reescritura del módulo/fase que toca en esta corrida, guiada por el spec — no por la sintaxis del código origen.

## Qué construir

1. Confirmar que los tests de caracterización de este módulo (definidos en `/sdd-propuesta`) pasan contra la implementación actual (baseline) antes de tocar nada — si no pasan, el test está mal escrito o el spec no describe la realidad. Eso es un descubrimiento (Paso 4 del SKILL): detenerse y resolverlo con el usuario antes de seguir.
2. Reescribir el módulo en el lenguaje/stack de destino, leyendo el spec para entender **qué** debe hacer, no traduciendo línea por línea el código viejo.
3. Correr los mismos tests de caracterización contra la implementación nueva. Deben pasar igual que contra la vieja.

## Qué pasa con el spec (regla estricta de este Caso)

La *Decisión* fechada de la migración y las *Referencias* nuevas **ya se escribieron en `/sdd-propuesta`**. Esta fase no toca el spec.

- Si las rutas o archivos reales del módulo migrado terminan siendo distintos de los que se escribieron en *Referencias*, es un ajuste por descubrimiento: proponerlo y pedir OK (Paso 4 del SKILL).
- **Nunca tocar** `Comportamiento` ni `Invariantes`. Si hiciera falta, esto dejó de ser una migración pura y hay que tratarlo como un Caso 3 aparte.

## Cuándo dar el módulo por terminado

Cuando el módulo nuevo pasa todos sus tests de caracterización y nada más quedó a medio migrar dentro de ese módulo. No arrancar el próximo módulo en la misma corrida de esta fase — cada módulo es su propio ciclo Exploración → Propuesta → Aplicación → Verificación, sobre el mismo plan padre.
