-- DDL Estructural para [HU-005] - Enviar notificaciones en tiempo real de reembolsos y contracargos vía Webhooks
CREATE TABLE IF NOT EXISTS reembolsos (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reembolsos_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
    CONSTRAINT chk_reembolsos_estado CHECK (estado IN ('PENDIENTE', 'ACTIVO', 'INACTIVO'))
);

-- Índices de Rendimiento
CREATE INDEX IF NOT EXISTS idx_reembolsos_usuario_id ON reembolsos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_reembolsos_estado ON reembolsos(estado);
CREATE INDEX IF NOT EXISTS idx_reembolsos_codigo ON reembolsos(codigo);
