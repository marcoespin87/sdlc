# Ciclo de vida completo — mapa de skills v2

La v1 cubre cuatro fases (explorar → proponer → aplicar → verificar). La v2 las mantiene idénticas en intención y **agrega lo que rodea al cambio**: dónde vive (ramas), cómo se retoma, qué pasa después del merge y qué hacer cuando algo falla en producción. **Todo es local** (sin remotos) y **toda escritura en git pasa por `scripts/sdd-git.sh`**.

```
                               /sdd-estado   (¿dónde estoy?  lee git; siempre disponible)
                                    │
 /sdd-ramas ─── mapa de ramas desde specs/planes (varios cambios o fases)
                                    │
 ┌────────────── un cambio ─────────────────────────────────────────────────────────┐
 │ 1 /sdd-exploracion   lee, detecta Caso, no escribe nada                           │
 │ 2 /sdd-propuesta     crea RAMA · escribe delta + criterios CA-NN · GATE 1 humano  │
 │                      → commit de propuesta (punto fijo del spec aprobado)          │
 │ 3 /sdd-aplicacion    pruebas en rojo → código en verde · commits pequeños          │
 │                      descubrimiento ⇒ detenerse y pedir OK (ajuste de spec)        │
 │ 4 /sdd-verificacion  2 direcciones · matriz CA→prueba · DoD · seguridad            │
 │                      (contexto limpio) · GATE 2 humano · merge local                 │
 └───────────────────────────────────────────────────────────────────────────────────┘
                                    │
 /sdd-entrega ── versión semántica · changelog · tag · despliegue · humo · reversión
                                    │
 /sdd-hotfix ─── bug en producción: prueba que reproduce → arreglo mínimo → PATCH
 /sdd-arquitectura ─ cambio transversal: ADR + docs/arquitectura.md (rama `arq/`)
```

## Qué skill usar

| Situación | Skill |
|---|---|
| "¿Dónde me quedé?", sesión nueva, rama ajena | `/sdd-estado` |
| Tengo un plan con fases o varios specs y quiero las ramas | `/sdd-ramas` |
| Idea, pedido o necesidad nueva | `/sdd-exploracion` → `/sdd-propuesta` → `/sdd-aplicacion` → `/sdd-verificacion` |
| El cambio toca la forma transversal del sistema (stack, capas, despliegue, proveedor de LLM, base de datos) | `/sdd-arquitectura` (en vez de la Propuesta normal) |
| Cambio ya mergeado que hay que publicar | `/sdd-entrega` |
| Algo falla en producción | `/sdd-hotfix` |

## Los cuatro gates humanos (no se saltan)

| Gate | Dónde | Qué aprueba |
|---|---|---|
| 1 | `/sdd-propuesta` | El diff del spec, los criterios y el plan: "¿describe lo que queremos construir?" |
| 2 | `/sdd-verificacion` | El reporte, el diff del spec si se ajustó, y el cierre del cambio |
| 3 | `/sdd-entrega` | Versión, changelog y tag antes de publicar |
| 4 | Siempre | Cualquier acción que cambia el tronco o no se deshace: merge, tag, borrar ramas, reset, reescribir historia (ver `ramas-y-commits.md` §4) |

Una aprobación **no se extiende** a la acción siguiente: aprobar el spec no autoriza el merge; aprobar el merge no autoriza el release.

## Dónde vive el estado del ciclo

- **Git** es el registro: nombre de rama, trailers `SDD-*` de los commits, tags. `/sdd-estado` lo lee con `sdd-estado.sh`.
- **`docs/specs/`** guarda lo que corre; **`docs/plan-*.md`** lo que falta; el **historial de git** (rama y commits) el estado del cambio abierto.
- La conversación **no** es el registro: una sesión nueva debe poder retomar solo con el repo.

## Regla de precedencia (igual que v1)

`spec` > `docs/arquitectura.md` (y ADR) > plan > apuntes y docs históricos. Si dos documentos se contradicen, gana el de la izquierda y el otro se corrige.

## Invocación automática y encadenamiento

**Las skills no se invocan escribiendo comandos**: el agente las llama solo, según lo que pide el usuario y el estado del repositorio, guiado por la descripción de cada skill. Escribir `/sdd-…` sigue funcionando, pero no hace falta.

| Cuando ocurre… | El agente invoca… |
|---|---|
| Empieza una sesión o una tarea que toca el repositorio | `sdd-estado` (siempre primero: lee ramas, fase y specs) |
| El usuario pide construir, cambiar, quitar o migrar algo con efecto observable | `sdd-exploracion` |
| El Caso quedó confirmado por el usuario | `sdd-propuesta` |
| El usuario aprueba el gate 1 y el commit de propuesta está hecho | `sdd-aplicacion` (sin que el usuario lo pida de nuevo) |
| La aplicación terminó con todo en verde | `sdd-verificacion` (se encadena sola) |
| El usuario aprueba el gate 2 | merge local con `sdd-git.sh merge`; si se despliega, ofrece `sdd-entrega` |
| El usuario reporta un fallo en algo que ya funciona | `sdd-hotfix` |
| Se discute o cambia stack, base de datos, proveedor de LLM, capas o flujo de ramas | `sdd-arquitectura` |
| El usuario pide planear ramas desde un plan o los specs | `sdd-ramas` |
| El usuario pide versión, changelog, tag o despliegue | `sdd-entrega` |

**Dónde sí se detiene el agente y espera a una persona** (el encadenamiento nunca atraviesa estos puntos):

1. Confirmar el Caso y el alcance al final de la exploración.
2. **Gate 1**: aprobación del diff del spec y de los criterios, antes de cualquier código.
3. Un hallazgo que el spec no previó (ajuste de spec con OK).
4. **Gate 2**: aprobación del reporte de verificación.
5. Cada acción sensible: merge, borrar rama, tag, despliegue, comandos destructivos (`ramas-y-commits.md` §4).

## Cuándo NO entrar al ciclo

Invocar el ciclo completo para todo sería un obstáculo. No se usa para:

- **Preguntas, explicaciones, lectura de código, análisis** y ejecutar comandos: sin cambios, sin skill de cambio.
- **Cambios menores sin efecto observable** → **vía rápida** (abajo).
- Experimentos descartables (spikes) que no se mergean: se hacen en una rama aparte y se descartan.

## Vía rápida

Para cambios que **no alteran el comportamiento ni tocan specs, planes o arquitectura** (corregir un typo, un comentario, formato, una nota del README, renombrar algo interno sin efecto, añadir una prueba a algo ya especificado). Sigue en rama y con script, pero sin spec ni criterios:

1. `sdd-git.sh crear-rama refactor <capacidad> <slug> --ejecutar` (tipo `refactor`).
2. Commits con `sdd-git.sh commit --caso rapida --fase aplicacion --tipo docs|chore|refactor|test …`.
3. Correr las pruebas y el lint del proyecto si el cambio toca código.
4. `sdd-git.sh merge … --caso rapida --aprobado "…" --ejecutar` con el OK del usuario.

**Límites que el script hace cumplir** (no son sugerencias): hasta 5 archivos y 40 líneas por commit, y 8 archivos y 80 líneas en total en la rama; solo tipos `docs`, `chore`, `refactor` y `test`; nunca `docs/specs/`, `docs/plan-*`, `docs/adr/` ni `docs/arquitectura.md`; una rama que mezcle la vía rápida con cualquier otro caso exige verificación completa. Si el cambio se sale de esos límites, **es un cambio de verdad**: se descarta la vía rápida y se empieza por `sdd-exploracion`.

En la duda sobre si algo tiene efecto observable, **se trata como cambio** (ciclo completo).
