# 🎵 Guía Paso a Paso: Sistema de Sinestesia Audiovisual

Esta guía te llevará desde cero hasta tener todo el sistema funcionando: SuperCollider → Node.js → Hydra + openFrameworks

---

## 📋 Prerequisitos

Antes de empezar, asegúrate de tener instalado:

- ✅ **Node.js** (v14 o superior)
- ✅ **SuperCollider** con ProxySpace
- ✅ **openFrameworks** (0.11.0 o superior)
- ✅ Addon **ofxOsc** (viene incluido con oF)
- ✅ Un navegador web moderno (Chrome, Firefox)

---

## 🚀 PASO 1: Configurar el Proxy Node.js

### 1.1 Instalar dependencias

Abre una terminal en la carpeta del proyecto y ejecuta:

```bash
cd /Users/sdcarr/Desktop/proxyspace-hydra/hydra
npm install
```

Esto instalará las dependencias del `package.json`, incluyendo:

- `osc` - Para comunicación OSC
- `ws` - Para WebSockets con Hydra

### 1.2 Verificar instalación

Revisa que las librerías se instalaron correctamente:

```bash
npm list osc ws
```

Deberías ver algo como:

```
├── osc@2.4.x
└── ws@8.x.x
```

### 1.3 Iniciar el proxy

```bash
node osc_ws_proxy.js
```

Deberías ver mensajes como:

```
HTTP server listening on port 8080
OSC server listening on port 57120
WebSocket server ready
OSC client to openFrameworks configured (127.0.0.1:12345)
```

**✅ CHECKPOINT 1**: El proxy está corriendo y esperando conexiones.

---

## 🎨 PASO 2: Abrir Hydra en el navegador

### 2.1 Abrir monitor OSC

Con el proxy corriendo, abre tu navegador y ve a:

```
http://localhost:8080/templates/hydra/osc_monitor.html
```

Este es un monitor visual que te muestra en tiempo real:

- Estado de conexión WebSocket
- Mensajes OSC que llegan desde SuperCollider
- Contadores de `/kick`, `/bass_level`, `/melody_note`
- Log completo de todos los mensajes

### 2.2 Verificar conexión WebSocket

En la consola del navegador (F12 → Console) deberías ver:

```
WebSocket connected to ws://localhost:8080
```

### 2.3 Probar visuales básicos

En el editor de Hydra (en la página web), prueba este código:

```javascript
// Visual básico pulsante
osc(10, 0.1, 1)
  .color(1, 0.5, 0.8)
  .out()
```

**✅ CHECKPOINT 2**: Hydra está conectado y mostrando visuales.

---

## 🖼️ PASO 3: Compilar y ejecutar openFrameworks

### 3.1 Crear proyecto en openFrameworks

Si aún no tienes un proyecto oF creado:

1. Abre el **projectGenerator** de openFrameworks
2. Crea un nuevo proyecto llamado `sinestesia` o similar
3. Añade el addon: **ofxOsc**
4. Genera el proyecto

### 3.2 Copiar los archivos de código

Copia estos archivos a la carpeta `src/` de tu proyecto oF:

```bash
# Desde la carpeta del proyecto oF
cp /Users/sdcarr/Desktop/proxyspace-hydra/of/WordInstance.h src/
cp /Users/sdcarr/Desktop/proxyspace-hydra/of/WordInstance.cpp src/
cp /Users/sdcarr/Desktop/proxyspace-hydra/of/ofApp.h src/
cp /Users/sdcarr/Desktop/proxyspace-hydra/of/ofApp.cpp src/
```

### 3.3 Compilar el proyecto

#### En Xcode (macOS):

1. Abre el archivo `.xcodeproj` del proyecto
2. Selecciona el target y presiona **Cmd+B** para compilar
3. Si compila sin errores, presiona **Cmd+R** para ejecutar

#### En Visual Studio (Windows):

1. Abre el archivo `.sln`
2. Presiona **F7** para compilar
3. Presiona **F5** para ejecutar

#### Con Makefile (Linux/macOS):

```bash
cd tu-proyecto-oF
make
make run
```

### 3.4 Verificar que oF está escuchando

Deberías ver una ventana negra con texto en la esquina superior:

```
FPS: 60.0
Palabras activas: 0
Dualidades disponibles: 4
```

Y en la consola/terminal:

```
[notice ] ofApp: OSC receptor iniciado en puerto 12345
[notice ] ofApp: Escena de Platón inicializada con 4 dualidades
```

**✅ CHECKPOINT 3**: openFrameworks está escuchando en puerto 12345.

---

## 🎼 PASO 4: Conectar SuperCollider

### 4.1 Iniciar SuperCollider

Abre SuperCollider y ejecuta este código de prueba:

```supercollider
// Configurar conexión al proxy Node.js
n = NetAddr("127.0.0.1", 57120);

// Probar envío básico
n.sendMsg("/test", "hola");

// Debería aparecer en la consola del proxy Node.js
```

### 4.2 Probar mensaje /kick

```supercollider
// Enviar un kick
n.sendMsg("/kick");

// Esto debería:
// 1. Crear un par de palabras en openFrameworks
// 2. Hacer trigger de las palabras existentes
// 3. Actualizar el visual de Hydra (si tienes el código conectado)
```

**✅ CHECKPOINT 4**: SuperCollider puede enviar mensajes al sistema.

---

## 🧪 PASO 5: Pruebas de Integración

### 5.1 Probar todos los mensajes OSC

Ejecuta este código en SuperCollider:

```supercollider
(
// Configurar conexión
n = NetAddr("127.0.0.1", 57120);

// Rutina de prueba
fork {
    // Test 1: Kick (crear dualidad)
    "Enviando /kick...".postln;
    n.sendMsg("/kick");
    2.wait;

    // Test 2: Bass level (cambiar fondo)
    "Enviando /bass_level...".postln;
    5.do { |i|
        n.sendMsg("/bass_level", i / 4);
        0.5.wait;
    };
    2.wait;

    // Test 3: Melody note (cambiar colores)
    "Enviando /melody_note...".postln;
    10.do {
        n.sendMsg("/melody_note", rrand(0.0, 1.0));
        0.3.wait;
    };

    "Tests completados!".postln;
};
)
```

Deberías ver:

- **openFrameworks**: Palabras apareciendo, fondo cambiando, colores mutando
- **Consola del proxy**: Mensajes OSC siendo reenviados
- **Hydra**: Visuales reaccionando (si has conectado los datos OSC)

### 5.2 Verificar el flujo completo

En 3 terminales/ventanas diferentes deberías ver:

**Terminal 1 (Proxy Node.js):**

```
OSC message from SuperCollider: /kick []
Forwarding to openFrameworks: /kick []
Broadcasting to 1 WebSocket clients
```

**Terminal 2 (SuperCollider post window):**

```
Enviando /kick...
Enviando /bass_level...
Enviando /melody_note...
```

**Ventana oF:**

- Palabras "CUERPO" y "ALMA" aparecen
- Fondo cambia de negro a tonos oscuros
- Colores de palabras mutan según las notas

**✅ CHECKPOINT 5**: Todo el sistema está integrado y funcionando.

---

## 🎹 PASO 6: Crear una Performance Básica

### 6.1 Código de ejemplo en SuperCollider

```supercollider
(
// Configuración
n = NetAddr("127.0.0.1", 57120);
s.boot;

// ProxySpace para audio
p = ProxySpace.push(s);

// Kick drum cada 2 segundos
~kick = {
    var sig = SinOsc.ar(60) * EnvGen.kr(Env.perc(0.01, 0.3), Impulse.kr(0.5));
    // Enviar mensaje OSC cuando hay kick
    SendReply.kr(Impulse.kr(0.5), '/kick', 0);
    sig ! 2;
};

// Bass continuo con nivel variable
~bass = {
    var freq = LFNoise1.kr(0.1).range(40, 80);
    var sig = SinOsc.ar(freq) * 0.3;
    var level = Amplitude.kr(sig).poll(4, label: "bass");
    // Enviar nivel de bajo
    SendReply.kr(Impulse.kr(8), '/bass_level', level);
    sig ! 2;
};

// Melodía aleatoria
~melody = {
    var notes = [60, 62, 64, 67, 69].midicps;
    var freq = TChoose.kr(Impulse.kr(4), notes);
    var sig = SinOsc.ar(freq) * EnvGen.kr(Env.perc(0.01, 0.2), Impulse.kr(4)) * 0.2;
    // Enviar nota de melodía
    SendReply.kr(Impulse.kr(4), '/melody_note', freq.cpsmidi);
    sig ! 2;
};

// OSCFunc para reenviar los mensajes
OSCFunc({ |msg|
    n.sendMsg(msg[0], msg[3]); // Reenviar al proxy
}, '/kick');

OSCFunc({ |msg|
    n.sendMsg('/bass_level', msg[3].linlin(0, 0.3, 0, 1)); // Normalizar
}, '/bass_level');

OSCFunc({ |msg|
    n.sendMsg('/melody_note', msg[3]);
}, '/melody_note');

// Tocar todo
~kick.play;
~bass.play;
~melody.play;

"Sistema de sinestesia iniciado!".postln;
)

// Para detener:
// p.clear;
```

### 6.2 Controles manuales (teclado en oF)

Mientras el sistema corre, puedes usar estas teclas en la ventana de openFrameworks:

- **ESPACIO**: Trigger manual de todas las palabras
- **1-4**: Activar dualidades específicas de Platón
- **n**: Crear palabra aleatoria "PALABRA"
- **c**: Limpiar todas las palabras
- **b**: Cambiar color de fondo aleatorio
- **Click del mouse**: Crear palabra "CLICK" donde hagas click

**✅ CHECKPOINT 6**: Tienes una performance audiovisual completa.

---

## 🐛 Solución de Problemas

### Problema: "Cannot find module 'osc'"

**Solución:**

```bash
cd hydra
npm install osc ws
```

### Problema: openFrameworks no recibe mensajes

**Diagnóstico:**

```bash
# En otra terminal, escucha el puerto 12345
nc -ul 12345

# Luego envía un mensaje desde SuperCollider
n.sendMsg("/test");

# Deberías ver el mensaje en nc
```

**Solución:**

- Verifica que oF esté escuchando en puerto 12345
- Verifica que el proxy esté reenviando (mira la consola del proxy)
- Revisa el firewall de macOS

### Problema: Hydra no muestra nada

**Solución:**

- Abre la consola del navegador (F12)
- Verifica que el WebSocket esté conectado
- Recarga la página (Cmd+R / F5)

### Problema: "Address already in use"

**Causa:** Ya hay algo corriendo en puerto 57120 o 8080

**Solución:**

```bash
# Encontrar proceso en puerto 57120
lsof -i :57120

# Matar proceso
kill -9 [PID]

# O cambiar el puerto en osc_ws_proxy.js
```

### Problema: Palabras no aparecen en oF

**Diagnóstico:**

- Revisa la consola de oF, debería decir: `[notice] ofApp: Nuevo par spawneado: CUERPO / ALMA`
- Si no aparece, el mensaje OSC no está llegando

**Solución:**

- Verifica que SuperCollider esté enviando a puerto 57120
- Verifica que el proxy esté reenviando a puerto 12345
- Usa `ofLogNotice()` para debug

---

## 📊 Arquitectura del Sistema

```
┌─────────────────┐
│  SuperCollider  │ Audio + OSC out (→ 127.0.0.1:57120)
└────────┬────────┘
         │ OSC messages (/kick, /bass_level, /melody_note)
         ↓
┌────────────────────────────────┐
│   Node.js Proxy (osc_ws_proxy) │
│   • Recibe OSC en :57120       │
│   • Sirve HTTP en :8080        │
│   • WebSocket server           │
│   • Reenvía OSC a :12345       │
└─────┬──────────────────┬───────┘
      │                  │
      │ WebSocket        │ OSC forwarding
      ↓                  ↓
┌─────────────┐    ┌──────────────────┐
│   Hydra     │    │  openFrameworks  │
│  (Browser)  │    │   • ofxOsc :12345│
│  Visuales   │    │   • WordInstance │
└─────────────┘    │   • Dualidades   │
                   └──────────────────┘
```

---

## 🎯 Resumen del Flujo

1. **SuperCollider** genera audio y envía mensajes OSC → `127.0.0.1:57120`
2. **Node.js proxy** recibe OSC y hace dos cosas:
   - Envía por **WebSocket** → Hydra (navegador)
   - Reenvía por **OSC** → openFrameworks (`127.0.0.1:12345`)
3. **Hydra** recibe datos por WebSocket y los usa para generar visuales reactivos
4. **openFrameworks** recibe OSC y:
   - `/kick` → crea nuevo par de dualidades + trigger
   - `/bass_level` → cambia color de fondo
   - `/melody_note` → cambia color de palabras aleatorias

---

## 🎨 Próximos Pasos

Una vez que todo funcione, puedes:

1. **Personalizar las dualidades** en `ofApp.cpp` (líneas 24-27)
2. **Ajustar colores y tamaños** en la función `spawnNewPair()`
3. **Crear nuevos mensajes OSC** para más interacciones
4. **Añadir efectos visuales** en Hydra sincronizados con el audio
5. **Grabar la performance** con OBS o similar

---

## 📚 Recursos Adicionales

- **openFrameworks**: https://openframeworks.cc/documentation/
- **ofxOsc**: https://openframeworks.cc/documentation/ofxOsc/
- **Hydra**: https://hydra.ojack.xyz/
- **SuperCollider**: https://doc.sccode.org/

---

## ✅ Checklist Final

Antes de tu presentación, verifica:

- [ ] Node.js proxy corriendo sin errores
- [ ] Hydra abierto en navegador y conectado
- [ ] openFrameworks compilado y ejecutándose
- [ ] SuperCollider enviando mensajes correctamente
- [ ] Las 4 dualidades aparecen cuando envías `/kick`
- [ ] El fondo cambia con `/bass_level`
- [ ] Los colores mutan con `/melody_note`
- [ ] Sin errores en ninguna consola

---

¡Disfruta tu sistema de sinestesia audiovisual! 🎵🌈✨
