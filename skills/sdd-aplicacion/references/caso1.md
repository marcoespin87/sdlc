# Caso 1 — Aplicación del cambio

Base vacía de código, pero **no de specs**: los specs de cada capacidad, el índice y el documento de arquitectura ya se escribieron y aprobaron en `/sdd-propuesta`.

## Qué construir

- El sistema completo tal como lo describen los specs (y el plan, si lo hay), capacidad por capacidad.
- Respetar el patrón, la organización de carpetas y los comandos que fija el documento de arquitectura.
- **No crear specs, índice ni documento de arquitectura en esta fase**: ya existen. Si falta alguno, la Propuesta quedó incompleta — volver a `/sdd-propuesta`.
- Mantener los specs en `Estado: en desarrollo`. Pasan a `desplegado` (o `parcial`, si quedan fases pendientes) al cerrar `/sdd-verificacion`.

## Orden sugerido

Construir de abajo hacia arriba: primero lo que otras capacidades van a necesitar (ej. modelo de datos base, o lo que figura como "Depende de" en *Referencias*), después cada capacidad. Si el plan ya trae un orden de fases, seguir ese en vez de improvisar uno nuevo.
