# Plan Técnico de Construcción y Desglose (WBS) [HU-003]

## 1. Tareas Técnicas Ordenadas por Capas
- [ ] **TASK-BD-01 (Base de Datos):** Crear migraciones DDL para tabla contabilidads e índices
  *Criterio de salida:* Tablas creadas en base de datos local con claves e índices verificados.
- [ ] **TASK-BE-01 (Backend API):** Configurar Mock Server para OpenAPI de contabilidads
  *Criterio de salida:* Mock server respondiendo ejemplos 200, 201 y 400 para permitir trabajo en paralelo de Frontend.
- [ ] **TASK-BE-02 (Backend API):** Implementar endpoints reales de contabilidads y validaciones
  *Criterio de salida:* Lógica de negocio implementada, respuestas RFC 7807 y matriz de roles verificada.
- [ ] **TASK-FE-01 (Frontend UI):** Construir pantalla de Generar automáticamente asientos contables y facturas electrónicas post-pago con los 4 estados
  *Criterio de salida:* Componentes visuales implementando Empty, Loading, Success y Error contra el mock server.
- [ ] **TASK-QA-01 (Pruebas):** Automatización de pruebas unitarias y de integración para contabilidads
  *Criterio de salida:* Cobertura >= 80% y validación de contrato OpenAPI superada.

## 2. Estructura Recomendada para el Repositorio
```text
src/
├── domain/
│   └── contabilidad/
│       ├── models.py
│       └── service.py
├── infrastructure/
│   ├── database/
│   │   └── migrations/
│   └── repositories/
├── api/
│   ├── routes/
│   │   └── contabilidad_routes.py
│   └── middlewares/
└── ui/
    └── components/
        └── contabilidad/
            ├── ContabilidadView.tsx
            └── states/

```
