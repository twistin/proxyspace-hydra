/*
PLANTILLA LIVE CODING · SUPER COLLIDER → HYDRA
------------------------------------------------
Esta plantilla parte de `sound2.scd`, adaptada para sesiones con
texto mutable en Hydra. Sigue estos pasos antes de ejecutarla:

 1. Lanza tu boilerplate global (buffers, MIDI, StageLimiter, Logic, etc.).
 2. Asegúrate de que el servidor está booted y `ProxySpace` no está duplicado.
 3. Ejecuta este archivo por bloques, ajustando las secciones marcadas.

SECCIONES
 0. Preámbulo y recordatorios
 1. Tempo + ProxySpace
 2. Conexión OSC → Hydra
 3. Carga del setup compartido (literal)
 4. Capas sonoras base (pulso, bajo, texturas)
 5. Control OSC para ritmo/bajos/agudos
 6. Utilidades de escena y control
 7. Limpieza rápida

Personaliza notas, envolventes y rutas según tu set.
*/


////////////////////////////////////////////////////////
// 0. PREÁMBULO
////////////////////////////////////////////////////////
// Ejecuta primero tu script principal (server, buffers, MIDI, StageLimiter).
// Este archivo no redefine Buffer.freeAll ni abre Logic; asume que ya está hecho.


////////////////////////////////////////////////////////
// 1. TEMPO + PROXYSPACE (reutiliza si ya existe)
////////////////////////////////////////////////////////
(
var bpm = 90;
var clock;

if(p.isNil) {
    clock = TempoClock(bpm/60);
    p = ProxySpace(server: s, clock: clock);
    p.push;
    p.makeTempoClock;
    clock.tempo_(bpm/60);
    "[LiveTemplate] ProxySpace creado y empujado.".postln;
} {
    clock = p.clock;
    clock.tempo_(bpm/60);
    if(currentEnvironment !== p) {
        p.push;
    };
    "[LiveTemplate] ProxySpace existente reutilizado.".postln;
};

p.fadeTime_(2.5);
p.quant_(4);

topEnvironment[\liveClock] = clock;
thisThread.clock = clock;
)

// limpia proxies heredados que ahora viven en topEnvironment
p[\setVerbMix].tryPerform(\clear);


////////////////////////////////////////////////////////
// 2. CONEXIÓN OSC → HYDRA (puerto 57121)
////////////////////////////////////////////////////////
(
topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57121);
"[LiveTemplate] OSC hacia Hydra → 127.0.0.1:57121".postln;

CmdPeriod.doOnce({
    OSCdef(\liveTextBridge).tryPerform(\free);
    ~osc_ctrl.tryPerform(\stop);
    ~master.tryPerform(\stop);
    topEnvironment.removeAt(\hydraAddr);
    "[LiveTemplate] CmdPeriod: OSC y master liberados.".postln;
});
)


////////////////////////////////////////////////////////
// 3. CARGA DEL SETUP COMPARTIDO (literal)
////////////////////////////////////////////////////////
("../Setup/Setup.scd").loadRelative;
"[LiveTemplate] Setup general cargado.".postln;


////////////////////////////////////////////////////////
// 4. CAPAS SONORAS BASE (pulso, bajo, textura)
////////////////////////////////////////////////////////

~pulse = {
    var clock = topEnvironment[\liveClock] ? TempoClock.default;
    var trig = Impulse.kr(clock.tempo * 2);
    var note = Demand.kr(trig, 0, Dseq([0, 5, 3, 7, 10, 4, 9, 2].scramble, inf));
    var env = Decay2.kr(trig, 0.005, 0.18);
    var sig = SinOscFB.ar((note + 60).midicps * [1, 1.01], 1.2, env);
    Splay.ar(sig, 0.45) * 0.25;
};
~pulse.play(quant: 1);

~bass = {
    var clock = topEnvironment[\liveClock] ? TempoClock.default;
    var trig = Impulse.kr(clock.tempo);
    var step = Demand.kr(trig, 0, Dseq([0, -2, -5, -7, -12, -7].mirror2, inf));
    var env = EnvGen.kr(Env.perc(0.02, 0.8, curve: -3), trig);
    var freq = (step + 38 + LFNoise1.kr(0.2).range(-3, 3)).midicps;
    var sig = (Saw.ar(freq, env * 0.4) + SinOsc.ar(freq / 2, 0, env * 0.3));
    Splay.ar(sig, 0.25);
};
~bass.play(quant: 1);

~wash = {
    var mod = SinOsc.kr([0.05, 0.08]).range(400, 2600);
    var src = PinkNoise.ar(0.2) + Dust2.ar(3, 0.4);
    var filtered = RLPF.ar(src, mod, 0.15);
    var shimmer = PitchShift.ar(filtered, 0.15, [1, 1.5], 0, 0.03);
    Splay.ar(AllpassN.ar(shimmer, 1.6, { Rand(0.2, 0.6) } ! 2, 3), 0.6) * 0.18;
};
~wash.play(quant: 1);

~mix = {
    var dry = (~pulse.ar(2) + ~bass.ar(2) + ~wash.ar(2));
    LeakDC.ar(dry) * 0.5;
};
~mix.play(quant: 1);

~master = {
    var dry = ~mix.ar(2);
    var wet = GVerb.ar(dry, 70, 6, 0.4, 0.5, 15, 0.5, 0.3, 0.15);
    var mixAmt = \mix.kr(0.35).clip(0.0, 1.0);
    // crossfade sin anidar arrays para NodeProxy
    (dry * (1.0 - mixAmt)) + (wet * mixAmt);
};
~master.play(quant: 1);

topEnvironment[\setVerbMix] = { |mix = 0.35| // usa topEnvironment[\setVerbMix].(0.4) para ajustar reverb
    ~master.tryPerform(\set, \mix, mix.clip(0.0, 1.0));
};


////////////////////////////////////////////////////////
// 5. CONTROL OSC (ritmo, bajos, agudos) → Hydra
////////////////////////////////////////////////////////
(
~osc_ctrl = {
    var mono = Mix(~master.ar(2));
    var rhythmRaw = Amplitude.kr(mono, 0.01, 0.08).clip(0.0, 0.4);
    var bassRaw = Amplitude.kr(LPF.ar(mono, 180), 0.01, 0.12).clip(0.0, 0.35);
    var highRaw = Amplitude.kr(HPF.ar(mono, 3200), 0.01, 0.1).clip(0.0, 0.2);

    var rhythm = Lag.kr(rhythmRaw.linexp(0.003, 0.35, 0.08, 0.98), 0.12).clip(0.08, 0.98);
    var bass = Lag.kr(bassRaw.linexp(0.002, 0.32, 0.1, 0.95), 0.16).clip(0.1, 0.95);
    var high = Lag.kr(highRaw.linexp(0.001, 0.18, 0.05, 0.9), 0.1).clip(0.05, 0.9);

    SendTrig.kr(Impulse.kr(12), 1, rhythm);  // /sc/rhythm
    SendTrig.kr(Impulse.kr(8), 2, bass);     // /sc/bass
    SendTrig.kr(Impulse.kr(16), 3, high);    // /sc/high
    Silent.ar;
};
~osc_ctrl.play(quant: 1);
)

(
OSCdef(\liveTextBridge, { |msg|
    var id = msg[2];
    var value = msg[3];
    var route = [nil, "/sc/rhythm", "/sc/bass", "/sc/high"][id];
    var addr = topEnvironment[\hydraAddr];

    if(route.isNil) { ^nil };

    if(addr.isNil) {
        addr = NetAddr("127.0.0.1", 57121);
        topEnvironment[\hydraAddr] = addr;
    };

    addr.sendMsg(route, value);
}, '/tr', s.addr);
)


////////////////////////////////////////////////////////
// 6. ESCENAS + CONTROLES (ajusta a tu flujo)
////////////////////////////////////////////////////////
topEnvironment[\scene] = { |index = 0| // invoca con topEnvironment[\scene].(idx)
    var addr = topEnvironment[\hydraAddr];
    addr.tryPerform(\sendMsg, "/sc/scene", index);
};

topEnvironment[\playAll] = { // topEnvironment[\playAll].() vuelve a lanzar capas
    var keys = [\pulse, \bass, \wash, \mix, \master];
    var oscProxy;

    keys.do({ |key|
        var proxy = p.at(key);
        if(proxy.isKindOf(NodeProxy)) {
            proxy.play(quant: 1);
        };
    });

    oscProxy = p.at(\osc_ctrl);
    if(oscProxy.isKindOf(NodeProxy)) {
        oscProxy.play(quant: 1);
    };

    "[LiveTemplate] Capas reactivadas.".postln;
};

topEnvironment[\stopAll] = { // topEnvironment[\stopAll].() detiene todo
    [\pulse, \bass, \wash, \mix, \master].do({ |key|
        var proxy = p.at(key);
        proxy.tryPerform(\stop);
    });
    "[LiveTemplate] Capas detenidas.".postln;
};

topEnvironment[\fadeOut] = { // topEnvironment[\fadeOut].() aplica fade y escena 3
    ~master.tryPerform(\set, \mix, 0.05);
    topEnvironment[\scene].(3);
};


////////////////////////////////////////////////////////
// 7. LIMPIEZA RÁPIDA
////////////////////////////////////////////////////////
topEnvironment[\cleanup] = { // topEnvironment[\cleanup].() resetea OSC + capas
    topEnvironment[\stopAll].();
    p[\osc_ctrl].tryPerform(\stop);
    OSCdef(\liveTextBridge).free;
    ~master.tryPerform(\stop);
    topEnvironment.removeAt(\hydraAddr);
    "[LiveTemplate] Limpieza completa.".postln;
};

// EJEMPLO DE SECUENCIA FINAL
// topEnvironment[\scene].(1);
// topEnvironment[\fadeOut].();
// topEnvironment[\cleanup].();
