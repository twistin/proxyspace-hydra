#!/bin/bash

# Script para descargar imágenes de ejemplo para LANDSCAPES
# Usa placeholders de picsum.photos (servicio de imágenes aleatorias)

LANDSCAPE_DIR="/Users/sdcarr/Desktop/proxyspace-hydra/of/bin/data/landscapes"

echo "📸 Descargando imágenes de ejemplo para LANDSCAPES..."
echo ""

# Crear directorio si no existe
mkdir -p "$LANDSCAPE_DIR"

# Descargar 5 imágenes de paisajes (1920x1080)
# Puedes reemplazar estos URLs con tus propias imágenes

cd "$LANDSCAPE_DIR"

echo "1/5 - Descargando landscape_01.jpg..."
curl -L "https://picsum.photos/1920/1080?random=1" -o landscape_01.jpg

echo "2/5 - Descargando landscape_02.jpg..."
curl -L "https://picsum.photos/1920/1080?random=2" -o landscape_02.jpg

echo "3/5 - Descargando landscape_03.jpg..."
curl -L "https://picsum.photos/1920/1080?random=3" -o landscape_03.jpg

echo "4/5 - Descargando landscape_04.jpg..."
curl -L "https://picsum.photos/1920/1080?random=4" -o landscape_04.jpg

echo "5/5 - Descargando landscape_05.jpg..."
curl -L "https://picsum.photos/1920/1080?random=5" -o landscape_05.jpg

echo ""
echo "✅ Descarga completa!"
echo "📁 Imágenes guardadas en: $LANDSCAPE_DIR"
echo ""
echo "Tip: Puedes reemplazar estas imágenes con tus propios paisajes/lugares"
echo "     Solo arrastra tus imágenes JPG/PNG a la carpeta landscapes/"
# ...existing code...
