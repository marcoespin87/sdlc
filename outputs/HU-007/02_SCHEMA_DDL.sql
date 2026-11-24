-- DDL Estructural para [HU-007] - Automatizar la conciliación bancaria de transacciones
CREATE TABLE IF NOT EXISTS contabilidads (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_contabilidads_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
    CONSTRAINT chk_contabilidads_estado CHECK (estado IN ('PENDIENTE', 'ACTIVO', 'INACTIVO'))
);

-- Índices de Rendimiento
CREATE INDEX IF NOT EXISTS idx_contabilidads_usuario_id ON contabilidads(usuario_id);
CREATE INDEX IF NOT EXISTS idx_contabilidads_estado ON contabilidads(estado);
CREATE INDEX IF NOT EXISTS idx_contabilidads_codigo ON contabilidads(codigo);
