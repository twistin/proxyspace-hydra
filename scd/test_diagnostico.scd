// ========================================
// SCRIPT DE VERIFICACIÓN RÁPIDA
// ========================================
// Ejecuta cada bloque por separado para diagnosticar

// === TEST 1: Verificar servidor ===
(
"=== TEST 1: Estado del Servidor ===".postln;
"Server running: ".post; s.serverRunning.postln;
"Server address: ".post; s.addr.postln;
"\n".postln;
)

// === TEST 2: Verificar proxies ===
(
"=== TEST 2: Estado de Proxies ===".postln;
"~a1 isPlaying: ".post; ~a1.isPlaying.postln;
"~osc_ctrl isPlaying: ".post; ~osc_ctrl.isPlaying.postln;
"~mix isPlaying: ".post; ~mix.isPlaying.postln;
"~verb isPlaying: ".post; ~verb.isPlaying.postln;
"\n".postln;
)

// === TEST 3: Verificar NetAddr ===
(
"=== TEST 3: Dirección OSC ===".postln;
"hydraAddr: ".post; topEnvironment[\hydraAddr].postln;
if(topEnvironment[\hydraAddr].isNil) {
	"⚠️ PROBLEMA: hydraAddr es nil!".postln;
	"Creando nueva dirección...".postln;
	topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57121);
	"✓ Dirección creada: ".post; topEnvironment[\hydraAddr].postln;
};
"\n".postln;
)

// === TEST 4: Enviar mensaje de prueba ===
(
"=== TEST 4: Envío de mensaje de prueba ===".postln;
topEnvironment[\hydraAddr].sendMsg("/sc/rhythm", 0.5);
topEnvironment[\hydraAddr].sendMsg("/sc/bass", 0.6);
topEnvironment[\hydraAddr].sendMsg("/sc/high", 0.7);
"✓ Mensajes de prueba enviados (rhythm=0.5, bass=0.6, high=0.7)".postln;
"Verifica en el navegador si los valores cambiaron.".postln;
"\n".postln;
)

// === TEST 5: Verificar audio ===
(
"=== TEST 5: Verificación de Audio ===".postln;
"Abriendo medidores de nivel...".postln;
s.meter;
"¿Ves actividad en los medidores?".postln;
"Si NO: El audio no está corriendo".postln;
"Si SÍ: El audio está corriendo pero tal vez muy bajo".postln;
"\n".postln;
)

// === TEST 6: Reiniciar patrón de audio ===
(
"=== TEST 6: Reiniciando patrón de audio ===".postln;
~a1.stop;
"Patrón detenido...".postln;
1.wait;
~a1.resume;
"✓ Patrón reiniciado".postln;
"Deberías escuchar kick drums periódicos".postln;
"\n".postln;
)

// === TEST 7: Secuencia de valores crecientes ===
(
"=== TEST 7: Enviando secuencia de prueba ===".postln;
"Enviando 10 valores crecientes a Hydra...".postln;
fork {
	10.do { |i|
		var val = i * 0.08 + 0.1;
		topEnvironment[\hydraAddr].sendMsg("/sc/rhythm", val);
		topEnvironment[\hydraAddr].sendMsg("/sc/bass", val * 0.9);
		topEnvironment[\hydraAddr].sendMsg("/sc/high", val * 1.1);
		("  Enviado " ++ i ++ ": rhythm=" ++ val.round(3)).postln;
		0.5.wait;
	};
	"\n✓ Secuencia completa. ¿Viste cambios en el navegador?".postln;
}
)

// === SOLUCIÓN RÁPIDA: Reiniciar todo ===
(
"=== REINICIO COMPLETO ===".postln;
"Deteniendo todos los proxies...".postln;
~a1.stop;
~osc_ctrl.stop;
~verb.stop;
~mix.stop;
1.wait;
"✓ Detenidos".postln;
"\nAhora vuelve a ejecutar sound2.scd desde el principio".postln;
"Luego ejecuta: ~a1.resume".postln;
)
