# Criterios de aceptación, pruebas y trazabilidad

La v1 pide "criterios concretos y verificables" pero no dice cómo se escriben, cómo se enlazan con las pruebas ni qué se corre. Resultado típico: criterios que se verifican "leyendo". La v2 hace que **cada criterio tenga identificador, método de verificación y una prueba que lo cubre**.

## 1. Cómo se escribe un criterio

Identificador estable `CA-NN` (dos dígitos, único dentro del cambio), una condición observable y su método:

```
CA-03  Dado un DataSpec con una relación 1:N de 1 a 3 hijos, al generar 1.000 padres
       cada padre tiene entre 1 y 3 hijos y ninguna clave foránea queda huérfana.
       Verificación: automática — tests/integration/test_relaciones.py::test_cardinalidad_1_a_3
```

| Método | Cuándo | Qué se registra |
|---|---|---|
| **automática** | Casi siempre. Es lo que se prefiere | Ruta de la prueba y nombre |
| **medición** | Rendimiento, tamaño, tiempo (con umbral numérico) | Comando, entorno y valor medido |
| **manual** | Solo experiencia de usuario o algo no automatizable | Pasos exactos y quién los hizo |

Un criterio sin método se considera mal escrito: devolver a `/sdd-propuesta`. Frases como "funciona bien", "es rápido" o "se ve correcto" no son criterios.

### Tipos de criterio que casi siempre faltan

- **No-regresión** (Caso 2 y 3): lo que ya existía se comporta igual.
- **Modos de falla**: por cada fila de *Modos de falla* del spec, un criterio que provoca el fallo y comprueba la respuesta.
- **Límites**: por cada tope de *Límites y defaults*, un criterio en el borde (justo debajo, justo encima).
- **Invariantes**: por cada invariante nuevo, un criterio que intenta violarlo.
- **Paridad** (Caso 3 sin cambio de comportamiento, Caso 4): mismas entradas, mismas salidas.
- **Reproducibilidad** (si el sistema es determinista, como este): misma entrada y semilla, mismos bytes, con 1 y con N procesos.
- **Derivados de un paquete de diseño** (`diseno-a-spec.md` §4): uno por operación del contrato y cada error documentado, uno por fila de la matriz de roles (permitida y denegada), uno por estado de pantalla, uno por mitigación de seguridad y uno por regla del DDL que sea invariante. Cada criterio anota de qué archivo del paquete salió.

## 2. Pruebas primero (rojo → verde)

En `/sdd-aplicacion`, antes del código de cada tarea:

1. Escribir la prueba del criterio; identificarlo en el nombre o en un marcador (`CA-03`). Para Python: nombre de función con el id, un `@pytest.mark.ca("CA-03")` registrado, o el id en el docstring. Lo importante es que **un `grep` por `CA-NN` encuentre la prueba**.
2. Correrla y **ver que falla por la razón correcta** (no por un error de import o de sintaxis).
3. Commit `test(<cap>): …` con `SDD-CA`.
4. Escribir el código mínimo para que pase; commit `feat|fix(<cap>): …`.
5. Refactorizar con las pruebas en verde.

Excepciones razonables: configuración, plantillas y documentación (sin comportamiento que probar), y exploración técnica (spike descartable, que no se mergea).

## 3. Matriz de trazabilidad

Se mantiene en el plan (si existe) o en el cuerpo del commit de propuesta, y `/sdd-verificacion` la completa:

| Criterio | Sección del spec | Prueba | Resultado | Evidencia |
|---|---|---|---|---|
| CA-01 | Contrato · `POST /jobs` | `tests/integration/test_jobs.py::test_crea_job` | ✅ | salida de pytest |
| CA-02 | Límites · volumen máximo | `tests/unit/test_limites.py::test_tope_volumen` | ✅ | — |
| CA-03 | Modos de falla · job huérfano | manual: reiniciar con un job en ejecución | ✅ | 2026-11-20, captura |

Reglas: todo criterio tiene fila; toda fila tiene resultado; todo comportamiento nuevo del spec (cada ítem de *Contrato*, *Límites* y *Modos de falla*) está cubierto por al menos un criterio. Un ítem del spec sin criterio es un hueco de la Propuesta y se señala.

## 4. Qué se corre antes de dar por buena una fase

| Gate | Comandos (los del proyecto; ver `docs/arquitectura.md` → Comandos) |
|---|---|
| Fin de `/sdd-aplicacion` | formato/lint, tipos, pruebas unitarias e integración del módulo y de sus dependientes, `sdd-lint.sh` |
| `/sdd-verificacion` | lo anterior sobre todo el proyecto, más la prueba de determinismo/reproducibilidad si el spec la declara, escaneo de secretos, auditoría de dependencias y revisión de seguridad (ver `entrega.md` §3) |
| Antes del merge | pruebas, lint y tipos locales en verde (la corrida local completa) |

Si el proyecto no tiene alguno de estos comandos todavía, **decirlo explícitamente** y proponer crearlo como tarea; no omitirlo en silencio.

## 5. Cobertura útil, no cobertura numérica

Las skills no fijan un porcentaje global. Si `docs/arquitectura.md` declara un umbral de cobertura **del proyecto** (por ejemplo 80 %), es un gate de `/sdd-verificacion` y su informe (`.xml` o `.html`) se adjunta como evidencia en la matriz. Lo que se exige es la cobertura de criterios (§3) y que los caminos de falla del spec estén probados. Si el proyecto ya mide cobertura, se vigila que **no baje** respecto al tronco en el código tocado.
