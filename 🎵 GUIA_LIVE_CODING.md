# Sistema de Escenas para Live Coding
## SuperCollider + openFrameworks

---

## 🎬 ESCENAS DISPONIBLES

### 1️⃣ LANDSCAPES (Paisajes)
Muestra imágenes de lugares que cambían con el ritmo.

**Comportamiento OSC:**
- `/kick` → Cambia a la siguiente imagen
- `/bass_level` → Controla opacidad de la imagen (0.0-1.0)
- `/melody_note` → (sin efecto en esta escena)

**Preparación:**
- Coloca tus imágenes JPG/PNG en: `of/bin/data/landscapes/`
- Las imágenes se escalan para cubrir toda la ventana

---

### 2️⃣ DUALISMOS (Dualidades de Platón)
Sistema de texto con conceptos filosóficos duales.

**Comportamiento OSC:**
- `/kick` → Crea nuevo par de dualidades aleatorio
- `/bass_level` → Cambia color de fondo (0.0-1.0)
- `/melody_note` → Cambia color de palabra aleatoria

**Dualidades disponibles:**
1. CUERPO / ALMA
2. MUNDO SENSIBLE / MUNDO INTELIGIBLE
3. APARIENCIA / ESENCIA
4. DEVENIR / SER

**Propiedades:**
- Tiempo de vida: 6 segundos
- Tamaño: 72pt, sin escala
- Colores: Rosa (255,100,150) vs Azul (100,150,255)
- Fade out en últimos ~2 segundos

---

## ⌨️ CONTROLES

### Durante Performance:
- **1** → Cambiar a LANDSCAPES
- **2** → Cambiar a DUALISMOS
- **c** → Limpiar escena actual

### Solo en DUALISMOS:
- **ESPACIO** → Trigger manual de todas las palabras
- **n** → Crear nueva dualidad manualmente

---

## 🎵 DESDE SUPERCOLLIDER

### Enviar mensajes OSC:
```supercollider
// Ya configurado en sound2.scd:
n = NetAddr("127.0.0.1", 57122);

// Mensajes disponibles:
n.sendMsg("/kick");                    // Trigger escena
n.sendMsg("/bass_level", 0.0-1.0);     // Nivel de bajo
n.sendMsg("/melody_note", 0.0-1.0);    // Nota de melodía
```

### Cambiar escena desde SC:
```supercollider
// Opción 1: Cambiar con código específico en SC
OSCdef(\cambiarEscena, {
    // Tu lógica para decidir qué escena
}, '/escena');

// Opción 2: Presionar teclas 1 o 2 en oF durante el set
```

---

## 🔄 FLUJO DE DATOS

```
SuperCollider (puerto 57122)
    ↓
Node.js Proxy (osc_ws_proxy.js)
    ↓ ↓
    ↓ └──→ WebSocket (8080) → Hydra (navegador)
    └──────→ OSC (12345) → openFrameworks (escenas)
```

---

## 🚀 INICIO RÁPIDO

1. **Iniciar Node.js proxy:**
   ```bash
   cd /Users/sdcarr/Desktop/proxyspace-hydra/hydra
   SC_OSC_PORT=57122 node osc_ws_proxy.js
   ```

2. **Compilar y ejecutar oF:**
   - Abrir Xcode
   - Cmd+B (compilar)
   - Cmd+R (ejecutar)
   - Aparece ventana fullscreen con escena LANDSCAPES

3. **Iniciar SuperCollider:**
   - Abrir `scd/sound2.scd`
   - Ejecutar configuración
   - `~k.play` para empezar el kick

4. **Durante el set:**
   - Presiona `1` o `2` en oF para cambiar escenas
   - Improvisa en SuperCollider
   - Los visuales reaccionan automáticamente

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
proxyspace-hydra/
├── hydra/                          # Proyecto Node.js + Hydra
│   ├── osc_ws_proxy.js            # Proxy OSC → WebSocket + oF
│   └── hydra_client.html          # Visuales Hydra
├── of/                            # Proyecto openFrameworks
│   ├── src/
│   │   ├── ofApp.h/cpp            # Aplicación principal + escenas
│   │   └── WordInstance.h/cpp     # Clase de palabras
│   └── bin/data/landscapes/       # 🖼️ TUS IMÁGENES AQUÍ
└── scd/
    └── sound2.scd                 # SuperCollider + OSC
```

---

## 🎨 TIPS PARA LIVE CODING

### Preparación:
- [ ] Coloca 5-10 imágenes en `landscapes/`
- [ ] Prueba ambas escenas antes del set
- [ ] Verifica que el proxy OSC esté corriendo
- [ ] Ten `sound2.scd` listo en SuperCollider

### Durante el set:
- Empieza con **LANDSCAPES** para impacto visual inmediato
- Cambia a **DUALISMOS** en secciones más conceptuales
- Usa `/kick` como timing principal
- Modula `/bass_level` para dinámicas sutiles
- `/melody_note` añade variación de color en DUALISMOS

### Combinaciones sugeridas:
1. **Intro**: LANDSCAPES con kicks lentos
2. **Build-up**: DUALISMOS con palabras acumulándose
3. **Drop**: LANDSCAPES con cambios rápidos de imagen
4. **Breakdown**: DUALISMOS con pocas palabras, colores sutiles

---

## 🐛 TROUBLESHOOTING

**No veo imágenes en LANDSCAPES:**
- Verifica que haya archivos en `of/bin/data/landscapes/`
- Formatos válidos: JPG, JPEG, PNG
- Revisa la consola de oF para errores de carga

**Las palabras no aparecen en DUALISMOS:**
- Verifica que `/kick` llegue desde SuperCollider
- Presiona `n` manualmente para probar
- Revisa logs de OSC en la consola

**El proxy no recibe mensajes:**
- Verifica puerto 57122 en SuperCollider: `NetAddr("127.0.0.1", 57122)`
- Reinicia el proxy si es necesario

---

¡Listo para tu live coding! 🎉
