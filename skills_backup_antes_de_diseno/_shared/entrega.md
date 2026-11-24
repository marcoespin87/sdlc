# Calidad antes del merge, entrega, versiones y reversión

La v1 termina en el merge. Un ciclo de software completo sigue con la entrega y con saber **cómo volver atrás**. Este archivo lo cubre sin salir del método: todo se deriva de los specs, los criterios y el historial.

## 1. Definición de terminado (DoD) — checklist de `/sdd-verificacion`

Un cambio está terminado cuando **todo** esto es verdad (cada ítem, marcado con evidencia):

- [ ] Todos los criterios `CA-NN` cumplen y la matriz de trazabilidad está completa (`criterios-y-pruebas.md` §3).
- [ ] Dirección 2: el spec describe exactamente lo construido (recortado si hizo falta).
- [ ] No-regresión comprobada en las capacidades relacionadas.
- [ ] `sdd-lint.sh` sin errores; el índice de specs es coherente.
- [ ] Pruebas, lint y tipos en verde en local (corrida completa de los comandos del proyecto).
- [ ] §3 (seguridad y dependencias) revisada: sin hallazgos nuevos sin decisión.
- [ ] Documentación al día: `docs/arquitectura.md` si cambió algo transversal (vía `/sdd-arquitectura`), README o guía de uso si cambió cómo se usa.
- [ ] Plan: tareas marcadas; `destilado` si era la última fase.
- [ ] La cuerpo del commit de propuesta (o el reporte) está completa y las decisiones de reversión escritas (§5).
- [ ] OK humano explícito de cierre.

## 2. Verificación con contexto limpio (recomendada)

El agente que construyó no debería ser el único que lo aprueba. Para Caso 3, Caso 4, cambios de más de ~400 líneas de diff o cualquier cambio con invariantes tocados:

1. Ofrecer verificar en una **sesión nueva** (o en un subagente de contexto limpio, si el entorno lo permite) que reciba **solo**: el diff del spec, la matriz de criterios, el diff del código y los comandos del proyecto.
2. Ese verificador no ve el historial de cómo se construyó ni las justificaciones del implementador.
3. Su reporte reemplaza al de la fase si encuentra discrepancias; se resuelven antes del cierre.

Es opcional por cambio, pero la skill debe **ofrecerlo siempre** en los casos de arriba.

## 3. Seguridad, dependencias y datos (no es "seguridad completa", es higiene mínima)

Lista corta que se corre en `/sdd-verificacion`; cada hallazgo se resuelve o se registra como decisión fechada:

| Chequeo | Cómo |
|---|---|
| Secretos en el diff | Buscar claves, tokens y cadenas de conexión en `git diff <tronco>...HEAD`; `.env` fuera del repo; `.env.example` sin valores reales |
| Dependencias nuevas o cambiadas | Listarlas con versión y licencia; auditoría del gestor (`pip-audit`, `npm audit` u otro); fijar versiones |
| Entradas externas | Todo lo que llega por API, archivo subido o LLM se valida (tipo, tamaño, formato) antes de usarse |
| Salidas hacia el LLM o terceros | Qué datos viajan; que se cumplan los invariantes de privacidad del spec (por ejemplo, filtro de datos personales) |
| Permisos y rutas | Sin rutas construidas con texto del usuario; archivos subidos renombrados; sin ejecución de código recibido |
| Licencias de activos | Fuentes, plantillas, imágenes y modelos que entran al producto: licencia anotada (en este proyecto, también en el manifiesto) |
| Revisión de seguridad asistida | Ofrecer correr la skill `security-review` sobre la rama |

## 4. Entrega (`/sdd-entrega`)

Después del merge, sobre el tronco:

### Versionado semántico derivado del delta

| Delta del cambio | Efecto en la versión |
|---|---|
| NULO, o cambio sin delta de comportamiento | PATCH |
| AGREGADO (compatible) | MINOR |
| MODIFICADO o ELIMINADO que rompe un contrato o invariante observable | MAJOR (en `0.x`, MINOR) |
| Hotfix | PATCH |

La versión del próximo release es el mayor efecto entre los cambios mergeados desde el último tag.

### Changelog desde el método

Formato *Keep a Changelog*. Se **genera, no se inventa**: de los commits `feat`/`fix`/`change` y de las *Decisiones* nuevas de los specs desde el último tag, agrupado en Agregado / Cambiado / Corregido / Eliminado / Seguridad. Cada línea apunta al spec o al commit de merge. Lo revisa el humano.

### Pasos

1. **Precondiciones:** tronco con las pruebas locales completas en verde, `sdd-lint.sh` sin errores, sin cambios sin commitear.
2. Calcular versión y changelog (arriba). Mostrarlos y pedir OK.
3. Commit `chore(release): vX.Y.Z` (archivo de versión + `CHANGELOG.md`), con trailer `SDD-Fase: entrega`, en el tronco de integración.
4. **Modelo de dos ramas** (`ramas-y-commits.md` §1): llevar el tronco de integración (`develop`) a la **rama de releases** (`main`/`master`) con un merge `--no-ff` (OK explícito) y **taggear allí**. En el modelo de tronco único, el tag va sobre el mismo tronco.
5. Tag anotado `vX.Y.Z` (OK explícito).
6. Despliegue según `docs/arquitectura.md` → "Despliegue" (por ejemplo `docker compose up -d --build`). Si el proyecto no documenta el despliegue, **no inventarlo**: proponer documentarlo.
7. **Humo post-despliegue:** correr los criterios marcados `smoke` y la comprobación de salud; registrar resultado.
8. Cerrar: hito/issues vinculados, nota de release.

## 5. Reversión (se decide antes de mergear, no después del incidente)

Cada cambio con comportamiento nuevo responde en el reporte de merge:

- **¿Se puede revertir con `git revert`?** (sí/no, y por qué no).
- **Estado persistente:** ¿el cambio modifica esquemas o datos? Si sí: plan de migración **hacia atrás** o respaldo previo.
- **Interruptor:** ¿hay una bandera de configuración para apagarlo sin redeploy?
- **Versión de vuelta:** el tag anterior al que se regresa.

Un cambio que modifica datos persistentes sin plan de reversión no se mergea.

## 6. Bugs en producción

Ver `sdd-hotfix`. Principio: **primero una prueba que reproduce el fallo**, después el arreglo mínimo; si el spec era correcto el spec no cambia; si el spec era el equivocado, es Caso 3 y no un hotfix.
