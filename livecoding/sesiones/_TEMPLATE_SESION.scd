// ===================================================================
// 🎛️ Plantilla General de Sesión ProxySpace Hydra
// -------------------------------------------------------------------
// Duplica este archivo, renómbralo con la fecha/nombre del show y
// personalízalo. Secciones clave:
//   1. Metadata y checklist
//   2. Arranque rápido (proxy + oF + setup SC)
//   3. Instrumentos / buffers / patrones
//   4. Puente OSC → openFrameworks (parámetros estándar)
//   5. Timeline y cues
//   6. Notas post‑show
// ===================================================================

// -------------------------------------------------------------------
// 1. METADATA Y CHECKLIST
// -------------------------------------------------------------------

/*
SESIÓN:
  Título:   <nombre del set>
  Lugar:    <venue / stream>
  Fecha:    <AAAA-MM-DD>
  Notas:    <temperatura, público, mood…>

CHECKLIST RÁPIDO:
  [ ] Proxy Node `./start_live_session.sh`
  [ ] openFrameworks corriendo en 12345
  [ ] Setup.scd evaluado
  [ ] Samples cargados (ruta revisada)
  [ ] Controladores MIDI / OSC conectados
  [ ] Hydra / Browser mostrando HUD
*/

// -------------------------------------------------------------------
// 2. ARRANQUE AUTOMÁTICO
// -------------------------------------------------------------------

(
// Opcional: lanzar proxy/startup desde SC (útil si trabajas off-site)
// fork { "/path/a/start_live_session.sh".standardizePath.unixCmd };

SoundSessionStartAll.();    // Inicializa server, buffers base y puente OSC
SoundSessionPlay.();        // Arranca patrón de referencia (puedes pararlo luego)

// Configuración extra específica del set
SoundSession.use({
    ~tempo = 100/60;           // Ajusta BPM global
    t.tempo_(~tempo);          // Aplica tempo al clock
    ~samplesRelative = "samples/set1/set-sounds/"; // Actualiza si cambia
});
)

// -------------------------------------------------------------------
// 3. INSTRUMENTOS / BUFFERS / PATRONES
// -------------------------------------------------------------------

/*
Guía:
  - Usa NodeProxy para proxies de audio (`~nombre.ar(2)`).
  - Para patrones complejos, encapsula en `Pdef`/`Tdef` y asócialos a un proxy.
  - Llama `~visBridge.watch(\nombre, ~nombre);` para exponer parámetros estándar
    (`/of/nombre/rms`, `/of/nombre/peak`, etc.) automáticamente.
*/

(
// Ejemplo: Drone base
~drone.ar(2);
~drone[0] = {
    var sig = Pulse.ar([40, 41] + LFNoise0.kr(0.1).range(-0.5, 0.5), 0.3);
    sig = RLPF.ar(sig, LFNoise1.kr(0.05).range(200, 1200), 0.2);
    sig = sig.tanh;
    sig * 0.2;
};
~drone.play;
~visBridge.watch(\drone, ~drone);

// Ejemplo: Player de buffers con patrón
~grains = NodeProxy.audio(s, 2);
~grains.source = { Silent.ar(2) }; // placeholder

~grains.pattern = Pbind(
    \instrument, \bufsynth,
    \buf, Pxrand(~visBridge.buffersFor(\setSounds), inf), // helper opcional
    \dur, Pexprand(0.125, 0.5, inf),
    \rate, Pwhite(0.5, 2.0, inf),
    \spos, Pwhite(0.0, 0.9, inf),
    \amp, Pexprand(0.2, 0.7, inf),
    \atk, 0.01,
    \sus, Pwhite(0.0, 0.2, inf),
    \rel, Pwhite(0.1, 0.4, inf),
    \pan, Pwhite(-0.8, 0.8, inf)
);

~grains.play;
~grains.pattern.play(t, quant: 1);
~visBridge.watch(\grains, ~grains);

// Añade tus instrumentos adicionales aquí
)

// -------------------------------------------------------------------
// 4. PUENTE OSC → OPENFRAMEWORKS / HYDRA
// -------------------------------------------------------------------

/*
Convenciones sugeridas (respetadas en ofApp.cpp):
  /kick                 → trigger escena LANDSCAPES/DUALISMOS
  /bass_level           → intensidad global (erosión, blur)
  /melody_note          → tinte y revelación
  /texture              → desplazamiento y feedback decay
  /of/<canal>/rms       → nivel continuo de un proxy (auto via visBridge)
  /of/<canal>/peak      → picos (flash, particulas)
  /of/<canal>/centroid  → centroid espectral (color, saturación)
  /scene/<id>           → cambiar escena visual directamente (si lo necesitas)

Puedes añadir rutas nuevas así:
*/

(
// Ejemplo: enviar rate y pan del patrón `~grains`
OSCdef(\grainsExtra, { |msg|
    var rate = msg[3].linlin(0.5, 2.0, 0.0, 1.0).clip(0, 1);
    var pan = msg[4];
    topEnvironment[\hydraAddr].sendMsg("/of/grains/rate", rate);
    topEnvironment[\hydraAddr].sendMsg("/of/grains/pan", pan);
}, '/proxyspace/grains', skipInfrared: true);

// Activa triggers manuales si quieres reacciones dramatizadas
~cambiarEscena = { |id = 0| topEnvironment[\hydraAddr].sendMsg("/scene", id) };
)

// -------------------------------------------------------------------
// 5. TIMELINE / CUES
// -------------------------------------------------------------------

/*
Estructura sugerida para tu set:

ACTO 0 — CHECK SOUND (2 min)
  - Revisa drone base (~drone)
  - Ajusta niveles en Hydra/of HUD

ACTO 1 — INTRO TEXTURAS (5 min)
  - Activa ~grains.pattern
  - Envía `/kick` manual para iniciar erosión visual
  - Usa SoundSessionStop.(); si quieres limpiar antes del siguiente acto

ACTO 2 — GROOVE PRINCIPAL (10 min)
  - Añade nuevo proxy ~perc
  - Sincroniza con patrones MIDI externamente (tempo: 100 BPM)
  - Manipula `/texture` via slider

ACTO 3 — CLÍMAX / FADE (5 min)
  - Incrementa globalIntensity via `/bass_level`
  - Usa `SoundSessionCleanup.();` al finalizar

Escribe tus cues específicos aquí:
*/

/*
Cue A: ______________________________________________________________
Cue B: ______________________________________________________________
Cue C: ______________________________________________________________
*/

// -------------------------------------------------------------------
// 6. NOTAS POST-SHOW
// -------------------------------------------------------------------

/*
✅ Qué funcionó:
  -
  -

⚠️ Problemas a corregir:
  -
  -

💡 Ideas para iterar:
  -
  -
*/
