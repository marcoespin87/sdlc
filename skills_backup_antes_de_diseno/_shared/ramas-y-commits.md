# Ramas, commits y merge — solo repositorio local

**Alcance de las skills: únicamente el repositorio local.** Las skills **nunca** ejecutan `git push`, `git pull`, `git fetch`, `git remote`, `gh` ni ninguna acción contra un remoto, y no abren pull requests, issues ni releases en ninguna plataforma. Publicar lo que está en el repositorio local es **criterio manual del desarrollador**. Si el repo tiene remotos configurados, se ignoran.

Regla única: **un cambio SDD vive en una rama local propia, con un historial que cuenta el ciclo** (spec aprobado → pruebas → código → verificación). El tronco de integración nunca recibe commits directos, salvo el merge de un cambio ya verificado.

> Las rutas `../_shared/` son relativas a la carpeta de cada skill. Los scripts viven en `_shared/scripts/`.

## 0. Las escrituras de git van por script, no por comandos a mano

**Toda escritura en git se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`** (la ruta es relativa a la carpeta de cada skill). El agente **no** arma `git switch -c`, `git add`, `git commit`, `git merge`, `git branch -d`, `git tag` ni `git worktree add` por su cuenta. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente; para el estado del ciclo, `sdd-estado.sh`.

Por qué: las reglas de este documento (rama correcta, formato de commit, trailers, "la propuesta solo toca `docs/`", "no se mergea sin verificación", "nunca un remoto") quedan **verificadas por código** y no dependen de que el agente las recuerde en cada sesión.

**Cómo se usa: simular, mostrar, ejecutar.** Todo subcomando que escribe **simula por defecto**: muestra qué haría y no toca nada. Se repite con `--ejecutar` solo cuando corresponde (con la autorización de §4). Los subcomandos sensibles exigen además `--aprobado "<cita textual de la aprobación del usuario>"`, que queda en `.git/sdd-aprobaciones.log`.

| Acción | Subcomando |
|---|---|
| Ver el tronco resuelto | `sdd-git.sh tronco` |
| Crear la rama de un cambio | `sdd-git.sh crear-rama <tipo> <capacidad> <slug> [--worktree DIR] [--ejecutar]` |
| Cambiar de rama (árbol limpio) | `sdd-git.sh cambiar <rama> [--ejecutar]` |
| Commitear (solo los archivos listados) | `sdd-git.sh commit --tipo T --capacidad C --asunto "…" --fase F --caso N --archivos a b [--cuerpo-archivo F] [--spec S] [--plan P] [--ca "CA-01,CA-02"] [--atribucion "…"] [--ejecutar]` |
| Ajuste de spec en aplicación | `sdd-git.sh commit … --fase aplicacion --tipo spec --ajuste --aprobado "…" --ejecutar` |
| Actualizar la rama con el tronco | `sdd-git.sh actualizar-rama [--ejecutar]` |
| Mergear al tronco (tras verificación) | `sdd-git.sh merge <rama> --capacidad C --caso N --asunto "…" --cuerpo-archivo F --aprobado "…" --ejecutar` |
| Llevar el tronco a la rama de releases | `sdd-git.sh merge <tronco> --destino <release> … --aprobado "…" --ejecutar` |
| Borrar una rama ya mergeada | `sdd-git.sh borrar-rama <rama> --aprobado "…" --ejecutar` |
| Crear un tag local | `sdd-git.sh tag vX.Y.Z --mensaje-archivo F --aprobado "…" --ejecutar` |
| Worktree para trabajo paralelo | `sdd-git.sh worktree <rama> <directorio> [--ejecutar]` |
| Cambio menor de la vía rápida | `sdd-git.sh commit --caso rapida --fase aplicacion --tipo docs|chore|refactor|test …` (límites duros: ver `ciclo-de-vida.md`) |

Lo que el script **rechaza** (exit 2, con el motivo): crear ramas con tipo o nombre inválido; commitear en el tronco (salvo `chore` de entrega); un commit de propuesta que toque algo fuera de `docs/`; un commit de aplicación sin commit de propuesta previo (salvo hotfix); un `spec` en aplicación sin `--ajuste` y `--aprobado`; commitear specs o planes con `sdd-lint.sh` en rojo; mergear una rama sin commit de verificación o atrasada respecto al tronco; borrar una rama no mergeada; un tag fuera de SemVer o fuera del tronco. **No tiene subcomandos de remoto**: `push`, `pull`, `fetch`, `remote` y `gh` devuelven RECHAZADO.

Los comandos destructivos (`reset --hard`, `clean`, `checkout -- <archivo>`, `stash drop`, `branch -D`, `rebase`, `commit --amend`) **no tienen subcomando**: no los hace el agente; si hacen falta, se los propone al usuario para que los ejecute él.

## 1. El tronco de integración

Es la rama de la que nacen las ramas de cambio y a la que vuelven al mergear. **Se lee del repositorio local, no se asume.** `sdd-estado.sh` lo resuelve en este orden:

1. `git config sdd.tronco <rama>`
2. Una línea `- **Tronco de integración:** \`<rama>\`` en `docs/arquitectura.md` → "Flujo de trabajo"
3. La primera rama local que exista entre `develop`, `main`, `master`, `trunk` (y avisa si hay otras, porque es ambiguo)

**En este repositorio el tronco de integración es `develop`** (`git config sdd.tronco develop`). `master` queda como está; las skills no lo tocan salvo que el desarrollador declare una rama de releases (`git config sdd.release master` o `- **Rama de releases:** \`master\`` en `docs/arquitectura.md`), en cuyo caso solo `/sdd-entrega` la usa, con OK.

Antes de cualquier acción de ramas, la skill corre `sdd-estado.sh` y **lee el estado real**: rama actual, ramas abiertas, cuáles están atrasadas respecto al tronco, árbol de trabajo sucio, specs y planes. Nunca se actúa sobre una suposición de cómo está el repo.

## 2. Nombre de la rama

`<tipo>/<capacidad>-<slug-corto>` en kebab-case, en minúsculas, sin acentos, máx. ~50 caracteres.

| Caso / situación | Tipo | Ejemplo |
|---|---|---|
| Caso 1, desde cero (plan padre) | `init` | `init/mvp-datos-sinteticos` |
| Caso 1, una fase del plan padre | `feat` | `feat/m1a-motor-determinista` |
| Caso 2, funcionalidad nueva | `feat` | `feat/generation-estacionalidad` |
| Caso 3, comportamiento cambia | `change` | `change/dataspec-volumen-unico` |
| Caso 3, solo implementación | `refactor` | `refactor/jobs-cola-sqlite` |
| Caso 3, fix colateral de la Fase 0 | `fix` | `fix/formats-xml-nombres` |
| Caso 4, migración (un módulo) | `migrate` | `migrate/formats-parsers` |
| Caso 5, baseline de una capacidad | `baseline` | `baseline/generation` |
| Cambio de arquitectura (`sdd-arquitectura`) | `arq` | `arq/llm-proveedor-unico` |
| División de un spec aprobada | `spec` | `spec/dividir-agent-router` |
| Bug en algo que ya corre (`sdd-hotfix`) | `hotfix` | `hotfix/jobs-huerfano` |

- La capacidad es la misma que el nombre del spec (`spec-<capacidad>.md`): **la rama se deduce del spec** y viceversa.
- Un cambio, una rama, un propósito. Si aparece algo ajeno, es otro cambio: rama aparte.
- La rama se crea **desde el tronco de integración actual**, al inicio de `sdd-propuesta` (la exploración no escribe nada). Con el nombre propuesto y la autorización del usuario.
- Si la rama atrasa respecto al tronco, se actualiza **mergeando el tronco en la rama** (`sdd-git.sh actualizar-rama`), no con `rebase`: el rebase cambia los hashes y el commit de propuesta deja de ser el punto fijo que se cita. El rebase solo si el usuario lo pide, y lo hace él.

### Varias ramas desde un plan o desde los specs

`sdd-ramas` lee el índice de specs, las *Referencias* ("Depende de / Usada por") y las fases de los planes, y propone un **mapa de ramas** en orden de dependencia. Reglas:

- Una rama por fase de un plan padre, mergeadas **en orden de dependencia**.
- **Ramas apiladas** (B nace de A) solo si B necesita código de A sin mergear; al mergear A, B se actualiza con el tronco. Si no, ambas nacen del tronco.
- Trabajo en paralelo: un worktree por rama (`sdd-git.sh worktree <rama> <directorio>` o `crear-rama --worktree`), nunca dos cambios en el mismo árbol.
- Los conflictos típicos están en `docs/specs/README.md` y en `Referencias`: resolverlos leyendo ambos lados, nunca con "aceptar el mío".

## 3. Los commits cuentan el ciclo

Formato **Conventional Commits**, con la capacidad como alcance y **trailers SDD** que `sdd-estado.sh` lee para saber en qué fase está la rama.

```
<tipo>(<capacidad>): <imperativo corto, sin punto, ≤72 caracteres>

<cuerpo opcional: qué y por qué, no cómo>

SDD-Caso: 2
SDD-Fase: propuesta
SDD-Spec: spec-generation.md
SDD-CA: CA-01, CA-02
```

| Tipo | Cuándo | Trailer `SDD-Fase` |
|---|---|---|
| `spec` | Delta del spec aprobado, ajuste por descubrimiento, recorte en verificación, división | `propuesta` / `aplicacion` (ajuste) / `verificacion` (recorte) |
| `docs` | Plan, documento de arquitectura, ADR, índice | `propuesta` |
| `test` | Pruebas que cubren criterios (rojas primero) | `aplicacion` |
| `feat` / `fix` / `refactor` / `perf` | Código | `aplicacion` |
| `chore` | Estado del spec/plan, versión, changelog | `verificacion` / `entrega` |

Trailers: `SDD-Caso` (1–5, `arq`, `hotfix`, `entrega` o `rapida`), `SDD-Fase` (`propuesta`, `aplicacion`, `verificacion`, `entrega`), `SDD-Spec`, `SDD-Plan` (si hay), `SDD-CA` (criterios que cubre el commit), `SDD-Ajuste: aprobado` (solo en un ajuste de spec con OK explícito).

Si quien commitea es Claude, **añadir al final las líneas de atribución que indique el entorno**, después de los trailers SDD.

### Dónde viven los criterios y el reporte (sin pull request)

Sin PR, el historial local es el registro:

- **Los criterios `CA-NN`:** en el plan si hay plan; si no, en el **cuerpo del commit de propuesta**.
- **El reporte de verificación:** en el **cuerpo del commit de merge** (plantilla en `plantilla-reporte.md`).
- `git log <tronco>` + `git show <commit-de-propuesta>` bastan para reconstruir qué se aprobó y cómo se verificó.

### Secuencia mínima de commits de un cambio

1. *(si hubo división de spec aprobada)* `spec(<cap>): dividir …` — commit propio, sin código ni delta.
2. `spec(<cap>): <delta>` (+ plan, índice, arquitectura si nacen) — **commit de propuesta**, hecho **después** del OK del gate de `sdd-propuesta`. Es el punto fijo contra el que se verifica.
3. `test(<cap>): …` — pruebas de los criterios, **fallando** antes del código (`SDD-CA` los lista).
4. `feat|fix|refactor(<cap>): …` — uno por tarea o unidad coherente. Pequeños, que compilen y pasen lo que ya pasaba.
5. *(solo si hubo descubrimiento)* `spec(<cap>): ajuste …` con `SDD-Ajuste: aprobado`.
6. `spec(<cap>): recortar a lo construido` / `chore(<cap>): estado desplegado` — cierre de `sdd-verificacion`.
7. **Merge local** al tronco de integración (§5).

## 4. Autorización: qué se hace solo y qué pide OK cada vez

| Acción | Regla |
|---|---|
| Crear la rama de cambio y hacer **commits locales** en ella | **Una sola autorización por cambio** ("¿puedo crear la rama y commitear en ella mientras dure el cambio?"). Vale solo para esa rama y ese cambio |
| Merge de la rama al tronco de integración | **OK explícito**, después del gate humano de `sdd-verificacion` |
| Borrar una rama local (incluso mergeada) | **OK explícito** |
| Crear un tag local (`/sdd-entrega`) | **OK explícito** |
| `git reset --hard`, `git clean`, `git checkout -- <archivos>`, `git stash drop`, `git branch -D`, `rebase`, `commit --amend` | **No tienen subcomando**: el agente no los ejecuta. Se le proponen al usuario, mostrando qué se perdería, y los hace él |
| Cambiar de rama con el árbol sucio | `sdd-git.sh cambiar` lo rechaza; si el cambio arrastraría trabajo ajeno, detenerse |
| Cualquier comando contra un remoto (`push`, `pull`, `fetch`, `remote`, `gh`) y la apertura de PR o issues | **No se ejecutan nunca.** Son del desarrollador |
| Saltarse hooks (`--no-verify`) | Nunca. Si un hook falla, se arregla la causa |

La aprobación de un gate de spec **no** autoriza el merge: son decisiones distintas.

## 5. Merge local

Con el OK del gate de `sdd-verificacion`:

1. `sdd-git.sh merge <rama> --capacidad <c> --caso <n> --asunto "…" --cuerpo-archivo <reporte> --aprobado "<cita del OK>"` sin `--ejecutar`: **simula** y muestra qué entra.
2. Con el OK, repetirlo con `--ejecutar`: el script cambia al tronco y hace `merge --no-ff` con el **reporte de verificación como mensaje** (`plantilla-reporte.md`) y `SDD-Fase: verificacion`. Si hay conflictos, aborta solo, vuelve a la rama original y sale con código 3.
3. Con OK aparte, `sdd-git.sh borrar-rama <rama> --aprobado "…" --ejecutar` (el script solo borra ramas ya mergeadas).

| Situación | Estrategia | Por qué |
|---|---|---|
| Cambio con propuesta (commits `spec` + `test` + código) | **`--no-ff`** | Conserva el commit de propuesta como punto fijo de auditoría ("spec antes que código") y la rama como unidad |
| Cambio pequeño sin plan | `--no-ff` igualmente | Un solo estilo; si el desarrollador prefiere `--squash`, lo decide él y se pierde el commit de propuesta |
| Hotfix | `--no-ff` | Misma razón; el historial del hotfix es corto |

Si hay conflictos al mergear, se resuelven leyendo ambos lados; los de `docs/specs/README.md` y las *Referencias* se tratan a mano y nunca con "aceptar el mío". Si el merge se complica, `git merge --abort` y se reporta.

## 6. Protecciones locales (opcionales)

Como no hay remoto que proteja el tronco, la protección es local: los *hooks* de `hooks-ejemplo.md` (no commitear en el tronco, lint del spec al guardar, spec antes que código). La disciplina de "el tronco solo recibe merges" se hace cumplir ahí, no en la plataforma.
