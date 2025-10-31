// =======================================================
// === TEST DE EFECTOS LANDSCAPES (Erosión Sonora) ===
// =======================================================
(
var addr;
addr = topEnvironment[\hydraAddr] ?? { NetAddr("127.0.0.1", 57122) };
topEnvironment[\testAddr] = addr;
"✅ NetAddr configurado".postln;
)


// Test rápido de kick
topEnvironment[\testAddr].sendMsg("/kick");

// Test de erosión
topEnvironment[\testAddr].sendMsg("/bass_level", 0.6);

// Test de revelación
topEnvironment[\testAddr].sendMsg("/melody_note", 0.8);

// Test de ondulación
topEnvironment[\testAddr].sendMsg("/texture", 0.5);
// 1. Definir NetAddr FUERA del ProxySpace usando topEnvironment
// IMPORTANTE: No usar ~addr porque estamos en ProxySpace
(
var addr;
addr = topEnvironment[\hydraAddr] ?? { NetAddr("127.0.0.1", 57122) };
topEnvironment[\testAddr] = addr; // Guardar en topEnvironment
"✅ NetAddr configurado: ".post; addr.postln;
)

// 2. Cambiar a escena LANDSCAPES
topEnvironment[\testAddr].sendMsg("/scene", 0); // 0 = LANDSCAPES
"Cambiado a LANDSCAPES".postln;

// =======================================================
// === TESTS INDIVIDUALES ===
// =======================================================

// TEST 1: Kick (cambiar imagen + activar efectos)
(
topEnvironment[\testAddr].sendMsg("/kick");
"✅ KICK enviado - imagen debería cambiar".postln;1
)

// TEST 2: Bass Level (erosión + blur)
(
fork {
	10.do { |i|
		var val = i.linlin(0, 9, 0.0, 1.0);
		topEnvironment[\testAddr].sendMsg("/bass_level", val);
		("Bass: " ++ val.round(0.01)).postln;
		0.3.wait;
	};
	"✅ Bass test completado".postln;
};
)

// TEST 3: Melody Note (revelación + color)
(
fork {
	10.do { |i|
		var val = i.linlin(0, 9, 0.0, 1.0);
		topEnvironment[\testAddr].sendMsg("/melody_note", val);
		("Melody: " ++ val.round(0.01)).postln;
		0.3.wait;
	};
	"✅ Melody test completado".postln;
};
)

// TEST 4: Texture (wave displacement + feedback)
(
fork {
	10.do { |i|
		var val = i.linlin(0, 9, 0.0, 1.0);
		topEnvironment[\testAddr].sendMsg("/texture", val);
		("Texture: " ++ val.round(0.01)).postln;
		0.3.wait;
	};
	"✅ Texture test completado".postln;
};
)

// =======================================================
// === SECUENCIA COMPLETA DE PRUEBA ===
// =======================================================

(
fork {
	var addr = topEnvironment[\testAddr];
	"🎬 Iniciando secuencia de prueba LANDSCAPES".postln;

	// Paso 1: Imagen nítida (sin efectos)
	"1. Imagen nítida inicial (5 seg)".postln;
	5.wait;

	// Paso 2: Activar efectos con kick
	"2. KICK - activar efectos".postln;
	addr.sendMsg("/kick");
	2.wait;

	// Paso 3: Erosión progresiva (bass)
	"3. Erosión progresiva (bass 0 → 0.8)".postln;
	10.do { |i|
		var val = i.linlin(0, 9, 0.0, 0.8);
		addr.sendMsg("/bass_level", val);
		0.4.wait;
	};

	// Paso 4: Revelación + color (melody)
	"4. Revelación + color (melody 0.3 → 1.0)".postln;
	10.do { |i|
		var val = i.linlin(0, 9, 0.3, 1.0);
		addr.sendMsg("/melody_note", val);
		0.4.wait;
	};

	// Paso 5: Ondulación (texture)
	"5. Wave displacement (texture 0 → 0.7)".postln;
	10.do { |i|
		var val = i.linlin(0, 9, 0.0, 0.7);
		addr.sendMsg("/texture", val);
		0.4.wait;
	};

	// Paso 6: Combinar todo
	"6. Combinación (3 seg)".postln;
	addr.sendMsg("/bass_level", 0.6);
	addr.sendMsg("/melody_note", 0.8);
	addr.sendMsg("/texture", 0.5);
	3.wait;

	// Paso 7: Decay (dejar que se desvanezca)
	"7. Decay automático (5 seg)".postln;
	addr.sendMsg("/bass_level", 0.0);
	addr.sendMsg("/melody_note", 0.3);
	addr.sendMsg("/texture", 0.0);
	5.wait;

	"✅ Secuencia completa finalizada".postln;
};
)

// =======================================================
// === STOP DE EMERGENCIA ===
// =======================================================

// Detener todo y resetear valores
(
var addr = topEnvironment[\testAddr];
addr.sendMsg("/bass_level", 0.0);
addr.sendMsg("/melody_note", 0.5);
addr.sendMsg("/texture", 0.0);
"⛔ Reset enviado".postln;
)

// =======================================================
// === PATRONES CONTINUOS PARA LIVE CODING ===
// =======================================================

// Patrón 1: Erosión pulsante
(
var addr = topEnvironment[\testAddr];
Pdef(\erosionPulse,
	Pbind(
		\type, \osc,
		\addr, addr,
		\oscPath, "/bass_level",
		\val, Pseq([0.2, 0.6, 0.8, 0.4], inf),
		\dur, 4
	)
).play;
)

Pdef(\erosionPulse).stop;

// Patrón 2: Revelación cíclica
(
var addr = topEnvironment[\testAddr];
Pdef(\revealCycle,
	Pbind(
		\type, \osc,
		\addr, addr,
		\oscPath, "/melody_note",
		\val, Pwhite(0.3, 1.0),
		\dur, Pwhite(2, 6)
	)
).play;
)

Pdef(\revealCycle).stop;

// Patrón 3: Ondulación aleatoria
(
var addr = topEnvironment[\testAddr];
Pdef(\waveRandom,
	Pbind(
		\type, \osc,
		\addr, addr,
		\oscPath, "/texture",
		\val, Pwhite(0.0, 0.7),
		\dur, Pwhite(1, 4)
	)
).play;
)

Pdef(\waveRandom).stop;

// Patrón 4: Kicks periódicos
(
var addr = topEnvironment[\testAddr];
Pdef(\kickPattern,
	Pbind(
		\type, \osc,
		\addr, addr,
		\oscPath, "/kick",
		\dur, 8 // Cada 8 beats = cambio de imagen
	)
).play;
)

Pdef(\kickPattern).stop;

// DETENER TODOS LOS PATRONES
Pdef.all.do(_.stop);
