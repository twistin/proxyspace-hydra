




//////////// Pbind ritmicos ////////////


///////////////////////////////
///   1   -- 240 Plucks --
///////////////////////////////


b = Bus.audio(s,1);
( // start reverb at the end of the group
~reverb = Synth("reverbBus", [\inBus, b, \wet, 0.6]);

Pbind(
	\instrument, "plucking",
	\out, b,
	\scale, Scale.major.tuning_(\just),
	\octave, 4,
	\degree, Pseq([1,3,7,8,Prand([7,10,11,13,14]),8,7,3], inf),
	\dur, Pseq([Pwrand([
		Pseq([0.2,0.2]),
		//0.2,
		0.4,
		Pseq([0.1],4),
		Pseq([0.05],4)],
		[0.5,0.3,0.1,0.1] // weights
	)], 240),
	\coef, Pwrand([0.8, 0.6, 0.4, 0.2], [0.4,0.3,0.2,0.1], inf),
	\amp, 1,
	\addAction, 0, // make sure new synths are added to head of group (optional)
).play;
)

// set reverb 'wetness'
~reverb.set(\wet,1);

( // set tempo
var bpm = 50;
t = TempoClock.default;
t.tempo_(bpm/60) // beats per minute
)



///////////////////////////
/////// 2   -- Risset rhythm --
//////////////////////////

b = Buffer.readChannel(s,  "/Users/sdcarr/Documents/GitHub/My-setup-sc-live-coding/samples/set1/breaks175/bpm.wav", channels:1);
b.free;
b.play
// amount of time it takes for the audio to speed up or slow down 2x
// the rhythm repeats seamlessly every megabar
var megabardur = 20.0;
Pbind(
    \instrument, \risset,
    \buf, b,
    \megabardur, megabardur,
    \dur, megabardur,
    \bufdur, b.duration,
    \level, (0..5),
    \bandwidth, 0.8, // adjust this if the illusion isn't very convincing
    \centerrate, 1.0,
    \dir, 1 // 1 for accel, -1 for decel
).play;


///////////////////
////// 3        HOME
/////////////////////



(
b = Buffer.readChannel(server: s, path:"/Users/sdcarr/Documents/GitHub/My-setup-sc-live-coding/samples/set1/tabla/looperman-l-0672759-0135386-indian-tabla-68-another-pattern.wav" , channels: [0]);
c = Buffer.readChannel(server: s, path:"/Users/sdcarr/Documents/GitHub/My-setup-sc-live-coding/samples/set1/tabla/Lage Raho Munna Bhai - Good Morning Mumbai.mp3" , channels: [0]);
d = Buffer.readChannel(server: s, path:"/Users/sdcarr/Documents/GitHub/My-setup-sc-live-coding/samples/set1/tabla/looperman-l-0672759-0137303-tabla-pattern.wav" , channels: [0]);
e = Buffer.readChannel(server: s, path:"/Users/sdcarr/Documents/GitHub/My-setup-sc-live-coding/samples/set1/tabla/Female Sigh-SoundBible.com-675137452.wav" , channels: [0]);
)



////////////////
///  PBINDS  ///
/////////////////

(

~bass = Pbind(
	\instrument, "fm2_a",
	\midinote, Pseq([
		[39, 46],
		[34, 41],
		[36, 43],
		[32, 39],
		[39, 46],
		[34, 41],
		[36, 43],
		[32, 39],
		39,
		46,
		34,
		41,
		36,
		43,
		32,
		39,
		39,
		46,
		34
	], 1),
	\dur, Pseq([
		Pn(Pseq([1.5, 2, 2, 2]), 2),
		Pn(2, 26)] * 1.5),
	\ctranspose, 12,
	\att, 0.01,
	\rel, 0.01,
	\amp, 0.1
);

~chords = Pbind(
	\instrument, "chords2",
	\midinote,Pseq([
		Pn(Pseq([63, 63, 70, 67, 65]), 3),
		72, 67, 65, 63, 63, 68, 68, 68,
		Pn(Pseq([63, 63, 70, 67, 65]), 2),
		72, 67, 65, 63, 63, 68, 68, 68,
		Pn(70, 4),
		67,
		Pn(70, 4),
		75, 74, 72,
		Pn(67, 5),
		Pn(68, 5),
		Pn(67, 2),
		Pn(75, 5),
		Pn(74, 5),
		72,
		Pn(67, 5),
		Pn(68, 5),
		67, 70, 63, 62,
		Pn(67, 2),
		70,
		62, 60,
		Pn(67, 5),
		Pn(68, 5),
		Pn(67, 4),
		70, 63, 62,
		Pn(67, 2), 70, 62, 60,
		Pn(67, 5),
		Pn(68, 5),
		Pn(63, 2)
	]),
	\dur, Pseq([
		Pn(Pseq([0.5, 0.5, 2, 1, 0.5]), 3),
		1.5, 1.5, Pn(0.5, 3), Pn(1, 3),
		Pn(Pseq([0.5, 0.5, 2, 1, 0.5]), 2),
		1.5, 1.5, Pn(0.5, 3), Pn(1, 3),
		Pn(1/2, 3), 1,
		1/2,
		1,
		Pn(1/2, 3),
		Pn(1/2, 2), 1,
		Pn(1/2, 3), Pn(1, 2),
		1, Pn(1/2, 3), 1,
		Pn(1, 2),
		Pn(1/2, 3), Pn(1, 2),
		1, Pn(1/2, 3), Pn(1, 2),
		1,
		Pn(1/2, 3), Pn(1, 2),
		Pn(1/2, 3), Pn(1, 2),
		Pn(1/2, 3), 1,
		Pn(1/2, 1),
		1,
		1/2, 1,
		Pn(1/2, 3), Pn(1, 2),
		1, Pn(1/2, 3), 1,
		1, 2, Pn(1/2, 2),
		Pn(1/2, 2), 2,
		Pn(1/2, 5),
		Pn(1/2, 3), Pn(1, 2),
		1, Pn(1/2, 4),
		1/2, 4
		] * 0.6),
	\ctranspose, 12,
	\att, 0.01,
	\rel, 0.1,
	\amp, 0.3
);

~snare = Pbind(
	\instrument, "snare",
	\dur, Pseq([Rest(1), 1/2, Rest(1.7), 1/2], 7),
	\att, 0.01,
	\rel, 0.1,
	\sinfreq, 180,
	\ffreq, 3000,
	\amp, 0.2
);

~kick = Pbind(
	\instrument, "kick",
	\dur, Pseq([1/2, 1/2, Rest(1/2), 1, 1/2, Rest(0.7)], 7),
	\att, 0.01,
	\rel, 0.22,
	\sinfreq, 120,
	\glissf, 0.5,
	\amp, 0.6,
);

~tabla1 = Pbind(
	\instrument, "grain-asr",
	\buffer, b,
	\startPos, 0,
	\dur, 4,
	\rate, Pn(1, 1),
	\amp, 0.7,
);

~tabla2 = Pbind(
	\instrument, "grain-asr",
	\buffer, d,
	\startPos, 0,
	\dur, 3.5,
	\rate, Pn(1, 1),
	\amp, 0.7,
);

~radio = Pbind(
	\instrument, "grain-asr",
	\buffer, c,
	\startPos, 0,
	\dur, 6,
	\rate, Pn(1, 1),
	\amp, 0.1,
);


~temple = Pbind(
	\instrument, "grain-asr",
	\buffer, b,
	\startPos, Pwhite(0.10, 0.15),
	\dur, 1/2,
	\att, 0.31,
	\rel, 0.5,
	\rate, Pseq([1, 5, 3, 3.3], 3),
	\amp, Pwhite(0.02, 0.95),
	\pan, Pwhite(-1.0, 1.0),
	\legato, Pn(Pgeom(0.1, 1.05, 40))
);

~alarm1 = Pbind(
    \instrument, "am1_b",
	\freq, Pwhite(700, 705),
	\dur, Pseq([Pn(0.1, 5), 0.2], 4),
    \amp, Pwhite(0.15, 0.2) * 0.2,
    \att, 0.01,
    \rel, 0.1,
	\modfreq, Pwhite(10, 30),
	\pos, 0
);

~alarm2 = Pbind(
    \instrument, "am1_a",
	\freq, Pwhite(700, 705),
	\dur, Pseq([Pn(0.12, 5), 0.2], 4),
    \amp, Pwhite(0.15, 0.2),
    \att, 0.01,
    \rel, 0.1,
	\modfreq, Pwhite(10, 30),
	\pos, 0
);

~snooze = Pbind(
	\instrument, "snare",
	\dur, Pn(1, 1),
	\att, 0.01,
	\rel, 0.1,
	\sinfreq, 80,
	\ffreq, 100,
	\amp, 0.2
);

~waves = Pbind(
	\instrument, "waves",
	\dur, Pn(12, 1),
	\amp, 0.4
);

~sigh = Pbind(
	\instrument, "grain-asr",
	\buffer, e,
	\startPos, 0.1,
	\dur, 3,
	\rate, Pn(1, 1),
	\amp, 0.1,
);
)

/////////////////
/// SEQUENCE ///
/////////////////
(
t = TempoClock(60/60);
s = TempoClock(94/60);
{
	~alarm1.play(t);
	3.5.wait(t);
	~snooze.play(t);
	1.wait(t);
	~temple.play(t);
	6.wait(t);
	~waves.play(t);
	8.wait(t);
	~radio.play(t);
	4.wait(t);
	~chords.play(t);
	1.25.wait(t);
	~bass.play(t);
	6.wait(t);
	~snare.play(s);
	~kick.play(s);
	17.5.wait(t);
	~tabla1.play(t);
	4.wait(t);
	~tabla2.play(t);
	4.wait(t);
	~tabla2.play(t);
	4.wait(t);
	~tabla2.play(t);
	4.wait(t);
	~tabla1.play(t);
	 3.wait(t);
	~tabla1.play(t);
	3.wait(t);
	~tabla1.play(t);
	4.wait(t);
	~tabla2.play(t);
	10.wait(t);
	~alarm2.play(t);
	4.wait(t);
	~snooze.play(t);
	1.wait(t);
	~sigh.play(t);
}.fork(t);
)

//////////////////////////////
/////// 4  ALGORITHMIC BEATS
//////////////////////////////


(Ndef(\delay, {
	var src = In.ar(2,2);
	var loc = LocalIn.ar(2)+src;
	loc = DelayC.ar(loc,1/~tp*2,LFNoise0.ar(~tp).range(0.125,1).round(0.25)/~tp);
	loc = FreqShift.ar(loc,LFNoise1.ar(3/~tp).range(-15,15));
	loc = loc+(loc ring4: WhiteNoise.ar(1*LFNoise1.ar(0.25)));

	LocalOut.ar(loc*0.5);
	Pan2.ar(loc,SinOsc.ar(2))
}).play

(
{
	var kick, snare, hihat, noise, fill1, rh1;
	fill1 = Pseq([Pseq([1],4),Pseq([0.125],8)],inf); // Fill used with a snare
	rh1 = Pwrand([0.5,1,0.25,0.125],[0.75,0.15,0.05,0.05],inf); // Different hihat rhythm
	~freq = 60; // Fundamental Frequency
	~bar = 1/~tp*16; //
	kick = Pbind(*[
		\instrument, \sin,
		freq: ~freq,
		lw: 0,
		index: 10,
		lpF: 20000,
		hpF: 40,
		mix: Pwhite(0.75,1),
		dur: 1/~tp,
		amp: 0.75,
		pan: 0,
		out: 0
	]);
	snare = Pbind(*[
		\instrument, \sin,
		freq: Pseq([\rest,~freq],inf),
		lw: 1.5,
		index: Pwhite(5000,7500),
		lpF: 15000,
		hpF: 100,
		mix: Pwhite(0.25,0.5),
		dur: 1/~tp,
		amp: 0.3,
		pan: 0,
		out: 0
	]);
	hihat = Pbind(*[
		\instrument, \sin,
		freq: ~freq,
		lw: 1.5,
		index: Pwhite(5000,15000),
		lpF: 17500,
		hpF: 500,
		mix: Pwhite(0,0.5),
		dur: 0.5/~tp,
		amp: 0.125,
		pan: Pwhite(-1.0,1.0),
		out: Pwrand([0,2],[0.95,0.05],inf)
	]);
	noise = Pbind(*[
		\instrument, \sin,
		freq: ~freq*4,
		lw: 1,
		index: Pwhite(150,300),
		lpF: 15000,
		hpF: 2500,
		mix: Pwhite(0,1),
		dur: 4/~tp,
		amp: 0.1,
		pan: 0,
		out: 2
	]);
	Pdef(\kick, kick).play; ~bar.wait;
	Pdef(\snare, snare).play; ~bar.wait;
	Pdef(\hihat, hihat).play; ~bar.wait;
	Pdef(\hihat2, hihat).play;
	Pbindef(\hihat2, \dur, 0.75/~tp); ~bar.wait;
	Pdef(\hihat3, hihat).play;
	Pbindef(\hihat3, \dur, 0.25/~tp, \amp, 0.125*Pseq([1,0.5],inf)); ~bar.wait;
	Pbindef(\snare, \dur, fill1/~tp, \freq, ~freq); ~bar.wait;
	Pbindef(\snare, \dur, 1/~tp);
	Pdef(\kick).pause; ~bar.wait;
	Pdef(\kick, kick).play;
	Pdef(\noise, noise).play;
	Pbindef(\hihat2, \dur, rh1/~tp, \freq, ~freq*4);

}.fork
)
)


//////////////////////////////
/////// 5
//////////////////////////////




