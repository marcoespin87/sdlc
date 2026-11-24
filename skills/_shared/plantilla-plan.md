# Plantilla del plan — `docs/plan-<tema>-<fecha>.md`

**El plan es opcional** (metodología v4, regla 3.3, "regla de proporción"): se crea **solo** si el cambio tiene fases, alternativas o decisiones abiertas. Si no tiene ninguna, no se crea: el delta del spec es el plan, y los criterios de aceptación `CA-NN` van en el cuerpo del commit de propuesta (y el reporte de `/sdd-verificacion` en el commit de merge).

Cuando existe, la metodología no fija un formato rígido para el plan — pero usar siempre esta misma estructura entre proyectos evita el problema real que apareció en la práctica: un plan con encabezados mezclados en inglés y español, o secciones inventadas por cada cambio, que hacen cada plan distinto a leer. Usar encabezados en español, siempre los mismos.

```markdown
# Plan: <Tema del cambio>

**Fecha:** YYYY-MM-DD
**Estado:** en desarrollo | destilado
**Caso:** 1 | 2 | 3 | 4 (Caso 5 ya resuelto entra como 2 o 3)

## Contexto
<Qué existe hoy, qué se pide cambiar, por qué. Si el cambio parte de un
spec existente, resumir la porción relevante.>

## Delta
<Uno de: AGREGADO | MODIFICADO | ELIMINADO | NULO | 100% del sistema (solo
Caso 1). Una frase de qué significa concretamente en este cambio.>

## Delta del spec escrito
<Qué se escribió en docs/specs/ en esta Propuesta, sin copiarlo: qué spec,
qué sección nació o se reemplazó, y qué sub-secciones se tocaron. Ej.:
"`spec-reservas-salas.md`: sección nueva 'Reservas recurrentes' (Contrato,
Límites y defaults, Modos de falla) + Decisión fechada + Referencias".
En un cambio sin delta de comportamiento: "solo Decisiones + Referencias;
Comportamiento intacto".>

## Decisiones tomadas y enfoque técnico
<Decisiones ya cerradas para este cambio (stack si aplica, dónde vive la
lógica, formato de errores, etc.) y el enfoque técnico general. Alternativas
evaluadas y descartadas, si las hubo.>

## Mapa de ramas
<Una fila por rama. En un plan con fases, una rama por fase, en orden de
dependencia (ver `ramas-y-commits.md` §2 y `/sdd-ramas`). En un plan de una
sola fase: una fila.>

| Fase | Rama | Depende de | Spec(s) | Estado |
|---|---|---|---|---|
| F1 | `feat/<capacidad>-<slug>` | tronco | `spec-<capacidad>.md` | pendiente / en curso / mergeada |

## Tareas
- [ ] <tarea de código 1> (cubre CA-01)
- [ ] <tarea de código 2> (cubre CA-02, CA-03)

## Criterios de aceptación
<Casos concretos y verificables — NO "funciona bien". Se escriben antes de
construir, junto con el delta del spec, para que la verificación no la defina
quien construyó. Cada uno lleva identificador `CA-NN` y método de
verificación (automática con ruta de la prueba, medición con umbral, o
manual con pasos). Ver `criterios-y-pruebas.md`.>
- **CA-01** <condición observable>. Verificación: <automática: ruta::prueba | medición: umbral | manual: pasos>
- **CA-02** <condición observable>. Verificación: <…>

## Trazabilidad
<La completa /sdd-verificacion. Una fila por criterio; ningún criterio sin fila.>

| Criterio | Sección del spec | Prueba | Resultado |
|---|---|---|---|
| CA-01 | Contrato · … | `tests/…::test_…` | pendiente |

## Pendientes de decisión
<Preguntas abiertas que necesitan respuesta humana, incluidas las
dependencias o riesgos "por evaluar" que salieron de Exploración. Mientras
haya alguna, el gate de /sdd-propuesta no se aprueba. Vacío si no hay
ninguna.>

## Ajustes durante la construcción
<Lo completa /sdd-aplicacion si descubrió algo que el spec no previó: qué se
descubrió, qué ajuste del spec se propuso y quién lo aprobó. Vacío si no hubo.>
```

## Reglas

- El nombre de archivo lleva la fecha en la que nace el plan: `docs/plan-<tema>-<fecha>.md`. No renombrar el archivo si el plan se retoca después — la fecha marca el nacimiento, no la última edición.
- **Las tareas son de código.** Escribir el spec no es una tarea del plan: ya se hizo en `/sdd-propuesta`, antes de aprobar el plan. Nunca poner "en `/sdd-aplicacion`: agregar la sección al spec".
- **El plan no copia el delta del spec**, lo referencia en "Delta del spec escrito". Si los dos dicen lo mismo con palabras distintas, en algún momento van a divergir.
- Un plan grande (varias fases) es un plan padre con sub-secciones de fase, pero cada fase se sigue cerrando como su propio cambio acotado (regla 3.3) — no se junta todo en un solo cambio gigante. Las fases siguientes usan este mismo plan: no se crea un plan por fase.
- **Destilar** (en `/sdd-verificacion`): el delta del spec ya estaba escrito desde la Propuesta, así que destilar es confirmar que el spec describe exactamente lo construido, recortar lo que no se hizo, actualizar **Estado** a `destilado` y dejar una nota de qué quedó en el spec y qué quedó afuera. En un plan con fases, al cerrar cada fase se marcan sus tareas como hechas y el plan sigue `en desarrollo`; pasa a `destilado` recién al cerrar la última fase.
- El plan puede tener alternativas descartadas, dudas y fases futuras — el spec no puede. No confundir los dos documentos.
- Si el usuario aprobó dividir un spec (ver `verificacion-division.md`, extensión de las skills), eso **no es un plan aparte** ni obliga a crear uno: si ya hay plan, va como una tarea más ("separar `<subcapacidad>` en `spec-<padre>-<subcapacidad>.md`, en commit aparte"), que se ejecuta en `/sdd-propuesta` antes de escribir el delta, con los siete puntos de control como criterios de aceptación de esa tarea. Si la negó, la decisión fechada va en `Decisiones` del spec.
