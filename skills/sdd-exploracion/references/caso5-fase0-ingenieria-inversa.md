# Caso 5 — Código sin spec previo (Fase 0: ingeniería inversa de especificación)

Hay código real corriendo, pero nunca se documentó formalmente. Antes del ciclo normal de 4 fases, hay que ejecutar, **una sola vez por capacidad y de forma incremental**, la Fase 0. Nunca documentar "todo el sistema de una vez" — no es revisable por un humano.

**Es una de las dos únicas excepciones a la regla "spec primero"** (regla 3.1 de la metodología v4): acá el código existe primero por definición. La otra es un spike descartable que no se mergea.

Esta rama reemplaza el resto del flujo de Exploración para la capacidad en cuestión. No sigue a `/sdd-propuesta` hasta que el spec candidato de esta capacidad quede validado.

Las rutas `../../_shared/` de este archivo son relativas a este archivo (equivalen a `../_shared/` desde la carpeta de la skill).

## Paso 1 — Elegir UNA capacidad

Si el usuario no especificó cuál, elegir la más chica o más aislada del código para empezar (menos dependencias con el resto). Decir explícitamente cuál se eligió y por qué. No intentar cubrir varias capacidades en la misma invocación.

Una capacidad puede cruzar subproyectos (backend + frontend): se describe en **un solo spec**, no uno por subproyecto.

## Paso 2 — Redactar el spec candidato

Usar `../../_shared/plantilla-spec.md` como formato — incluidas las sub-secciones de *Comportamiento* que apliquen (*Alcance*, *Contrato*, *Flujo*, *Límites y defaults*, *Modos de falla*) — con una regla adicional obligatoria para Fase 0: **marcar cada afirmación de Comportamiento e Invariantes como `[Confirmado por test]`, `[Confirmado por docs]` o `[Inferido del código]`** — nunca mezclar dos etiquetas en el mismo ítem; si una parte de un ítem está confirmada y otra inferida, partirlo en dos ítems separados.

- `[Confirmado por test]`: hay un test que ejercita exactamente ese comportamiento y pasa.
- `[Confirmado por docs]`: hay documentación previa (README, comentarios, tickets) que lo describe, aunque no haya test.
- `[Inferido del código]`: solo se dedujo leyendo el código — es lo que el código *hace*, no necesariamente lo que *debería* hacer.

Si un ítem está confirmado a la vez por test y por docs, lleva **una sola** de las dos etiquetas.

**Si la documentación afirma algo que el código no hace**, no elegir uno de los dos en silencio: es una **contradicción**. Escribirla como tal en el candidato y llevarla al gate (Paso 6).

Ubicar cada ítem en la sub-sección que le corresponde: un tope va en *Límites y defaults* aunque el código lo valide junto con el contrato; lo que pasa cuando algo falla va en *Modos de falla*. No mandar topes a *Invariantes* salvo que haya una razón de negocio para que nunca cambien.

`Estado` del spec candidato: `en desarrollo` — todavía no pasó la revisión humana.

## Paso 2b — Verificación de división del spec candidato

Extensión de las skills (no está en la metodología v4). Antes de llevarlo a la revisión humana, correr `../../_shared/verificacion-division.md` sobre el candidato recién redactado. Dos particularidades de la Fase 0:

- **El criterio 3 ("cambia sola") se mide con el `git log` del código**, no con planes: qué archivos de esta capacidad cambian juntos en los últimos commits. Si el historial no alcanza para afirmarlo, el criterio no se cumple.
- Si se cumplen los cinco criterios, **proponerle al humano escribir el candidato ya como spec padre + spec hijo** en vez de documentar un spec enorme y dividirlo después.

Si no se recomienda dividir, reportarlo en una línea y no escribir nada al respecto en el spec.

## Paso 3 — Señalar bugs y código muerto aparte, sin corregirlos

Si durante la lectura aparece algo que parece un bug o código muerto, **listarlo aparte, fuera del spec**, con la ruta exacta. No corregirlo en este paso — la corrección va en un cambio separado, después de que el humano confirme que efectivamente es un bug y no una decisión rara pero intencional.

**Qué es y qué no es código muerto:**

| Es código muerto | **No** es código muerto |
|---|---|
| Una función, clase o constante exportada que nada referencia: ni otro módulo, ni una ruta, ni un test | Un endpoint registrado en el router aunque el frontend no lo llame: se puede invocar por HTTP. Si no está documentado, es un hallazgo de documentación, no código muerto |
| Una rama de código inalcanzable | Una función que solo usan los tests |
| Un archivo que ningún import alcanza | Un campo que el frontend no muestra pero la API devuelve |

Buscar referencias con búsqueda de texto en todo el repo antes de declarar algo muerto, y decir en el hallazgo cómo se comprobó.

**Otros hallazgos que van aparte:** efectos colaterales de los tests sobre datos reales, configuración que depende del entorno (zona horaria, rutas absolutas), y dependencias entre subproyectos no documentadas.

## Paso 4 — Documento de arquitectura

Seguir `../../_shared/convenciones.md`, sección "Documento de arquitectura y convenciones":

- **Si ya existe uno con contenido de arquitectura**, se reutiliza: no se crea otro ni se reescribe en este paso (se actualiza aparte, por un cambio dedicado).
- **Si solo existe un archivo de contexto generado por una herramienta sin contenido de arquitectura** (ejemplo real: el `AGENTS.md`/`CLAUDE.md` que escribe Next.js 16), no cuenta: crear `docs/arquitectura.md` y agregar al archivo de contexto una línea que enlace a él, sin borrar lo que escribió la herramienta.
- **Si no existe ninguno**, crearlo (sección 6 de la metodología: nace en la Propuesta de un Caso 1, o en la Fase 0 de un Caso 5).

Contenido mínimo en `convenciones.md`, incluida la instrucción de la regla 3.1: de acá en adelante, leer el spec antes de proponer y escribir el delta del spec antes de codificar.

## Paso 5 — Índice

Crear `docs/specs/README.md` si no existe (tabla Capacidad → Spec → Spec padre). Si ya existe, agregar la fila de esta capacidad — y la de cada spec hijo, con su padre en la última columna.

## Paso 6 — Gate: revisión humana obligatoria

Esto **no es opcional**, a diferencia del resto de los gates de Exploración que son solo una confirmación rápida. Presentar al humano, en este orden:

1. Las **contradicciones** entre documentación y código.
2. Todo lo marcado `[Inferido del código]` — esto es lo que más riesgo tiene de documentar un bug como si fuera comportamiento correcto.
3. Los bugs, código muerto y demás hallazgos del Paso 3, cada uno con cómo se comprobó.
4. Preguntar explícitamente, **por cada ítem**: "¿esto es comportamiento correcto, o es un bug?" — no un "¿apruebas?" genérico.
5. La recomendación de división del Paso 2b, si la hubo, para que el humano la apruebe o la niegue junto con el resto.

No avanzar a `/sdd-propuesta` para esta capacidad hasta tener esa confirmación. Cuando el humano confirma o corrige el spec candidato:

- **Si confirma que lo inferido es correcto:** el ítem queda como está, con su etiqueta.
- **Si confirma que algo es un bug:** reescribir ese ítem para describir el comportamiento **correcto**, completo (preguntar al humano lo que haga falta para que sea verificable: qué responde, qué ve el usuario). **Sin aclaraciones del tipo "hoy el código no lo cumple"**: el spec no guarda estados transitorios. El bug queda listado **fuera del spec** como **fix colateral pendiente**, con la ruta y cómo se comprobó (ver `plantilla-spec.md`, sección "Bug confirmado en la Fase 0").
- **Si confirma código muerto:** no se describe en el spec (lo que no se usa no es comportamiento). Queda como pendiente de un cambio de limpieza aparte, fuera del spec.
- **Si descarta un hallazgo** (no era bug ni código muerto): no dejar rastro en el spec.
- Con la revisión completa: si **no** quedaron fixes colaterales pendientes, cambiar `Estado` a `desplegado`. Si quedaron, el spec sigue `en desarrollo`: la v4 lo da por validado recién cuando esos fixes se cierran (diagrama de la Fase 0: bug → fix colateral → spec validado).

**Ningún arreglo de código entra en este cambio.** Los fixes van en cambios separados del que crea el spec (rama de fix colateral), para que el diff del spec quede limpio y revisable por sí solo.

## Paso 7 — Cerrar el baseline

Con la revisión humana cerrada, proponer el cierre del baseline **solo con `docs/`** (spec, índice, documento de arquitectura): en una rama propia `baseline/<capacidad>` (`../../_shared/ramas-y-commits.md` §2), con un commit `docs(<capacidad>): baseline del spec` y trailers `SDD-Caso: 5`, con su propio merge local. En el cuerpo del commit de propuesta (o en el mensaje del merge) listar los **fixes colaterales pendientes** y el código muerto a limpiar. Crear la rama, commitear y mergear piden el OK del usuario según `ramas-y-commits.md` §4.

## Qué pasa después

**Primero, los fixes colaterales.** Si quedaron bugs confirmados, cada uno es un cambio propio (Caso 3, rama "fix colateral" de `sdd-propuesta/references/caso3.md`): el comportamiento correcto ya está escrito y aprobado desde esta revisión, así que ese cambio corrige el código para que cumpla el spec. Al cerrar el último fix, el spec pasa a `desplegado`. Mientras tanto, no entran otros cambios sobre esta capacidad.

Una vez que el spec de esta capacidad queda en `Estado: desplegado`, cualquier cambio futuro sobre ella deja de ser Fase 0 y **va spec primero**: se comporta como Caso 2 (si agrega algo) o Caso 3 (si modifica algo) — usar `/sdd-exploracion` de nuevo normalmente, va a detectar el spec y seguir el árbol de decisión estándar. El delta del spec se escribirá y aprobará en `/sdd-propuesta`, antes del código.

Las demás capacidades del sistema heredado siguen pasando por esta misma Fase 0, una por una, cuando se las toque (o en un baseline dedicado si se quiere adelantar trabajo).
