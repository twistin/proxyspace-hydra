#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# 🚀 Script de Arranque del Proxy OSC
# ═══════════════════════════════════════════════════════════════

# Cargar nvm si existe
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Añadir rutas comunes de npm al PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Ir a la carpeta hydra
cd "$(dirname "$0")/hydra"

# Matar proxy anterior si existe
pkill -f 'node.*osc_ws_proxy' 2>/dev/null

# Arrancar proxy con puerto correcto
echo "🚀 Arrancando proxy OSC en puerto 57122..."
SC_OSC_PORT=57122 npm run proxy > /tmp/hydra_proxy.log 2>&1 &

echo "✅ Proxy arrancado (PID: $!)"
echo "📋 Ver logs: tail -f /tmp/hydra_proxy.log"
