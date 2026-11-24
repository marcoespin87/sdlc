# Caso 1 — Propuesta de cambio

Delta = 100% del sistema. Es la Propuesta más grande que va a existir en el proyecto — el resto de los cambios futuros van a ser incrementales sobre lo que esta deja escrito y construido.

## Qué se escribe en esta fase, antes del código

- **Un `docs/specs/spec-<capacidad>.md` por capacidad**, con `Estado: en desarrollo`, siguiendo `plantilla-spec.md`: *Propósito*, *Comportamiento* con las sub-secciones que apliquen, *Invariantes*, *Fuera de alcance*, *Decisiones* y *Referencias* con las dependencias entre esas capacidades ("Depende de / Usada por").
- **`docs/specs/README.md`** con la tabla completa.
- **El documento de arquitectura** (`AGENTS.md`/`CLAUDE.md`/`.cursorrules`/`docs/arquitectura.md`, el que corresponda — ver `convenciones.md`), con la instrucción de la regla 3.1. Es el único Caso del ciclo normal donde nace, fuera de la Fase 0 de Caso 5, y nace **acá**, antes del código.

## Qué debe contener el plan (si hay plan)

Un Caso 1 con varias capacidades suele construirse por fases, y entonces hay plan (regla 3.3). Si no hay plan, los criterios por capacidad van en el cuerpo del commit de propuesta, y stack y arquitectura quedan en el documento de arquitectura.

- **Stack elegido**, con una frase de por qué (o confirmado con el usuario si ya lo trajo decidido).
- **Arquitectura**: patrón (monolito, servicios separados, etc.), organización de carpetas. Lo que se decida acá se escribe en el documento de arquitectura; el plan lo referencia.
- Lista de **capacidades**, cada una con el spec que se escribió.
- **Mapa de ramas**: una rama por fase del plan, en orden de dependencia (las dependencias salen de las *Referencias* "Depende de / Usada por" de los specs). La rama de este primer cambio es `init/<tema>` y contiene solo specs, índice, arquitectura y plan; cada fase de código es otra rama que nace del tronco (o apilada, solo si necesita código de la anterior sin mergear). `/sdd-ramas` arma y crea ese mapa.
- **Flujo de trabajo en `docs/arquitectura.md`**: nombre del tronco, convención de ramas y commits, estrategia de merge, comandos de lint/pruebas, despliegue y reversión.
- Tareas de código agrupadas por capacidad — no hace falta un detalle exhaustivo tarea por tarea, pero sí una fase/tarea por capacidad como mínimo.
- Criterios de aceptación **por capacidad**, no uno genérico para todo el sistema.

## Preguntas abiertas típicas de este Caso

- Stack (si no vino decidido).
- Nombres de las capacidades, y dónde cortar entre ellas (criterio de tamaño de `convenciones.md`).
- Alcance de cada capacidad: qué entra y qué queda explícitamente fuera (va directo a *Fuera de alcance* de cada spec).
- Topes y fallas de cada capacidad (van directo a *Límites y defaults* y *Modos de falla*).
