# 🧪 Guía de Pruebas - Proxyspace Hydra

## ✅ Checklist de Prueba Completa

### 1. Verificar Instalación de Dependencias

```bash
cd /Users/sdcarr/Desktop/proxyspace-hydra/hydra
npm install
```

**Resultado esperado:**
- ✅ Dependencias instaladas sin errores
- ✅ `node_modules/` creado
- ✅ `nodemon`, `jest`, `osc`, `ws` presentes

---

### 2. Ejecutar Tests Unitarios

```bash
cd /Users/sdcarr/Desktop/proxyspace-hydra/hydra
npm test
```

**Resultado esperado:**
- ✅ Todos los tests pasan (verde)
- ✅ Coverage report muestra porcentajes
- ✅ `test/osc-client.test.js` y `test/proxy.test.js` ejecutados

**Si fallan tests:** Revisar errores específicos, pueden ser falsos positivos por el mock de WebSocket.

---

### 3. Iniciar el Proxy OSC↔WebSocket

**Opción A - Con logs de debug (recomendado para primera prueba):**
```bash
cd /Users/sdcarr/Desktop/proxyspace-hydra/hydra
DEBUG=true npm run dev
```

**Opción B - Modo silencioso (producción):**
```bash
cd /Users/sdcarr/Desktop/proxyspace-hydra/hydra
npm start
```

**Resultado esperado:**
```
[HH:MM:SS.mmm] [WS] Servidor WebSocket activo en puerto 8080
[HH:MM:SS.mmm] [OSC] Escuchando en 0.0.0.0:57121
[HH:MM:SS.mmm] [OSC] Modo DEBUG activado - todos los mensajes serán logueados
```

**⚠️ Si ves `EADDRINUSE`:**
```bash
# Liberar puertos ocupados
lsof -ti:8080 | xargs kill -9
lsof -ti:57121 | xargs kill -9
```

---

### 4. Iniciar SuperCollider

Abre SuperCollider y ejecuta **`sound2.scd`** paso a paso:

#### 4.1 Configurar ProxySpace y NetAddr
```supercollider
// Ejecutar TODO el bloque de configuración inicial
p = ProxySpace.push(s.boot);
p.makeTempoClock;
p.clock = TempoClock.default;

// CRÍTICO: Configurar la dirección OSC de Hydra
topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57121);
```

**Resultado esperado:**
- ✅ SuperCollider inicia servidor de audio
- ✅ ProxySpace configurado
- ✅ `topEnvironment[\hydraAddr]` definido

#### 4.2 Definir el Patrón de Envío OSC
```supercollider
// Ejecutar el Tdef ~osc_ctrl
Tdef(\osc_ctrl, {
  loop {
    var rhythm = (~rhythm.kr(1) ? 0).clip(0, 1);
    var bass = (~bass.kr(1) ? 0).clip(0, 1);
    var high = (~high.kr(1) ? 0).clip(0, 1);

    topEnvironment[\hydraAddr].sendMsg("/sc/rhythm", rhythm);
    topEnvironment[\hydraAddr].sendMsg("/sc/bass", bass);
    topEnvironment[\hydraAddr].sendMsg("/sc/high", high);

    0.05.wait;
  }
});
```

**Resultado esperado:**
- ✅ Tdef definido sin errores

#### 4.3 Definir los Proxies de Análisis de Audio
```supercollider
// Ejecutar los proxies ~rhythm, ~bass, ~high
~rhythm = { 
  var sig = SoundIn.ar(0);
  var amp = Amplitude.kr(sig, 0.05, 0.1);
  amp.clip(0, 1);
};

~bass = {
  var sig = SoundIn.ar(0);
  var filtered = LPF.ar(sig, 200);
  var amp = Amplitude.kr(filtered, 0.1, 0.2);
  amp.clip(0, 1);
};

~high = {
  var sig = SoundIn.ar(0);
  var filtered = HPF.ar(sig, 3000);
  var amp = Amplitude.kr(filtered, 0.05, 0.15);
  amp.clip(0, 1);
};
```

**Resultado esperado:**
- ✅ Proxies definidos (`~rhythm`, `~bass`, `~high`)

#### 4.4 Crear el Synth de Audio (Patrón ~a1)
```supercollider
// Ejecutar el Pbind de ~a1
~a1 = Pbind(
  \instrument, \default,
  \degree, Pseq([0, 2, 4, 5, 7], inf),
  \dur, 0.25,
  \amp, 0.3
);
```

**Resultado esperado:**
- ✅ Patrón musical definido

#### 4.5 **INICIAR TODO** (CRÍTICO)
```supercollider
// 🚨 ESTE ES EL PASO MÁS IMPORTANTE 🚨
~osc_ctrl.play;  // Inicia el envío OSC
~a1.resume;      // Inicia el patrón musical (Tdef empieza pausado!)
```

**Resultado esperado en la terminal del proxy (si `DEBUG=true`):**
```
[HH:MM:SS.mmm] [OSC] /sc/rhythm -> args=[0.1234] value=0.1234
[HH:MM:SS.mmm] [OSC] /sc/bass -> args=[0.0567] value=0.0567
[HH:MM:SS.mmm] [OSC] /sc/high -> args=[0.0891] value=0.0891
```

**⚠️ Si NO ves mensajes OSC:**
- Verifica `topEnvironment[\hydraAddr]` → debe devolver `NetAddr(127.0.0.1, 57121)`
- Asegúrate de haber ejecutado `~osc_ctrl.play`
- **CRÍTICO:** Ejecuta `~a1.resume` (el Tdef inicia pausado)
- Verifica que SuperCollider esté recibiendo audio (prueba con `{ SoundIn.ar(0) }.play`)

---

### 5. Abrir Hydra en el Navegador

#### 5.1 Iniciar Servidor HTTP
```bash
# En una NUEVA terminal (deja el proxy corriendo en la anterior)
cd /Users/sdcarr/Desktop/proxyspace-hydra
python3 -m http.server 8000
```

**Resultado esperado:**
```
Serving HTTP on :: port 8000 (http://[::]:8000/) ...
```

#### 5.2 Abrir el Template en el Navegador
1. Abre Chrome/Firefox/Safari
2. Navega a: **http://localhost:8000/templates/hydra/layer_mixer_template.html**

**Resultado esperado en el HUD (parte superior izquierda):**
```
Hydra · Layer Mixer
Estado: Conectado ← Debe estar en verde
Ritmo: 0.XXXX   ← Debe cambiar continuamente
Bajo:  0.XXXX   ← Debe cambiar continuamente
Agudo: 0.XXXX   ← Debe cambiar continuamente
Escena: 0 · Aurora Boreal
```

**En la consola del navegador (F12):**
```
[OSC] rhythm = 0.1234
[OSC] bass = 0.0567
[OSC] high = 0.0891
```

**⚠️ Si dice "Conectado" pero valores están en 0.1000:**
- SuperCollider NO está enviando OSC
- Revisa paso 4.5 (ejecutar `~osc_ctrl.play` y `~a1.resume`)

**⚠️ Si dice "Desconectado" o "Error":**
- El proxy no está corriendo en puerto 8080
- Revisa paso 3

---

### 6. Pruebas Interactivas

#### 6.1 Verificar Reactividad Visual
**Con audio reproduciéndose en SuperCollider:**
- ✅ Las visuales deben **moverse/cambiar** según el ritmo
- ✅ Los números en el HUD deben **actualizarse continuamente**
- ✅ El log inferior debe mostrar mensajes OSC llegando

#### 6.2 Cambiar Escenas
**Método 1 - Botones en el navegador:**
- Clic en botones superiores derechos: `0 · Aurora Boreal`, `1 · Glitch Stream`, `2 · Texturas Lentas`
- ✅ Visual debe cambiar inmediatamente
- ✅ Botón activo debe tener borde dorado

**Método 2 - OSC desde SuperCollider:**
```supercollider
// Enviar cambio de escena manualmente
topEnvironment[\hydraAddr].sendMsg("/sc/scene", 1); // Glitch Stream
topEnvironment[\hydraAddr].sendMsg("/sc/scene", 2); // Texturas Lentas
topEnvironment[\hydraAddr].sendMsg("/sc/scene", 0); // Aurora Boreal
```

#### 6.3 Controlar Parámetros de Escenas
```supercollider
// Controles específicos de Aurora Boreal
topEnvironment[\hydraAddr].sendMsg("/sc/aurora/pulse", 0.8);
topEnvironment[\hydraAddr].sendMsg("/sc/aurora/warp", 0.5);
topEnvironment[\hydraAddr].sendMsg("/sc/aurora/spark", 0.9);
topEnvironment[\hydraAddr].sendMsg("/sc/aurora/contrast", 0.4);

// Controles de Glitch Stream
topEnvironment[\hydraAddr].sendMsg("/sc/glitch/feedback", 0.7);
topEnvironment[\hydraAddr].sendMsg("/sc/glitch/pixelate", 0.6);

// Controles de Texturas Lentas
topEnvironment[\hydraAddr].sendMsg("/sc/textura/grain", 0.5);
topEnvironment[\hydraAddr].sendMsg("/sc/textura/bloom", 0.8);
```

**Resultado esperado:**
- ✅ Las visuales cambian inmediatamente al enviar mensajes
- ✅ Los valores se suavizan (smoothing) progresivamente

---

### 7. Test de Estrés / Estabilidad

#### 7.1 Envío Rápido de Mensajes
```supercollider
// Enviar muchos mensajes rápidamente
(
100.do {
  topEnvironment[\hydraAddr].sendMsg("/sc/rhythm", 1.0.rand);
  topEnvironment[\hydraAddr].sendMsg("/sc/bass", 1.0.rand);
  topEnvironment[\hydraAddr].sendMsg("/sc/high", 1.0.rand);
  0.01.wait;
}
)
```

**Resultado esperado:**
- ✅ El proxy no crashea
- ✅ El navegador sigue respondiendo
- ✅ Los valores se actualizan suavemente (smoothing funciona)

#### 7.2 Reconexión WebSocket
1. En la terminal del proxy, presiona `Ctrl+C` para detenerlo
2. Espera 5 segundos
3. Reinicia el proxy: `npm run dev`

**Resultado esperado:**
- ✅ El navegador detecta desconexión (Estado: "Desconectado")
- ✅ Al reiniciar el proxy, reconecta automáticamente (Estado: "Conectado")
- ✅ Los valores vuelven a fluir

---

### 8. Performance / Optimización

#### 8.1 Monitor de FPS (en consola del navegador)
```javascript
let frameCount = 0;
let lastTime = performance.now();
setInterval(() => {
  const now = performance.now();
  const fps = (frameCount * 1000) / (now - lastTime);
  console.log(`FPS: ${fps.toFixed(1)}`);
  frameCount = 0;
  lastTime = now;
}, 1000);
```

**Resultado esperado:**
- ✅ FPS > 30 (mínimo aceptable)
- ✅ FPS > 60 (ideal)

**⚠️ Si FPS < 30:**
- Reduce resolución del canvas (ver README Troubleshooting)
- Simplifica las escenas (menos capas)

---

## 🎯 Resumen de Verificación Rápida

Ejecuta esto para una prueba completa en **5 minutos**:

```bash
# Terminal 1: Proxy con debug
cd osc-proxy && DEBUG=true npm run dev

# Terminal 2: Servidor HTTP
python3 -m http.server 8000
```

**En SuperCollider:**
```supercollider
// Ejecutar TODO de golpe
p = ProxySpace.push(s.boot);
topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57121);
Tdef(\osc_ctrl, { /* ... código completo ... */ });
~rhythm = { /* ... */ };
~bass = { /* ... */ };
~high = { /* ... */ };
~a1 = Pbind(/* ... */);
~osc_ctrl.play;
~a1.resume;  // ¡NO OLVIDES ESTO!
```

**En el navegador:**
- Abre: `http://localhost:8000/templates/hydra/layer_mixer_template.html`
- Verifica HUD: `Estado: Conectado` (verde)
- Verifica valores cambiando continuamente
- Prueba botones de escenas

---

## 🐛 Troubleshooting Rápido

| Problema | Solución |
|----------|----------|
| `EADDRINUSE` puerto 8080/57121 | `lsof -ti:8080 \| xargs kill -9` |
| "Conectado" pero valores en 0.1000 | Ejecuta `~osc_ctrl.play` y `~a1.resume` en SC |
| No se ve nada visual | Abre consola (F12), busca errores de Hydra |
| Proxy no muestra mensajes OSC | Ejecuta con `DEBUG=true npm run dev` |
| Tests fallan | Normal si es primera vez, revisa mocks |
| FPS bajo | Reduce resolución canvas o simplifica escenas |

---

## 📊 Criterios de Éxito

✅ **Proyecto funcional** si:
1. Proxy inicia sin errores (puertos 8080, 57121)
2. SuperCollider envía OSC visible en logs del proxy
3. Navegador conecta (HUD muestra "Conectado")
4. Valores numéricos cambian continuamente
5. Visuales reaccionan a cambios en valores OSC
6. Cambio de escenas funciona (botones o OSC)
7. FPS > 30 en navegador

---

**¿Listo para producción?** Ejecuta:
```bash
./setup.sh  # Genera start.sh y stop.sh
./start.sh  # Inicia todo automáticamente
```
