# Plantilla del reporte de cambio (cuerpo del commit de merge)

No hay pull request: el repositorio es solo local. El reporte de verificación se escribe como **mensaje del commit de merge** al tronco de integración (`git merge --no-ff <rama>`), de modo que `git log` y `git show` bastan para saber qué se aprobó y cómo se verificó. Los criterios `CA-NN` viven en el plan o en el cuerpo del **commit de propuesta**; este reporte los resume con su resultado.

Primera línea (asunto): `merge(<capacidad>): <imperativo corto>` — igual que el commit de propuesta.

```
merge(<capacidad>): <imperativo corto>

Qué y por qué
  <2–4 frases: el problema y el cambio. Sin repetir el spec.>

Caso: 2 · Delta: AGREGADO · Plan: docs/plan-<tema>-<fecha>.md (o "sin plan")

Specs
  - docs/specs/spec-<capacidad>.md — secciones: <Contrato, Límites y defaults, Modos de falla…>
  - Relacionadas: spec-<otra>.md (consume / es consumida / conflicto con invariante)
  - Commit de propuesta (punto fijo del spec aprobado): <hash>

Criterios de aceptación
  CA-01  <condición observable>      prueba: tests/…::test_…      OK
  CA-02  <…>                         manual: <pasos>             OK
  Cobertura del spec: cada ítem de Contrato, Límites y Modos de falla tiene criterio.

Ajustes durante la construcción
  <Ninguno. | Qué se descubrió, qué ajuste del spec, quién lo aprobó y en qué commit (SDD-Ajuste: aprobado).>

Verificación
  Dirección 1 (código cumple spec y criterios): <resultado>
  Dirección 2 (spec = lo construido):           <igual / se recortó …>
  No-regresión:                                  <qué se probó>
  Contexto limpio:                               <hecha / no aplica / rechazada por el usuario>
  Seguridad y dependencias:                      <sin hallazgos / hallazgos y decisión>
  Pruebas, lint y tipos locales:                 <comandos y resultado>
  sdd-lint.sh:                                   <sin errores>

Riesgos y reversión
  Revertir con `git revert -m 1 <hash-del-merge>`: <sí/no, y por qué no>
  Datos persistentes afectados: <no / sí → plan>
  Interruptor de configuración: <no / nombre>
  Versión de vuelta: <tag local anterior o "ninguna todavía">

SDD-Caso: 2
SDD-Fase: verificacion
SDD-Spec: spec-<capacidad>.md
SDD-CA: CA-01, CA-02
```

Reglas:
- No pegar el diff del spec: se referencia el commit de propuesta.
- Si el cambio no tiene plan, la tabla de trazabilidad (criterio → sección del spec → prueba → resultado) va completa en este mensaje.
- Si el desarrollador decide después publicar en un remoto y abrir un PR, este mismo texto sirve como descripción; esa acción es suya y manual.
