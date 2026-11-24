# Skills SDD v2 — ciclo de vida completo, solo repositorio local

Segunda versión de las skills SDD Spec-Anchored. **La v1 (`../skills/`) no se tocó**: esta carpeta es una copia ampliada. Mientras se llame `skills-v2`, Claude Code **no la carga**; se activa a propósito (ver "Cómo activarla").

## Tres decisiones de diseño que definen la v2

1. **Solo repositorio local.** Ninguna skill ejecuta `push`, `pull`, `fetch`, `remote` ni `gh`, ni abre PR o issues. Publicar es manual del desarrollador. Los criterios y el reporte de verificación viven en el historial (`commit de propuesta` y `commit de merge`), no en un PR.
2. **Las escrituras en git las hace un script, no el agente.** Todo —crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree— pasa por `_shared/scripts/sdd-git.sh`, que simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`. El agente no arma `git switch/add/commit/merge/branch/tag` a mano.
3. **Las skills se invocan solas.** Sin `disable-model-invocation`: el agente las llama según lo que pide el usuario y el estado real del repo (`sdd-estado.sh` lee ramas y fase). Se detiene únicamente en los gates humanos.

## Qué se analizó de la v1 y qué se encontró

La v1 es sólida en su núcleo (spec antes que código, gates humanos, ajuste por descubrimiento con OK, verificación en dos direcciones, regla de proporción del plan) y eso se **conserva intacto**. Le falta lo que rodea al cambio:

| # | Hueco de la v1 | Cómo lo resuelve la v2 |
|---|---|---|
| 1 | **No hay ramas.** Habla de "MR" pero ninguna fase crea ni nombra una rama | Una rama por cambio, nombre derivado del spec (`<tipo>/<capacidad>-<slug>`); `sdd-ramas` deriva el mapa desde specs y planes |
| 2 | **El delta aprobado queda sin commitear** hasta el cierre | Commit de propuesta tras el gate 1: punto fijo de auditoría ("el spec fue primero"). `sdd-git.sh` impide que ese commit toque algo fuera de `docs/` |
| 3 | **Asume `main` y que hay remoto/`gh`** | Tronco leído del repo local (`git config sdd.tronco` → `docs/arquitectura.md` → primera rama local conocida); todo funciona sin remoto |
| 4 | **Estado en la conversación** | Estado en git: rama, trailers `SDD-*`, tags. `sdd-estado.sh` lo lee, incluidas ramas atrasadas y árbol sucio |
| 5 | **Criterios sin identificador ni prueba** | `CA-NN` con método de verificación, pruebas primero, matriz criterio → spec → prueba |
| 6 | **Sin definición de terminado ni seguridad** | DoD con evidencia, chequeos de secretos, dependencias y licencias, `security-review` |
| 7 | **Verificación con contexto limpio casi invisible** | Se ofrece siempre en Caso 3/4, diffs grandes o invariantes tocados |
| 8 | **Reglas solo en prosa** | `sdd-lint.sh` (formato de specs, índice, planes), `sdd-git.sh` (reglas de git) y hooks sugeridos |
| 9 | **El ciclo termina en el merge** | `sdd-entrega`: SemVer derivado del delta, changelog del historial, tag local, despliegue documentado, humo, reversión |
| 10 | **Sin camino para bugs en lo que ya corre** | `sdd-hotfix`: prueba que reproduce primero, arreglo mínimo, post-mortem versionado |
| 11 | **Los cambios de arquitectura no tienen skill** | `sdd-arquitectura`: ADR + `docs/arquitectura.md` + impacto sobre todos los specs |
| 12 | **Ambigüedad sobre qué requiere permiso** | Matriz de autorización: commits locales con una autorización por cambio; merge, borrado, tag y destructivos con OK cada vez |
| 13 | **Un ciclo completo para todo es un estorbo** | **Vía rápida** con límites que el script hace cumplir (≤5 archivos y 40 líneas por commit; ≤8 archivos y 80 líneas por rama; sin tocar specs) |

## Qué hay

```
skills-v2/
├── README.md
├── sdd-estado/         NUEVA  ¿dónde estoy? (solo lectura)
├── sdd-ramas/          NUEVA  mapa de ramas desde specs y planes
├── sdd-exploracion/    v1 + estado de git, desvíos a hotfix/arquitectura/vía rápida
├── sdd-propuesta/      v1 + rama, criterios CA-NN, lint, commit del spec aprobado
├── sdd-aplicacion/     v1 + pruebas primero, commits por tarea, ajustes en commit propio
├── sdd-verificacion/   v1 + trazabilidad, DoD, seguridad, contexto limpio, merge local
├── sdd-entrega/        NUEVA  versión, changelog, tag local, despliegue, humo, reversión
├── sdd-hotfix/         NUEVA  bug en lo que ya corre
├── sdd-arquitectura/   NUEVA  ADR + arquitectura
└── _shared/
    ├── convenciones.md, plantilla-spec.md, plantilla-plan.md, verificacion-division.md   (v1, ajustados)
    ├── ciclo-de-vida.md        mapa, invocación automática, encadenamiento, vía rápida
    ├── ramas-y-commits.md      §0 el script de git · ramas · commits y trailers · autorizaciones · merge local
    ├── criterios-y-pruebas.md  CA-NN, pruebas primero, trazabilidad
    ├── entrega.md              DoD, seguridad, versión, changelog, reversión
    ├── plantilla-reporte.md    reporte de verificación = cuerpo del commit de merge
    ├── claude-md-plantilla.md  CLAUDE.md sugerido para reforzar la invocación automática
    ├── hooks-ejemplo.md        guardarraíles (sugeridos, no instalados)
    ├── diseno-a-spec.md        paquete de diseño por HU → spec, CA-NN y plan; Gate 1 con varios roles
    └── scripts/
        ├── sdd-git.sh          ÚNICA puerta de escritura en git (solo local)
        ├── sdd-estado.sh       estado del ciclo leído de git
        ├── sdd-lint.sh         formato de specs, índice y planes
        └── sdd-comun.sh        resolución del tronco (compartida)
```

## `sdd-git.sh`: qué hace y qué rechaza

Subcomandos: `tronco`, `crear-rama`, `cambiar`, `commit`, `actualizar-rama`, `merge`, `borrar-rama`, `tag`, `worktree`, `ayuda`. **No existen** subcomandos de remoto (`push`, `pull`, `fetch`, `remote`, `gh` devuelven RECHAZADO).

Rechaza, con el motivo (exit 2): nombre o tipo de rama inválido · árbol sucio al crear o cambiar de rama · commit en el tronco (única excepción: `chore` de entrega) · commit de propuesta que toque algo fuera de `docs/` · commit de aplicación sin commit de propuesta previo · `spec` en aplicación sin `--ajuste` y `--aprobado` · specs o planes con `sdd-lint.sh` en rojo · merge sin commit de verificación o con la rama atrasada · borrar una rama no mergeada, el tronco o la rama activa · tag fuera de SemVer, repetido o fuera del tronco. Un conflicto de merge se aborta solo (exit 3). Las aprobaciones humanas que cita el agente quedan en `.git/sdd-aprobaciones.log`.

## Extensión: paquete de diseño por historia de usuario

Cuando la fase de Diseño entrega un paquete por HU (`docs/design/HU-0NN/`: arquitectura C4 + ADR, modelo de datos, OpenAPI, UI de 4 estados, matriz de seguridad, plan WBS, acta DoR), ese paquete es **insumo** de la Propuesta, que lo convierte en spec, criterios `CA-NN` y plan. Qué cambió:

- `_shared/diseno-a-spec.md` (nuevo): tabla de mapeo paquete → spec/arquitectura/plan, derivación de `CA-NN`, cobertura del paquete y Gate 1 con varios aprobadores.
- Una capacidad puede tener una o varias HU; cada HU es un cambio con su rama. Índice con columna *Historias* y trailer `SDD-HU`.
- `sdd-git.sh commit --hu` registra el trailer y **rechaza** el commit de propuesta si el acta DoR tiene firmas sin aprobar; `sdd-estado.sh` muestra el `SDD-HU`; `sdd-lint.sh` comprueba que las rutas de `docs/design/` citadas en los specs existan y que cada HU con paquete figure en el índice.
- `sdd-exploracion` lee el paquete y verifica su cobertura; `sdd-propuesta` aplica el mapeo y deriva los criterios; `sdd-arquitectura` consolida C4/ADR/tokens una sola vez; `sdd-aplicacion` y `sdd-verificacion` tratan el contrato y el DDL referenciados como forma exacta; `sdd-ramas` usa el WBS y una rama por HU.

## Qué se verificó y qué no

**Probado** (repositorios de juguete en una carpeta temporal; nada tocó un repo real):
- `sdd-git.sh`: **45 comprobaciones, 0 fallas** — ciclo completo (rama → propuesta → aplicación → ajuste → verificación → actualizar → merge → borrar → tag), todos los rechazos con su motivo (leídos, no solo el código de salida), merge hacia la rama de releases, entrega, hotfix, y la vía rápida con sus límites. Las pruebas encontraron **un error real** en el parseo del límite de la vía rápida y se corrigió.
- `sdd-lint.sh`: pasa limpio en los specs reales de `datafactory`; detecta los 14 errores sembrados en un proyecto roto a propósito.
- `sdd-estado.sh`: tronco resuelto por config, por `docs/arquitectura.md` y por rama conocida; ramas atrasadas; trailers por fase.

**No probado:** el ciclo completo conducido por Claude (no hay specs ni código en `datafactory_v2` todavía), la invocación automática en una sesión real (depende de cómo tu versión de Claude Code pondere las descripciones), los hooks, la verificación en subagente y bash menor a 4 (el script usa arreglos asociativos). **Hay que observar las primeras sesiones** y ajustar las descripciones si el agente no llama a una skill cuando debería, o la llama de más.

## Cómo activarla

1. **Probar sin riesgo:** renombrar carpetas — `skills` → `skills-v1` y `skills-v2` → `skills`. Se revierte con el mismo renombrado.
2. **Este repo ya tiene `develop` como tronco** (`git config sdd.tronco develop`, local). Para que lo vea cualquier clon, agregarlo a `docs/arquitectura.md` → "Flujo de trabajo": `- **Tronco de integración:** \`develop\``.
3. **`.gitignore`:** hoy ignora `.claude` completo, así que las skills **no se versionan**. Recomendado ignorar solo `.claude/settings.local.json`.
4. **Reforzar la invocación automática:** copiar la plantilla de `_shared/claude-md-plantilla.md` a un `CLAUDE.md` en la raíz.
5. **Opcional, recomendado:** los hooks de `_shared/hooks-ejemplo.md` — sobre todo "git de escritura solo vía script" y "nada contra remotos". Sin hooks, el script garantiza las reglas, pero nada impide que el agente use `git` a mano si se desvía.

## Límites honestos

- `sdd-git.sh` **garantiza** las reglas cuando se usa; no puede impedir por sí solo que el agente invoque `git` directamente. Para eso son los hooks.
- `--aprobado "<cita>"` es una cita que el agente escribe: queda registrada, pero el script no puede comprobar que el usuario la dijera. Es trazabilidad, no autenticación.
- El tronco `develop` y `master` están en el mismo commit. Mientras no se declare una rama de releases (`git config sdd.release master`), `sdd-entrega` taggea sobre `develop`.
- Un hotfix creado desde la rama de releases entra al tronco de integración con el script; llevarlo a producción sin arrastrar cambios no entregados es una operación manual del desarrollador.
