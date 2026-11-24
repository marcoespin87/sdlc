# Del paquete de diseño al spec (fase de Diseño)

> **Extensión de las skills.** Cubre el caso en que la fase de Diseño produce, por cada historia de usuario (HU), un **paquete de diseño** (arquitectura, modelo de datos, contrato de API, UI, seguridad, plan técnico). Ese paquete es **insumo**: `sdd-exploracion` lo lee y `sdd-propuesta` lo convierte en spec, criterios `CA-NN` y plan. Lo que sale de Diseño hacia Desarrollo es el **spec aprobado**; el paquete queda **referenciado** desde él, no copiado.

## 1. Qué es el paquete y dónde vive

Carpeta `docs/design/HU-0NN/` (si el proyecto ya usa otra ruta, respetarla; ver `convenciones.md`). Nombres tal como los genera el diseñador; no se renombran.

| Archivo | Contenido |
|---|---|
| `00_ACTA_APROBACION_DOR.md` | Definition of Ready: criterios de diseño y firmas por rol (`[ ] Aprobado` → `[x] Aprobado`) |
| `01_ARQUITECTURA_C4_Y_ADR.md` | C4 contexto y contenedores, diagrama de secuencia, ADR de la HU |
| `02_MODELO_DATOS_ERD.md`, `02_SCHEMA_DDL.sql` | ERD, diccionario de datos y DDL |
| `03_OPENAPI_CONTRATO.json` | Contrato OpenAPI 3.1 (errores Problem Details, mocks) |
| `04_UI_ESPECIFICACION_4_ESTADOS.md`, `04_PROTOTIPO_VISUAL.html` | Estados de pantalla (vacío, cargando, éxito, error), tokens, prototipo |
| `05_MATRIZ_SEGURIDAD_ACCESOS.md` | Roles y permisos, mitigaciones OWASP, clasificación de datos |
| `06_PLAN_CONSTRUCCION_WBS.md` | Tareas por capa (`TASK-BD/BE/FE/QA-NN`), criterios de salida, dependencias, estructura de repositorio |
| `design_package_HU-0NN.json` (opcional) | Índice consolidado legible por máquina, con `provenance` y `human_gate` |

**Precedencia:** `spec` > documento de arquitectura / ADR > paquete de diseño. El paquete es una propuesta de diseño hasta que el spec aprobado la recoge; si lo contradice, gana el spec y el paquete se corrige en el generador, no a mano en el spec.

## 2. HU y capacidad

La unidad de las skills es la **capacidad** (`spec-<capacidad>.md`); la de Diseño es la **HU**.

| Situación | Qué se hace |
|---|---|
| Una HU, capacidad nueva | Nace el spec (Caso 1 o 2) |
| Varias HU de la misma capacidad | Mismo spec; cada HU es una **subcapacidad** (sección nueva en *Comportamiento*) y **un cambio propio**: su rama, su Gate 1, su commit de propuesta |
| Una HU sobre una capacidad que ya existe | Cambio sobre ese spec (Caso 2 si agrega, Caso 3 si cambia lo prometido) |
| Una HU que abarca dos capacidades | Se parte en dos cambios, en orden de dependencia (`/sdd-ramas`) |

La relación se registra en tres lugares: la columna *Historias* del índice `docs/specs/README.md`, la línea `Historias:` de *Referencias* del spec y el trailer `SDD-HU` de los commits.

## 3. Tabla de mapeo: del paquete al spec y a la arquitectura

| Del paquete | Va a | Cómo |
|---|---|---|
| OpenAPI (operaciones, entradas, salidas) | Spec → *Contrato* | Tabla en forma **observable**: operación, quién, respuesta, entrada/salida con su significado. El `.json` se referencia como forma exacta. |
| OpenAPI (errores Problem Details) | Spec → *Modos de falla* | Un ítem por error relevante, con lo que ve quien llama |
| DDL y diccionario de datos | Spec → *Referencias* (forma exacta) | El `.sql` se referencia y luego se implementa como migración. No se copia. |
| Reglas del DDL (`UNIQUE`, `FK RESTRICT`, `CHECK` de estados, baja lógica) | Spec → *Invariantes* y *Límites y defaults* | Cada invariante lleva su porqué |
| ERD | Queda en el paquete | Se referencia; no se duplica en el spec |
| Diagrama de secuencia | Spec → *Flujo* | Resumido en prosa; el diagrama se referencia |
| C4 contexto y contenedores | `docs/arquitectura.md` | **Una vez por proyecto**, no por HU (en un Caso 1 lo escribe `sdd-propuesta`; después, `sdd-arquitectura`) |
| ADR de la HU | `docs/adr/NNNN-*.md` o *Decisiones* | Si es transversal (p. ej. «monolito modular»), un solo ADR global vía `sdd-arquitectura`; si es propio de la capacidad, *Decisiones* del spec, con fecha |
| UI de 4 estados | Spec → *Contrato* (pantalla), *Flujo*, *Modos de falla* (error) y *Límites* (carga) | Cada estado se vuelve un `CA-NN` |
| Tokens de diseño | `docs/arquitectura.md` | Convención transversal de UI |
| Prototipo HTML | Spec → *Referencias* | Solo se referencia |
| Matriz de roles | Spec → *Alcance* (roles) y *Contrato* (columna «quién») | Cada fila permitida y cada fila denegada genera un `CA-NN` |
| Restricciones y mitigaciones (baja lógica, filtro por sucursal, BOLA, inyección) | Spec → *Invariantes* | Cada mitigación genera un `CA-NN` que intenta violar el invariante |
| Clasificación de datos | `docs/arquitectura.md` (invariantes de seguridad) | Transversal |
| Plan WBS | `docs/plan-<tema>-<fecha>.md` | Las tareas pasan a *Tareas* con los `CA-NN` que cubren; las dependencias (`bloqueada_por`) alimentan el *Mapa de ramas*; la estructura de repo va a `docs/arquitectura.md` |
| Cobertura mínima (p. ej. 80 %) | `docs/arquitectura.md` | Umbral **del proyecto**; `sdd-verificacion` lo mide |
| Acta DoR | Gate 1 de `sdd-propuesta` | Ver §6 |
| `design_package_*.json` | Lo lee `sdd-exploracion` | No se duplica en el spec; Desarrollo no lo necesita |

## 4. Cómo se derivan los `CA-NN` del paquete

Además de los tipos de `criterios-y-pruebas.md` §1, `sdd-propuesta` crea al menos un criterio por cada:

1. **Operación del contrato** (camino feliz y cada error documentado).
2. **Fila de la matriz de roles**, permitida y denegada (la denegada intenta la acción y espera el rechazo).
3. **Estado de pantalla** (vacío, cargando, éxito, error). Verificación automática si hay prueba de interfaz; si no, manual con pasos exactos.
4. **Mitigación de seguridad** (BOLA/IDOR, inyección, exposición de datos): un criterio que intenta romperla.
5. **Regla del DDL** que sea invariante (unicidad, integridad referencial, baja lógica).
6. **Criterio Gherkin de la HU**, si existe (viene de Planificación): se traduce a `CA-NN`.

Cada `CA-NN` indica en la matriz de trazabilidad de qué archivo del paquete salió. Un ítem del paquete sin criterio es un hueco, igual que un ítem del spec sin criterio.

## 5. Cobertura del paquete (la hace `sdd-exploracion`, antes de proponer)

Antes de escribir un spec a partir del paquete, comprobar y reportar en una tabla corta *requisito de la HU → dónde aparece en el paquete*:

- Cada requisito y cada criterio Gherkin de la HU aparece en el paquete (por ejemplo: «doble aprobación», «MFA», «multimoneda»). Si falta, **no se inventa**: se devuelve al generador del diseño.
- El modelo de datos no es genérico para todas las HU (mismas columnas y nombres derivados solo del título). Señales de plantilla: nombres mal pluralizados, la misma tabla en historias distintas, tablas o APIs «reutilizadas» sin relación con la historia.
- Los roles del acta y de la matriz coinciden con los de la HU.

Un paquete que no pasa esta revisión **bloquea el gate de `sdd-propuesta`**, como cualquier decisión abierta.

## 6. Gate 1 con varios aprobadores (acta DoR)

- Los roles que deben aprobar se declaran en `docs/arquitectura.md`, sección *Flujo de trabajo*: `- **Aprobadores del Gate 1:** Arquitecto de Software, Líder Técnico, Diseñador UI/UX, Oficial de Seguridad`. Sin declaración, el Gate 1 sigue siendo de una sola persona.
- `sdd-propuesta` muestra el diff del spec y los `CA-NN` y pide el OK **a cada rol**. **El agente no firma por nadie:** la marca `[x] Aprobado` (con nombre y fecha) la pone la persona; el agente solo puede editarla si esa persona la pide en el chat.
- El commit de propuesta lleva `--hu HU-0NN` y `--aprobado` con la cita de **cada rol**, por ejemplo `Arquitecto: «…»; Líder técnico: «…»; UI/UX: «…»; Seguridad: «…»`. Queda en `.git/sdd-aprobaciones.log`.
- `sdd-git.sh commit --fase propuesta --hu HU-0NN` **rechaza** el commit mientras el acta tenga `[ ] Aprobado` sin marcar.

## 7. Qué leen las fases siguientes

- **`sdd-aplicacion`:** el spec y, como **formas exactas de solo lectura**, los archivos de `docs/design/` que el spec referencia (migración DDL, OpenAPI y sus mocks). Si el código no puede cumplirlos, es un hallazgo (Paso 4), no un ajuste silencioso.
- **`sdd-verificacion`:** valida el contrato implementado contra el OpenAPI, el esquema migrado contra el DDL, los estados de pantalla y la matriz de roles, mediante los `CA-NN` derivados; y mide el umbral de cobertura que declare `docs/arquitectura.md`.
- **`sdd-ramas`:** una rama por HU, ordenadas con las dependencias del WBS y las dependencias entre specs.
