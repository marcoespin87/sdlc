# Plantilla de `CLAUDE.md` para que el agente use las skills solo

Las descripciones de las skills le dicen al agente **cuándo** usarlas, pero un archivo `CLAUDE.md` en la raíz del proyecto se carga en **cada sesión** y refuerza las reglas que no deben depender de que el agente las deduzca. **Copiarlo a la raíz del proyecto es una decisión del desarrollador** (no lo hacen las skills). Ajustar los nombres si el proyecto ya tiene un `CLAUDE.md`; si ya tiene contenido de arquitectura, ver la regla de `convenciones.md` (sección "Documento de arquitectura").

```markdown
# Flujo de trabajo (SDD v2)

Este proyecto se desarrolla con specs primero. Las skills `sdd-*` están en `.claude/skills/` y **las invocas tú, sin que el usuario escriba comandos**.

## Siempre
1. Al empezar una sesión o una tarea que toque el repositorio, usa la skill `sdd-estado` para leer la rama, las ramas abiertas y la fase del ciclo. No supongas cómo está el repo.
2. **Todo lo que escribe en git va por `bash .claude/skills/_shared/scripts/sdd-git.sh`** (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree). Nunca armes `git switch/add/commit/merge/branch/tag` a mano. El script simula primero; ejecútalo con `--ejecutar` solo cuando corresponda.
3. **Trabajamos solo en el repositorio local.** No ejecutes `git push/pull/fetch/remote` ni `gh`, ni abras PR o issues. Publicar es cosa del desarrollador.
4. El tronco de integración de este repo es `develop`. No se commitea en él: solo recibe merges de ramas verificadas.

## Qué skill usar
- Pedido que cambia comportamiento, contratos, datos o estructura → `sdd-exploracion`, y de ahí `sdd-propuesta` → `sdd-aplicacion` → `sdd-verificacion` (se encadenan solas).
- Bug en algo que ya funciona → `sdd-hotfix`.
- Cambio de stack, base de datos, proveedor de LLM, capas o flujo de ramas → `sdd-arquitectura`.
- Planear ramas desde un plan o los specs → `sdd-ramas`.
- Versión, changelog, tag o despliegue → `sdd-entrega`.
- Preguntas, lectura de código, análisis: responde directamente.
- Cambios menores sin efecto observable (typos, comentarios, formato, notas del README): vía rápida (`.claude/skills/_shared/ciclo-de-vida.md`). En la duda, es un cambio y va por el ciclo completo.

## Dónde te detienes y esperas a la persona
Confirmación del Caso y alcance · gate 1 (spec y criterios aprobados, antes de código) · un hallazgo que el spec no previó · gate 2 (reporte de verificación) · merge, borrar ramas, tags, despliegue y cualquier comando destructivo.

## Reglas que no se negocian
- El spec es la instrucción: no codifiques nada que no describa, y no lo reescribas en silencio para que coincida con el código.
- Pruebas primero: cada criterio `CA-NN` tiene una prueba que falla antes del código.
- Precedencia ante contradicciones: spec > docs/arquitectura.md (y ADR) > plan > apuntes.

## Comandos del proyecto
(completar: cómo correr, lintear, testear y medir)
```

## Por qué ayuda

- Las descripciones de las skills compiten con todo lo demás que el agente ve; este archivo está **siempre** en contexto.
- Repite en un solo lugar las tres reglas más importantes: git solo por script, solo local, y dónde parar.
- Es corto a propósito: un `CLAUDE.md` largo se ignora en parte.
