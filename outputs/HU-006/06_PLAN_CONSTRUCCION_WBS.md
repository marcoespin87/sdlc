# Plan Técnico de Construcción y Desglose (WBS) [HU-006]

## 1. Tareas Técnicas Ordenadas por Capas
- [ ] **TASK-BD-01 (Base de Datos):** Crear migraciones DDL para tabla reembolsoss e índices
  *Criterio de salida:* Tablas creadas en base de datos local con claves e índices verificados.
- [ ] **TASK-BE-01 (Backend API):** Configurar Mock Server para OpenAPI de reembolsoss
  *Criterio de salida:* Mock server respondiendo ejemplos 200, 201 y 400 para permitir trabajo en paralelo de Frontend.
- [ ] **TASK-BE-02 (Backend API):** Implementar endpoints reales de reembolsoss y validaciones
  *Criterio de salida:* Lógica de negocio implementada, respuestas RFC 7807 y matriz de roles verificada.
- [ ] **TASK-FE-01 (Frontend UI):** Construir pantalla de Habilitar la gestión en tiempo real de Contracargos con los 4 estados
  *Criterio de salida:* Componentes visuales implementando Empty, Loading, Success y Error contra el mock server.
- [ ] **TASK-QA-01 (Pruebas):** Automatización de pruebas unitarias y de integración para reembolsoss
  *Criterio de salida:* Cobertura >= 80% y validación de contrato OpenAPI superada.

## 2. Estructura Recomendada para el Repositorio
```text
src/
├── domain/
│   └── reembolsos/
│       ├── models.py
│       └── service.py
├── infrastructure/
│   ├── database/
│   │   └── migrations/
│   └── repositories/
├── api/
│   ├── routes/
│   │   └── reembolsos_routes.py
│   └── middlewares/
└── ui/
    └── components/
        └── reembolsos/
            ├── ReembolsosView.tsx
            └── states/

```
