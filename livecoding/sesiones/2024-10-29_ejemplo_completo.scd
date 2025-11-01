// ═══════════════════════════════════════════════════════════════
// 🎵 EJEMPLO DE SESIÓN - ProxySpace Hydra
// ═══════════════════════════════════════════════════════════════
// Fecha: 2024-10-29
// Concepto: Demostración de flujo LANDSCAPES → DUALISMOS
// Notas: Ejemplo completo con comentarios explicativos
// ═══════════════════════════════════════════════════════════════

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃ 🚀 ARRANQUE RÁPIDO                                         ┃
// ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
// ┃ 1. Abrir openFrameworks (Xcode → Cmd+R)                   ┃
// ┃ 2. Ejecutar BLOQUE 1 (líneas 19-45, Cmd+Return)           ┃
// ┃ 3. Esperar "✅ OSC configurado" en Post window             ┃
// ┃ 4. Ejecutar resto de bloques uno por uno durante sesión   ┃
// ┃                                                            ┃
// ┃ ⚠️  El proxy Node.js se arranca AUTOMÁTICAMENTE           ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

// ┌─────────────────────────────────────────────────────────────┐
// │ 1. ARRANQUE AUTOMÁTICO DEL SISTEMA                         │
// └─────────────────────────────────────────────────────────────┘
// ⚠️  EJECUTAR ESTE BLOQUE PRIMERO (seleccionar líneas 19-45, Cmd+Return)

(
// 1.1 Arrancar proxy OSC en background
fork {
    "🚀 Arrancando proxy Node.js...".postln;
    (thisProcess.nowExecutingPath.dirname.dirname.dirname +/+ "start_proxy.sh").unixCmd;

    // Esperar 2 segundos a que arranque el proxy
    2.wait;
    "✅ Proxy listo para recibir OSC".postln;
};

// 1.2 Cargar Setup (SynthDefs, Snippets, Samples, ProxySpace)
("../setup/Setup.scd").loadRelative;

// 1.3 Configurar OSC
topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57122);
"✅ OSC configurado en 127.0.0.1:57122".postln;

CmdPeriod.doOnce({
    OSCdef(\sendKick).tryPerform(\free);
    OSCdef(\sendBass).tryPerform(\free);
    OSCdef(\sendMelody).tryPerform(\free);
    OSCdef(\sendTexture).tryPerform(\free);
    topEnvironment.removeAt(\hydraAddr);
    "⛔ OSCdefs liberados".postln;
});

// 1.4 Matar proxy al cerrar SuperCollider
ServerQuit.add({
    "🛑 Deteniendo proxy Node.js...".postln;
    "pkill -f 'node.*osc_ws_proxy'".unixCmd;
});
)

// ═══════════════════════════════════════════════════════════════
// PARTE 1: ESCENA LANDSCAPES (15 min)
// ═══════════════════════════════════════════════════════════════

// ┌─────────────────────────────────────────────────────────────┐
// │ 3. FASE A: SOUNDSCAPE PURO (3-5 min)                       │
// └─────────────────────────────────────────────────────────────┘

// Drone ambiental - Solo audio, sin efectos visuales
~ambient.ar(2);
~ambient.fadeTime = 4;
~ambient[0] = {
    var sig, freq;
    freq = [200, 201, 250, 251]; // Batimiento sutil
    sig = SinOsc.ar(freq, mul: 0.1);
    sig = sig + LFNoise1.ar(0.5, 0.2); // Textura de ruido
    sig = FreeVerb.ar(sig, 0.8, 0.9, 0.5); // Reverb profunda
    Splay.ar(sig) * 0.3;
};
~ambient.play;

// Textura de viento (opcional)
~wind.ar(2);
~wind.fadeTime = 6;
~wind[0] = {
    var sig = WhiteNoise.ar(0.1);
    sig = BPF.ar(sig, LFNoise1.kr(0.1).range(1000, 3000), 0.3);
    sig = sig * LFNoise1.kr(0.2).range(0.3, 0.7);
    sig ! 2;
};
~wind.play;

// ┌─────────────────────────────────────────────────────────────┐
// │ 4. FASE B: ACTIVACIÓN DE EFECTOS (2-3 min)                 │
// └─────────────────────────────────────────────────────────────┘

// Primer kick → activa efectos visuales y cambia imagen
topEnvironment[\hydraAddr].sendMsg("/kick");

// Configurar envío automático de OSC
(
~bass_level.ar(2);
~bass_level.fadeTime = 0.1;
~bass_level[0] = { DC.ar(0) };

OSCdef(\sendBass, {
    arg msg, time, addr, port;
    var val = msg[3].linlin(-1, 1, 0, 1).clip(0, 1);
    topEnvironment[\hydraAddr].sendMsg("/bass_level", val);
}, '/proxyspace/bass_level');

~bass_level[1] = { SendReply.kr(Impulse.kr(20), '/proxyspace/bass_level', ~bass_level.ar) };
)

(
~melody_note.ar(2);
~melody_note.fadeTime = 0.5;
~melody_note[0] = { DC.ar(0.5) };

OSCdef(\sendMelody, {
    arg msg, time, addr, port;
    var val = msg[3].linlin(-1, 1, 0, 1).clip(0, 1);
    topEnvironment[\hydraAddr].sendMsg("/melody_note", val);
}, '/proxyspace/melody_note');

~melody_note[1] = { SendReply.kr(Impulse.kr(20), '/proxyspace/melody_note', ~melody_note.ar) };
)

(
~texture_level.ar(2);
~texture_level.fadeTime = 2;
~texture_level[0] = { DC.ar(0) };

OSCdef(\sendTexture, {
    arg msg, time, addr, port;
    var val = msg[3].linlin(-1, 1, 0, 1).clip(0, 1);
    topEnvironment[\hydraAddr].sendMsg("/texture", val);
}, '/proxyspace/texture_level');

~texture_level[1] = { SendReply.kr(Impulse.kr(20), '/proxyspace/texture_level', ~texture_level.ar) };
)

// Introducir erosión gradual
~bass_level[0] = { Line.kr(0, 0.4, 20) }; // 20 segundos

// Kick pattern cada 8 beats
(
Pdef(\kickPattern,
    Pbind(
        \type, \osc,
        \addr, topEnvironment[\hydraAddr],
        \oscPath, "/kick",
        \dur, 8,

    )
).play;
)

// ┌─────────────────────────────────────────────────────────────┐
// │ 5. FASE C: DESARROLLO (5-8 min)                            │
// └─────────────────────────────────────────────────────────────┘

// Añadir bass pulsante
~bass.ar(2);
~bass.fadeTime = 0.1;
~bass[0] = {
    var sig, env, freq;
    freq = [60, 61].midicps;
    env = LFPulse.kr(0.5, 0, 0.3); // Pulso lento
    sig = LFTri.ar(freq) * env * 0.1;
};
~bass.play;

// Erosión aumenta con el bass
~bass_level[0] = { LFNoise1.kr(0.5).range(0.3, 0.6) };

// Revelación progresiva con melodía
~melody.ar(2);
~melody.fadeTime = 0.5;
~melody[0] = {
    var sig, freq;
    freq = Duty.kr(4, 0, Dseq([72, 75, 79, 77].midicps, inf));
    sig = SinOsc.ar(freq) * 0.07;
    sig = sig + SinOsc.ar(freq * 2.01) * 0.1; // Armónico
    sig ! 2;
};
~melody.play;

// Controlar revelación con melodía
~melody_note[0] = { LFNoise1.kr(0.2).range(0.6, 1.0) };

// Añadir ondulación con textura
~texture_level[0] = { LFNoise1.kr(0.3).range(0.2, 0.5) };

// Kicks más frecuentes
Pdef(\kickPattern).set(\dur, 6);

// ┌─────────────────────────────────────────────────────────────┐
// │ 6. FASE D: CLÍMAX + DECAY (3-5 min)                        │
// └─────────────────────────────────────────────────────────────┘

// Intensidad máxima
~bass_level[0] = 0.75;
~melody_note[0] = 1.0;
~texture_level[0] = 0.6;

// Kicks rápidos
Pdef(\kickPattern).set(\dur, 4);

// Después de 20 segundos, empezar decay
(
fork {
    20.wait;
    "🔽 Iniciando decay...".postln;

    // Fade out de erosión
    ~bass_level[0] = { Line.kr(0.75, 0, 15) };

    // Fade out de ondulación
    ~texture_level[0] = { Line.kr(0.6, 0, 15) };

    // Detener kicks
    5.wait;
    Pdef(\kickPattern).stop;

    // Fade out de melodía
    10.wait;
    ~melody_note[0] = { Line.kr(1.0, 0.5, 10) };

    "✅ Decay completado - Listo para DUALISMOS".postln;
};
)

// ═══════════════════════════════════════════════════════════════
// PARTE 2: ESCENA DUALISMOS (15 min)
// ═══════════════════════════════════════════════════════════════

// ⚠️ Presionar tecla "2" en openFrameworks para cambiar escena

// ┌─────────────────────────────────────────────────────────────┐
// │ 7. FASE A: INTRODUCCIÓN TIPOGRÁFICA (2-3 min)              │
// └─────────────────────────────────────────────────────────────┘

// Detener audio de LANDSCAPES
~ambient.stop(8);
~wind.stop(8);
~bass.stop(4);
~melody.stop(4);

// Kick pattern más lento para palabras
(
Pdef(\dualKicks,
    Pbind(
        \type, \osc,
        \addr, topEnvironment[\hydraAddr],
        \oscPath, "/kick",
        \dur, 6, // Cada 6 beats
    )
).play;
)

// Bass rítmico simple
~dualBass.ar(2);
~dualBass.fadeTime = 0.02;
~dualBass[0] = {
    var sig, env;
    env = EnvGen.kr(Env.perc(0.001, 0.4), Impulse.kr(1));
    sig = SinOsc.ar(60 * env.exprange(1, 8)) * env * 0.4;
    sig ! 2;
};
~dualBass.play;

// Ondulación tipográfica suave
~bass_level[0] = { SinOsc.kr(0.25).range(0, 0.3) };

// ┌─────────────────────────────────────────────────────────────┐
// │ 8. FASE B: EXPLORACIÓN DE SETS (8-10 min)                  │
// └─────────────────────────────────────────────────────────────┘

// Set Platón (tecla "3" en oF)
// Set Musical (tecla "4" en oF)
// Set Textura (tecla "5" en oF)

// Aumentar frecuencia de palabras
Pdef(\dualKicks).set(\dur, 4);

// Añadir hi-hats
~hats.ar(2);
~hats.fadeTime = 0.01;
~hats[0] = {
    var sig, env;
    env = EnvGen.kr(Env.perc(0.001, 0.1), Impulse.kr(4));
    sig = WhiteNoise.ar(env * 0.15);
    sig = HPF.ar(sig, 8000);
    sig ! 2;
};
~hats.play;

// ┌─────────────────────────────────────────────────────────────┐
// │ 9. FASE C: EFECTOS GENERATIVOS (5-8 min)                   │
// └─────────────────────────────────────────────────────────────┘

// Glitch tipográfico progresivo
~texture_level[0] = { LFNoise1.kr(0.5).range(0, 0.7) };

// Rotación rítmica
~bass_level[0] = { LFSaw.kr(0.25).range(0, 0.8) };

// Dispersión con melodía
~melody_note[0] = { LFNoise1.kr(0.3).range(0.3, 0.9) };

// Melodía synth
~dualMelody.ar(2);
~dualMelody.fadeTime = 0.1;
~dualMelody[0] = {
    var sig, freq;
    freq = Duty.kr(2, 0, Dseq([72, 75, 79, 77, 75, 72].midicps, inf));
    sig = Pulse.ar(freq, 0.5) * 0.15;
    sig = RLPF.ar(sig, freq * 4, 0.3);
    sig ! 2;
};
~dualMelody.play;

// Palabras más rápidas
Pdef(\dualKicks).set(\dur, 3);

// ┌─────────────────────────────────────────────────────────────┐
// │ 10. FASE D: FINAL (2-3 min)                                │
// └─────────────────────────────────────────────────────────────┘

// Densidad máxima
Pdef(\dualKicks).set(\dur, 2);

// Efectos al máximo
~bass_level[0] = 0.8;
~texture_level[0] = 0.7;
~melody_note[0] = 0.9;

// Fade out final
(
fork {
    20.wait;
    "🔽 Fade out final...".postln;

    // Detener kicks
    Pdef(\dualKicks).stop;

    // Fade de efectos
    ~bass_level[0] = { Line.kr(0.8, 0, 10) };
    ~texture_level[0] = { Line.kr(0.7, 0, 10) };
    ~melody_note[0] = { Line.kr(0.9, 0, 10) };

    // Fade de audio
    ~dualBass.stop(6);
    ~hats.stop(6);
    ~dualMelody.stop(8);

    10.wait;
    "✅ SESIÓN FINALIZADA".postln;
};
)

// ═══════════════════════════════════════════════════════════════
// NOTAS DE LA SESIÓN
// ═══════════════════════════════════════════════════════════════

/*

✅ QUÉ FUNCIONÓ BIEN:
- Transición suave de LANDSCAPES a DUALISMOS
- Erosión progresiva en Fase C muy efectiva
- Combinación de glitch + rotación en DUALISMOS

⚠️ PROBLEMAS ENCONTRADOS:
- Ninguno en esta sesión de ejemplo

💡 IDEAS PARA PRÓXIMAS SESIONES:
- Probar con samples de field recordings
- Explorar más variaciones de Sets en DUALISMOS
- Añadir tercer acto con ambas escenas mezcladas

🎯 VALORES CLAVE QUE SONARON BIEN:
- LANDSCAPES erosión: 0.3 - 0.6 (dulce spot)
- DUALISMOS rotación: LFSaw 0.25 Hz
- Tempo 90 BPM funciona perfecto

*/

// ═══════════════════════════════════════════════════════════════
// FIN DE LA SESIÓN
// ═══════════════════════════════════════════════════════════════
