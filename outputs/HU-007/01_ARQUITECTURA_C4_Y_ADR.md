# Planos de Arquitectura e Integraciones [HU-007]

## 1. Diagrama de Contexto (C4 Nivel 1)
```mermaid
graph TD
    User["Usuario / Operador\n[Persona]\nCliente final"]
    System["Módulo: Automatizar la conciliación bancaria de transacciones\n[Software System]\nSatisface: [HU-007]"]
    AuthService["Servicio Corporativo de Autenticación\n[OAuth2 / OIDC]"]

    User -->|Opera interfaz con HTTPS| System
    System -->|Valida tokens y permisos| AuthService
```

## 2. Diagrama de Contenedores (C4 Nivel 2)
```mermaid
graph TD
    User["Navegador / Cliente"]
    subgraph Boundary["Límite del Sistema - Automatizar la conciliación bancaria de transacciones"]
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
    participant BE as Backend API (HU-007)
    participant DB as Base de Datos

    U->>FE: Inicia acción correspondiente a Automatizar la conciliación bancaria de transacciones
    FE->>BE: POST /api/v1/contabilidad (Payload)
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

### ADR-HU-007-01: Arquitectura Modular para Automatizar la conciliación bancaria de transacciones
* **Estado:** ACEPTADO
* **Contexto:** Se requiere implementar Automatizar la conciliación bancaria de transacciones satisfaciendo [HU-007]. Se evalúa la arquitectura con base en volumen estimado.
* **Decisión:** Implementar como servicio modular monolítico con persistencia relacional.
* **Justificación:** Evita sobreingeniería y complejidad operacional innecesaria ya que el tráfico no amerita microservicios distribuidos.

