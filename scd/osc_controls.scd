// =======================================================
// === CONTROLES OSC PARA ESCENAS DE openFrameworks ===
// =======================================================

// Configurar destino (debe estar corriendo osc_ws_proxy.js)
n = NetAddr("127.0.0.1", 57122);

// ====================================
// === ESCENA 1: LANDSCAPES (Ambient/Glitch) ===
// ====================================

// KICKS -> Cambiar imagen + glitch momentáneo
n.sendMsg("/kick");

// BASS -> Zoom sutil + brillo
n.sendMsg("/bass_level", 0.5);  // 0.0-1.0

// MELODY -> Tinte de color (azules/cianes para calma)
n.sendMsg("/melody_note", 0.7); // 0.0-1.0

// TEXTURE -> Control de glitch continuo
n.sendMsg("/texture", 0.3);     // 0.0-1.0 (cantidad de glitch)

// ====================================
// === ESCENA 2: DUALISMOS (Rítmico/Dinámico) ===
// ====================================

// KICKS -> Crear nuevas dualidades
n.sendMsg("/kick");

// BASS -> Brillo de fondo + tamaño de palabras
n.sendMsg("/bass_level", 0.8);  // 0.0-1.0

// MELODY -> Cambiar color de palabras
n.sendMsg("/melody_note", 0.4); // 0.0-1.0

// CONTRAST -> Velocidad de rotación (futuro)
n.sendMsg("/contrast", 0.5);    // 0.0-1.0

// ====================================
// === EJEMPLOS DE INTEGRACIÓN ===
// ====================================

// Ejemplo 1: LANDSCAPES - Ambient con glitches ocasionales
(
fork {
    var tempo = 2; // segundos entre cambios
    
    loop {
        // Kick cada cierto tiempo
        n.sendMsg("/kick");
        
        // Variar bass (zoom lento)
        n.sendMsg("/bass_level", 0.3.rrand(0.7));
        
        // Glitch aleatorio
        if(0.3.coin, {
            n.sendMsg("/texture", 0.4.rrand(0.8));
        }, {
            n.sendMsg("/texture", 0.0);
        });
        
        tempo.wait;
    };
};
)

// Ejemplo 2: DUALISMOS - Contraste rítmico
(
fork {
    var beat = 0.5; // 120 BPM
    
    loop {
        // Kick en cada beat
        n.sendMsg("/kick");
        
        // Bass variando (intensidad)
        n.sendMsg("/bass_level", [0.2, 0.5, 0.8, 1.0].choose);
        
        // Melodía aleatoria (colores)
        n.sendMsg("/melody_note", 0.0.rrand(1.0));
        
        beat.wait;
    };
};
)

// ====================================
// === ENVÍO DESDE PROXYS (Integrado) ===
// ====================================

// Para enviar desde tus propios proxys de audio:
// Agrega esto a ~osc_ctrl en sound2.scd:

/*
// ENVÍO DE /texture (nivel de ruido/textura)
~texture_level = {
    var sig = ~verb.ar(1);
    var noiseSig = HPF.ar(sig, 3000); // Detectar altas frecuencias (textura)
    var ampNoise = Amplitude.kr(noiseSig, 0.0, 0.1);
    var textureLevel = Lag.kr(ampNoise, 0.2).linlin(0.0, 0.1, 0.0, 1.0).clip(0.0, 1.0);
    SendTrig.kr(Impulse.kr(6), 4, textureLevel); // ID 4: /texture
    Silent.ar;
};
~texture_level.play;

// OSCdef para /texture
OSCdef(\sendTexture, { |msg|
    var value = msg[3];
    var addr = topEnvironment[\hydraAddr];
    addr.sendMsg("/texture", value);
}, '/tr', nil, argTemplate: [nil, 4]); // ID 4
*/

// ====================================
// === CAMBIO MANUAL DE ESCENA ===
// ====================================

// Presiona en openFrameworks:
// 1 -> LANDSCAPES
// 2 -> DUALISMOS

// Presiona en DUALISMOS:
// 3 -> Set de Platón (CUERPO/ALMA, etc)
// 4 -> Set Musical (RITMO/MELODÍA, etc)
// 5 -> Set de Textura (DENSO/DISPERSO, etc)

"✅ Controles OSC cargados".postln;
