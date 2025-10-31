// =======================================================
// === 1. SETUP GLOBAL Y PROXYSPACE (CRÍTICO) ============
// =======================================================

// 1. Configuración del Reloj
t = TempoClock(90/60).permanent_(true);

// 2. Configuración de la Dirección de Red (OBJETO CRÍTICO)
// Al definirlo AQUÍ, aseguramos que la dirección se mantenga accesible.
(
topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57121);
"Destino OSC configurado en 127.0.0.1:57121".postln;

CmdPeriod.doOnce({
	OSCdef(\sendRhythm).tryPerform(\free);
	topEnvironment.removeAt(\hydraAddr);
});
)

/// PROXY ///
// Se inicia ProxySpace después de definir ~netAddr globalmente.
p = ProxySpace(
	server:s.boot,
	clock: t
).push;


// =======================================================
// === 2. DEFINICIÓN DE AUDIO Y PATRONES =================
// =======================================================

//// BUFFER ///
e = ();
e.buf=();
e.buf.path = PathName(thisProcess.nowExecutingPath).parentPath ++ "../samples/set1/glitch4/";
PathName(e.buf.path).entries.collect({
	arg n,i;
	e.buf[i] = Buffer.read(s,n.fullPath);
})


////////
// Definición del Synth Percusivo (~a)
~a.clear;

~a.play; ~a.awake_(false);
~a = {Splay.ar(SinOscFB.ar(\freq.ir(80)*[1,1.5],\fb.ir(2),\amp.ir(0.5)),\sp.ir(1),) * Env.perc(\atk.ir(0.05),\rel.ir(0.05),1,\cur.ir(-7) ).ar(2)}

// Definición del Patrón Rítmico (~a1)
~a1.clear;
~a1.pause;
// La ejecución real se hace al final con ~a1.resume;


~a1 = Tdef(\a1, {
	loop{
		~a.spawn([\freq, [80,90,100].choose, \fb, 1, \sp, [0,1].choose, \atk, 0.05, \rel,0.09,\amp, 0.3]);
	0.25.wait;
		~a.spawn([\freq, [100,200,200].choose, \fb, 0.5, \sp, [0,1].choose, \atk, 0.05, \rel,0.09, \amp, 0.3]);
	0.25.wait;
		~a.spawn([\freq, [200,300,400].choose, \fb, 0.5, \sp, [0,1].choose, \atk, 0.05, \rel,0.09,\amp, 0.3]);
	0.25.wait;
	};
});

// Conexión de la Señal al Mix Bus
~mix = {~a}; // Conecta el sonido percusivo (~a) al bus ~mix


// Definición y Ejecución de la Reverb (~verb)
(
~mix.ar; // Aseguramos que ~mix esté corriendo
~verb = {
	XFade2.ar(
		LPF.ar(
			GVerb.ar(
				~mix.ar(1), 80,8, maxroomsize:1000),
			8500
		),
		~mix, \pan.kr(0,0.5),\rel.kr(0.15)
	)
};
~verb.play; // Ejecutamos la reverb para que su señal exista
)


// =======================================================
// === 3. INTEGRACIÓN Y CONTROL OSC ======================
// =======================================================

// 1. DEFINICIÓN DEL PROXY DE CONTROL (~osc_ctrl)
~osc_ctrl = {
    var ampMeas, ctrlValue;

    // Mide la Amplitud (RMS) de la salida final ~verb.
    ampMeas = Amplitude.kr(~verb.ar, 0.0, 0.01);

    // Suavizado (Lag) y Mapeo (0.0 a 0.2 -> 0.1 a 0.9 para Hydra)
    ctrlValue = Lag.kr(ampMeas, 0.2);
    ctrlValue = ctrlValue.linlin(0.0, 0.2, 0.1, 0.9).clip(0.1, 0.9);

    // Envío OSC: Envía un trigger 10 veces por segundo.
    SendTrig.kr(Impulse.kr(10), 0, ctrlValue);

    Silent.ar; // Proxy solo de control, no de audio.
};

// 2. EJECUCIÓN DEL PROXY DE CONTROL
~osc_ctrl.play;

// 3. FUNCIÓN DE ENVÍO OSC (OSCdef)
OSCdef(\sendRhythm, { |msg|
	var value = msg[3], addr;

    // CORRECCIÓN CLAVE: PUERTO 57121
	addr = topEnvironment[\hydraAddr];
	if(addr.isNil) {
		addr = NetAddr("127.0.0.1", 57121);
		topEnvironment[\hydraAddr] = addr;
	};
	addr.sendMsg("/sc/rhythm", value);

    // *** LÍNEA COMENTADA: Ya no inundaremos la consola con mensajes de "0.0" ***
    // ("OSC OUT: /sc/rhythm " + value.round(4)).postln;

}, '/tr', nil);

"Conexión OSC de Ritmo corregida y activa. Ejecute ~a1.resume para empezar a enviar datos.".postln;

// =======================================================
// === 4. INICIO =========================================
// =======================================================

// Esta línea inicia el patrón rítmico.
~a1.resume;
~a1.pause;

// --- FIN SECCIÓN DE CONEXIÓN OSC ---
