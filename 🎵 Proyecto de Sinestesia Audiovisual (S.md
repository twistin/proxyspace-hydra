# 🎵 Proyecto de Sinestesia Audiovisual
## SuperCollider ↔ openFrameworks ↔ Hydra

Este proyecto establece un sistema de live coding audiovisual en tiempo real que conecta un sintetizador de audio (SuperCollider) con visualizaciones tanto en openFrameworks (aplicación nativa) como en Hydra (navegador web), utilizando el protocolo OSC (Open Sound Control) y un proxy Node.js como puente de comunicación.

---

## 💡 Concepto Principal

El proyecto permite crear performances audiovisuales donde:
- **SuperCollider** genera audio y envía datos de control vía OSC
- **Node.js Proxy** actúa como puente bidireccional entre los componentes
- **openFrameworks** muestra dos escenas interactivas: LANDSCAPES (imágenes) y DUALISMOS (texto filosófico)
- **Hydra** (opcional) proporciona visualizaciones GLSL generativas en el navegador

---

## 🛠️ Componentes de la Arquitectura

El flujo de datos atraviesa los siguientes componentes:

| Componente | Archivo | Función | Puerto |
|------------|---------|---------|--------|
| **Generador de Audio** | `scd/sound2.scd` | ProxySpace con audio reactivo y envío OSC | → 57122 |
| **Proxy (Puente)** | `osc-proxy/osc_ws_proxy.js` | Recibe OSC y reenvía a WebSocket + openFrameworks | 57122 (OSC in)<br>8080 (WS out)<br>12345 (OSC out) |
| **Visuales Nativos** | `of/src/ofApp.cpp` | Sistema de escenas con imágenes y texto | 12345 (OSC in) |
| **Visuales Web** | `hydra/hydra_client*.html` | Síntesis visual GLSL en navegador | 8080 (WS in) |

### Diagrama de Flujo:
```
SuperCollider (57122)
    ↓ OSC
Node.js Proxy
    ↓ ↓
    ↓ └──→ WebSocket (8080) → Hydra (navegador)
    └──────→ OSC (12345) → openFrameworks (app)
```

---

## 🎬 Escenas de openFrameworks

### 1️⃣ LANDSCAPES (Paisajes)
Muestra imágenes de lugares que reaccionan al audio.

**Comportamiento OSC:**
- `/kick` → Cambia a la siguiente imagen del set
- `/bass_level` (0.0-1.0) → Controla opacidad de la imagen
- `/melody_note` → Sin efecto en esta escena

**Preparación:**
- Coloca imágenes JPG/PNG en: `of/bin/data/landscapes/`
- Las imágenes se escalan automáticamente para cubrir la ventana

### 2️⃣ DUALISMOS (Dualidades de Platón)
Sistema de texto con conceptos filosóficos duales.

**Comportamiento OSC:**
- `/kick` → Crea nuevo par de dualidades aleatorio
- `/bass_level` (0.0-1.0) → Modula color de fondo
- `/melody_note` (0.0-1.0) → Cambia color de palabra aleatoria

**Dualidades disponibles:**
1. CUERPO / ALMA
2. MUNDO SENSIBLE / MUNDO INTELIGIBLE
3. APARIENCIA / ESENCIA
4. DEVENIR / SER

**Propiedades de palabras:**
- Fuente: 72pt, sin escala dinámica
- Tiempo de vida: 6 segundos
- Fade out: últimos ~2 segundos
- Colores: Rosa (255,100,150) vs Azul (100,150,255)

---

## 🚀 Guía de Configuración y Ejecución

Sigue este orden para establecer la conexión correctamente:

### Paso 1: Iniciar el Proxy de Node.js

Abre una terminal y ejecuta:

```bash
cd /Users/sdcarr/Desktop/proxyspace-hydra/hydra
SC_OSC_PORT=57122 node osc_ws_proxy.js
```

**Salida esperada:**
```
[OSC] Escuchando en 0.0.0.0:57122
[WS] Servidor WebSocket activo en puerto 8080
[OSC->oF] Cliente OSC listo 127.0.0.1:12345
```

### Paso 2: Iniciar openFrameworks

1. Abre el proyecto en Xcode
2. Compila: **Cmd+B**
3. Ejecuta: **Cmd+R**
4. Verás la ventana con la escena LANDSCAPES (por defecto)

**Controles de teclado:**
- **1** → Cambiar a escena LANDSCAPES
- **2** → Cambiar a escena DUALISMOS
- **c** → Limpiar escena actual
- **n** → (DUALISMOS) Crear nueva dualidad
- **ESPACIO** → (DUALISMOS) Trigger palabras

### Paso 3: Iniciar SuperCollider

1. Abre `scd/sound2.scd` en SuperCollider
2. Ejecuta el boot del servidor (si no está iniciado)
3. Configura el NetAddr (línea 10):
   ```supercollider
   n = NetAddr("127.0.0.1", 57122);
   ```
4. Ejecuta tu código de audio
5. Los mensajes OSC se enviarán automáticamente

**Mensajes OSC enviados:**
- `/kick` - Detecta kicks del bombo
- `/bass_level` - Nivel de frecuencias bajas (0.0-1.0)
- `/melody_note` - Notas de melodía normalizadas (0.0-1.0)

### Paso 4 (Opcional): Abrir Hydra

Abre `hydra/hydra_client.html` en tu navegador para visualizaciones GLSL adicionales.

---

## ⚙️ Configuración de Mensajes OSC

### Desde SuperCollider:

```supercollider
// Configurar destino
n = NetAddr("127.0.0.1", 57122);

// Enviar mensajes manualmente
n.sendMsg("/kick");                    // Trigger visual
n.sendMsg("/bass_level", 0.5);         // Nivel medio
n.sendMsg("/melody_note", 0.75);       // Nota alta

// Detección automática (ya implementada en sound2.scd)
OSCdef(\sendKick, { |msg|
    if(msg[2] == 1, {  // ID del kick
        n.sendMsg("/kick");
    });
}, '/trigger');
```

### En openFrameworks:

Los mensajes se procesan automáticamente en `ofApp::update()`:
- LANDSCAPES: `/kick` cambia imagen, `/bass_level` controla alpha
- DUALISMOS: `/kick` crea palabras, `/bass_level` modula fondo, `/melody_note` cambia colores

---

## 📁 Estructura del Proyecto

```
proxyspace-hydra/
├── 🎵 GUIA_LIVE_CODING.md          # Manual completo para performances
├── 🎵 Proyecto de Sinestesia...md   # Este archivo (README)
│
├── hydra/                           # Proxy Node.js + Hydra
│   ├── osc_ws_proxy.js             # Proxy OSC ↔ WebSocket + oF
│   ├── hydra_client.html           # Cliente visual Hydra básico
│   ├── hydra_client2.html          # Variante 2
│   ├── hydra_client3.html          # Variante 3
│   └── package.json                # Dependencias Node
│
├── of/                              # Proyecto openFrameworks
│   ├── src/
│   │   ├── ofApp.h                 # Header con enum Scene
│   │   ├── ofApp.cpp               # Lógica de escenas y OSC
│   │   ├── WordInstance.h          # Clase de palabras
│   │   └── WordInstance.cpp        # Implementación de palabras
│   ├── bin/data/
│   │   └── landscapes/             # 🖼️ Coloca tus imágenes aquí
│   │       └── README.md           # Instrucciones de uso
│   └── download_sample_images.sh   # Script para imágenes de prueba
│
└── scd/
    ├── sound.scd                    # ProxySpace básico
    ├── sound1.scd                   # Versión intermedia
    └── sound2.scd                   # ⭐ Versión actual con OSC
```

---

## 🎨 Tips para Live Coding

### Preparación:
- [ ] Coloca 5-10 imágenes en `of/bin/data/landscapes/`
- [ ] Prueba ambas escenas antes del set
- [ ] Verifica que el proxy OSC esté corriendo
- [ ] Ten `sound2.scd` cargado en SuperCollider
- [ ] Opcional: Abre `hydra_client.html` en una segunda pantalla

### Durante la Performance:
1. **Intro**: Inicia con LANDSCAPES y kicks lentos
2. **Build-up**: Cambia a DUALISMOS, acumula palabras
3. **Drop**: Regresa a LANDSCAPES con cambios rápidos
4. **Breakdown**: DUALISMOS con pocas palabras, colores sutiles
5. Usa **1** y **2** para cambiar entre escenas según la energía

### Modulación Recomendada:
- `/kick`: Timing principal del set
- `/bass_level`: Dinámicas sutiles de intensidad
- `/melody_note`: Variación de color (solo DUALISMOS)

---

## 🐛 Troubleshooting

### El proxy no recibe mensajes de SC:
- Verifica el puerto en SuperCollider: `NetAddr("127.0.0.1", 57122)`
- Asegúrate de que el proxy esté corriendo en 57122
- Revisa si otro proceso ocupa el puerto: `lsof -i :57122`

### No veo imágenes en LANDSCAPES:
- Coloca archivos JPG/PNG en `of/bin/data/landscapes/`
- Ejecuta `./of/download_sample_images.sh` para imágenes de prueba
- Revisa la consola de oF para errores de carga

### Las palabras no aparecen en DUALISMOS:
- Verifica que lleguen mensajes `/kick` (mira consola de oF)
- Presiona `n` manualmente para probar
- Asegúrate de estar en la escena 2 (presiona `2`)

### openFrameworks no compila:
- Verifica que `ofxOsc` esté en tu carpeta `addons/`
- Asegúrate de que `WordInstance.h` y `.cpp` estén en Xcode
- Limpia el build: Product → Clean Build Folder (Shift+Cmd+K)

---

## 📚 Recursos Adicionales

- **openFrameworks**: https://openframeworks.cc/
- **Hydra**: https://hydra.ojack.xyz/
- **SuperCollider**: https://supercollider.github.io/
- **OSC Protocol**: http://opensoundcontrol.org/

---

## 🎉 ¡Listo para el Live Coding!

El sistema está preparado para performances audiovisuales en tiempo real. Experimenta con las escenas, improvisa en SuperCollider, y deja que los visuales reaccionen a tu música.

**Versión**: 2.0 (Sistema de escenas)  
**Última actualización**: Octubre 2025
