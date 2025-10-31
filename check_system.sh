#!/bin/bash

# =================================================================
# SCRIPT DE DIAGNÓSTICO RÁPIDO - ProxySpace Hydra
# =================================================================

echo ""
echo "🔍 DIAGNÓSTICO DEL SISTEMA"
echo "========================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# === 1. Verificar Node.js ===
echo -e "${BLUE}[1/5]${NC} Verificando Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "  ${GREEN}✓${NC} Node.js instalado: ${NODE_VERSION}"
else
    echo -e "  ${RED}✗${NC} Node.js NO encontrado"
fi
echo ""

# === 2. Verificar procesos Node (Proxy) ===
echo -e "${BLUE}[2/5]${NC} Verificando proxy OSC→WebSocket..."
PROXY_PID=$(lsof -ti:8080 2>/dev/null)
if [ ! -z "$PROXY_PID" ]; then
    echo -e "  ${GREEN}✓${NC} Proxy corriendo en puerto 8080 (PID: ${PROXY_PID})"
    PROXY_CMD=$(ps -p $PROXY_PID -o command= 2>/dev/null)
    echo -e "     Comando: ${PROXY_CMD}"
else
    echo -e "  ${RED}✗${NC} Proxy NO está corriendo en puerto 8080"
    echo -e "     ${YELLOW}→${NC} Ejecuta: cd hydra && node osc_ws_proxy.js"
fi
echo ""

# === 3. Verificar puerto OSC (57121) ===
echo -e "${BLUE}[3/5]${NC} Verificando puerto OSC (57121)..."
OSC_PID=$(lsof -ti:57121 2>/dev/null)
if [ ! -z "$OSC_PID" ]; then
    echo -e "  ${GREEN}✓${NC} Puerto 57121 en uso (PID: ${OSC_PID})"
    OSC_CMD=$(ps -p $OSC_PID -o command= 2>/dev/null)
    echo -e "     Comando: ${OSC_CMD}"
else
    echo -e "  ${YELLOW}⚠${NC} Puerto 57121 libre (esperando conexión de SC)"
fi
echo ""

# === 4. Verificar servidor HTTP (8000) ===
echo -e "${BLUE}[4/5]${NC} Verificando servidor HTTP (puerto 8000)..."
HTTP_PID=$(lsof -ti:8000 2>/dev/null)
if [ ! -z "$HTTP_PID" ]; then
    echo -e "  ${GREEN}✓${NC} Servidor HTTP corriendo en puerto 8000"
    HTTP_CMD=$(ps -p $HTTP_PID -o command= 2>/dev/null)
    echo -e "     Comando: ${HTTP_CMD}"
else
    echo -e "  ${RED}✗${NC} Servidor HTTP NO está corriendo"
    echo -e "     ${YELLOW}→${NC} Ejecuta: python3 -m http.server 8000"
fi
echo ""

# === 5. Verificar SuperCollider ===
echo -e "${BLUE}[5/5]${NC} Verificando SuperCollider..."
if command -v sclang &> /dev/null; then
    SC_VERSION=$(sclang -v 2>&1 | head -n 1)
    echo -e "  ${GREEN}✓${NC} SuperCollider instalado"
    echo -e "     ${SC_VERSION}"
    
    # Buscar procesos de sclang
    SC_RUNNING=$(pgrep -fl sclang | grep -v grep)
    if [ ! -z "$SC_RUNNING" ]; then
        echo -e "  ${GREEN}✓${NC} Procesos sclang detectados:"
        echo "$SC_RUNNING" | while read line; do
            echo -e "     ${line}"
        done
    else
        echo -e "  ${YELLOW}⚠${NC} No se detectaron procesos sclang corriendo"
    fi
else
    echo -e "  ${RED}✗${NC} SuperCollider NO encontrado en PATH"
fi
echo ""

# === RESUMEN ===
echo "========================================"
echo -e "${BLUE}RESUMEN${NC}"
echo "========================================"
echo ""

ISSUES=0

# Proxy OSC
if [ -z "$PROXY_PID" ]; then
    echo -e "${RED}✗${NC} Proxy OSC NO está corriendo"
    echo -e "   Solución: ${YELLOW}cd hydra && node osc_ws_proxy.js${NC}"
    ISSUES=$((ISSUES + 1))
else
    echo -e "${GREEN}✓${NC} Proxy OSC funcionando"
fi

# Servidor HTTP
if [ -z "$HTTP_PID" ]; then
    echo -e "${RED}✗${NC} Servidor HTTP NO está corriendo"
    echo -e "   Solución: ${YELLOW}python3 -m http.server 8000${NC}"
    ISSUES=$((ISSUES + 1))
else
    echo -e "${GREEN}✓${NC} Servidor HTTP funcionando"
fi

# SuperCollider
if ! command -v sclang &> /dev/null; then
    echo -e "${RED}✗${NC} SuperCollider no instalado"
    ISSUES=$((ISSUES + 1))
else
    echo -e "${GREEN}✓${NC} SuperCollider instalado"
fi

echo ""

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ Sistema configurado correctamente${NC}"
    echo ""
    echo "📋 PRÓXIMOS PASOS:"
    echo "   1. Abre SuperCollider y ejecuta: scd/sound2.scd"
    echo "   2. En SuperCollider ejecuta: ~a1.resume"
    echo "   3. Abre: http://localhost:8000/templates/hydra/layer_mixer_template.html"
    echo "   4. Verifica que los valores OSC cambien (verde = OK, naranja = congelado)"
else
    echo -e "${RED}⚠ Encontrados ${ISSUES} problema(s)${NC}"
    echo ""
    echo "Consulta DIAGNOSTICO.md para más ayuda"
fi

echo ""
