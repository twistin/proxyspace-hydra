# 🎭 Workflow para Sesión en Vivo

## 📋 CHECKLIST PRE-SHOW (15 min antes)

### 1. **Verificación de Puertos y Procesos**
```bash
# En Terminal 1 - Verificar puertos libres
lsof -i :57120  # SC server
lsof -i :57122  # OSC proxy
lsof -i :12345  # openFrameworks
lsof -i :8080   # Hydra

# Si hay procesos colgados:
pkill -9 sclang
pkill -9 node
```

### 2. **Arranque Ordenado del Sistema**

**Terminal 1 - SuperCollider**
```bash
# 1. Abrir SuperCollider IDE
# 2. Boot server: s.boot
# 3. Esperar "Server 'localhost' running"
```

**Terminal 2 - Proxy OSC**
```bash
cd ~/Desktop/proxyspace-hydra/hydra
SC_OSC_PORT=57122 npm run proxy

# Verificar:
# ✅ [OSC] Escuchando en 0.0.0.0:57122
# ✅ [HTTP] Servidor estático activo en puerto 8080
# ✅ [WS] Cliente conectado
```

**Terminal 3 - openFrameworks**
```bash
# 1. Abrir Xcode
# 2. Cmd+R para ejecutar
# 3. Verificar ventana se abre en ESCENA 1 (LANDSCAPES)
```

**Terminal 4 - Hydra (opcional)**
```bash
# Abrir navegador: http://localhost:8080
```

### 3. **Test de Comunicación OSC**

En SuperCollider:
```supercollider
// Ejecutar SETUP
(
topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57122);
"✅ OSC configurado".postln;
)

// Test rápido
topEnvironment[\hydraAddr].sendMsg("/kick");
// Debería cambiar imagen en oF
```

---

## 🎬 ESTRUCTURA DE SET (2 escenas)

### **ESCENA 1: LANDSCAPES** (15-20 min)
**Concepto**: Erosión sonora progresiva sobre paisajes

#### **Fase A: Soundscape Puro (3-5 min)**
- Solo imagen nítida
- Soundscape ambiental sin efectos visuales
- Sin mensajes OSC (excepto cambios de imagen con kicks esporádicos)

```supercollider
// Código de ejemplo - Soundscape ambient
~landscape = {
    var sig = SinOsc.ar([200, 201], mul: 0.1);
    sig = sig + LFNoise1.ar(0.5, 0.3);
    sig = FreeVerb.ar(sig, 0.8, 0.9, 0.5);
};
~landscape.play;
```

#### **Fase B: Activación de Efectos (2-3 min)**
- Primer kick activa efectos: `topEnvironment[\hydraAddr].sendMsg("/kick");`
- Introducir erosión gradual con bass
- Revelación con melodía

```supercollider
// Ejemplo - Activación progresiva
~bass_level.ar(2);
~bass_level[0] = { LFNoise1.kr(0.5).range(0, 0.6) }; // Erosión suave

~melody.ar(2);
~melody[0] = { LFNoise1.kr(0.2).range(0.5, 1.0) }; // Revelación
```

#### **Fase C: Desarrollo (5-8 min)**
- Combinar erosión + revelación + ondulación
- Kicks periódicos para cambiar imágenes

```supercollider
// Ejemplo - Desarrollo completo
~texture.ar(2);
~texture[0] = { LFNoise1.kr(0.3).range(0.3, 0.7) }; // Ondulación

// Kicks automáticos cada 8 beats
~kickPattern = Pbind(\type, \osc, \addr, topEnvironment[\hydraAddr], 
    \oscPath, "/kick", \dur, 8).play;
```

#### **Fase D: Clímax + Decay (3-5 min)**
- Máxima intensidad
- Dejar que efectos decaigan naturalmente
- Transición a ESCENA 2

```supercollider
// Clímax
~bass_level[0] = 0.8;
~melody[0] = 1.0;
~texture[0] = 0.7;

// Decay (después de 30 seg)
~bass_level[0] = { Line.kr(0.8, 0, 10) };
~texture[0] = { Line.kr(0.7, 0, 10) };
```

---

### **ESCENA 2: DUALISMOS** (15-20 min)
**Concepto**: Tipografía generativa con contrastes filosóficos

#### **Cambio de Escena**
```supercollider
// Presionar tecla "2" en oF
// O desde SC (si implementas mensaje /scene):
// topEnvironment[\hydraAddr].sendMsg("/scene", 1);
```

#### **Fase A: Introducción (2-3 min)**
- Kicks generan pares de palabras
- Tipografía simple con onda sinusoidal
- Ritmo lento

```supercollider
// Kicks lentos
Pdef(\dualKicks, 
    Pbind(\type, \osc, \addr, topEnvironment[\hydraAddr],
        \oscPath, "/kick", \dur, 6)
).play;
```

#### **Fase B: Exploración de Sets (8-10 min)**
- Cambiar entre sets con teclas 3, 4, 5
- Set 0: Platón (filosofía)
- Set 1: Musical (ritmo/melodía)
- Set 2: Textura (contraste sonoro)

```supercollider
// Ejemplo - Cambiar sets cada 2 minutos
// Tecla "3" en oF para Set Platón
// Tecla "4" para Set Musical
// Tecla "5" para Set Textura
```

#### **Fase C: Efectos Generativos (5-8 min)**
- Glitch tipográfico con `/texture`
- Rotación con `/bass_level`
- Dispersión con `/melody_note`

```supercollider
// Glitch progresivo
~texture.ar(2);
~texture[0] = { LFNoise1.kr(0.5).range(0, 0.8) };

// Rotación rítmica
~bass_level.ar(2);
~bass_level[0] = { LFSaw.kr(0.25).range(0, 1.0) };

// Dispersión melódica
~melody.ar(2);
~melody[0] = { LFNoise1.kr(0.3).range(0, 0.8) };
```

#### **Fase D: Final (2-3 min)**
- Densidad máxima de palabras
- Kicks rápidos
- Fade out gradual

```supercollider
// Kicks rápidos
Pdef(\dualKicks).set(\dur, 2);

// Fade out (último minuto)
~bass_level[0] = { Line.kr(0.7, 0, 20) };
~texture[0] = { Line.kr(0.6, 0, 20) };
```

---

## 🚨 CONTROLES DE EMERGENCIA

### **Si algo se rompe durante el show:**

#### **1. Resetear Efectos Visuales**
```supercollider
// Resetear todos los parámetros a 0
(
var addr = topEnvironment[\hydraAddr];
addr.sendMsg("/bass_level", 0.0);
addr.sendMsg("/melody_note", 0.5);
addr.sendMsg("/texture", 0.0);
"⛔ RESET VISUAL".postln;
)
```

#### **2. Detener Todo el Audio**
```supercollider
// STOP absoluto
(
Pdef.all.do(_.stop);
p.clear;
"⛔ AUDIO DETENIDO".postln;
)
```

#### **3. Cambiar Escena de Emergencia**
```
Tecla "1" en oF → LANDSCAPES
Tecla "2" en oF → DUALISMOS
```

#### **4. Reinicio Rápido del Sistema**
```bash
# Terminal 1
pkill -9 sclang
pkill -9 node

# Terminal 2
cd ~/Desktop/proxyspace-hydra/hydra
SC_OSC_PORT=57122 npm run proxy

# SuperCollider: s.boot + ejecutar setup
```

---

## 📝 NOTAS IMPORTANTES

### **Durante la Performance:**
- ✅ Tener `test_landscapes.scd` abierto para tests rápidos
- ✅ Monitor OSC visible para verificar comunicación
- ✅ Ventana de oF en pantalla secundaria o proyector
- ✅ SuperCollider en pantalla principal para live coding

### **Valores Seguros (nunca falla):**
```supercollider
// LANDSCAPES
~bass_level → 0.0 - 0.7 (evitar > 0.8)
~melody → 0.3 - 1.0
~texture → 0.0 - 0.6

// DUALISMOS
~bass_level → 0.0 - 0.8
~melody → 0.0 - 0.9
~texture → 0.0 - 0.8
```

### **Backup Plan:**
- Si oF crashea → solo usar Hydra
- Si OSC falla → tocar solo audio sin visuals
- Si todo falla → tener stems de audio pre-grabados

---

## 🎯 CHECKLIST POST-SHOW

- [ ] Detener todos los Pdefs: `Pdef.all.do(_.stop);`
- [ ] Limpiar ProxySpace: `p.clear;`
- [ ] Cerrar oF (Cmd+Q)
- [ ] Detener proxy Node.js (Ctrl+C en terminal)
- [ ] `s.quit` en SuperCollider
- [ ] Guardar cualquier código interesante

---

## 📚 ARCHIVOS CLAVE

- `scd/sound2.scd` → Setup OSC + ejemplos de audio
- `scd/test_landscapes.scd` → Tests de LANDSCAPES
- `of/src/ofApp.cpp` → Código visual (si necesitas ajustar)
- `hydra/osc_ws_proxy.js` → Proxy OSC

**¡Suerte en la sesión! 🎵🎨**
