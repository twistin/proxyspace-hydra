#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# 🎵 Crear Nueva Sesión - ProxySpace Hydra
# ═══════════════════════════════════════════════════════════════

echo "════════════════════════════════════════════════════════"
echo "  🎵 Crear Nueva Sesión - ProxySpace Hydra"
echo "════════════════════════════════════════════════════════"
echo ""

# Obtener fecha actual en formato YYYY-MM-DD
FECHA=$(date +%Y-%m-%d)

# Pedir nombre de la sesión
echo "📝 Ingresa un nombre para la sesión (sin espacios):"
echo "   Ejemplo: landscapes_experimento"
read -p "Nombre: " NOMBRE

# Validar que no esté vacío
if [ -z "$NOMBRE" ]; then
    echo "❌ Error: Debes ingresar un nombre"
    exit 1
fi

# Crear nombre completo del archivo
ARCHIVO="${FECHA}_${NOMBRE}.scd"
RUTA="sesiones/${ARCHIVO}"

# Verificar si ya existe
if [ -f "$RUTA" ]; then
    echo "⚠️  El archivo $ARCHIVO ya existe."
    read -p "¿Sobrescribir? (s/n): " RESPUESTA
    if [ "$RESPUESTA" != "s" ]; then
        echo "❌ Cancelado"
        exit 1
    fi
fi

# Copiar plantilla
echo ""
echo "📋 Copiando plantilla..."
cp templates/session_template.scd "$RUTA"

# Reemplazar fecha en el archivo
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/\[RELLENAR\]/${FECHA}/1" "$RUTA"
else
    # Linux
    sed -i "s/\[RELLENAR\]/${FECHA}/1" "$RUTA"
fi

echo "✅ Sesión creada: $RUTA"
echo ""
echo "════════════════════════════════════════════════════════"
echo "  🚀 Siguiente paso:"
echo "════════════════════════════════════════════════════════"
echo ""
echo "1. Abre SuperCollider IDE"
echo "2. Abre el archivo: $RUTA"
echo "3. Ejecuta todo el archivo (Cmd+A, Cmd+Return)"
echo ""
echo "¡Buena sesión! 🎶"
echo ""
