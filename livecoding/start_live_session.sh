#!/usr/bin/env bash
# Arranca proxy OSC, abre openFrameworks y la plantilla SuperCollider

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🎵 ProxySpace Hydra · Inicio de sesión"
echo "====================================="

# 1. Proxy OSC
PROXY_SCRIPT="${ROOT}/../start_proxy.sh"

if lsof -ti:8080 >/dev/null 2>&1; then
  echo "🛰  Proxy OSC ya está corriendo en el puerto 8080"
else
  echo "🚀 Iniciando proxy OSC..."
  if [ -x "${PROXY_SCRIPT}" ]; then
    "${PROXY_SCRIPT}"
  else
    echo "⚠️  start_proxy.sh no encontrado en ${PROXY_SCRIPT}"
  fi
fi

# 2. Visuales openFrameworks
OF_APP="${ROOT}/of/bin/ofDebug.app"
OF_PROJECT="${ROOT}/of/of.xcodeproj"
if [ -d "${OF_APP}" ]; then
  echo "🎨 Abriendo visuales (ofDebug.app)"
  open "${OF_APP}"
elif [ -d "${OF_PROJECT}" ]; then
  echo "⚠️  bin/ofDebug.app no encontrado, abriendo proyecto en Xcode"
  open "${OF_PROJECT}"
else
  echo "⚠️  No se encontró openFrameworks compilado ni el proyecto Xcode"
fi

# 3. Plantilla SuperCollider
SC_FILE="${ROOT}/sesiones/sound2.scd"
if [ -f "${SC_FILE}" ]; then
  if command -v open >/dev/null 2>&1; then
    echo "🎼 Abriendo plantilla SuperCollider (sound2.scd)"
    open -a "SuperCollider" "${SC_FILE}" || echo "⚠️  No se pudo abrir SuperCollider automáticamente."
  else
    echo "⚠️  Ejecuta SuperCollider y abre ${SC_FILE}"
  fi
else
  echo "⚠️  Plantilla SuperCollider no encontrada en ${SC_FILE}"
fi

echo
echo "👉 En SuperCollider, evalúa todo el archivo y ejecuta: SoundSessionStartAll.();"
