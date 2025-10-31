# 🔤 Tipografía Generativa - DUALISMOS

## Efectos Implementados

La escena DUALISMOS ahora incluye **4 modos de tipografía generativa** que se activan aleatoriamente con cada `/kick`:

### 1️⃣ **Texto Normal con Onda Sinusoidal**
- Movimiento sutil de onda vertical
- Mantiene legibilidad
- Efecto orgánico y fluido

### 2️⃣ **Glitch Tipográfico**
- Letras individuales desplazadas aleatoriamente
- Cambios de color RGB en algunos caracteres
- Intensidad controlable (0.3 - 0.8)
- Evoca corrupción digital y error

### 3️⃣ **Dispersión de Letras**
- Las letras "explotan" hacia afuera desde el centro
- Patrón radial/circular
- Rango: 50-150 píxeles
- Efecto de desintegración

### 4️⃣ **Texto Vertical**
- Caracteres apilados verticalmente
- Estética oriental/alternativa
- Espaciado entre letras controlable

---

## 🎛️ Control OSC

### `/kick` - Efectos Aleatorios
Cada kick genera un **nuevo par de palabras** y aplica efectos generativos aleatorios:
- 30% probabilidad → Glitch tipográfico
- 30% probabilidad → Dispersión
- 20% probabilidad → Texto vertical
- 20% probabilidad → Normal con onda

Además:
- Rotación aleatoria: `-15°` a `+15°`
- Espaciado de letras: `-5px` a `+10px`

### `/bass_level` (0.0 - 1.0) - Rotación Continua
Controla la rotación de **todas las palabras** simultáneamente:
- `0.0` → `-30°`
- `0.5` → `0°`
- `1.0` → `+30°`

### `/melody_note` (0.0 - 1.0) - Dispersión Continua
Controla la cantidad de dispersión radial:
- `0.0` → Sin dispersión
- `1.0` → Dispersión máxima (100px)

También cambia el color de una palabra aleatoria según el espectro HSB.

### `/texture` (0.0 - 1.0) - Glitch Tipográfico
Controla la intensidad del glitch en todas las palabras:
- `0.0` → Sin glitch
- `1.0` → Glitch máximo (0.8)
- Desplazamientos, colores alterados, caos visual

---

## 🎨 Propiedades de WordInstance

Cada palabra tiene ahora:

```cpp
float rotation;        // Rotación en grados
float letterSpacing;   // Espaciado entre letras (px)
float waveOffset;      // Offset para onda sinusoidal
float glitchAmount;    // Intensidad de glitch (0-1)
bool useVerticalText;  // Activar modo vertical
float disperseAmount;  // Dispersión radial (0-150px)
```

---

## 🎭 Ejemplos de Uso en SuperCollider

```supercollider
// Activar glitch tipográfico intenso
n.sendMsg("/texture", 0.8);

// Rotación suave con bass
n.sendMsg("/bass_level", 0.7);

// Dispersión media con melodía
n.sendMsg("/melody_note", 0.5);

// Generar nuevo par con efecto aleatorio
n.sendMsg("/kick");

// Combinar todo (caos controlado)
(
~texture.ar(2, 0.5); // 50% de glitch
~bass_level.ar(2, 0.6); // Rotación 18°
~melody.ar(2, 0.8); // Dispersión 80px
)
```

---

## 🔧 Filosofía de Diseño

1. **Variedad** - Cada kick produce un efecto diferente
2. **Legibilidad parcial** - Algunos modos mantienen lectura, otros la destruyen
3. **Control continuo** - OSC modula intensidad en tiempo real
4. **Caos organizado** - Aleatoriedades dentro de rangos estéticos

---

## 🚀 Próximos Pasos

**Recompila en Xcode** y prueba:

1. Lanza kicks para ver efectos aleatorios
2. Modula `/texture` para glitch progresivo
3. Usa `/bass_level` para rotaciones rítmicas
4. Combina `/melody_note` con dispersión gradual

**¡Tipografía viva y reactiva!** 🎨✨
