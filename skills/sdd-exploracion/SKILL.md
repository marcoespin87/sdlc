---
name: sdd-exploracion
description: Use when the user asks to build, add, change, remove, refactor or migrate something that alters behavior, contracts, data or structure (crear, agregar, modificar, implementar, migrar, documentar codigo existente) and there is no approved spec delta for it on the current local branch yet. First phase of every change: reads the specs and the local git state, announces the Case (1 from scratch, 2 new feature, 3 modification, 4 language migration, 5 undocumented code) and summarizes the problem. Writes nothing. Do not use for questions, reading code, running commands, or trivial edits that do not change behavior (typos, comments, formatting): those take the fast path described in ciclo-de-vida.md.
argument-hint: [descripción de la idea o necesidad del cambio]
---

# sdd-exploracion — Fase 1: Exploración

Primera fase del ciclo de la metodología SDD Spec-Anchored (v4). Determinar qué existe hoy, cuál de los 5 escenarios de partida aplica, qué specs se relacionan con el cambio y qué lo restringe — antes de escribir el delta del spec o el plan.

No construir nada en esta fase. No escribir el delta del spec ni el plan todavía (eso es `/sdd-propuesta`). El único artefacto que esta fase puede llegar a crear es el spec candidato de la Fase 0 (Caso 5) — todo lo demás es un resumen en la conversación.

Leer `../_shared/convenciones.md` antes de tocar cualquier archivo: define la regla 3.1 ("specs primero"), dónde viven los specs, el índice, las dependencias entre specs y el documento de arquitectura. Las rutas `../_shared/` son relativas a la carpeta de esta skill.

> **Git solo por script.** Toda escritura en git (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree) se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`, nunca con `git switch`, `git add`, `git commit`, `git merge`, `git branch` o `git tag` armados a mano. El script simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`; los subcomandos sensibles exigen `--aprobado "<cita del OK del usuario>"`. No hay comandos de remoto: nada de push, pull, PR ni `gh`. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente. Detalle en `../_shared/ramas-y-commits.md` §0.

## Paso 1 — Leer el estado actual del repo

Buscar, en la raíz del proyecto donde se invocó el skill (no en la carpeta de las skills):

1. `docs/specs/README.md` — el índice. Leerlo **primero**: dice qué specs existen y, en la columna *Spec padre* (extensión de las skills), cuáles son hijos de cuál. Con eso se decide qué specs abrir y cuáles no.
2. `docs/specs/` — ¿existe? ¿tiene algún `spec-*.md`?
3. Un documento de arquitectura: `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, o `docs/arquitectura.md` — en la raíz **y en subcarpetas** de subproyectos. Distinguir un documento con contenido de arquitectura de un archivo que generó una herramienta sin ese contenido (ver `convenciones.md`).
4. Código fuente relevante a lo que el usuario está pidiendo (aunque no tenga spec).
5. **El estado de git** (v2): correr `bash ../_shared/scripts/sdd-estado.sh` (o seguir `/sdd-estado`). Dice el tronco, la rama actual, las ramas de cambio abiertas y la fase de cada una. Si ya hay una rama abierta sobre la **misma capacidad**, decirlo antes de seguir: puede ser el mismo cambio retomado o un conflicto con trabajo en curso. Si el árbol de trabajo tiene cambios sin commitear que no son de esta tarea, avisarlo.
6. **El paquete de diseño de la HU** (si existe): `docs/design/HU-0NN/` y su `design_package_HU-0NN.json`. Es **insumo**, no spec (ver `../_shared/diseno-a-spec.md`). Leerlo completo para esta HU; no abrir los de otras HU salvo que el índice las relacione.

**Qué specs abrir cuando hay relaciones padre-hijo** (extensión de las skills): si el cambio es sobre un spec hijo, leerlo completo y abrir el padre **solo si** el cambio toca lo que el hijo declara en `Referencias` que usa de él. Si el cambio es sobre el padre, abrir solo los hijos cuya relación toca el cambio. No cargar la familia entera "por las dudas".

Si `$ARGUMENTS` no deja claro qué se quiere cambiar, preguntar antes de seguir — no asumir.

## Paso 2 — Identificar la capacidad afectada y sus specs relacionadas

Una capacidad es la porción del sistema que el spec describiría (ver el criterio de tamaño en `convenciones.md`). A partir del pedido del usuario, nombrar la capacidad en kebab-case (ej. `carrito-compras`, `autenticacion`). Si no es obvio a cuál capacidad existente pertenece, o si es nueva, decirlo explícitamente. **Si el pedido viene de una historia de usuario (HU-0NN)**, decir a qué capacidad pertenece (una capacidad puede reunir varias HU como subcapacidades) o si abarca dos y debe partirse en dos cambios (`diseno-a-spec.md` §2).

**Listar las specs relacionadas**, a partir del índice y de las *Referencias* ("Depende de / Usada por") de la spec afectada. Una línea por cada una:

```
Specs relacionadas:
- spec-notificaciones.md — es consumida: reservas le avisa cuando se cancela una reserva.
- spec-autenticacion.md — consume: reservas usa su sesión para saber quién reserva.
- spec-calendario.md — posible conflicto con invariante: "un evento no puede solaparse con otro del mismo usuario".
```

Tipos de relación: **consume** / **es consumida** / **posible conflicto con invariante**. Si no hay ninguna, decirlo en una línea.

Separar además las **dependencias o riesgos por evaluar**: lo que todavía no se sabe si afecta al cambio. No se resuelven acá: pasan a `/sdd-propuesta` como decisiones abiertas y bloquean su gate.

## Paso 3 — Detectar el Caso (árbol de decisión)

Seguir este orden, no saltar pasos:

0. **Desvíos previos al árbol (v2).** Antes de clasificar en los 5 Casos, descartar dos situaciones que tienen su propia skill:
   - **¿Es un bug en algo que ya corre en producción** (el spec está bien y el código no lo cumple, o falla en uso real)? → `/sdd-hotfix`, no este árbol. Si el bug revela que el *spec* era el equivocado, vuelve acá como Caso 3.
   - **¿Cambia la forma transversal del sistema** (stack, capas, base de datos, proveedor de LLM, despliegue, convenciones de ramas)? → `/sdd-arquitectura`. No se mezcla con un cambio funcional: si el pedido combina ambos, separarlos en dos cambios, arquitectura primero.

1. **¿`docs/specs/` no existe o está vacío?**
   - **Y no hay código relevante para lo pedido** → **Caso 1** (desde cero). Ir a `references/caso1-desde-cero.md`.
   - **Y sí hay código para la capacidad en cuestión, aunque no tenga spec** → **Caso 5** (código sin spec previo). Ir a `references/caso5-fase0-ingenieria-inversa.md` — esta rama tiene su propio flujo y gate, descrito ahí, y no sigue el resto de este documento. La existencia de un `AGENTS.md`/`CLAUDE.md` no cambia esta detección: el Caso 5 lo define la ausencia de `docs/specs/`.
2. **`docs/specs/` existe. ¿Hay un spec para esta capacidad puntual?**
   - **No, pero el sistema ya tiene otras capacidades documentadas** → **Caso 2** (funcionalidad nueva). Ir a `references/caso2-funcionalidad-nueva.md`.
   - **No, pero SÍ hay código de esta capacidad ya corriendo sin documentar** (capacidad "huérfana" dentro de un sistema por lo demás documentado) → **Caso 5**, igual que arriba, pero acotado a esa capacidad.
   - **Sí, existe spec de esta capacidad. ¿Qué pide el usuario?**
     - Agregar algo que el spec **todavía no describe** — una subcapacidad nueva tal que el comportamiento ya documentado sigue siendo cierto sin ningún matiz después del cambio (ej. sección 7 de la metodología: agregar un filtro por estado al historial, que ya tenía `spec-historial.md` — sin usar el filtro, la lista sigue idéntica) → sigue siendo **Caso 2** (funcionalidad nueva), con la única diferencia de que acá el spec ya existe y en `/sdd-propuesta` se le escribe una sección nueva en vez de nacer uno (salvo que la subcapacidad nueva cumpla los cinco criterios de `verificacion-division.md` y el usuario apruebe que nazca como spec hijo). Ir a `references/caso2-funcionalidad-nueva.md`.
     - Cambiar/eliminar algo que el spec ya describe (comportamiento u obligado a tocar implementación) → **Caso 3** (modificación de un requerimiento existente). Ir a `references/caso3-modificacion-existente.md`.
     - Corregir el código para que cumpla un ítem que la Fase 0 dejó escrito como comportamiento correcto (**fix colateral** de un bug confirmado; el spec sigue `en desarrollo` por eso) → **Caso 3**, rama fix colateral. Si el spec está `en desarrollo` por fixes pendientes y lo pedido es otra cosa, decirlo: primero van los fixes colaterales.
     - Reescribir en otro lenguaje/stack sin cambiar el comportamiento → **Caso 4** (migración de lenguaje). Ir a `references/caso4-migracion-lenguaje.md`.

   **Cómo distinguir agregar de cambiar, cuando el spec ya existe:** no preguntar si el spec va a cambiar (las tres ramas lo cambian). Preguntar si lo que el spec **ya describe hoy** sigue siendo cierto, sin ningún matiz, después del cambio. Si sí → Caso 2 (se suma algo encima). Si algo que el spec ya prometía deja de cumplirse, o pasa a comportarse distinto → Caso 3.

**No asumir el Caso en silencio.** Anunciarlo explícitamente al usuario ("Esto es un Caso N porque...") antes de seguir con el resto de la fase — es la decisión que más condiciona todo lo que sigue, y es barata de corregir acá y cara de corregir después.

## Paso 4 — Ejecutar la rama del Caso detectado

Cada `references/casoN-*.md` dice exactamente qué leer, qué preguntar y qué resumen dejar para esa rama. Seguirlo. Todas las ramas (excepto Caso 5) terminan produciendo:

- Un resumen del problema (2-4 frases).
- El **Caso** confirmado.
- El **delta tentativo**: AGREGADO / MODIFICADO / ELIMINADO / NULO / 100% del sistema.
- **Qué secciones del spec se van a escribir en `/sdd-propuesta`**, a grandes rasgos (ej. "sección nueva en Comportamiento con Contrato, Límites y Modos de falla" o "solo Decisiones + Referencias").
- Los **invariantes existentes** que restringen el cambio (citados del spec leído, con su "porqué").
- Las **specs relacionadas** (Paso 2) y las **dependencias o riesgos por evaluar**.
- **Si hay paquete de diseño:** la **tabla de cobertura** *requisito de la HU → dónde aparece en el paquete* (`diseno-a-spec.md` §5), con las señales de paquete genérico o incompleto. Un paquete que no la pasa se devuelve al generador del diseño; **no se completa inventando** y bloquea el gate de `/sdd-propuesta`.

Este resumen es el input que `/sdd-propuesta` va a necesitar a continuación — dejarlo explícito en la respuesta, no implícito.

## Paso 5 — Verificación de división del spec

Extensión de las skills (no está en la metodología v4). Correr siempre, sobre el spec afectado **tal como está hoy**, siguiendo `../_shared/verificacion-division.md`: medir los disparadores y, si alguno se activa, evaluar los cinco criterios y usar el formato de salida de ese archivo.

- Si no hay disparadores: una sola línea en el resumen, no más.
- Si se cumplen los cinco criterios: **recomendar** la división y preguntarle al usuario si la aprueba. No dividir acá aunque apruebe — esta fase no toca specs; la división se aplica en `/sdd-propuesta`, en un commit propio, antes de escribir el delta. Dejar la respuesta del usuario escrita en el resumen.
- Si el usuario niega: decir que quedará registrado en `Decisiones` del spec cuando se escriba el delta en `/sdd-propuesta`.

En Caso 5, esta verificación corre dentro de la Fase 0, sobre el spec candidato — ver esa referencia.

## Paso 6 — Cerrar la fase

Terminar siempre indicándole al usuario:
- Qué Caso se detectó y por qué.
- Que la próxima fase es `/sdd-propuesta`, donde **se crea la rama del cambio, se escribe y se aprueba el delta del spec antes de codificar** (excepto en Caso 5, donde primero hay que cerrar la revisión humana de la Fase 0 — ver esa referencia).
- **La rama que se propone** (`<tipo>/<capacidad>-<slug>`, según `../_shared/ramas-y-commits.md` §2). La Exploración **no la crea**: no escribe nada. Si el cambio es una fase de un plan con varias, decir que `/sdd-ramas` puede armar el mapa de ramas completo.
- **Encadenamiento:** una vez que el usuario confirma el Caso y el alcance, la siguiente skill (`sdd-propuesta`) se invoca sola; no hace falta que el usuario escriba ningún comando. Si el cambio resulta ser de la **vía rápida** (`../_shared/ciclo-de-vida.md`), decirlo y seguir por ahí en vez de abrir una propuesta.
- Si quedó algo por confirmar antes de seguir (nombre de la capacidad, alcance), preguntarlo ahora, no dejarlo para la fase siguiente.

## Sesión nueva sin historial de esta fase

Si `/sdd-propuesta`, `/sdd-aplicacion` o `/sdd-verificacion` se invocan sin que esta fase haya corrido en la misma conversación, esa skill **recupera el estado desde git** con `sdd-estado.sh`: la rama, los trailers `SDD-Caso` y `SDD-Fase` de sus commits y el spec `en desarrollo`. El Caso queda en el trailer `SDD-Caso` del commit de propuesta; el delta, en el spec commiteado; los criterios, en el plan o en el cuerpo del commit de propuesta. Solo si algo de eso no existe, la skill se lo pide al usuario.

## Referencias

- `../_shared/convenciones.md` — regla 3.1, rutas, dependencias entre specs.
- `../_shared/plantilla-spec.md` — formato fijo del spec (necesario para leer specs existentes con criterio, y obligatorio en la rama Caso 5).
- `../_shared/verificacion-division.md` — extensión de las skills (Paso 5).
- `../_shared/ciclo-de-vida.md` — mapa completo de skills (v2); `../_shared/ramas-y-commits.md` — rama propuesta y estado en git.
- `../_shared/diseno-a-spec.md` — paquete de diseño por HU, HU ↔ capacidad, cobertura del paquete.
- `../_shared/scripts/sdd-estado.sh` — estado del ciclo leído de git.
- `references/caso1-desde-cero.md`
- `references/caso2-funcionalidad-nueva.md`
- `references/caso3-modificacion-existente.md`
- `references/caso4-migracion-lenguaje.md`
- `references/caso5-fase0-ingenieria-inversa.md`
