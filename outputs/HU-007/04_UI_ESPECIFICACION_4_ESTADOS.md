# Especificación UI/UX y Sistema de Diseño [HU-007]

* **Pantalla:** La conciliación bancaria de transacciones

## 1. Cobertura de los 4 Estados Obligatorios
- **Estado Vacío (Empty):** Vista de inicio sin registros. Mensaje de bienvenida: 'Aún no hay contabilidads asociados a este entorno.' Botón de acción principal: [+ Registrar Contabilidad].
- **Estado Cargando (Loading):** Skeleton screen animado con shimmer de 3 filas. Botones de envío deshabilitados (disabled) para garantizar idempotencia y evitar duplicidad de solicitudes.
- **Estado Éxito (Success / Normal):** Vista operativa con tabla/tarjetas interactivas de contabilidads, datos enmascarados, badges de estado verde 'ACTIVO' y toast de confirmación.
- **Estado Error (Error):** Banner de error RFC 7807 (Problem Details) con mensaje claro y comprensible para el usuario, código de seguimiento correlacionado y botón [↻ Reintentar Operación].

## 2. Tokens de Diseño Aplicados
```json
{
  "color_primary": "#0052CC",
  "color_background": "#F4F5F7",
  "color_success": "#36B37E",
  "color_error": "#DE350B",
  "font_family": "Inter, system-ui, -apple-system, sans-serif",
  "base_grid": "8px"
}
```
