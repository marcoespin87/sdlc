# Seguridad, Accesos y Mitigación de Riesgos [HU-007]

## 1. Matriz de Roles y Permisos (Sin Siglas Opacas)
| Recurso / Endpoint | Acción | Rol | Permitido | Condición / Restricción |
| :--- | :--- | :--- | :---: | :--- |
| `/contabilidads` | Listar / Consultar (GET) | **Administrador de Sistema** | ✓ SÍ | Acceso total sin restricciones. |
| `/contabilidads` | Listar / Consultar (GET) | **Operador de Sucursal** | ✓ SÍ | Filtrado automático estricto por sucursal_id del token. |
| `/contabilidads` | Crear Registro (POST) | **Operador de Sucursal** | ✓ SÍ | Permitido. Se valida límite operativo de creación diaria. |
| `/contabilidads` | Eliminar Registro (DELETE) | **Cualquier Rol** | ✗ NO | Borrado físico prohibido. Solo se admite baja lógica (estado='INACTIVO'). |

## 2. Mitigación de Riesgos Técnicos (OWASP Top 10)
- **Control de Acceso Roto (BOLA / IDOR):** Validación en capa de servicio verificando que el usuario pertenezca a la sucursal del registro.
- **Inyección SQL / NoSQL:** Uso estricto de consultas parametrizadas y mapeo con ORM tipado.
- **Exposición de Datos Sensibles:** Uso de DTOs específicos de salida evitando exponer campos no autorizados de la base de datos.
