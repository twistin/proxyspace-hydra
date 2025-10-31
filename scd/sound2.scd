// =======================================================
// === 1. SETUP GLOBAL Y CONFIGURACIÓN (PUERTO 57122) ===
// =======================================================

// 1. Configuración del Reloj
t = TempoClock(90/60).permanent_(true);

// 2. Definición del NetAddr para el Proxy (Puerto 57122 - Puerto libre)
(
topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57122);
"✅ Destino OSC configurado en 127.0.0.1:57122 (Proxy Node.js)".postln;

CmdPeriod.doOnce({
	OSCdef(\sendKick).tryPerform(\free);
	OSCdef(\sendBass).tryPerform(\free);
	OSCdef(\sendMelody).tryPerform(\free);
	topEnvironment.removeAt(\hydraAddr);
});
)

// Inicia el ProxySpace y el Servidor
p = ProxySpace(server:s.boot, clock: t).push;


// =======================================================
// === 2. DEFINICIÓN DE AUDIO Y PATRONES =================
// =======================================================

//// BUFFER (Mantener aquí tus buffers de audio si los usas)
e = ();
e.buf=();
e.buf.path = PathName(thisProcess.nowExecutingPath).parentPath ++ "/Users/sdcarr/Desktop/My-setup-sc-live-coding/samples/set1/set-sounds/";
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
~a1.clear(10);
~a1.pause;
~a1.resume;

~a1 = Tdef(\a1, {
	loop{
		~a.spawn([\freq, [80,90,100].choose, \fb, 1, \sp, [0,1].choose, \atk, 0.05, \rel,0.09,\amp, 0.3]);
	0.25.wait;
		~a.spawn([\freq, [100,200,300].choose, \fb, 0.5, \sp, [0,1].choose, \atk, 0.05, \rel,0.09, \amp, 0.3]);
	0.25.wait;
		~a.spawn([\freq, [200,300,400].choose, \fb, 0.5, \sp, [0,1].choose, \atk, 0.05, \rel,0.09,\amp, 0.3]);
	0.25.wait;
	};
});

// Conexión de la Señal al Mix Bus
~mix = {~sn +~h + ~t5 + ~r3 + ~a +~g3+  (~k.ar(2)?0)}; // Suma ~k si existe

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
~verb.play; // Ejecutamos la reverb
)


// =======================================================
// === 3. SISTEMA DE SINESTESIA OSC ======================
// =======================================================

// MENSAJES OSC COMPATIBLES CON openFrameworks:
// /kick          - Crea nuevo par de dualidades + trigger todas las palabras
// /bass_level    - Cambia color de fondo (0.0-1.0)
// /melody_note   - Cambia color de palabras aleatorias (nota MIDI o 0.0-1.0)

// 1. DEFINICIÓN DEL PROXY DE CONTROL (~osc_ctrl)
~osc_ctrl = {
	var verbSig = ~verb.ar(1),
		ampRMS, kickDetect,
		bassSig, ampBass, bassLevel,
		highSig, ampHigh, melodyValue;

	// --- 1. KICK DETECTOR (cada golpe fuerte) ---
	ampRMS = Amplitude.kr(verbSig, 0.0, 0.01);
	kickDetect = Trig.kr(ampRMS > 0.1, 0.5); // Umbral MÁS SENSIBLE (0.2→0.1)
	SendTrig.kr(kickDetect, 1, 1.0); // ID 1: /kick (envía 1.0 cuando hay kick)

	// --- 2. BASS LEVEL (nivel continuo de bajos) ---
	bassSig = LPF.ar(verbSig, 150); // Filtro: < 150Hz
	ampBass = Amplitude.kr(bassSig, 0.0, 0.05);
	bassLevel = Lag.kr(ampBass, 0.3); // Suavizado lento
	bassLevel = bassLevel.linlin(0.0, 0.2, 0.0, 1.0).clip(0.0, 1.0); // Normalizado 0-1
	SendTrig.kr(Impulse.kr(8), 2, bassLevel); // ID 2: /bass_level (8 veces/seg)

	// --- 3. MELODY NOTE (agudos mapeados a notas) ---
	highSig = HPF.ar(verbSig, 1000); // Filtro: > 1000Hz
	ampHigh = Amplitude.kr(highSig, 0.0, 0.01);
	melodyValue = Lag.kr(ampHigh, 0.05); // Suavizado rápido
	melodyValue = melodyValue.linlin(0.0, 0.1, 0.0, 1.0).clip(0.0, 1.0); // Normalizado 0-1
	SendTrig.kr(Impulse.kr(4), 3, melodyValue); // ID 3: /melody_note (4 veces/seg)

	Silent.ar; // Proxy solo de control, no de audio.
};

// 2. EJECUCIÓN DEL PROXY DE CONTROL
~osc_ctrl.play;

// 3. OSCdef PARA KICK
OSCdef(\sendKick, { |msg|
	var value = msg[3];
	var addr = topEnvironment[\hydraAddr];

	if(value > 0.5) { // Solo envía cuando hay un kick real
		addr.sendMsg("/kick");
		"🥁 KICK → openFrameworks".postln;
	};
}, '/tr', nil, argTemplate: [nil, 1]); // Filtra ID 1

// 4. OSCdef PARA BASS LEVEL
OSCdef(\sendBass, { |msg|
	var value = msg[3];
	var addr = topEnvironment[\hydraAddr];

	addr.sendMsg("/bass_level", value);
	// ("🔊 BASS: " ++ value.round(0.01)).postln; // Descomentar para debug
}, '/tr', nil, argTemplate: [nil, 2]); // Filtra ID 2

// 5. OSCdef PARA MELODY NOTE
OSCdef(\sendMelody, { |msg|
	var value = msg[3];
	var addr = topEnvironment[\hydraAddr];

	addr.sendMsg("/melody_note", value);
	// ("🎹 MELODY: " ++ value.round(0.01)).postln; // Descomentar para debug
}, '/tr', nil, argTemplate: [nil, 3]); // Filtra ID 3

"✅ Sistema de Sinestesia OSC activo".postln;
"   /kick → Crea dualidades de Platón".postln;
"   /bass_level → Controla fondo".postln;
"   /melody_note → Controla colores".postln;
"".postln;
"▶️  Ejecuta: ~a1.resume".postln;
// --- FIN SECCIÓN OSC ---

~sn.play

~k = Pbind(\instrument,\bplay,\buf,d["k"][0],\dur,1,\amp,1);
~sn = Pbind(\instrument,\bplay,\buf,d["s"][2],\dur,2,\amp,1);
~k.clear
~sn.play
~g3[0] = Pbind(
	\instrument, \bufsynth,
\buf, Pxrand(d["glitch4"], inf),
	\dur, 0.25,
	\rate, Pwhite(0.5,1.5,inf),
	\amp,1,
	\atk, 0.05,
	\sus, 0.04,
	\rel, 0.005
)

~g3[0].play
 ~t5.pl
1122

~g3.stop
~m3.play
~m3[0] = Pbind(

	\instrument, \plucking,
	\scale, Scale.gong.tuning_(just),
	\octave, 4,
	\degree, Pseq([ 0, 2, 4, 7, 9 ], inf), // four main notes
	\mtranspose, Pseq([Pseq([0],3),Pseq([-5],3)],inf), // switched mode every 3 notes (*2)

	\gtranspose, Pseq([Pseq([0],36),Pseq([4],36),Pseq([[-3]],36),Pseq([2],36)],inf),
	\ctranspose, Pser([Pseries(-4,1,6) +.x Pseq([0], 144)],1),

	\coef, Pser([Prand([0.2,0.3,0.4,0.5],1), Prand([0.8,0.7,0.6,0.5],11)], inf),
	\dur, Prand([0.25,0.26,0.24,0.255,0.255,0.25], inf) * 0.9,
	\decay, Prand([1,2,3,4,5], inf),
	\out, b,
    \amp, 1,
)


~h.play;
~h = Pbind(\instrument,\bplay,\buf,d["ch"][0],\dur,0.25,\amp,Pexprand(0.5,1));
~b6.clear(4)
~b6[0] =Pbind(
	\instrument, \subBass2,
	\scale, Scale.minorPentatonic,
	\degree, Prand([0, [3,11], 7, [5,13],  10 ],inf),
	\octave, [2,3,4],
	\dur, Pseq([0.25], inf),
	\amp, 0.09,
	\level, 1.5,
	\atk, 0,
	\sus, 0,
	\rel, 0.75,
	\curve,-6,
	\pan,Pwhite(-3,-3,inf)
)
~b6.stop

~r3[0] =Pbind(
		\instrument, \bufsynth,

       \buf, Pxrand(d["shout"],inf),
		\dur, 0.25,
		\rate, Pwhite(1.0,5.0,inf),
		\spos,0,
		\amp, 14.dbamp,
		\atk, 0.5,
		\sus, Pwhite(0.0,0.15),
		\rel, 0.1,
		\cur,1,
	\pan, Prand([-1,0, 1],inf)

	)


~r3.play
~strings.clear(4)
