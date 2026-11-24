# Caso 3 — Aplicación del cambio

Código existente intervenido según la porción del spec que ya se reemplazó y aprobó en `/sdd-propuesta`.

## Qué construir

- Modificar (o eliminar) el código existente para que cumpla la porción del spec ya reemplazada.
- **No tocar el spec.** La porción de *Comportamiento*, los *Invariantes* modificados, la *Decisión* fechada y las *Referencias* ya están escritos.
- **Si la Propuesta declaró que el comportamiento observable no cambia** (solo implementación): el spec solo tiene la *Decisión* y las *Referencias* nuevas, y *Comportamiento* está intacto. El código nuevo tiene que producir exactamente las mismas salidas que el viejo para las mismas entradas. Si al construir resulta imposible mantener la paridad, **eso es un descubrimiento** (Paso 4 del SKILL): detenerse y decirlo. No ajustar *Comportamiento* para que coincida con lo construido.

## Verificación propia (antes de pasar a `/sdd-verificacion`)

Repasar qué otras partes del sistema dependían del comportamiento/implementación anterior (identificadas en `/sdd-exploracion` y `/sdd-propuesta`, incluidas las specs relacionadas en *Referencias*) y confirmar que siguen funcionando, o que su ajuste también quedó cubierto por este mismo cambio.
