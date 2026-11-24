# Roadmap y Backlog Priorizado (BDD + MoSCoW / WSJF)

- **Generado (UTC):** `2026-11-23T21:13:28Z`
- **Resumen:** El roadmap inicial se enfoca en establecer una base sólida para el procesamiento de pagos (Sprint 1), seguida por la habilitación de funcionalidades clave como tokenización y cumplimiento fiscal (Sprint 2). Los Sprints 3 y 4 se dedicarán a la gestión avanzada de tesorería, mitigación de riesgos (reembolsos, contracargos), integraciones críticas (SAP) y automatización financiera (conciliación, reportes, multimoneda), priorizando la seguridad, la eficiencia y el cumplimiento normativo en cada etapa.

## Épicas

- **EPIC-01 — Procesamiento de Pagos y Experiencia del Cliente** (Valor: Aumentar la tasa de conversión, mejorar la satisfacción del cliente y habilitar modelos de negocio de suscripción.): Habilitar un flujo de pago flexible y seguro para el cliente final, soportando múltiples métodos de pago y tokenización para transacciones recurrentes, mejorando la usabilidad y la seguridad.
- **EPIC-02 — Gestión Financiera y Cumplimiento Fiscal** (Valor: Reducir errores manuales, optimizar la eficiencia operativa, garantizar la trazabilidad fiscal y proporcionar visibilidad financiera.): Automatizar los procesos contables, de facturación, conciliación y reportes para asegurar la exactitud financiera, el cumplimiento normativo y la integración con sistemas ERP.
- **EPIC-03 — Operaciones de Tesorería y Mitigación de Riesgos** (Valor: Proteger los activos de la empresa, mejorar la eficiencia en la resolución de disputas y mantener informados a los stakeholders sobre eventos críticos.): Implementar funcionalidades para la gestión segura de reembolsos, contracargos y notificaciones en tiempo real, minimizando el fraude y mejorando la respuesta a eventos críticos de tesorería.

## Historias de Usuario Priorizadas

### HU-001 (Sprint 1 | Must Have | WSJF 7.5 | 5 pts): Habilitar Checkout Multicanal para diversos métodos de pago
- **Épica:** `EPIC-01` | **RF:** `RF-001` | **Depende de:** `Ninguna`
- **Historia:** *Como* Cliente final, *quiero* Realizar pagos a través de un Checkout Multicanal, soportando tarjetas de crédito/débito, transferencias bancarias vía PSE y billeteras digitales, *para* Pueda completar la compra de forma rápida y sin ser redirigido fuera del flujo de compra..

```gherkin
Scenario: Pago exitoso con tarjeta de crédito/débito en Checkout Multicanal
  Given el cliente ha seleccionado una tarjeta de crédito/débito y ha ingresado los datos requeridos en el Checkout Multicanal
  When confirma el pago y el sistema procesa la transacción
  Then el sistema autoriza el pago en < 300ms p95, muestra un mensaje de éxito y redirige al cliente a la página de confirmación de compra.

Scenario: Fallo de pago por datos inválidos o rechazo bancario
  Given el cliente intenta realizar un pago con datos de tarjeta inválidos o el banco emisor rechaza la transacción
  When el sistema intenta procesar el pago
  Then el sistema muestra un mensaje de error claro, permite al cliente reintentar con otra información y no almacena datos sensibles en texto plano.

```

### HU-002 (Sprint 2 | Must Have | WSJF 6.0 | 8 pts): Implementar Tokenización de Tarjetas para pagos recurrentes
- **Épica:** `EPIC-01` | **RF:** `RF-002` | **Depende de:** `HU-001`
- **Historia:** *Como* Cliente final, *quiero* Que mis datos de tarjeta sean tokenizados y almacenados de forma segura, *para* Se puedan procesar cobros de suscripciones y pagos recurrentes de forma automática y segura, sin reingresar mi información..

```gherkin
Scenario: Tokenización exitosa de tarjeta para uso futuro
  Given el cliente ha realizado un pago exitoso con tarjeta y ha optado por guardar su método de pago para futuras transacciones
  When el sistema procesa la solicitud de tokenización
  Then el sistema genera un token único, almacena los datos sensibles en la Bóveda de Tokenización (PCI-DSS compliant) y asocia el token al perfil del cliente, sin almacenar el CVV.

Scenario: Rechazo de tokenización por fallo de seguridad o consentimiento
  Given una petición de tokenización que no cumple con los estándares de seguridad (ej. intento de almacenar PAN en texto plano) o el cliente no ha dado consentimiento explícito
  When el sistema evalúa la solicitud de tokenización
  Then el sistema rechaza la operación, registra el intento en bitácora inmutable y no persiste ningún dato sensible de tarjeta.

```

### HU-003 (Sprint 2 | Must Have | WSJF 7.0 | 8 pts): Generar automáticamente asientos contables y facturas electrónicas post-pago
- **Épica:** `EPIC-02` | **RF:** `RF-003` | **Depende de:** `HU-001`
- **Historia:** *Como* Sistema de Pagos/Facturación, *quiero* Generar automáticamente un Asiento Contable y disparar la emisión de una Factura Electrónica (en formato XML y PDF) ante la autoridad fiscal correspondiente (DIAN/CFDI) y enviarla por correo electrónico al comprador, *para* Se automatice el registro contable y el cumplimiento fiscal post-pago..

```gherkin
Scenario: Generación y envío exitoso de factura electrónica y asiento contable
  Given un pago ha sido aprobado y confirmado por el sistema
  When el sistema dispara la generación del Asiento Contable y la Factura Electrónica
  Then el sistema genera el Asiento Contable, emite la Factura Electrónica en XML y PDF a la autoridad fiscal, la envía al correo del comprador y registra el evento en bitácora inmutable.

Scenario: Manejo de errores en la emisión de factura electrónica
  Given un pago ha sido aprobado, pero la integración con la autoridad fiscal falla o devuelve un error al intentar emitir la Factura Electrónica
  When el sistema intenta emitir la Factura Electrónica
  Then el sistema registra el error en un log auditable, notifica al equipo de operaciones para intervención manual y reintenta la emisión según una política de reintentos configurable.

```

### HU-004 (Sprint 3 | Must Have | WSJF 8.0 | 13 pts): Permitir gestión de reembolsos con doble aprobación y MFA para montos altos
- **Épica:** `EPIC-03` | **RF:** `RF-004` | **Depende de:** `HU-001`
- **Historia:** *Como* Personal de Soporte, *quiero* Procesar Reembolsos de pagos a clientes, exigiendo un flujo de doble aprobación con Autenticación Multifactor (MFA) para Reembolsos mayores a $500 USD por parte del Líder de Tesorería, *para* Se prevengan fraudes internos, se mejore la eficiencia en la atención al cliente y se mantenga trazabilidad fiscal..

```gherkin
Scenario: Doble aprobación exitosa de reembolso con MFA
  Given un reembolso de $750 USD ha sido solicitado por Personal de Soporte y está pendiente de aprobación por el Líder de Tesorería
  When el Líder de Tesorería verifica su segundo factor MFA y aprueba la solicitud
  Then el sistema ejecuta el reembolso idempotente, guarda usuario, IP y timestamp UTC en bitácora inmutable y actualiza el estado del reembolso a 'Aprobado'.

Scenario: Rechazo de reembolso por falta de MFA o aprobación
  Given un reembolso mayor a $500 USD es intentado aprobar sin MFA o por un usuario no autorizado
  When el sistema evalúa la solicitud de aprobación
  Then el sistema rechaza la operación, registra el intento fallido en la bitácora de seguridad y mantiene el reembolso en estado 'Pendiente de Aprobación'.

```

### HU-005 (Sprint 3 | Should Have | WSJF 5.5 | 5 pts): Enviar notificaciones en tiempo real de reembolsos y contracargos vía Webhooks
- **Épica:** `EPIC-03` | **RF:** `RF-005` | **Depende de:** `HU-004, HU-006`
- **Historia:** *Como* Sistema de Notificaciones, *quiero* Enviar alertas y notificaciones en tiempo real sobre el estado de los Reembolsos y Contracargos a través de Webhooks firmados, *para* Se mantenga informados a los stakeholders sobre eventos críticos de tesorería y riesgo..

```gherkin
Scenario: Envío exitoso de Webhook de reembolso aprobado
  Given un reembolso ha sido aprobado y procesado exitosamente
  When el sistema detecta el cambio de estado del reembolso
  Then el sistema genera un evento de Webhook, lo firma con HMAC-SHA256, incluye un timestamp anti-replay y lo envía a los endpoints configurados vía TLS 1.3.

Scenario: Manejo de errores en el envío de Webhook
  Given un evento de contracargo ocurre, pero el endpoint del Webhook configurado no está disponible o devuelve un error HTTP 5xx
  When el sistema intenta enviar el Webhook
  Then el sistema registra el error, implementa una política de reintentos exponencial y notifica al equipo de operaciones sobre el fallo persistente.

```

### HU-006 (Sprint 3 | Must Have | WSJF 7.2 | 8 pts): Habilitar la gestión en tiempo real de Contracargos
- **Épica:** `EPIC-03` | **RF:** `RF-006` | **Depende de:** `HU-001`
- **Historia:** *Como* Equipo de Riesgos, *quiero* Gestionar en tiempo real los Contracargos recibidos de los adquirentes, *para* Se reduzcan pérdidas por fraude y se optimice la resolución de disputas..

```gherkin
Scenario: Recepción y registro exitoso de un contracargo
  Given el sistema recibe una notificación de contracargo de un adquirente de pagos
  When el sistema procesa la notificación
  Then el sistema registra el contracargo en la base de datos, lo asocia a la transacción original, actualiza el estado de la orden y registra el evento en bitácora inmutable.

Scenario: Manejo de contracargos duplicados o inválidos
  Given el sistema recibe una notificación de contracargo que ya ha sido procesada o que contiene datos inválidos
  When el sistema intenta registrar el contracargo
  Then el sistema detecta la duplicidad o invalidez, rechaza el procesamiento, registra el intento en un log de errores y no altera el estado de la transacción original.

```

### HU-007 (Sprint 4 | Must Have | WSJF 6.5 | 13 pts): Automatizar la conciliación bancaria de transacciones
- **Épica:** `EPIC-02` | **RF:** `RF-007` | **Depende de:** `HU-001, HU-003`
- **Historia:** *Como* Sistema de Conciliación, *quiero* Automatizar la Conciliación Bancaria, cruzando extractos bancarios y reportes de adquirentes con las órdenes pagadas, *para* Se optimice la gestión financiera y se asegure la exactitud de los registros..

```gherkin
Scenario: Conciliación exitosa de transacciones
  Given el sistema ha importado extractos bancarios y reportes de adquirentes, y existen órdenes pagadas en el sistema
  When el proceso de conciliación automática se ejecuta
  Then el sistema identifica y marca como conciliadas las transacciones coincidentes, genera un reporte de diferencias y registra el proceso en bitácora inmutable.

Scenario: Identificación de transacciones no conciliadas
  Given el proceso de conciliación automática se ha ejecutado
  When existen transacciones en los extractos bancarios/reportes de adquirentes que no tienen una contraparte en las órdenes pagadas del sistema
  Then el sistema lista estas transacciones como 'no conciliadas' en un reporte de excepciones y las marca para revisión manual por el equipo de tesorería.

```

### HU-008 (Sprint 3 | Must Have | WSJF 6.8 | 8 pts): Integrar pólizas consolidadas de transacciones con ERP SAP
- **Épica:** `EPIC-02` | **RF:** `RF-008` | **Depende de:** `HU-003`
- **Historia:** *Como* Sistema de Integración, *quiero* Enviar la póliza consolidada de transacciones al sistema ERP SAP, *para* Se integren los datos financieros con el sistema contable central de la empresa..

```gherkin
Scenario: Envío exitoso de póliza consolidada a SAP
  Given se ha generado una póliza consolidada de transacciones diarias
  When el sistema intenta enviar la póliza a SAP
  Then la póliza es enviada y registrada exitosamente en SAP, y el evento es registrado en la bitácora inmutable con un ID de transacción SAP.

Scenario: Manejo de errores en la integración con SAP
  Given el sistema intenta enviar una póliza consolidada a SAP, pero la conexión falla o SAP devuelve un error de validación
  When el sistema procesa la respuesta de SAP
  Then el sistema registra el error detalladamente, notifica al equipo de finanzas y permite reintentar el envío de la póliza una vez resuelto el problema.

```

### HU-009 (Sprint 4 | Should Have | WSJF 5.8 | 13 pts): Soportar transacciones multimoneda y cálculo de impuestos internacionales
- **Épica:** `EPIC-02` | **RF:** `RF-009` | **Depende de:** `HU-001, HU-003`
- **Historia:** *Como* Sistema de Pagos/Facturación, *quiero* Soportar transacciones y registros en múltiples monedas, incluyendo el cálculo de impuestos internacionales aplicables, *para* Se habiliten operaciones en mercados internacionales y se asegure el cumplimiento fiscal en diferentes jurisdicciones..

```gherkin
Scenario: Procesamiento exitoso de pago en moneda extranjera con cálculo de impuestos
  Given un cliente realiza una compra en una moneda diferente a la base del sistema y se aplican impuestos internacionales
  When el sistema procesa el pago y la facturación
  Then el sistema calcula el tipo de cambio, aplica los impuestos correspondientes, registra la transacción en la moneda original y base, y emite una Factura Electrónica conforme a la normativa local.

Scenario: Validación de configuración de impuestos para nueva jurisdicción
  Given se intenta configurar una nueva jurisdicción fiscal con reglas de impuestos complejas
  When el administrador guarda la configuración de impuestos
  Then el sistema valida que todas las reglas obligatorias estén definidas y que no haya conflictos, mostrando errores claros si la configuración es incompleta o inconsistente.

```

### HU-010 (Sprint 4 | Should Have | WSJF 5.0 | 8 pts): Generar reportes ejecutivos de tesorería con flujo de caja y saldos
- **Épica:** `EPIC-02` | **RF:** `RF-010` | **Depende de:** `HU-001, HU-003, HU-007`
- **Historia:** *Como* Sistema de Reportes, *quiero* Generar Reportes Ejecutivos de Tesorería que incluyan flujo de caja, comisiones de pasarela y saldos por conciliar, *para* Se proporcione visibilidad financiera para la toma de decisiones estratégicas..

```gherkin
Scenario: Generación exitosa de reporte de flujo de caja
  Given existen datos de pagos, reembolsos, contracargos y conciliaciones en el sistema
  When un usuario autorizado solicita un reporte de flujo de caja para un período específico
  Then el sistema genera un reporte consolidado que muestra ingresos, egresos y saldos, con datos enmascarados para PII y acceso restringido por RBAC.

Scenario: Acceso denegado a reportes sin autorización o MFA
  Given un usuario sin los permisos adecuados o sin completar MFA intenta acceder a un reporte ejecutivo de tesorería
  When el sistema evalúa la solicitud de acceso
  Then el sistema deniega el acceso, registra el intento en la bitácora de seguridad y muestra un mensaje de error indicando la falta de permisos o autenticación.

```
