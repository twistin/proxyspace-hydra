# 🎨 LANDSCAPES - Efectos Mejorados

## ✨ Nuevos efectos visuales:

### 1. **Chromatic Aberration** (Aberración Cromática)
- Separa canales RGB con desplazamiento
- Se activa con **kicks** (5-15 pixels)
- Controlado por **/texture** (0-20 pixels)
- Da aspecto de glitch analógico

### 2. **RGB Split Glitch** (Bloques desplazados)
- Corta la imagen en bloques horizontales
- Los desplaza aleatoriamente
- Intensidad: 5-15 bloques según `glitchAmount`
- Perfecto para momentos intensos

### 3. **Scanlines** (Líneas de escaneo)
- Líneas horizontales estilo CRT
- Intensidad controlada por **/bass_level** (0.2-0.6)
- Da atmósfera retro/cyberpunk

### 4. **Pixelación Dinámica**
- Efecto de pixeles grandes
- Controlado por **/melody_note** (0-8 pixels)
- Estética lo-fi/8-bit

### 5. **Feedback Loop** (Rastro de imagen)
- La imagen anterior persiste levemente
- Crea efecto de "fantasma" o "eco visual"
- Fade del 96% (deja 4% de rastro)

### 6. **Tinte de Color**
- Capa multiplicativa de color
- TODO el espectro (0-255 hue)
- Controlado por **/melody_note**
- Opacidad 200/255

### 7. **Zoom Reactivo**
- Zoom 1.0x - 1.2x según **/bass_level**
- Transición suave (3% por frame)
- Da sensación de "respiración"

### 8. **Brillo Variable**
- 60%-100% según **/bass_level**
- Crea dinámicas de luz

---

## 🎛️ Mapeo OSC actualizado:

### `/kick`
- Cambia imagen
- **Glitch fuerte** (0.5-0.8)
- **Chromatic shift** (5-15px)

### `/bass_level` (0.0-1.0)
- **Zoom**: 1.0 → 1.2x
- **Brillo**: 60% → 100%
- **Scanlines**: 0.2 → 0.6

### `/melody_note` (0.0-1.0)
- **Tinte de color**: 0-255 hue (TODO el espectro)
- **Pixelación**: 0-8 pixels

### `/texture` (0.0-1.0)
- **Glitch continuo**: 0.0 → 1.0
- **Chromatic shift**: 0 → 20px

---

## 🎨 Comportamiento visual:

### Estado base (sin audio):
- Imagen limpia con feedback sutil
- Scanlines leves (0.3)
- Sin glitch ni desplazamiento

### Con kicks:
- Imagen cambia
- Explosión de glitch RGB
- Desplazamiento cromático fuerte
- Se desvanece gradualmente (92%/frame)

### Con bass alto:
- Zoom aumenta (sensación de acercamiento)
- Brillo sube (más luz)
- Scanlines más visibles (retro intenso)

### Con melodía variante:
- Colores cambian constantemente
- Pixelación aparece/desaparece
- Estética lo-fi dinámica

### Con texture alta:
- Glitch constante
- RGB split permanente
- Imagen "rota" controlada

---

## 🔥 Comparación ANTES vs AHORA:

### ANTES:
- ❌ Cambio simple de imagen
- ❌ Glitch básico (3 copias offset)
- ❌ Tinte limitado a azules
- ❌ Texto ilegible
- ❌ Poco reactivo

### AHORA:
- ✅ 8 efectos visuales diferentes
- ✅ Glitch RGB split + chromatic aberration
- ✅ Tinte con TODO el espectro de colores
- ✅ Texto con fondo oscuro legible
- ✅ Altamente reactivo a todos los parámetros
- ✅ Feedback loop para continuidad visual
- ✅ Scanlines para atmósfera retro
- ✅ Pixelación para estética lo-fi

---

## 🎯 Tips de uso:

### Intro ambient suave:
```supercollider
n.sendMsg("/bass_level", 0.3);   // Poco zoom, scanlines suaves
n.sendMsg("/melody_note", 0.5);  // Color medio (cianes/verdes)
n.sendMsg("/texture", 0.0);      // Sin glitch
// Kicks cada 4-6 segundos
```

### Build-up con tensión:
```supercollider
n.sendMsg("/texture", 0.5);      // Glitch creciendo
n.sendMsg("/bass_level", 0.7);   // Zoom aumentando
n.sendMsg("/melody_note", rrand(0.0, 1.0)); // Colores aleatorios
// Kicks cada 2 segundos
```

### Drop intenso:
```supercollider
n.sendMsg("/kick");              // Kicks rápidos
n.sendMsg("/texture", 0.9);      // Glitch máximo
n.sendMsg("/bass_level", 1.0);   // Zoom y scanlines full
n.sendMsg("/melody_note", rrand(0.0, 1.0)); // Color caótico
// Kicks cada 0.5 segundos
```

### Breakdown glitch:
```supercollider
n.sendMsg("/texture", 0.8);      // Glitch alto
n.sendMsg("/melody_note", rrand(0.7, 1.0)); // Pixelación alta
// Sin kicks, solo texture
```

---

## 📊 Parámetros internos (para ajustar):

En `ofApp.cpp`:

```cpp
// Línea ~110: Intensidad de glitch en kick
targetGlitchAmount = 0.5f + ofRandom(0.3f); // 0.5-0.8

// Línea ~111: Chromatic shift en kick  
chromaShift = ofRandom(5.0f, 15.0f);        // 5-15px

// Línea ~205: Decay de glitch
targetGlitchAmount *= 0.92f;                // 92% (más rápido)

// Línea ~206: Decay de chroma
chromaShift *= 0.9f;                        // 90%

// Línea ~316: Scanlines espaciado
for (int i = 0; i < ofGetHeight(); i += 4) // Cada 4 pixels
```

---

¡Ahora LANDSCAPES es mucho más expresivo y visual! 🎨✨
