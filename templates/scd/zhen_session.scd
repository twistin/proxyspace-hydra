/*
SESIÓN "ZHEN" · ADAPTADA AL PIPELINE OSC ↔ HYDRA
-------------------------------------------------
Usa este archivo como punto de partida para ejecutar la pieza
"zhèn" dentro de ProxySpace y con envío de parámetros hacia Hydra.

Resumen de bloques:
 1. Boot + Tempo (TempoClock + recursos base)
 2. Opcional: carga de Setup externo
 3. Conexión OSC con el proxy (puerto 57121)
 4. Infrastructure de audio (buses, grupos, reverb)
 5. Patrones melódicos (Pdef) equivalentes a ~a .. ~e
 6. Control OSC (/sc/rhythm, /sc/bass, /sc/high, /sc/scene)
 7. Utilidades play/pause/resume/stop

Duplicar y personalizar según necesidad.
*/


// === 1. TEMPO Y RECURSOS BASE ===
(
var newClock;
~bpm = 90;
~clock = if(p.notNil and: { p.respondsTo(\clock) }, {
    p.clock;
}, {
    newClock = TempoClock(~bpm/60);
    newClock.permanent_(true);
    newClock;
});

~clock.tempo_(~bpm/60);

s.waitForBoot({
    Routine({
        ("[Zhen] Server online · Tempo: " ++ ~bpm ++ " BPM").postln;

        topEnvironment[\zhenOscCtrlSynth].tryPerform(\free);
        topEnvironment[\zhenMasterSynth].tryPerform(\free);
        topEnvironment[\zhenFxGroup].tryPerform(\free);
        topEnvironment[\zhenMainGroup].tryPerform(\free);
        topEnvironment[\zhenMixBus].tryPerform(\free);
        topEnvironment[\zhenFxBus].tryPerform(\free);

        topEnvironment[\zhenMainGroup] = Group.head(s);
        s.sync;
        topEnvironment[\zhenFxGroup] = Group.after(topEnvironment[\zhenMainGroup]);
        s.sync;
        topEnvironment[\zhenMixBus] = Bus.audio(s, 2);
        topEnvironment[\zhenFxBus] = Bus.audio(s, 2);
        s.sync;

        SynthDef(\zhenMaster, { |inBus, outBus = 0, mix = 0.35|
            var dry = In.ar(inBus, 2);
            var wet = LPF.ar(GVerb.ar(dry, 80, 8, 0.7, 0.5, 15, 0.5, 0.3, 0.35), 8500);
            Out.ar(outBus, XFade2.ar(dry, wet, mix.linlin(0, 1, -1, 1)));
        }).add;

        SynthDef(\zhenOscCtrl, { |inBus|
            var dry = In.ar(inBus, 2);
            var mono = Mix(dry);
            var rhythmEnv = Lag.kr(Amplitude.kr(mono, 0.01, 0.1), 0.15).linlin(0.0, 0.25, 0.1, 0.95).clip(0.1, 0.95);
            var bassEnv = Lag.kr(Amplitude.kr(LPF.ar(mono, 180), 0.01, 0.2), 0.2).linlin(0.0, 0.2, 0.1, 0.9).clip(0.1, 0.9);
            var highEnv = Lag.kr(Amplitude.kr(HPF.ar(mono, 3500), 0.01, 0.2), 0.12).linlin(0.0, 0.05, 0.05, 0.85).clip(0.05, 0.85);

            SendTrig.kr(Impulse.kr(12), 1, rhythmEnv);
            SendTrig.kr(Impulse.kr(8), 2, bassEnv);
            SendTrig.kr(Impulse.kr(16), 3, highEnv);
            Silent.ar;
        }).add;

        s.sync;

        topEnvironment[\zhenMasterSynth] = Synth.tail(topEnvironment[\zhenFxGroup], \zhenMaster, [
            \inBus, topEnvironment[\zhenMixBus],
            \outBus, 0,
            \mix, 0.35
        ]);
        s.sync;

        topEnvironment[\zhenOscCtrlSynth] = Synth.tail(topEnvironment[\zhenFxGroup], \zhenOscCtrl, [
            \inBus, topEnvironment[\zhenMixBus]
        ]);
        s.sync;

        "[Zhen] Grupos, buses y FX listos.".postln;
    }).play(AppClock);
});
)


// === 2. CARGA OPCIONAL DE SETUP ===
(
var setupRelative = "../Setup/Setup.scd";
var basePath = PathName(thisProcess.nowExecutingPath).parentPath;
var absoluteSetup = basePath ++ setupRelative;

if(File.exists(absoluteSetup)) {
    setupRelative.loadRelative;
    ("[Zhen] Setup cargado: " ++ absoluteSetup).postln;
} {
    "[Zhen] Setup opcional no encontrado; continúa sin él.".postln;
};
)


// === 3. OSC → HYDRA ===
(
var host = "127.0.0.1";
var port = 57121;

topEnvironment[\hydraAddr] = NetAddr(host, port);
("[Zhen] OSC hacia Hydra → " ++ host ++ ":" ++ port).postln;

CmdPeriod.doOnce({
    OSCdef(\zhenRouter).tryPerform(\free);
    topEnvironment[\zhenOscCtrlSynth].tryPerform(\free);
    topEnvironment[\zhenMasterSynth].tryPerform(\free);
    topEnvironment[\zhenFxGroup].tryPerform(\free);
    topEnvironment[\zhenMainGroup].tryPerform(\free);
    topEnvironment[\zhenMixBus].tryPerform(\free);
    topEnvironment[\zhenFxBus].tryPerform(\free);
    topEnvironment.removeAt(\hydraAddr);
    "[Zhen] CmdPeriod: recursos liberados.".postln;
});
)


// === 4. INFRAESTRUCTURA DE AUDIO ===
// Ya se crea dentro del bloque de arranque (sección 1).
~setVerbMix = { |mix = 0.35|
    topEnvironment[\zhenMasterSynth].tryPerform(\set, \mix, mix.clip(0.0, 1.0));
};


// === 5. PATRONES PRINCIPALES ===
(
~a = Pdef(\zhen_a,
    Pbind(
        \instrument, \FMRhodes1,
        \scale, Scale.majorPentatonic,
        \degree, Pseq([0, 3, 5, 7] + 2, inf),
        \dur, 0.25,
        \amp, 0.45,
        \group, Pfunc({ topEnvironment[\zhenMainGroup] ? 1 }),
        \out, Pfunc({ topEnvironment[\zhenMixBus] ? 0 })
    )
);

~b = Pdef(\zhen_b,
    Pbind(
        \instrument, \FMRhodes1,
        \scale, Scale.majorPentatonic,
        \degree, Pseq([0, 3, 5, 7], inf),
        \dur, 0.25,
        \amp, 0.45,
        \group, Pfunc({ topEnvironment[\zhenMainGroup] ? 1 }),
        \out, Pfunc({ topEnvironment[\zhenMixBus] ? 0 })
    )
);

~c = Pdef(\zhen_c,
    Pbind(
        \instrument, \FMRhodes1,
        \scale, Scale.majorPentatonic,
        \degree, Pseq([0, 3, 5, 7] - 5, inf),
        \dur, 0.25,
        \amp, 0.4,
        \group, Pfunc({ topEnvironment[\zhenMainGroup] ? 1 }),
        \out, Pfunc({ topEnvironment[\zhenMixBus] ? 0 })
    )
);

~d = Pdef(\zhen_d,
    Pbind(
        \instrument, \FMRhodes1,
        \scale, Scale.majorPentatonic,
        \degree, Pseq([0, 3, 5, 7, 10, 7, 5] - 10, inf),
        \dur, 0.5,
        \amp, 0.35,
        \group, Pfunc({ topEnvironment[\zhenMainGroup] ? 1 }),
        \out, Pfunc({ topEnvironment[\zhenMixBus] ? 0 })
    )
);

var rhythmDict = Prewrite(0.25,
    (
        0.25: #[0.25, 0.25, 0.25, 0.5],
        0.5: #[0.25, 0.5, 0.125, 0.125, 0.125, 0.125],
        0.125: #[0.375, 0.125],
        0.375: #[0.375, 0.375],
        1: #[1, 0.25]
    ),
    10
);

~e = Pdef(\zhen_e,
    Pbind(
        \instrument, \FMRhodes1,
        \scale, Scale.majorPentatonic,
        \degree, Pseq([0, 3, 5, 7], inf),
        \dur, rhythmDict,
        \amp, 0.3,
        \group, Pfunc({ topEnvironment[\zhenMainGroup] ? 1 }),
        \out, Pfunc({ topEnvironment[\zhenMixBus] ? 0 })
    )
);
)


(
OSCdef(\zhenRouter, { |msg|
    var id = msg[2];
    var value = msg[3];
    var addr = topEnvironment[\hydraAddr];
    var routes = [nil, "/sc/rhythm", "/sc/bass", "/sc/high", "/sc/scene"];

    if(addr.isNil) {
        addr = NetAddr("127.0.0.1", 57121);
        topEnvironment[\hydraAddr] = addr;
    };

    if(routes[id].notNil) {
        addr.sendMsg(routes[id], value);
    };
}, '/tr', s.addr);
)


// Helper para cambiar escena visual desde SC
~scene = { |index=0|
    var addr = topEnvironment[\hydraAddr];
    addr.tryPerform(\sendMsg, "/sc/scene", index);
};


// === 7. PLAY/PAUSE/RESUME/STOP ===
~zhenVoices = [~a, ~b, ~c, ~d, ~e];

~playAll = {
    ~zhenVoices.do({ |p| p.play(~clock, quant: 1); });
    "[Zhen] Voces iniciadas.".postln;
};

~pauseAll = {
    ~zhenVoices.do({ |p| p.pause; });
    "[Zhen] Voces en pausa.".postln;
};

~resumeAll = {
    ~zhenVoices.do({ |p| p.resume; });
    "[Zhen] Voces reanudadas.".postln;
};

~stopAll = {
    ~zhenVoices.do({ |p| p.stop; });
    "[Zhen] Voces detenidas.".postln;
};


// === 8. SECUENCIA DE CIERRE (INSPIRADA EN ~off ORIGINAL) ===
~off = Tdef(\zhen_off, {
    ~a.stop;
    6.wait;
    ~b.stop;
    5.wait;
    ~c.stop;
    4.wait;
    ~d.stop;
    10.wait;
    ~e.stop;
    10.wait;
    ~scene.(0);
    "[Zhen] Secuencia de apagado completada.".postln;
});


// === 9. LIMPIEZA MANUAL ===
(
~cleanup = {
    ~stopAll.();
    /*
    Esta plantilla fue reemplazada por `templates/scd/base_template.scd`.
    Conservamos el archivo vaciado para evitar referencias rotas.
    */
    topEnvironment[\zhenMainGroup].tryPerform(\free);
