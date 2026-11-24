---
name: sdd-arquitectura
description: Use when the user wants to decide, change or record a transversal decision: stack, database, LLM provider, module boundaries, deployment, branching or testing conventions (arquitectura, ADR, cambiar de base de datos, definir el flujo de ramas). Runs a dedicated change on its own local branch: an ADR in docs/adr/, the update of docs/arquitectura.md and an impact analysis over all specs, with a human gate. Not for functional changes.
argument-hint: [descripción del cambio de arquitectura que se quiere decidir o registrar]
---

# sdd-arquitectura — Cambio dedicado de arquitectura

`convenciones.md` dice que el documento de arquitectura "solo se actualiza mediante un cambio dedicado a arquitectura — nunca como efecto lateral de un cambio funcional", pero la v1 no tenía una skill para ese cambio. Esta es.

Lo que decide la arquitectura (stack, capas, fronteras de módulos, base de datos, proveedor de LLM, despliegue, convenciones de ramas y pruebas) **condiciona todos los specs**. Por eso se trata aparte: tiene su propia rama, su propio registro de decisión (ADR) y su propio gate.

Leer `../_shared/convenciones.md` (sección "Documento de arquitectura") y `../_shared/ramas-y-commits.md`.

> **Git solo por script.** Toda escritura en git (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree) se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`, nunca con `git switch`, `git add`, `git commit`, `git merge`, `git branch` o `git tag` armados a mano. El script simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`; los subcomandos sensibles exigen `--aprobado "<cita del OK del usuario>"`. No hay comandos de remoto: nada de push, pull, PR ni `gh`. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente. Detalle en `../_shared/ramas-y-commits.md` §0.

## Cuándo usarla

- Elegir o cambiar el **stack** o una pieza central (base de datos, cola, framework, proveedor de LLM).
- Cambiar las **fronteras entre módulos** o las reglas de dependencia.
- Definir o cambiar el **despliegue**, la reversión, los entornos.
- Definir o cambiar el **flujo de trabajo**: tronco, ramas, estrategia de merge, protecciones.
- Registrar una decisión que ya se tomó y no quedó escrita (ADR retroactivo).

No usarla para un cambio de comportamiento funcional (eso son los Casos 1 a 4) ni para un bug (`/sdd-hotfix`). Si un cambio funcional **necesita** una decisión de arquitectura, se hace **primero** esta, en su propia rama, y el cambio funcional después.

## Paso 1 — Leer el estado actual

1. `bash ../_shared/scripts/sdd-estado.sh`; confirmar rama limpia y tronco actualizado.
2. `docs/arquitectura.md` (o el archivo de arquitectura que corresponda) y los ADR existentes en `docs/adr/`. La precedencia es `spec` > arquitectura/ADR > plan: si la decisión nueva contradice un spec, **los specs afectados cambian en este mismo cambio**.
3. El índice de specs: para el análisis de impacto del Paso 3.

## Paso 2 — Plantear la decisión

Con el usuario, dejar explícitos y por escrito:

- **Contexto:** qué problema o presión motiva la decisión.
- **Opciones consideradas** (mínimo dos, incluida "no cambiar"), cada una con sus ventajas, costos y riesgos.
- **Decisión** propuesta y por qué.
- **Consecuencias:** qué se vuelve más fácil, qué más difícil, qué deuda se acepta.
- **Reversibilidad:** cómo se deshace y cuánto cuesta.

No decidir por el usuario. Si falta información (costo, restricciones de la organización), preguntarla.

## Paso 3 — Análisis de impacto sobre los specs

Recorrer **todos** los specs del índice (no solo el más cercano) y para cada uno decir si la decisión: no lo toca, toca su *Arquitectura propia* o sus *Referencias*, toca un invariante, o lo contradice. El resultado es una tabla:

| Spec | Efecto | Cambio necesario |
|---|---|---|
| `spec-x.md` | Toca Invariantes (concurrencia) | Reescribir invariante con nuevo porqué |

Un spec contradicho o con invariante afectado **entra en este cambio** (se edita con su decisión fechada). Si el impacto es grande, proponer partirlo en varios cambios y decir el orden.

## Paso 4 — Rama y escritura

1. Proponer la rama `arq/<slug>` (`ramas-y-commits.md` §2) y esperar OK para crearla; pedir la autorización de commits locales.
2. Escribir:
   - **ADR** `docs/adr/NNNN-titulo-en-kebab.md` (numeración correlativa, nunca se renumera ni se borra; una decisión reemplazada pasa a `Estado: reemplazado por NNNN`).
   - **Actualizar `docs/arquitectura.md`** para que describa el estado resultante (no el historial: eso es el ADR) e incluya los comandos, el despliegue y el flujo de trabajo al día.
   - **Specs afectados** (Paso 3), con su `Decisión` fechada que enlaza al ADR.

Plantilla del ADR:

```markdown
# ADR NNNN: <Título de la decisión>

**Estado:** propuesto | aceptado | reemplazado por NNNN · **Fecha:** AAAA-MM-DD

## Contexto
<Qué problema o presión motiva la decisión.>

## Opciones consideradas
1. <Opción A> — ventajas · costos · riesgos
2. <Opción B> — …
3. No cambiar — …

## Decisión
<Qué se decide y por qué esta opción.>

## Consecuencias
<Qué mejora, qué empeora, qué deuda se acepta.>

## Reversibilidad
<Cómo se deshace y cuánto cuesta.>

## Specs afectados
<Lista de `spec-*.md` tocados y qué cambió en cada uno.>
```

## Paso 5 — Lint y gate humano

1. `bash ../_shared/scripts/sdd-lint.sh` sin errores.
2. Mostrar: el ADR, el diff de `docs/arquitectura.md`, el diff de cada spec afectado y la tabla de impacto. Consigna: *"¿esto describe la decisión que tomamos y sus consecuencias?"*. **OK explícito** antes de seguir.

## Paso 6 — Commit y cierre

- Commit con `bash ../_shared/scripts/sdd-git.sh commit --tipo docs --capacidad arq --asunto "<decisión>" --fase propuesta --caso arq --spec <spec afectado> --archivos docs/adr/… docs/arquitectura.md [specs afectados] --ejecutar` (primero simulando; el script corre el lint y solo admite rutas bajo `docs/`). Si se tocaron specs, pueden ir en commits separados del ADR. La rama se crea con `sdd-git.sh crear-rama arq <tema> <slug> --ejecutar`.
- Si la decisión **exige código** (migrar a otra base, cambiar de proveedor), este cambio solo registra la decisión; el código va por el ciclo normal con su propia rama, que cita el ADR. No se mezclan.
- Verificación y merge: el cierre del cambio sigue la skill `sdd-verificacion` (Pasos 6 y 7), con una DoD recortada a lo que aplica (lint, coherencia entre ADR, arquitectura y specs). **El merge local pide OK explícito**; nada se hace contra remotos.

## Lo que esta skill NO hace

- No implementa la decisión en código.
- No reescribe ADR aceptados (se reemplazan con uno nuevo).
- No toma la decisión por el usuario.

## Referencias

- `../_shared/convenciones.md` — documento de arquitectura, precedencia.
- `../_shared/ramas-y-commits.md` — rama `arq/`, commits, autorizaciones.
- `../_shared/scripts/sdd-estado.sh`, `../_shared/scripts/sdd-lint.sh`.
