# 🚀 Arranque del Sistema - Orden de Inicio

## 📋 Componentes Necesarios (3 en total)

### **1. Proxy OSC Node.js** 🔌
**Qué hace**: Recibe OSC desde SuperCollider (puerto 57122) y lo reenvía a openFrameworks (12345) y Hydra WebSocket (8080)

**Cómo arrancar**:
```bash
cd ~/Desktop/proxyspace-hydra/hydra
SC_OSC_PORT=57122 npm run proxy
```

**Verificar que esté corriendo**:
```
✅ [OSC] Escuchando en 0.0.0.0:57122
✅ [HTTP] Servidor estático activo en puerto 8080
✅ [WS] Cliente conectado
```

**Dejar corriendo en segundo plano** (no cerrar esta terminal)

---

### **2. openFrameworks (Visuales)** 🎨
**Qué hace**: Renderiza las dos escenas (LANDSCAPES y DUALISMOS), recibe OSC en puerto 12345

**Cómo arrancar**:
```bash
# Opción 1: Desde Xcode
# 1. Abrir: of/proxyspace-hydra.xcodeproj
# 2. Cmd+R (Run)

# Opción 2: Desde terminal (si tienes makefiles)
cd ~/Desktop/proxyspace-hydra/of
make && make run
```

**Verificar**:
- Se abre ventana con imagen (ESCENA 1: LANDSCAPES por defecto)
- No debe haber errores de compilación

**Controles de teclado**:
- `1` → LANDSCAPES
- `2` → DUALISMOS
- `3` → Set Platón (en DUALISMOS)
- `4` → Set Musical (en DUALISMOS)
- `5` → Set Textura (en DUALISMOS)

---

### **3. SuperCollider (Audio + OSC)** 🎵
**Qué hace**: Genera audio, envía mensajes OSC al proxy

**Cómo arrancar**:
```bash
# 1. Abrir SuperCollider IDE
open -a "SuperCollider"

# 2. Abrir tu sesión
# Archivo → Open → sesiones/TU_SESION.scd

# 3. Ejecutar todo el archivo (Cmd+A, Cmd+Return)
# Esto carga Setup.scd automáticamente
```

**Verificar**:
```
✅ "Setup done!" en Post window
✅ "✅ OSC configurado en 127.0.0.1:57122"
```

**Test de comunicación**:
```supercollider
// En SuperCollider, ejecutar:
topEnvironment[\hydraAddr].sendMsg("/kick");
// Debería cambiar imagen en openFrameworks
```

---

## 📊 Flujo de Datos

```
SuperCollider (Audio)
    ↓ OSC (puerto 57122)
Node.js Proxy
    ↓ OSC (puerto 12345)
openFrameworks (Visuales)

Node.js Proxy
    ↓ WebSocket (puerto 8080)
Hydra (Navegador - opcional)
```

---

## ⚡ Arranque Rápido (Script)

Voy a crear un script que arranca todo:

### **Terminal 1** - Proxy Node.js:
```bash
cd ~/Desktop/proxyspace-hydra/hydra
SC_OSC_PORT=57122 npm run proxy
```

### **Terminal 2** - openFrameworks:
```bash
open ~/Desktop/proxyspace-hydra/of/proxyspace-hydra.xcodeproj
# Luego Cmd+R en Xcode
```

### **Terminal 3** - SuperCollider:
```bash
open -a "SuperCollider"
# Abrir sesión y ejecutar
```

---

## 🔍 Verificación de Estado

### **Comprobar puertos ocupados**:
```bash
lsof -i :57122  # Proxy OSC
lsof -i :12345  # openFrameworks OSC
lsof -i :8080   # Hydra WebSocket
```

### **Matar procesos colgados**:
```bash
# Si algo está ocupando puertos:
pkill -9 node      # Mata proxy Node.js
pkill -9 sclang    # Mata SuperCollider
# oF hay que cerrarlo manualmente (Cmd+Q)
```

---

## ❓ Hydra (Navegador) - ¿Es Necesario?

**NO** es obligatorio, pero puedes usarlo para visuales web adicionales:

```bash
# Abrir navegador después de arrancar proxy:
open http://localhost:8080
```

En Hydra puedes recibir los mismos mensajes OSC vía WebSocket y crear visuales paralelos.

---

## 🎯 Orden Recomendado de Arranque

1. **Primero**: Proxy Node.js (porque es el intermediario)
2. **Segundo**: openFrameworks (para ver visuales)
3. **Tercero**: SuperCollider (para generar audio y OSC)

Si arrancas en otro orden, puede que los primeros mensajes OSC no lleguen (no es grave, solo envía otro `/kick`).

---

## 🚨 Problemas Comunes

### **"bind EADDRINUSE 0.0.0.0:57122"**
- El proxy ya está corriendo
- Solución: `pkill -9 node` y volver a arrancar

### **"OSCMonitor no recibe mensajes"**
- Verificar que proxy esté en puerto 57122
- Verificar: `topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57122);`

### **"openFrameworks no cambia imagen con /kick"**
- Verificar que proxy esté corriendo
- Test: `topEnvironment[\hydraAddr].sendMsg("/kick");`

### **"Setup.scd not found"**
- Verificar ruta relativa: `("../Setup/Setup.scd").loadRelative;`
- Debe ejecutarse desde `sesiones/` folder

---

## 📝 Checklist Pre-Show

```
[ ] Terminal 1: Proxy corriendo (puerto 57122)
[ ] Terminal 2: openFrameworks abierto (ventana visible)
[ ] Terminal 3: SuperCollider con sesión cargada
[ ] Test: topEnvironment[\hydraAddr].sendMsg("/kick") cambia imagen
[ ] Volumen: Checar que se escuche audio
```

---

## 🎵 Durante la Sesión

- **Proxy Node.js**: Déjalo corriendo, no toques esa terminal
- **openFrameworks**: Solo usa teclado para cambiar escenas (1, 2, 3, 4, 5)
- **SuperCollider**: Aquí haces todo el live coding

---

## 🛑 Apagar Todo al Finalizar

```bash
# Terminal proxy Node.js:
Ctrl+C

# openFrameworks:
Cmd+Q

# SuperCollider:
s.quit
Cmd+Q
```

---

**¡Listo para empezar! 🚀**
