# Verificación de división de specs

> **Extensión de las skills.** Esta regla no forma parte de la metodología v4 (`metodologia-sdd-spec-anchored_v4.md` no define specs hijos ni verificación de división). Estas skills la aplican como regla adicional. Si un participante pregunta dónde está en la metodología, la respuesta es: no está, es propia de las skills.

Verificación que corre en **las cuatro fases** del ciclo (y en la Fase 0 del Caso 5). El agente mide y, si corresponde, **recomienda** dividir un spec en un spec hijo. **El usuario aprueba o niega.** No existe un plan de división ni un tipo de cambio nuevo: es una recomendación dentro del trabajo que ya se está haciendo.

Reglas de fondo:

- **El agente nunca divide por iniciativa propia.** Sin aprobación explícita del usuario, no se toca la estructura de specs.
- **Los disparadores se recalculan en cada fase.** No se guarda ningún estado tipo "pendiente de dividir" en el spec — la metodología prohíbe estados transitorios en un spec.
- **Se deben cumplir los cinco criterios.** Si falta uno solo, no se recomienda dividir.

## Disparadores — cuándo se evalúa

Los umbrales de tamaño vienen del límite de 500 líneas que Anthropic define para los archivos de skills, que atacan el mismo problema: cuánto contexto tiene que cargar un agente para trabajar.

| Disparador | Umbral |
|---|---|
| Tamaño del spec | **400 líneas o más** (acercándose al límite de 500) |
| Tamaño excedido | **500 líneas o más** — recomendación prioritaria, señalarlo como tal |
| Sección desproporcionada | Una subcapacidad ocupa **más de un tercio** del spec |
| Cantidad de subcapacidades | **Más de 6** en `Comportamiento` |

Si no se activa ningún disparador, la verificación termina ahí: se reporta en una línea y no se evalúan criterios.

**Antes de recomendar, revisar `Decisiones` del spec.** Si ya se evaluó y el usuario negó la división, solo volver a recomendar si cambió algo: un criterio que antes no se cumplía ahora sí, o el spec creció más de un 25% desde esa decisión.

## Los cinco criterios — se deben cumplir todos

| # | Criterio | Cómo se verifica |
|---|---|---|
| 1 | **Cohesión:** su propósito se escribe en una frase sin "y" | Escribir esa frase |
| 2 | **Independencia:** tiene al menos 3 criterios de aceptación propios, verificables sin montar las otras subcapacidades | Listarlos |
| 3 | **Cambia sola:** de los últimos 5 cambios que la tocaron, al menos 4 no tocaron otras subcapacidades | Planes en `docs/`, historial de MRs, o `git log` del código que la implementa. **Si no hay historia suficiente, el criterio NO se cumple** |
| 4 | **Invariantes propios:** tiene al menos un invariante que no aplica al resto del spec | Revisar `Invariantes` |
| 5 | **Tamaño:** la sección supera **150 líneas** | Contarlas |

Exigir los cinco es deliberado: evita fragmentar un spec solo porque creció.

## Formato de salida

**Sin disparadores** — una línea, para no hacer ruido:

```
Verificación de división: sin disparadores (`spec-reservas.md`, 180 líneas).
```

**Con disparadores** — bloque completo, con la tabla de los cinco criterios:

```markdown
**Verificación de división — `spec-reservas.md`** (Fase: Exploración)
Disparadores: 430 líneas (≥400) · sección "Recurrentes" = 38% del spec
Candidata: Reservas recurrentes

| # | Criterio | ¿Cumple? | Evidencia |
|---|---|---|---|
| 1 | Cohesión | Sí | "Repetir una reserva en el tiempo con excepciones" |
| 2 | Independencia | Sí | 4 criterios propios (serie máxima, feriados, excepción, edición de serie) |
| 3 | Cambia sola | Sí | 4 de los últimos 5 cambios solo tocaron Recurrentes |
| 4 | Invariantes propios | Sí | "Serie máxima de 6 meses" |
| 5 | Tamaño | Sí | 165 líneas |

**Recomendación: dividir** — se cumplen los 5 criterios.
¿Apruebas separar "Reservas recurrentes" en `spec-reservas-recurrentes.md`?
```

Si falta algún criterio, el mismo bloque cierra con **"No se recomienda dividir — no se cumple el criterio N"** y no se le pregunta nada al usuario.

## Qué hacer con la respuesta

**Si el usuario aprueba:**

- La división se aplica **en un commit propio**, separado del cambio funcional, para que su diff se revise solo.
- Se aplica en `/sdd-propuesta`, que es la fase que escribe specs: **antes** de escribir el delta del cambio, para que el delta se escriba ya sobre el spec dividido. Si la aprobación ocurrió en Exploración, se aplica al llegar a Propuesta.
- Si la aprobación ocurre en `/sdd-aplicacion` o `/sdd-verificacion`, no se aplica ahí: queda para la Propuesta del próximo cambio.
- El movimiento debe cumplir los siete puntos de control de más abajo.

**Si el usuario niega:** registrarlo en `Decisiones` del spec padre y seguir con el cambio en curso.

```markdown
- 2026-09-16: se evaluó separar Reservas recurrentes y se decidió no dividir —
  *Porqué: <motivo del usuario>.*
```

**Si no se recomendó dividir** (faltó algún criterio): **no registrar nada en el spec**. Una evaluación que no llevó a ninguna recomendación no es una decisión; basta con reportarla en la conversación. Registrarla solo agrega ruido a `Decisiones`.

## Cómo se relacionan padre e hijo — las cuatro formas, todas obligatorias

**a) Nombre del archivo.** El hijo es un spec plano más, en `docs/specs/`, con el prefijo del padre:

```
docs/specs/
├── README.md
├── spec-reservas.md                 ← padre
├── spec-reservas-checkin.md         ← hijo
└── spec-reservas-recurrentes.md     ← hijo
```

**b) Índice `docs/specs/README.md`,** con la columna *Spec padre*:

| Capacidad | Spec | Spec padre |
|---|---|---|
| Reservas | `spec-reservas.md` | — |
| Check-in de reservas | `spec-reservas-checkin.md` | `spec-reservas.md` |
| Reservas recurrentes | `spec-reservas-recurrentes.md` | `spec-reservas.md` |

**c) `Referencias` en ambos specs,** diciendo **por qué** se relacionan (no basta con "ver spec X"):

```markdown
<!-- En el hijo -->
## Referencias
- Spec padre: `spec-reservas.md` — cada ocurrencia se crea con la validación de
  disponibilidad del padre; cancelar una ocurrencia usa la cancelación del padre.
- Código: `src/reservas/recurrentes/`
```

```markdown
<!-- En el padre -->
## Referencias
- Specs hijos:
  - `spec-reservas-recurrentes.md` — series de reservas; depende de Reservar y Cancelar.
  - `spec-reservas-checkin.md` — check-in y liberación por no-show; depende de Cancelar.
- Código: `src/reservas/`
```

**d) `Decisiones` en ambos specs,** con fecha y criterios cumplidos:

```markdown
## Decisiones
- 2026-09-16: se separa Reservas recurrentes en `spec-reservas-recurrentes.md` —
  *Porqué: criterios cumplidos 1, 2, 3, 4 y 5 (disparador: spec de 430 líneas).*
```

**Un solo nivel.** Un hijo no tiene hijos. Si un hijo necesita dividirse, la parte nueva queda como **hermana**, con el mismo padre. Con más niveles el agente termina leyendo los archivos a medias.

## Siete puntos de control cuando hubo división

1. Todo texto quitado de `Comportamiento` del padre aparece en el hijo, **sin cambio de significado**.
2. El hijo tiene todos los invariantes que le aplican, completos y con su porqué (los que aplican a ambos se escriben completos en los dos specs).
3. La relación está en los **cuatro lugares**: nombre del archivo, índice, `Referencias` del hijo y `Referencias` del padre.
4. `Decisiones` fechada y con los criterios cumplidos, **en ambos specs**.
5. El hijo hereda el `Estado` que tenía la sección en el padre.
6. El commit de la división **no toca código**.
7. Se respeta el nivel único: el padre no es a su vez hijo de otro spec.

## Qué carga el agente después de dividir

| El cambio es sobre... | Qué lee |
|---|---|
| Un spec hijo | El índice y el hijo completo. Abre el padre **solo si** el cambio toca lo que `Referencias` dice que usa de él |
| El spec padre | El índice y el padre completo. Abre **solo** los hijos cuya relación toca el cambio |
| Una capacidad sin relaciones | Su spec, como siempre |

## Dónde corre la verificación

| Fase | Sobre qué mide | Momento |
|---|---|---|
| `/sdd-exploracion` | El spec afectado, tal como está hoy | Al terminar de leerlo, antes del resumen de salida |
| `/sdd-propuesta` | El spec **con el delta ya escrito** | Después de escribir el delta, antes del gate de aprobación. Es la única fase que **aplica** una división aprobada |
| `/sdd-aplicacion` | El spec, solo si se ajustó por un descubrimiento | Después del ajuste. Solo avisa; nunca divide |
| `/sdd-verificacion` | El spec final, ya recortado si hizo falta | Junto con el reporte de criterios; **nunca bloquea el cierre** |
| Fase 0 (Caso 5) | El spec candidato recién redactado | Antes de la revisión humana obligatoria |
