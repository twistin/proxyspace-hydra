# 🎭 Guía de Escenas para Live Coding
## Sistema reactivo personalizado

---

## 🎨 ESCENA 1: LANDSCAPES (Ambient/Glitch)

### Estética:
- **Mood**: Calma, luz, texturas sutiles
- **Audio**: Ambient, algo de ritmo, glitches ocasionales
- **Visual**: Imágenes con zoom sutil, tintes de color, efectos de glitch

### Controles OSC:

| Mensaje | Parámetro | Efecto Visual |
|---------|-----------|---------------|
| `/kick` | - | Cambia a siguiente imagen + glitch momentáneo |
| `/bass_level` | 0.0-1.0 | Zoom sutil (1.0-1.15x) + brillo (0.7-1.0) |
| `/melody_note` | 0.0-1.0 | Tinte de color azul/cian sobre imagen |
| `/texture` | 0.0-1.0 | Cantidad de glitch continuo (0-80%) |

### Comportamiento:
- Transiciones **muy suaves** (ambient)
- Glitch se **desvanece automáticamente** después de kicks
- Zoom responde al bass **lentamente**
- Tinte de color crea **atmósfera lumínica**

### Tips de improvisación:
```supercollider
// Kicks espaciados (cada 2-4 segundos)
// Bass bajo (0.2-0.5) para calma
// Texture ocasional (0.3-0.6) para interés
// Melody variando color ambiente
```

---

## 🔥 ESCENA 2: DUALISMOS (Rítmico/Dinámico)

### Estética:
- **Mood**: Contraste, dualidad, energía
- **Audio**: Rítmico, texturas enfrentadas, melodías/ritmos duales
- **Visual**: Palabras contrastantes, colores dinámicos, tamaños reactivos

### Controles OSC:

| Mensaje | Parámetro | Efecto Visual |
|---------|-----------|---------------|
| `/kick` | - | Crea nuevo par de dualidades |
| `/bass_level` | 0.0-1.0 | Brillo fondo (0-80) + tamaño palabras (0.8-1.3x) |
| `/melody_note` | 0.0-1.0 | Cambia color de palabra aleatoria (todo el espectro) |
| `/contrast` | 0.0-1.0 | Velocidad de rotación (futuro) |

### Sets de Dualidades:

Presiona en openFrameworks para cambiar:

| Tecla | Set | Palabras |
|-------|-----|----------|
| **3** | Platón | CUERPO/ALMA, MUNDO SENSIBLE/INTELIGIBLE, APARIENCIA/ESENCIA, DEVENIR/SER |
| **4** | Musical | RITMO/MELODÍA, GRAVE/AGUDO, TENSO/RELAJADO, STACCATO/LEGATO |
| **5** | Textura | DENSO/DISPERSO, ÁSPERO/SUAVE, OSCURO/BRILLANTE, CAOS/ORDEN |

### Comportamiento:
- Kicks crean **parejas de palabras** enfrentadas
- Palabras duran **6 segundos**, fade en últimos 2s
- Tamaño varía con **bass dinámicamente**
- Colores cambian con **melodía constantemente**

### Tips de improvisación:
```supercollider
// Kicks frecuentes (cada 0.5-1 segundo)
// Bass alto (0.6-1.0) para intensidad
// Melody variando mucho (0.0-1.0) para colores
// Cambiar sets (3,4,5) según sección
```

---

## 🎹 Mensajes OSC Disponibles

### Ya implementados en `sound2.scd`:
- ✅ `/kick` - Detección automática de kicks
- ✅ `/bass_level` - Nivel continuo de bajos (8x/seg)
- ✅ `/melody_note` - Nivel de agudos (4x/seg)

### Nuevos (opcional):
- 🆕 `/texture` - Para control de glitch en LANDSCAPES
- 🆕 `/contrast` - Para efectos futuros en DUALISMOS

---

## 🚀 Flujo de Trabajo

### Setup inicial:
1. **Terminal**: Inicia proxy (`SC_OSC_PORT=57122 node osc_ws_proxy.js`)
2. **Xcode**: Compila y ejecuta oF (Cmd+B, Cmd+R)
3. **SuperCollider**: Carga `sound2.scd`, ejecuta setup
4. **oF**: Presiona `1` (LANDSCAPES) o `2` (DUALISMOS)

### Durante la sesión:

#### Tema 1 - LANDSCAPES (Intro/Ambient):
1. Presiona `1` en oF
2. Audio: Drones, texturas suaves, kicks espaciados
3. Visuales: Imágenes cambian lentamente, zoom sutil, glitches ocasionales
4. **Duración sugerida**: 3-5 minutos

#### Transición:
- Presiona `2` en oF durante una pausa o build-up
- Audio: Introduce ritmo más marcado

#### Tema 2 - DUALISMOS (Desarrollo/Clímax):
1. Ya en escena 2
2. Presiona `3`, `4` o `5` para elegir set de palabras
3. Audio: Rítmico, contrastes, dos texturas enfrentadas
4. Visuales: Palabras aparecen con kicks, colores cambian, tamaño dinámico
5. **Duración sugerida**: 5-8 minutos

---

## 🎛️ Parámetros Ajustables

### En SuperCollider (`sound2.scd`):

```supercollider
// Sensibilidad del kick detector (línea ~99)
kickDetect = Trig.kr(ampRMS > 0.1, 0.5); // Umbral: 0.05-0.3

// Tiempo de vida de palabras (ofApp.cpp, línea ~437)
360.0f  // 6 segundos a 60fps (180-600 = 3-10 segundos)
```

### En openFrameworks (teclas):

| Tecla | Función |
|-------|---------|
| **1** | Cambiar a LANDSCAPES |
| **2** | Cambiar a DUALISMOS |
| **3** | Set Platón (filosofía) |
| **4** | Set Musical |
| **5** | Set Textura |
| **c** | Limpiar palabras (DUALISMOS) |
| **n** | Crear dualidad manual (DUALISMOS) |
| **ESPACIO** | Trigger palabras (DUALISMOS) |

---

## 💡 Ideas de Improvisación

### LANDSCAPES:
```supercollider
// Glitch burst
(
fork {
    5.do {
        n.sendMsg("/texture", 0.7);
        n.sendMsg("/kick");
        0.1.wait;
    };
    n.sendMsg("/texture", 0.0);
};
)

// Respiración lenta (zoom)
(
fork {
    var phase = 0;
    loop {
        var breath = sin(phase) * 0.5 + 0.5;
        n.sendMsg("/bass_level", breath);
        phase = phase + 0.1;
        0.1.wait;
    };
};
)
```

### DUALISMOS:
```supercollider
// Explosión de palabras
(
fork {
    8.do {
        n.sendMsg("/kick");
        0.25.wait;
    };
};
)

// Contraste de tamaños
(
fork {
    loop {
        n.sendMsg("/bass_level", [0.2, 0.9].choose);
        1.wait;
    };
};
)
```

---

## 🐛 Solución de Problemas

**No veo glitch en LANDSCAPES:**
- Envía `/texture` con valores > 0.3
- O aumenta `glitchAmount` en el código

**Palabras muy pequeñas/grandes:**
- Ajusta `wordSizeMultiplier` rango en ofApp.cpp línea ~125
- Actualmente: 0.8-1.3x

**Kicks no se detectan:**
- Baja el umbral en sound2.scd línea ~99 (de 0.1 a 0.05)
- Sube volumen de ~k: `~k.vol = 0.5;`

**Cambios muy bruscos:**
- LANDSCAPES usa suavizado lento (0.03-0.05)
- DUALISMOS es más reactivo por diseño

---

## 📂 Archivos Modificados

- ✅ `of/src/ofApp.h` - Variables de escenas
- ✅ `of/src/ofApp.cpp` - Lógica completa de escenas
- ✅ `scd/sound2.scd` - OSC automático (kick más sensible)
- 🆕 `scd/osc_controls.scd` - Ejemplos de control manual

---

¡Listo para tu live coding! 🎉🎵

**Recuerda:**
- LANDSCAPES = Calma, luz, texturas sutiles
- DUALISMOS = Energía, contraste, dualidad rítmica
- Cambia entre escenas con 1/2 según la energía del set
