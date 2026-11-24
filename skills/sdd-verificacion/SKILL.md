---
name: sdd-verificacion
description: Use when the implementation on the change branch is done, or the user asks to verify, review, validate, close or merge a change. Checks both directions (code meets spec and criteria; spec describes exactly what was built), fills the criterion-to-test traceability matrix, runs the definition of done and the security checks, offers a clean-context verification, asks for the human closing gate and merges locally into the integration trunk. Never touches remotes.
argument-hint: [opcional: ruta al plan si hay más de uno aplicado sin verificar]
---

# sdd-verificacion — Fase 4: Verificación y fusión

Última fase del ciclo del cambio. Contrastar lo construido contra lo prometido **en dos direcciones**, dejar el spec describiendo exactamente lo que corre, comprobar la definición de terminado y cerrar el cambio con el merge.

Leer `../_shared/convenciones.md`, `../_shared/plantilla-spec.md`, `../_shared/criterios-y-pruebas.md` y `../_shared/entrega.md`. Las rutas `../_shared/` son relativas a la carpeta de esta skill.

> **Git solo por script.** Toda escritura en git (crear rama, cambiar de rama, commit, merge, borrar rama, tag, worktree) se hace con `bash ../_shared/scripts/sdd-git.sh <subcomando>`, nunca con `git switch`, `git add`, `git commit`, `git merge`, `git branch` o `git tag` armados a mano. El script simula por defecto, valida las reglas del ciclo y solo ejecuta con `--ejecutar`; los subcomandos sensibles exigen `--aprobado "<cita del OK del usuario>"`. No hay comandos de remoto: nada de push, pull, PR ni `gh`. Las lecturas (`git status`, `git diff`, `git log`, `git show`) sí pueden hacerse directamente. Detalle en `../_shared/ramas-y-commits.md` §0.

## Por qué esta fase sigue necesitando un humano

El spec y los criterios se escribieron y aprobaron en `/sdd-propuesta` y están **commiteados**: el agente que construyó no redactó el spec contra el que se lo verifica. Aun así, esta fase no se autoaprueba: cierra con el OK humano. **Ofrecer siempre** la verificación con contexto limpio (Paso 0) en los cambios donde `entrega.md` §2 la recomienda.

## Paso 0 — Verificación con contexto limpio (ofrecer)

Para Caso 3, Caso 4, diffs de más de ~400 líneas o cambios que tocan invariantes: ofrecer verificar en una **sesión nueva** o en un subagente que reciba **solo** el diff del spec, la lista de criterios `CA-NN`, el diff del código y los comandos del proyecto — sin el historial de cómo se construyó. Si el usuario acepta, el reporte de esa verificación reemplaza al de los Pasos 3 a 5, y esta sesión solo ejecuta los Pasos 5b a 7. Si lo rechaza, registrarlo en el reporte.

## Paso 1 — Ubicar rama, spec, criterios y plan

1. Correr `bash ../_shared/scripts/sdd-estado.sh`. La rama debe tener los commits de propuesta y de aplicación (`SDD-Fase`). Si falta alguno, no verificar: decir qué fase falta.
2. El plan, si existe (ruta de `$ARGUMENTS`, o `docs/plan-*.md` con `Estado: en desarrollo` cuyo trabajo ya se aplicó): tiene los criterios `CA-NN`, "Delta del spec escrito", "Trazabilidad" y "Ajustes durante la construcción". Sin plan: los criterios están en el cuerpo del commit de propuesta o en el commit de propuesta (`git show`), el delta es `git diff <tronco>...HEAD -- docs/specs/`, y los ajustes son los commits `SDD-Ajuste: aprobado`.
3. Si los criterios no se encuentran, pedírselos al usuario y no verificar contra criterios inventados.

## Paso 2 — Cargar la rama del Caso

Ir a `references/caso1.md`, `caso2.md`, `caso3.md` o `caso4.md` según el Caso — cada uno pesa distinto qué verificar (Caso 3 es el más exigente; Caso 4 exige paridad medida con tests, no solo lectura).

## Paso 3 — Dirección 1: el código cumple el spec y los criterios

Completar la **matriz de trazabilidad** (`criterios-y-pruebas.md` §3): una fila por `CA-NN` con la sección del spec, la prueba y el resultado, **corriendo** las pruebas y ejecutando los criterios manuales y de medición, no leyéndolos. Cumple / no cumple / parcial, con evidencia.

- No inventar criterios nuevos acá — si algo importante quedó afuera, es señal de que `/sdd-propuesta` los dejó incompletos: señalarlo, pero no usarlo para reprobar el cambio por sorpresa.
- **Cobertura del spec:** cada ítem de *Contrato*, *Límites y defaults* y *Modos de falla* del delta tiene al menos un criterio con resultado. Un ítem sin criterio es un hueco de la Propuesta: reportarlo.
- Contrastar el código contra las secciones que acotan al agente: el *Contrato*, los topes de *Límites y defaults*, lo que dice *Modos de falla* y lo que excluye *Fuera de alcance*.
- **No-regresión:** confirmar que lo que el spec ya describía antes de este cambio se sigue comportando igual (en Caso 2 y 3, probar puntualmente las capacidades relacionadas).
- **Paquete de diseño referenciado** (`../_shared/diseno-a-spec.md` §7): comprobar, con los `CA-NN` derivados, que el contrato implementado cumple el OpenAPI, que el esquema migrado coincide con el DDL, que se cubren los estados de pantalla y que cada fila de la matriz de roles (permitida y denegada) se comporta como dice.

## Paso 4 — Dirección 2: el spec describe exactamente lo construido

Recorrer el delta del spec (la sección nueva o la porción reemplazada) y preguntar, ítem por ítem: *¿esto corre?*

- **Si el spec promete algo que el código no hace** (quedó por debajo del delta): **recortar el spec** para que describa solo lo construido, en un commit `sdd-git.sh commit --tipo spec --capacidad <cap> --asunto "recortar a lo construido" --fase verificacion`. Lo que no se implementó no llega al tronco como texto: se queda en el plan (como fase futura o pendiente), si lo hay, o se descarta. Recortar es la regla, no una opción.
- **Si el código hace algo que el spec no describe**: es una discrepancia de la dirección 1 (se construyó fuera del spec). No se "arregla" agregándolo al spec acá: se reporta, y el usuario decide si vuelve a `/sdd-aplicacion` para quitarlo o si es un ajuste que debió pedirse en esa fase.
- **Estados transitorios en el spec** ("implementación a medias", "todavía sin endpoint"): quitarlos. `sdd-lint.sh` los avisa.

## Paso 5 — Definición de terminado, seguridad y pruebas locales

Recorrer el checklist de `../_shared/entrega.md` §1 (DoD) y los chequeos de seguridad y dependencias de §3, con evidencia:

- Correr formato/lint, tipos y **todas** las pruebas del proyecto; `bash ../_shared/scripts/sdd-lint.sh` sin errores. Si `docs/arquitectura.md` declara un **umbral de cobertura**, medirlo y adjuntar el informe (`.xml` o `.html`) como evidencia en la matriz.
- Secretos en el diff, dependencias nuevas (versión, licencia, auditoría), entradas externas validadas, datos hacia el LLM o terceros, licencias de activos. Ofrecer correr la skill `security-review` sobre la rama.
- **Pruebas locales**: la corrida completa de los comandos del proyecto (no se depende de un CI remoto). Si el proyecto no define alguno, decirlo y proponer crearlo.
- **Reversión** (`entrega.md` §5): confirmar que el reporte de merge responde si se puede revertir (`git revert -m 1 <merge>`), qué datos persistentes toca, si hay interruptor y a qué versión se vuelve.

## Paso 5a — Reporte

Producir un reporte corto (es el cuerpo del commit de merge; plantilla en `../_shared/plantilla-reporte.md`):

- Criterios: cumplidos / no cumplidos / parciales, con la matriz de trazabilidad.
- No-regresión.
- Dirección 2: si el spec quedó igual o qué se recortó.
- DoD y seguridad: sin hallazgos o los hallazgos con su decisión.
- Discrepancias, con el detalle necesario para decidir si hay que volver a `/sdd-aplicacion`.

Si hay discrepancias de la dirección 1, no cerrar el cambio — decirle al usuario que hace falta volver a `/sdd-aplicacion` antes de reintentar esta fase.

## Paso 5b — Verificación de división sobre el spec final

Extensión de las skills (no está en la metodología v4). Correr `../_shared/verificacion-division.md` sobre el spec final, ya recortado si hizo falta.

- Si hay disparadores y se cumplen los cinco criterios, incluirlo en el reporte como **recomendación para el próximo cambio** — nunca como discrepancia: **no bloquea el cierre**. Preguntarle igual al usuario si la aprueba; si dice que sí, se aplica en la próxima `/sdd-propuesta`, y si dice que no, se registra la decisión fechada en el spec.
- Si no se recomienda dividir, una línea en el reporte y nada en el spec.
- **Si en este cambio hubo una división** (aplicada en `/sdd-propuesta`), verificar los siete puntos de control:
  1. Todo texto quitado del padre aparece en el hijo, sin cambio de significado.
  2. El hijo tiene todos los invariantes que le aplican, completos y con su porqué.
  3. La relación está en los cuatro lugares: nombre del archivo, índice, `Referencias` del hijo y `Referencias` del padre.
  4. `Decisiones` fechada y con los criterios cumplidos, en ambos specs.
  5. El hijo heredó el `Estado` que tenía la sección.
  6. El commit de la división no toca código.
  7. Un solo nivel: el padre no es a su vez hijo de otro spec.

  Si alguno falla, es una discrepancia: se corrige antes de cerrar.

## Paso 6 — Gate: revisión humana

El diff del spec ya se aprobó en `/sdd-propuesta` (commit de propuesta). Acá **no se vuelve a pedir la aprobación de ese mismo diff**:

- **Si el spec se ajustó en `/sdd-aplicacion`** (commits `SDD-Ajuste: aprobado`) o se recortó en el Paso 4: mostrar el diff del spec **desde el commit de propuesta** (`git diff <hash-propuesta>..HEAD -- docs/specs/`) y pedir revisión explícita de ese diff.
- **Si no se ajustó**: decirlo explícitamente ("el spec está igual a lo aprobado en Propuesta"); lo recortado, si lo hubo, ya figura en el reporte.

El cierre sigue siendo del humano. No autoaprobar en nombre del usuario aunque el reporte no tenga discrepancias.

## Paso 7 — Cerrar el cambio (y destilar el plan, si lo hay)

Una vez que el humano aprueba:

1. Actualizar los `Estado` del spec si corresponde: `desplegado` si lo descrito ya corre completo, `parcial` si el plan tiene fases pendientes. En una migración (Caso 4) el `Estado` no cambia: ver `references/caso4.md`. **Siempre** actualizar `Última revisión` del spec a la fecha de hoy: así el cierre tiene contenido. Commit de cierre: `sdd-git.sh commit --tipo chore --capacidad <cap> --asunto "cierra la verificación" --fase verificacion --caso <n> --archivos <spec> [<plan>] --ejecutar`. **Sin este commit el script se niega a mergear.**
2. **Si hay plan:** completar la tabla de **Trazabilidad**, dejar una nota de qué quedó en el spec y qué (si algo del plan no se implementó) quedó afuera o se recortó. Si el plan no tiene fases, o esta es la última, actualizar `Estado: destilado`. **Si quedan fases pendientes**, marcar como hechas las tareas de esta fase y dejar el plan en `en desarrollo`: la próxima fase es un cambio nuevo, con su rama, que empieza en `/sdd-exploracion` y usa este mismo plan (`/sdd-ramas` lo tiene mapeado).
3. **Mergear en local, con OK explícito en cada paso** (`ramas-y-commits.md` §4 y §5), siempre con el script:
   - Escribir el reporte (plantilla `../_shared/plantilla-reporte.md`) en un archivo temporal y correr `bash ../_shared/scripts/sdd-git.sh merge <rama> --capacidad <cap> --caso <n> --asunto "…" --cuerpo-archivo <reporte> --aprobado "<cita del OK>"` primero sin `--ejecutar` (simula) y con `--ejecutar` tras el OK. Si la rama está atrasada, el script lo dice: `sdd-git.sh actualizar-rama --ejecutar` desde la rama y volver a verificar. Si hay conflictos, el script aborta el merge solo y devuelve el código 3.
   - **Nada contra remotos** (push, PR, checks remotos): publicar es manual del desarrollador.
   - Con OK aparte: `sdd-git.sh borrar-rama <rama> --aprobado "<cita>" --ejecutar` (solo borra ramas ya mergeadas).
4. Si el cambio se despliega o hay cambios acumulados para publicar, **ofrecer** `sdd-entrega` (no se invoca sola: publicar una versión es una decisión del usuario).

## Cerrar la fase

Confirmar al usuario que el cambio quedó cerrado (o qué falta para mergear), y recordarle que el próximo cambio arranca de nuevo en `/sdd-exploracion`.

## Referencias

- `../_shared/convenciones.md` — AS-BUILT y spec primero; destilar.
- `../_shared/plantilla-spec.md`
- `../_shared/criterios-y-pruebas.md` — matriz de trazabilidad y gates.
- `../_shared/entrega.md` — DoD, seguridad, contexto limpio, reversión.
- `../_shared/ramas-y-commits.md` — merge local, autorizaciones.
- `../_shared/plantilla-reporte.md`
- `../_shared/verificacion-division.md` — extensión de las skills (Paso 5b).
- `../_shared/scripts/sdd-estado.sh`, `../_shared/scripts/sdd-lint.sh`.
- `references/caso1.md`
- `references/caso2.md`
- `references/caso3.md`
- `references/caso4.md`
