/*
CÓDIGO SUPERCOLLIDER: DRONE + LFO (CONTROL DE RITMO PARA HYDRA)
--------------------------------------------------------------------
Este script envía el valor de una Onda de Baja Frecuencia (LFO)
directamente al proxy OSC en la ruta /sc/rhythm, garantizando que
el valor varíe para la modulación visual.

Instrucciones:
1. Arranca el proxy de Node.js (npm run proxy en /hydra).
2. Ejecuta la SECCIÓN 3 completa.
3. El valor en la consola fluctúa entre 0.2 y 0.7.
*/

// SECCIÓN 1: Arranque del Servidor
s.boot;


// SECCIÓN 2: Definición del Destino de Red (proxy)
// El proxy de Node.js escucha en este puerto.
(
topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57121);
"Destino OSC configurado en 127.0.0.1:57121".postln;

CmdPeriod.doOnce({
    ~drone.tryPerform(\free);
    OSCdef(\sendRhythm).tryPerform(\free);
    topEnvironment.removeAt(\hydraAddr);
});
)


// SECCIÓN 3: Sintetizador y Enlace OSC (VALOR GARANTIZADO)
// Ejecute este bloque. Verifique la fluctuación en la consola.
(
// Definición del sintetizador Drone
SynthDef(\drone, { |out=0, freq=55, gate=1|
    var osc, env, ampLFO, ctrlValue;

    // LFO (K-RATE): Crea una onda que pulsa lentamente.
    // Rango: 0.45 +/- 0.25 -> [0.2, 0.7]. Esta variación garantiza la modulación.
    ampLFO = SinOsc.kr(0.15, 0, 0.25, 0.45);

    // Envolvente de ataque/relajación
    env = EnvGen.kr(Env.adsr(0.1, 0.5, 0.6, 2), gate, doneAction: 2);

    // Oscilador de onda de sierra (sawtooth) modulado
    osc = LPF.ar(
        Saw.ar([freq, freq * 1.005], mul: 0.5)
        +
        SinOsc.ar(freq * 0.5, 0, 0.2),
        freq * 4
    );

    // Aplicar amplitud controlada por el LFO
    osc = osc * env * ampLFO;

    // ----------- ENVÍO OSC DIRECTO DEL LFO -----------

    // Enviamos el valor del LFO (ampLFO) directamente.
    // Usamos Lag para suavizar el valor enviado.
    ctrlValue = Lag.kr(ampLFO, 0.05);

    // Enviamos el LFO suavizado. La ruta OSC es /sc/rhythm
    SendTrig.kr(Impulse.kr(10), 0, ctrlValue);

    // Salida de audio
    Out.ar(out, Pan2.ar(osc, 0.0));
}).add;


// Creación de la instancia del sintetizador
~drone = Synth(\drone, [\freq, 110]);


// Función para enviar el valor OSC real
OSCdef(\sendRhythm, { |msg|
    var value = msg[3], addr;
    // Enviamos a la nueva ruta que el HTML espera
    addr = topEnvironment[\hydraAddr];
    if(addr.isNil) {
        addr = NetAddr("127.0.0.1", 57121);
        topEnvironment[\hydraAddr] = addr;
    };
    addr.sendMsg("/sc/rhythm", value);
    ("OSC OUT: /sc/rhythm " + value).postln;

}, '/tr', nil);

"Sintetizador 'drone' y enlace OSC de ritmo iniciados.".postln;
)

// SECCIÓN 4: DETENER EL PROCESO
(
~drone.free;
OSCdef(\sendRhythm).free;
"Proceso de audio y OSC detenido.".postln;
)
