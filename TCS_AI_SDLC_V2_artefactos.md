# Insumos y entregables por fase (diapositiva 8 de `TCS_AI_SDLC_V2.pptx`, cinco fases)

Cada fase se lee en dos tablas separadas:

- **Insumos**: lo que **entra** a la fase. La columna *Viene de* dice qué fase, skill o persona lo produjo.
- **Entregables**: lo que **sale** de la fase. La columna *Producido por* dice quién lo genera y *Aprobación* si requiere OK humano.

Rutas y extensiones según la estructura de las skills SDD (`skills/_shared/convenciones.md` y `skills/_shared/diseno-a-spec.md`).
Los marcados **Nuevo** no los producía ninguna skill antes de esta adaptación: son propuesta.
Lo que sale de una fase es el insumo de la siguiente, por eso algunos artefactos aparecen en las dos listas.

**Idea central de Diseño:** el paquete de diseño por historia (HU) es **insumo**; lo que Diseño entrega a Desarrollo es el **spec aprobado, los criterios `CA-NN` y el plan**, con el paquete referenciado como forma exacta. Una capacidad puede reunir una o varias HU; cada HU es un cambio con su rama y su Gate 1.

---

## 1. Planificación (sin skills: actividad de personas)

### Insumos
| Artefacto | Extensión / ruta | Viene de |
|---|---|---|
| Necesidades de negocio | `.docx` | Negocio |
| Contexto y restricciones | `.md` | Negocio / equipo |
| Normativas y SLOs | `.pdf` | Cumplimiento / negocio |
| Sistemas existentes | repositorio | Equipo técnico |

### Entregables
| Artefacto | Extensión / ruta | Producido por | Aprobación |
|---|---|---|---|
| Requerimientos funcionales y no funcionales | `.md` | Persona | Persona |
| Épicas e Historias + Gherkin | `.md` / `.feature` | Persona | Persona |
| Backlog / Roadmap | `.xlsx` / `.md` | Persona | Persona |
| Glosario de dominio | `.md` | Persona | Persona |
| **Pedido priorizado para SDD** (**Nuevo**) | `.md` o texto de ticket | Persona | Persona. Es lo que recibe `sdd-exploracion` como `$ARGUMENTS` |

---

## 2. Diseño (`sdd-exploracion`, `sdd-propuesta`)

### Insumos
| Artefacto | Extensión / ruta | Viene de |
|---|---|---|
| Pedido e Historias | `.md` | Planificación |
| **Paquete de diseño por HU** | `docs/design/HU-0NN/`: acta DoR (`00_*.md`), arquitectura C4 + ADR (`01_*.md`), modelo de datos (`02_*.md`, `02_*.sql`), OpenAPI (`03_*.json`), UI y prototipo (`04_*.md`, `04_*.html`), matriz de seguridad (`05_*.md`), plan WBS (`06_*.md`), índice `design_package_HU-0NN.json` | Generador de diseño (IA) + roles de diseño |
| Specs existentes e índice | `docs/specs/spec-<capacidad>.md`, `docs/specs/README.md` | Cambios anteriores (`sdd-propuesta`) |
| Arquitectura y ADRs | `docs/arquitectura.md` (o `AGENTS.md` / `CLAUDE.md`), `docs/adr/NNNN-*.md` | `sdd-arquitectura` |
| Código existente | repositorio | Desarrollo |
| Bocetos / Figma | enlace | Diseño UX (persona) |

### Entregables
| Artefacto | Extensión / ruta | Producido por | Aprobación |
|---|---|---|---|
| **Resumen + Caso + cobertura del paquete** (**Nuevo**) | conversación: Caso 1 a 5 y tabla *requisito de la HU → dónde aparece en el paquete* | `sdd-exploracion` | Persona confirma el Caso. Un paquete incompleto o genérico se devuelve al generador y bloquea el gate |
| Spec + índice con *Historias* | `docs/specs/spec-<capacidad>.md`, `docs/specs/README.md` (columna *Historias*) | `sdd-propuesta` | Gate 1 |
| Criterios de aceptación `CA-NN` derivados del paquete | `.md`: en el plan; sin plan, en el cuerpo del commit de propuesta | `sdd-propuesta` | Gate 1 |
| Plan = WBS + `CA-NN` | `docs/plan-<tema>-AAAA-MM-DD.md` (tareas `TASK-BD/BE/FE/QA-NN` con los criterios que cubren; dependencias → mapa de ramas) | `sdd-propuesta` | Gate 1 |
| Arquitectura: C4, tokens de UI, clasificación de datos, estructura de repo, umbral de cobertura, aprobadores del Gate 1 | `docs/arquitectura.md` (una vez por proyecto; en un Caso 1 la escribe `sdd-propuesta`, después `sdd-arquitectura`) | `sdd-propuesta` | Gate 1 |
| Rama + commit de propuesta | git: `<tipo>/<capacidad>-<slug>`, trailers `SDD-*` + `SDD-HU` | `sdd-propuesta` | Gate 1 |
| Paquete de diseño referenciado | `docs/design/HU-0NN/` (OpenAPI, DDL, ERD, UI, prototipo), citado en *Referencias → Diseño* del spec | Generador de diseño | Acta DoR firmada por los roles |

### Cómo se mapea el paquete al spec (resumen; detalle en `skills/_shared/diseno-a-spec.md`)
| Del paquete | Va a |
|---|---|
| OpenAPI | Spec → *Contrato* (forma observable) y *Modos de falla* (errores); el `.json` se referencia como forma exacta |
| DDL | Se referencia (forma exacta); sus reglas pasan a *Invariantes* con su porqué |
| ERD, prototipo HTML, JSON del paquete | Solo se referencian; no se copian |
| C4, tokens de UI, clasificación de datos, estructura de repo | `docs/arquitectura.md` (una vez por proyecto) |
| ADR de la HU | ADR global en `docs/adr/` si es transversal; si no, *Decisiones* del spec |
| UI de 4 estados | *Contrato*, *Flujo*, *Modos de falla*; un `CA-NN` por estado |
| Matriz de seguridad | *Alcance* y *Contrato* (roles), *Invariantes*; un `CA-NN` por fila y por mitigación |
| Plan WBS | `docs/plan-*.md` con los `CA-NN` por tarea |
| Acta DoR (4 firmas) | Gate 1 con varios aprobadores; `sdd-git.sh --hu` rechaza el commit mientras haya `[ ] Aprobado` |

---

## 3. Desarrollo (`sdd-aplicacion`, `sdd-arquitectura`, `sdd-ramas`, `sdd-estado`)

### Insumos
| Artefacto | Extensión / ruta | Viene de |
|---|---|---|
| Spec aprobado | commit de propuesta | Diseño (`sdd-propuesta`) |
| Criterios `CA-NN` y plan WBS | `.md`: `docs/plan-*.md` | Diseño (`sdd-propuesta`) |
| OpenAPI y DDL referenciados | `docs/design/HU-0NN/03_*.json`, `02_*.sql` (solo lectura) | Diseño (referenciados en el spec) |
| Arquitectura y ADRs | `docs/arquitectura.md`, `docs/adr/*.md` | `sdd-propuesta` / `sdd-arquitectura` |
| Código y pruebas existentes | repositorio | Cambios anteriores |
| Pedido transversal y estado git | conversación; ramas y trailers `SDD-*`, `SDD-HU` | Persona (para `sdd-arquitectura`) y git (para `sdd-estado` y `sdd-ramas`) |

### Entregables
| Artefacto | Extensión / ruta | Producido por | Aprobación |
|---|---|---|---|
| Pruebas por criterio | `tests/**`, con `CA-NN` en el nombre o marcador | `sdd-aplicacion` | — |
| Código fuente | `src/**`, en commits pequeños, cumpliendo OpenAPI y DDL | `sdd-aplicacion` | Si hay hallazgo, la persona aprueba el ajuste del spec |
| ADR global consolidado | `docs/adr/NNNN-titulo-en-kebab.md` | `sdd-arquitectura` | Persona |
| Arquitectura actualizada | `docs/arquitectura.md` | `sdd-arquitectura` | Persona |
| Mapa de ramas por HU | sección del plan `.md` | `sdd-ramas` | Persona |
| Estado del ciclo | salida de `sdd-estado.sh` | `sdd-estado` (script) | — |
| Registro de aprobaciones | `.git/sdd-aprobaciones.log` | Script `sdd-git.sh` | — |

---

## 4. Testing (`sdd-verificacion`)

### Insumos
| Artefacto | Extensión / ruta | Viene de |
|---|---|---|
| Código construido | rama con sus commits | Desarrollo (`sdd-aplicacion`) |
| Spec y criterios `CA-NN` | `docs/specs/spec-<capacidad>.md`, `.md` | Diseño (`sdd-propuesta`) |
| OpenAPI y DDL referenciados | `docs/design/HU-0NN/03_*.json`, `02_*.sql` | Diseño |
| Pruebas del proyecto | `tests/**` | Desarrollo (`sdd-aplicacion`) |
| Umbral de cobertura | `docs/arquitectura.md` | Diseño (arquitectura) |

### Entregables
| Artefacto | Extensión / ruta | Producido por | Aprobación |
|---|---|---|---|
| Matriz criterio → prueba → resultado | `.md`: en el plan; sin plan, en el commit de propuesta | `sdd-verificacion` | — |
| Reporte de verificación (valida contrato, esquema, estados y roles) | cuerpo del commit de merge (`plantilla-reporte.md`) | `sdd-verificacion` | Gate 2 |
| Spec ajustado o recortado a lo construido | `docs/specs/spec-<capacidad>.md` | `sdd-verificacion` | Persona |
| Cambio integrado | merge `--no-ff` al tronco | `sdd-verificacion` | Gate 2 |
| **Informe de cobertura** (**Nuevo**) | `.xml` / `.html`; se mide contra el umbral de `arquitectura.md` | `sdd-verificacion` | — |

---

## 5. Entrega & Operación, última fase (`sdd-hotfix`)

### Insumos
| Artefacto | Extensión / ruta | Viene de |
|---|---|---|
| Descripción del fallo | texto | Persona / usuario |
| Registros del incidente | `.log` / `.txt` | Operación |
| Spec de la capacidad | `docs/specs/spec-<capacidad>.md` | Diseño y Testing |
| Pruebas existentes | `tests/**` | Desarrollo |

### Entregables
| Artefacto | Extensión / ruta | Producido por | Aprobación |
|---|---|---|---|
| Prueba de regresión `CA-HF-NN` | `tests/**` | `sdd-hotfix` | — |
| Arreglo mínimo | `src/**` | `sdd-hotfix` | — |
| Post-mortem | `docs/postmortems/AAAA-MM-DD-<slug>.md` | `sdd-hotfix` | Persona |
| Merge de `hotfix/<capacidad>-<slug>` | git | `sdd-hotfix` | Persona |
| Criterio permanente en el spec (si el fallo escapó por falta de criterio) | `docs/specs/spec-<capacidad>.md`, por `sdd-propuesta` | `sdd-propuesta` | Gate 1 |
| **Retroalimentación al backlog** (**Nuevo**) | `.md` | Persona, desde el post-mortem | Persona. Cierra el ciclo hacia Planificación |
