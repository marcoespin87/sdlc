# Insumos y entregables por fase (diapositiva 8 de `TCS_AI_SDLC_V2.pptx`)

Cada fase se lee en dos tablas separadas:

- **Insumos**: lo que **entra** a la fase. La columna *Viene de* dice qué fase, skill o persona lo produjo.
- **Entregables**: lo que **sale** de la fase. La columna *Producido por* dice quién lo genera y *Aprobación* si requiere OK humano.

Rutas y extensiones según la estructura de las skills SDD (`skills/_shared/convenciones.md`).
Los marcados **Nuevo** no los produce hoy ninguna skill: son propuesta.
Lo que sale de una fase es el insumo de la siguiente, por eso algunos artefactos aparecen en las dos listas.

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
| Specs existentes e índice | `docs/specs/spec-<capacidad>.md`, `docs/specs/README.md` | Cambios anteriores (`sdd-propuesta`) |
| Arquitectura y ADRs | `docs/arquitectura.md` (o `AGENTS.md` / `CLAUDE.md`), `docs/adr/NNNN-*.md` | `sdd-arquitectura` |
| Código existente | repositorio | Desarrollo |
| Bocetos / Figma | enlace | Diseño UX (persona) |

### Entregables
| Artefacto | Extensión / ruta | Producido por | Aprobación |
|---|---|---|---|
| Resumen + Caso (1 a 5) | conversación (no escribe archivos) | `sdd-exploracion` | Persona confirma el Caso |
| Spec del cambio + índice actualizado | `docs/specs/spec-<capacidad>.md`, `docs/specs/README.md` | `sdd-propuesta` | Gate 1 |
| Criterios de aceptación `CA-NN` | `.md`: en el plan; sin plan, en el cuerpo del commit de propuesta | `sdd-propuesta` | Gate 1 |
| Plan por fases (solo si hay fases, alternativas o decisiones abiertas) | `docs/plan-<tema>-AAAA-MM-DD.md` | `sdd-propuesta` | — |
| Rama + commit de propuesta | git: `<tipo>/<capacidad>-<slug>`, trailers `SDD-*` | `sdd-propuesta` | Gate 1 |
| **Contrato exacto** (**Nuevo**) | `.yaml` (OpenAPI) / `.json` (JSON Schema) / `.sql` (migraciones), referenciado desde el spec | `sdd-propuesta` | Gate 1. El spec solo guarda la forma observable |

---

## 3. Desarrollo y Testing (`sdd-aplicacion`, `sdd-verificacion`, `sdd-arquitectura`, `sdd-estado`, `sdd-ramas`)

### Insumos
| Artefacto | Extensión / ruta | Viene de |
|---|---|---|
| Spec aprobado | commit de propuesta | Diseño (`sdd-propuesta`) |
| Criterios de aceptación `CA-NN` | `.md` | Diseño (`sdd-propuesta`) |
| Plan, tareas y mapa de ramas | `docs/plan-*.md` | Diseño (`sdd-propuesta`) |
| Arquitectura y ADRs | `docs/arquitectura.md`, `docs/adr/*.md` | `sdd-arquitectura` |
| Código y pruebas existentes | repositorio | Cambios anteriores |
| Pedido de cambio transversal | conversación | Persona (para `sdd-arquitectura`) |
| Índice y dependencias de specs | `docs/specs/README.md` | `sdd-propuesta` (para `sdd-ramas`) |
| Estado del repositorio | git: ramas, trailers `SDD-*` | Git (para `sdd-estado`) |

### Entregables
| Artefacto | Extensión / ruta | Producido por | Aprobación |
|---|---|---|---|
| Pruebas por criterio | `tests/**`, con `CA-NN` en el nombre o marcador | `sdd-aplicacion` | — |
| Código fuente | `src/**`, en commits pequeños | `sdd-aplicacion` | — |
| ADR | `docs/adr/NNNN-titulo-en-kebab.md` | `sdd-arquitectura` | Persona |
| Arquitectura actualizada | `docs/arquitectura.md` | `sdd-arquitectura` | Persona |
| Matriz criterio → prueba → resultado | `.md`: en el plan; sin plan, en el commit de propuesta | `sdd-verificacion` | — |
| Reporte de verificación | cuerpo del commit de merge (`plantilla-reporte.md`) | `sdd-verificacion` | Gate 2 |
| Spec ajustado o recortado | `docs/specs/spec-<capacidad>.md` | `sdd-aplicacion` (ajuste) / `sdd-verificacion` (recorte) | Persona |
| Mapa de ramas | sección del plan `.md` | `sdd-ramas` | Persona |
| Estado del ciclo | salida de `sdd-estado.sh` | `sdd-estado` (script) | — |
| Cambio integrado | merge `--no-ff` al tronco | `sdd-verificacion` | Gate 2 |
| Registro de aprobaciones | `.git/sdd-aprobaciones.log` | Script `sdd-git.sh` | — |
| **Informe de cobertura** (**Nuevo**) | `.xml` / `.html` | `sdd-verificacion` | — |

---

## 4. Entrega & Operación, última fase (`sdd-hotfix`)

### Insumos
| Artefacto | Extensión / ruta | Viene de |
|---|---|---|
| Descripción del fallo | texto | Persona / usuario |
| Registros del incidente | `.log` / `.txt` | Operación |
| Spec de la capacidad | `docs/specs/spec-<capacidad>.md` | Diseño y Desarrollo |
| Pruebas existentes | `tests/**` | Desarrollo |

### Entregables
| Artefacto | Extensión / ruta | Producido por | Aprobación |
|---|---|---|---|
| Prueba de regresión `CA-HF-NN` | `tests/**` | `sdd-hotfix` | — |
| Arreglo mínimo | `src/**` | `sdd-hotfix` | — |
| Post-mortem | `docs/postmortems/AAAA-MM-DD-<slug>.md` | `sdd-hotfix` | Persona |
| Merge de `hotfix/<capacidad>-<slug>` | git | `sdd-hotfix` | Persona |
| Criterio permanente en el spec (si el fallo escapó por falta de criterio) | `docs/specs/spec-<capacidad>.md` | `sdd-propuesta` | Gate 1 |
| **Retroalimentación al backlog** (**Nuevo**) | `.md` | Persona, desde el post-mortem | Persona. Cierra el ciclo hacia Planificación |
