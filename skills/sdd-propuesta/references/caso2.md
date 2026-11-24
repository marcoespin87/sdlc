# Caso 2 — Propuesta de cambio

Delta = AGREGADO. El sistema existente no cambia lo que ya hace; solo se le suma algo nuevo.

## Dónde nace el delta del spec

Decidirlo acá y escribirlo acá, antes del código. Tres opciones:

1. **Sección nueva** dentro de un spec existente — el caso por defecto para una subcapacidad. Se agrega en *Comportamiento* sin tocar lo que ya describe el spec.
2. **Spec propio** de una capacidad nueva (no hay spec de esa capacidad todavía; ver criterio de tamaño en `convenciones.md`). Nace completo con `Estado: en desarrollo` y su fila en el índice.
3. **Spec hijo** de un spec existente — extensión de las skills, solo si se cumplen los cinco criterios de `verificacion-division.md` **y** el usuario lo aprobó. La división se aplica en commit propio antes de escribir el delta.

## Qué escribir en el spec

- *Comportamiento*, con las sub-secciones que apliquen. Como mínimo, preguntarse por:
  - **Contrato:** la operación nueva en forma observable.
  - **Límites y defaults:** topes y valores por defecto de lo nuevo.
  - **Modos de falla:** qué pasa cuando lo nuevo no se puede completar (total o parcialmente).
- *Invariantes* que lo nuevo agrega, con su porqué. Los invariantes existentes que lo restringen no se reescriben: ya están.
- *Fuera de alcance*: lo que se decidió **no** incluir en esta subcapacidad.
- *Decisiones* fechadas de lo que condicionó el diseño, y *Referencias* con las dependencias.

## Enfoque técnico y criterios (en el plan si lo hay; si no, en el cuerpo del commit de propuesta)

- **Enfoque técnico**: cómo se integra lo nuevo con lo existente (reutilizar componentes/módulos ya presentes cuando tenga sentido, en vez de duplicar).
- Qué opción se eligió (en el plan, en "Delta del spec escrito"): cuál de las tres opciones de arriba se eligió y qué secciones se escribieron.
- Criterios de aceptación que cubran explícitamente: (a) lo nuevo funciona, y (b) lo que ya existía se sigue comportando exactamente igual que antes (no-regresión) — este segundo punto se olvida seguido y es el que verifica `/sdd-verificacion` con más rigor en este Caso.

## Preguntas abiertas típicas de este Caso

- Dónde vive la nueva lógica (cliente vs. servidor, nuevo módulo vs. extender uno existente).
- **Qué pasa cuando lo nuevo choca con lo existente o falla a medias.** Ejemplo: si una operación crea varias cosas y una no se puede crear, ¿falla todo o se crea lo que se pueda y se informa el resto? La respuesta se escribe en *Modos de falla*, no solo en el plan ni en el chat.
- Cómo se ve/comporta ante entradas inválidas o ausencia del dato nuevo.
- Si el spec afectado quedó cerca de los disparadores de tamaño: ¿dividir ahora o más adelante? La decisión es del usuario.
