# Caso 4 — Propuesta de cambio

Delta = NULO. Acá el protagonismo no es "qué cambia" (nada, a propósito) sino el enfoque técnico de la migración y los tests de caracterización que van a probar la paridad.

## Qué escribir en el spec, antes del código

Por cada módulo que se migra en este cambio:

- Una **Decisión** fechada documentando la migración de ese módulo (qué lenguaje/stack, por qué).
- Las **Referencias** nuevas: rutas y archivos del módulo en el lenguaje de destino.
- **Nada más.** *Comportamiento* e *Invariantes* no se tocan. Si al escribir el delta parece necesario tocarlos, esto dejó de ser una migración pura: separar lo que cambia como un Caso 3 aparte.

## Qué debe contener el plan

La migración va módulo por módulo, es decir, por fases: acá corresponde **un plan padre** para toda la migración (regla 3.3), con una fase por módulo. Lo crea la Propuesta del primer módulo; la de cada módulo siguiente usa ese mismo plan (ver Paso 6 del SKILL).

- **Estrategia módulo por módulo** (o fase por fase, si el sistema tiene una sola capacidad — ver la nota de `sdd-exploracion/references/caso4-migracion-lenguaje.md`): orden concreto, empezando por lo más aislado o menos riesgoso.
- **Equivalencias de librerías/framework** del lenguaje/stack origen al destino.
- **Tests de caracterización**: derivados de cada spec (no del código viejo), que van a correr primero contra la implementación actual para confirmar que describen el comportamiento real, y después contra cada módulo ya migrado.
- Aclarar que cada módulo migrado es su propio cambio acotado (su rama `migrate/<modulo>` y su merge): se explora, propone, aplica y verifica por separado. Un solo plan padre, pero nunca la migración completa en un solo cambio.

## Criterios de aceptación (siempre los mismos, por módulo)

1. Los tests de caracterización de ese módulo pasan igual en la versión vieja y en la nueva.
2. Ningún consumidor de la interfaz pública (API, CLI, lo que corresponda) tiene que cambiar cómo la usa.

## Preguntas abiertas típicas de este Caso

- Lenguaje/framework de destino, si no vino ya decidido.
- Orden de migración de los módulos.
