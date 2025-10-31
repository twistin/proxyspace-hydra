// ═══════════════════════════════════════════════════════════════
// 🧪 TEST DE CONEXIÓN OSC
// ═══════════════════════════════════════════════════════════════

// 1. Verificar que hydraAddr existe
(
if(topEnvironment[\hydraAddr].notNil, {
    "✅ hydraAddr configurado: %".format(topEnvironment[\hydraAddr]).postln;
}, {
    "❌ ERROR: hydraAddr NO configurado".postln;
    "Ejecuta primero el bloque de setup de tu sesión".postln;
});
)

// 2. Test de envío manual
(
if(topEnvironment[\hydraAddr].notNil, {
    "📤 Enviando /kick...".postln;
    topEnvironment[\hydraAddr].sendMsg("/kick");
    "✅ Mensaje enviado".postln;
}, {
    "❌ No se puede enviar, hydraAddr no configurado".postln;
});
)

// 3. Test de envío múltiple (cada 2 segundos)
(
~testTask = Task({
    10.do({ arg i;
        "📤 Test %/10 - Enviando /kick".format(i+1).postln;
        topEnvironment[\hydraAddr].sendMsg("/kick");
        2.wait;
    });
    "✅ Test completado".postln;
}).play;
)

// Detener test
~testTask.stop;

// 4. Test de todos los mensajes
(
if(topEnvironment[\hydraAddr].notNil, {
    "📤 Enviando /kick".postln;
    topEnvironment[\hydraAddr].sendMsg("/kick");
    
    1.wait;
    "📤 Enviando /bass_level 0.5".postln;
    topEnvironment[\hydraAddr].sendMsg("/bass_level", 0.5);
    
    1.wait;
    "📤 Enviando /melody_note 0.7".postln;
    topEnvironment[\hydraAddr].sendMsg("/melody_note", 0.7);
    
    1.wait;
    "📤 Enviando /texture 0.3".postln;
    topEnvironment[\hydraAddr].sendMsg("/texture", 0.3);
    
    "✅ Todos los mensajes enviados".postln;
}.fork;
)

// 5. Monitorear mensajes salientes (debug)
OSCFunc.trace(true);  // Activar trace
OSCFunc.trace(false); // Desactivar trace
