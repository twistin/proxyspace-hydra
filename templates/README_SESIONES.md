# 📁 Sistema de Sesiones - ProxySpace Hydra

## 🗂️ Estructura de Carpetas

```
proxyspace-hydra/
├── Setup/              → SynthDefs, Snippets, configuración ProxySpace
│   ├── Setup.scd       → Arranque del sistema (boot, MIDI, ProxySpace)
│   ├── Synthdefs.scd   → Definiciones de instrumentos
│   └── Snippets.scd    → Funciones útiles
├── samples/            → Archivos de audio (.wav, .aiff)
│   └── set1/          → Ejemplo de carpeta de samples
├── sesiones/           → Tus sesiones en vivo guardadas aquí
│   ├── 2024-10-29_landscapes.scd
│   └── 2024-11-01_dualismos.scd
└── templates/          → Plantillas base
    └── session_template.scd
```

---

## 🚀 Cómo Empezar una Nueva Sesión

### **Paso 1: Copiar la plantilla**

```bash
# Desde la carpeta raíz del proyecto
cp templates/session_template.scd sesiones/FECHA_NOMBRE.scd

# Ejemplo:
cp templates/session_template.scd sesiones/2024-10-29_experimento.scd
```

### **Paso 2: Editar metadatos**

Abre el archivo y rellena:
```supercollider
// Fecha: 29 octubre 2024
// Concepto: Exploración de ritmos afrocubanos con síntesis FM
// Notas: Preparar para show en vivo del viernes
```

### **Paso 3: Arrancar el sistema**

1. **Abrir SuperCollider IDE**
2. **Ejecutar la sesión** (Cmd+Return en todo el archivo)
3. El setup cargará automáticamente:
   - SynthDefs desde `Setup/Synthdefs.scd`
   - Snippets desde `Setup/Snippets.scd`
   - Samples desde `samples/set1/`
   - ProxySpace configurado (tempo 90 BPM, fadeTime 2.5s)

---

## 📋 Estructura de la Plantilla

### **Sección 1: Setup Automático**
```supercollider
("../Setup/Setup.scd").loadRelative;
```
- Carga todo desde la carpeta `Setup/`
- Usa rutas relativas (funciona desde cualquier subcarpeta)

### **Sección 2: Configuración OSC**
```supercollider
topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57122);
```
- Conecta con openFrameworks + Hydra
- Define OSCdefs para limpieza automática

### **Sección 3: Proxies de Audio**
Plantillas para:
- `~ambient` → Soundscapes / texturas ambientales
- `~kick` → Percusión / triggers
- `~bass` → Graves / línea de bajo
- `~melody` → Melodía / línea alta
- `~texture` → Ruido / textura

### **Sección 4: Envío Automático de OSC**
Proxies especiales que envían valores a oF/Hydra:
- `~bass_level` → `/bass_level` (erosión en LANDSCAPES)
- `~melody_note` → `/melody_note` (revelación en LANDSCAPES)
- `~texture_level` → `/texture` (ondulación en LANDSCAPES)

### **Sección 5: Patrones Rítmicos**
Pdefs listos para usar:
- `Pdef(\kickPattern)` → Envía `/kick` a oF
- `Pdef(\bassPattern)` → Secuencia de bass
- `Pdef(\melodyPattern)` → Secuencia melódica

### **Sección 6: Controles en Vivo**
Ejemplos de modificaciones durante performance:
```supercollider
// Erosión suave
~bass_level[0] = { LFNoise1.kr(0.5).range(0, 0.4) };

// Revelación gradual
~melody_note[0] = { Line.kr(0.3, 1.0, 20) };
```

### **Sección 7: Funciones Útiles**
- `~cambiarImagen.value` → Trigger manual de `/kick`
- `~resetVisual.value` → Reset de todos los efectos
- `~stopAll.value` → Stop total del audio

### **Sección 8: Notas**
Espacio para documentar ideas, problemas, mejoras

---

## 🎯 Workflow Recomendado

### **Durante una Sesión:**

1. **Ejecutar Setup** (línea 10)
   ```supercollider
   ("../Setup/Setup.scd").loadRelative;
   ```

2. **Configurar OSC** (Sección 2)
   ```supercollider
   // Ejecutar bloque de topEnvironment[\hydraAddr]
   ```

3. **Definir audio básico** (Sección 3)
   ```supercollider
   // Escribir código en ~ambient, ~kick, etc.
   ~ambient.play;
   ```

4. **Activar envíos OSC** (Sección 4)
   ```supercollider
   // Ejecutar bloques de ~bass_level, ~melody_note, ~texture_level
   ```

5. **Live coding** 🎵
   - Modificar proxies en tiempo real
   - Cambiar patrones con Pdef
   - Usar controles de Sección 6

### **Al Finalizar:**

1. Guardar el archivo `.scd` en `sesiones/`
2. Documentar en Sección 8:
   - Qué funcionó bien
   - Problemas encontrados
   - Ideas para futuras sesiones

---

## 🔧 Modificar el Setup Base

Si necesitas cambiar algo global (SynthDefs, Snippets, configuración):

### **Editar Setup.scd**
```bash
open Setup/Setup.scd
```

Cambios comunes:
- **Tempo**: `p.clock.tempo_(120/60);` (línea 48)
- **Fade time**: `p.fadeTime_(5);` (línea 50)
- **Samples folder**: `d.add(\foldernames -> PathName("../samples/SET2")` (línea 59)

### **Añadir SynthDefs**
```bash
open Setup/Synthdefs.scd
```

### **Añadir Snippets**
```bash
open Setup/Snippets.scd
```

Los cambios se aplicarán a **todas las sesiones futuras** que carguen `Setup.scd`.

---

## 📚 Ejemplos de Sesiones

### **Sesión tipo LANDSCAPES** (Ambient → Erosión)

```supercollider
// 1. Soundscape puro (sin efectos visuales)
~ambient[0] = { 
    var sig = SinOsc.ar([200, 201]) * 0.1;
    FreeVerb.ar(sig, 0.8, 0.9, 0.5);
};
~ambient.play;

// 2. Activar efectos con primer kick
topEnvironment[\hydraAddr].sendMsg("/kick");

// 3. Introducir erosión progresiva
~bass_level[0] = { Line.kr(0, 0.6, 30) };

// 4. Revelar gradualmente
~melody_note[0] = { Line.kr(0.3, 1.0, 20) };
```

### **Sesión tipo DUALISMOS** (Tipografía generativa)

```supercollider
// 1. Cambiar a escena 2 en oF (tecla "2")

// 2. Kicks para generar palabras
Pdef(\kickPattern, Pbind(\type, \osc, \addr, topEnvironment[\hydraAddr], 
    \oscPath, "/kick", \dur, 4)).play;

// 3. Glitch tipográfico
~texture_level[0] = { LFNoise1.kr(0.5).range(0, 0.8) };

// 4. Rotación rítmica
~bass_level[0] = { LFSaw.kr(0.25).range(0, 1.0) };
```

---

## ⚠️ Solución de Problemas

### **"Setup.scd not found"**
- Verifica que estás ejecutando desde `sesiones/`
- La ruta relativa `"../Setup/Setup.scd"` debe apuntar correctamente

### **"SynthDef not found"**
- Espera a que termine `Setup.scd` (verás "Setup done!" en Post window)
- El setup tiene un `3.wait` antes de cargar SynthDefs

### **OSC no funciona**
```supercollider
// Verificar proxy corriendo:
// Terminal: SC_OSC_PORT=57122 npm run proxy

// Test manual:
topEnvironment[\hydraAddr].sendMsg("/kick");
```

### **Samples no cargan**
- Verifica carpeta: `samples/set1/` existe
- Formato soportado: `.wav`, `.aiff`
- Cambiar carpeta en `Setup.scd` línea 59

---

## 🎵 Tips para Live Coding

1. **Usa Pdef para todo lo rítmico**
   - Puedes cambiar patrones en caliente
   - `Pdef(\name).play` / `.stop` / `.set(\dur, 2)`

2. **Usa Line/XLine para transiciones**
   ```supercollider
   ~bass_level[0] = { Line.kr(0, 0.8, 10) }; // 10 segundos
   ```

3. **Usa LFNoise para variación orgánica**
   ```supercollider
   ~melody_note[0] = { LFNoise1.kr(0.2).range(0.5, 1.0) };
   ```

4. **Documenta mientras tocas**
   - Si algo suena bien, copia el código a Sección 8
   - Marca con comentarios: `// ✅ FUNCIONA BIEN`

5. **Ten funciones de emergencia listas**
   ```supercollider
   ~stopAll.value;      // Pánico total
   ~resetVisual.value;  // Reset visual solamente
   ```

---

## 📖 Recursos Adicionales

- `WORKFLOW_LIVE.md` → Guía completa para shows en vivo
- `Setup/Synthdefs-index.md` → Lista de instrumentos disponibles
- `LANDSCAPES_EFFECTS.md` → Documentación de efectos visuales
- `TIPOGRAFIA_GENERATIVA.md` → Guía de DUALISMOS

---

**¡Listo para crear! 🎨🎵**
