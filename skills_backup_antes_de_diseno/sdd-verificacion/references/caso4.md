# Caso 4 — Verificación y fusión

Paridad de comportamiento — se mide con tests de caracterización, nunca alcanza con leer el código nuevo y que "se vea parecido".

## Qué verificar

- Los tests de caracterización de este módulo pasan igual contra la versión vieja (baseline) y la nueva — si no se corrieron contra ambas en este mismo ciclo, correrlos ahora.
- El spec de este módulo, respecto de antes de la Propuesta, cambió **solo** en `Referencias` y en una `Decisión` fechada — si cambió `Comportamiento` o `Invariantes`, señalarlo como discrepancia: algo de la migración cambió comportamiento sin que estuviera previsto.
- **Dirección 2:** las `Referencias` escritas en la Propuesta apuntan a los archivos que realmente existen en el lenguaje de destino.
- Ningún consumidor externo de la interfaz (API, CLI, lo que corresponda) necesita cambiar cómo la usa.
- **`Estado` del spec: no cambia.** Una migración no cambia comportamiento, y el spec ya describía lo que corre: sigue `desplegado` aunque queden módulos por migrar. La secuencia `en desarrollo` → `parcial` → `desplegado` es para specs que nacen por fases (Caso 1, Caso 2), no para una migración.

## Al cerrar

Si quedan más módulos por migrar, recordarle al usuario que el próximo es un cambio nuevo que vuelve a empezar en `/sdd-exploracion` (`/sdd-exploracion` → `/sdd-propuesta` → `/sdd-aplicacion` → `/sdd-verificacion`) y usa el **mismo plan padre** de la migración: no se crea un plan por módulo. El plan pasa a `destilado` recién al cerrar el último módulo.
