# Caso 3 — Propuesta de cambio

Delta = MODIFICADO o ELIMINADO. Ya se determinó en Exploración si esto toca el Comportamiento observable del spec o solo Decisiones/Referencias (cambio de implementación) — llevar esa distinción al spec y a los criterios explícitamente.

## Qué escribir en el spec, antes del código

- **Si toca Comportamiento:** reemplazar la porción afectada de *Comportamiento* con el comportamiento nuevo tal como va a quedar — no agregar el nuevo al lado del viejo, no dejar rastros del viejo. Si se modifica o se rompe a propósito un invariante, reescribirlo en *Invariantes* con su nuevo porqué (nunca dejar el viejo escrito junto al comportamiento que lo contradice). Agregar la *Decisión* fechada.
- **Si es solo cambio de implementación:** escribir **únicamente** la entrada de *Decisiones* (fechada, con el porqué) y las *Referencias* nuevas. *Comportamiento* queda **intacto, palabra por palabra**. Si al escribir el delta aparece la tentación de tocar *Comportamiento*, es la señal de que el cambio no es solo de implementación: detenerse y decírselo al usuario antes del gate.
- **Si es el fix colateral de un bug confirmado en una Fase 0:** el comportamiento correcto **ya está escrito y aprobado** desde la revisión humana de la Fase 0: no se reescribe. El delta del spec se limita a lo que falte decidir ahora (por ejemplo, qué muestra una pantalla que depende de ese comportamiento) y puede quedar vacío. Los criterios prueban ese ítem del spec más la no-regresión. El comportamiento observable **sí cambia** (el código pasa a cumplir el spec): no es un cambio "sin delta de comportamiento".

## Criterios (en el plan si lo hay; si no, en el cuerpo del commit de propuesta)

- **Si toca Comportamiento:** dejar explícito (en el plan, si lo hay, en "Delta del spec escrito") qué porción se reemplazó y qué invariante(s) se modifican o se rompen a propósito, con la razón.
- **Si es solo cambio de implementación:** el criterio de aceptación central es **paridad** — mismo comportamiento observable, verificable por comparación directa (mismas entradas → mismas salidas que antes del cambio), incluidos los casos borde.
- Impacto en lo dependiente: qué otras partes del sistema (y qué specs relacionadas) podrían asumir el comportamiento actual y deberían seguir funcionando igual, o ajustarse a propósito.

## Preguntas abiertas típicas de este Caso

- Si se rompe un invariante existente: ¿hay consenso explícito de que es correcto romperlo, o hace falta confirmarlo con más contexto de negocio?
- Umbrales de aceptación cuando el cambio es de performance/escalabilidad (ej. tiempo de respuesta) en vez de solo funcional.
