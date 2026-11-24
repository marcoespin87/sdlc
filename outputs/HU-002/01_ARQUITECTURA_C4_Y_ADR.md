# Planos de Arquitectura e Integraciones [HU-002]

## 1. Diagrama de Contexto (C4 Nivel 1)
```mermaid
graph TD
    User["Usuario / Operador\n[Persona]\nCliente final"]
    System["Módulo: Implementar Tokenización de Tarjetas para pagos recurrentes\n[Software System]\nSatisface: [HU-002]"]
    AuthService["Servicio Corporativo de Autenticación\n[OAuth2 / OIDC]"]

    User -->|Opera interfaz con HTTPS| System
    System -->|Valida tokens y permisos| AuthService
```

## 2. Diagrama de Contenedores (C4 Nivel 2)
```mermaid
graph TD
    User["Navegador / Cliente"]
    subgraph Boundary["Límite del Sistema - Implementar Tokenización de Tarjetas para pagos recurrentes"]
        SPA["Frontend Web UI\n[TypeScript / React]\nComponentes accesibles"]
        API["Backend Service API\n[FastAPI / Node.js]\nControladores y Lógica de Negocio"]
        DB[("Base de Datos Relacional\n[PostgreSQL]\nPersistencia de datos")]
    end

    User -->|HTTPS| SPA
    SPA -->|JSON / REST| API
    API -->|SQL Transaccional| DB
```

## 3. Diagrama de Secuencia (Casos Críticos y Errores)
```mermaid
sequenceDiagram
    autonumber
    actor U as Usuario (Cliente final)
    participant FE as Frontend UI
    participant BE as Backend API (HU-002)
    participant DB as Base de Datos

    U->>FE: Inicia acción correspondiente a Implementar Tokenización de Tarjetas para pagos recurrentes
    FE->>BE: POST /api/v1/pagos (Payload)
    BE->>BE: Validar token y matriz de roles
    alt Autorización Denegada
        BE-->>FE: 403 Forbidden (RFC 7807)
        FE-->>U: Muestra Estado de Error
    else Validación Exitosa
        BE->>DB: Ejecuta inserción / actualización transaccional
        DB-->>BE: Confirmación de persistencia
        BE-->>FE: 201 Created (Detalles del recurso)
        FE-->>U: Muestra Estado de Éxito
    end
```

## 4. Registro de Decisiones de Arquitectura (ADRs)

### ADR-HU-002-01: Arquitectura Modular para Implementar Tokenización de Tarjetas para pagos recurrentes
* **Estado:** ACEPTADO
* **Contexto:** Se requiere implementar Implementar Tokenización de Tarjetas para pagos recurrentes satisfaciendo [HU-002]. Se evalúa la arquitectura con base en volumen estimado.
* **Decisión:** Implementar como servicio modular monolítico con persistencia relacional.
* **Justificación:** Evita sobreingeniería y complejidad operacional innecesaria ya que el tráfico no amerita microservicios distribuidos.

