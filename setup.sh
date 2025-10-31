#!/usr/bin/env bash
# Setup script for proxyspace-hydra
# Verifica requisitos, instala dependencias y valida puertos

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}🎵 ProxySpace Hydra - Setup${NC}\n"

# 1. Verificar Node.js
echo -e "${CYAN}[1/5] Verificando Node.js...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js no encontrado${NC}"
    echo "Instala Node.js 18+ desde: https://nodejs.org"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${YELLOW}⚠ Node.js $NODE_VERSION detectado (se recomienda 18+)${NC}"
else
    echo -e "${GREEN}✓ Node.js $(node -v)${NC}"
fi

# 2. Verificar SuperCollider (opcional)
echo -e "\n${CYAN}[2/5] Verificando SuperCollider...${NC}"
if command -v sclang &> /dev/null; then
    echo -e "${GREEN}✓ SuperCollider encontrado: $(sclang -version 2>&1 | head -n1 || echo 'versión desconocida')${NC}"
else
    echo -e "${YELLOW}⚠ SuperCollider no encontrado en PATH (opcional para desarrollo)${NC}"
fi

# 3. Instalar dependencias Node
echo -e "\n${CYAN}[3/5] Instalando dependencias...${NC}"
cd hydra
if [ -f "package-lock.json" ]; then
    npm ci --silent
else
    npm install --silent
fi
echo -e "${GREEN}✓ Dependencias instaladas (osc, ws)${NC}"
cd ..

# 4. Verificar puertos disponibles
echo -e "\n${CYAN}[4/5] Verificando puertos...${NC}"
OSC_PORT=57121
WS_PORT=8080
HTTP_PORT=8000

check_port() {
    local port=$1
    local name=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}⚠ Puerto $port ($name) en uso${NC}"
        echo "  Libéralo con: kill \$(lsof -ti:$port)"
        return 1
    else
        echo -e "${GREEN}✓ Puerto $port ($name) disponible${NC}"
        return 0
    fi
}

PORTS_OK=true
check_port $OSC_PORT "OSC" || PORTS_OK=false
check_port $WS_PORT "WebSocket" || PORTS_OK=false
check_port $HTTP_PORT "HTTP Server" || PORTS_OK=false

if [ "$PORTS_OK" = false ]; then
    echo -e "\n${YELLOW}Algunos puertos están ocupados. Puedes:${NC}"
    echo "  1. Liberar los puertos manualmente"
    echo "  2. Configurar puertos alternativos (ver README)"
    read -p "¿Continuar de todos modos? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 5. Crear script de inicio rápido
echo -e "\n${CYAN}[5/5] Creando scripts de inicio...${NC}"

# Script para arrancar todo
cat > start.sh << 'EOF'
#!/usr/bin/env bash
# Inicia proxy + servidor HTTP en terminales separadas

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}🎵 Iniciando ProxySpace Hydra${NC}\n"

# Detectar sistema operativo
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - usar Terminal.app
    osascript <<APPLESCRIPT
tell application "Terminal"
    do script "cd $(pwd)/hydra && npm run proxy"
    delay 2
    do script "cd $(pwd) && python3 -m http.server 8000"
end tell
APPLESCRIPT
    echo -e "${GREEN}✓ Proxy y servidor HTTP lanzados en ventanas Terminal separadas${NC}"
    echo -e "\n${CYAN}Abre en el navegador:${NC}"
    echo "  http://localhost:8000/templates/hydra/base_template.html"
    echo "  http://localhost:8000/templates/hydra/layer_mixer_template.html"
else
    # Linux/otros - lanzar en background
    echo -e "${GREEN}Iniciando proxy OSC...${NC}"
    (cd hydra && npm run proxy) &
    PROXY_PID=$!
    
    echo -e "${GREEN}Iniciando servidor HTTP...${NC}"
    python3 -m http.server 8000 &
    HTTP_PID=$!
    
    echo -e "\n${GREEN}✓ Servicios iniciados${NC}"
    echo "  Proxy OSC PID: $PROXY_PID"
    echo "  HTTP Server PID: $HTTP_PID"
    echo -e "\n${CYAN}Abre en el navegador:${NC}"
    echo "  http://localhost:8000/templates/hydra/base_template.html"
    echo "  http://localhost:8000/templates/hydra/layer_mixer_template.html"
    echo -e "\n${CYAN}Para detener:${NC} kill $PROXY_PID $HTTP_PID"
    
    # Guardar PIDs para limpieza
    echo "$PROXY_PID $HTTP_PID" > .pids
fi
EOF

chmod +x start.sh

# Script para detener servicios
cat > stop.sh << 'EOF'
#!/usr/bin/env bash
# Detiene proxy y servidor HTTP

if [ -f .pids ]; then
    read PROXY_PID HTTP_PID < .pids
    echo "Deteniendo servicios..."
    kill $PROXY_PID $HTTP_PID 2>/dev/null || true
    rm .pids
    echo "✓ Servicios detenidos"
else
    echo "⚠ No hay servicios corriendo (archivo .pids no encontrado)"
    echo "Puedes detener manualmente con: pkill -f 'npm run proxy'"
fi
EOF

chmod +x stop.sh

echo -e "${GREEN}✓ Scripts creados: start.sh, stop.sh${NC}"

# 6. Resumen
echo -e "\n${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Setup completado${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}\n"

echo -e "${CYAN}Siguiente paso:${NC}"
echo "  ./start.sh               # Inicia proxy + servidor HTTP"
echo ""
echo -e "${CYAN}O manualmente:${NC}"
echo "  cd hydra && npm run proxy    # Terminal 1"
echo "  python3 -m http.server 8000  # Terminal 2"
echo "  # Abre SuperCollider y ejecuta scd/sound2.scd"
echo ""
echo -e "${CYAN}URLs para el navegador:${NC}"
echo "  http://localhost:8000/templates/hydra/base_template.html"
echo "  http://localhost:8000/templates/hydra/layer_mixer_template.html"
echo ""
echo -e "${CYAN}Documentación:${NC}"
echo "  README.md"
echo "  docs/live-coding-playbook.md"
