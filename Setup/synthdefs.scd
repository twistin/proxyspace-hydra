



             //////// Biblioteca SynthDef ////////

                      ////// Drums //////////
                      ////// KICKS /////

// 808
(
SynthDef("kick808", {arg out = 0, freq1 = 240, freq2 = 60, amp = 1, ringTime = 10, att = 0.001, rel = 1, dist = 0.5, pan = 0;
	var snd, env;
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freq1, freq2, 0.1),
		decaytime: ringTime);
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "unknown",
	category: \drums,
	tags: [\percussion, \kick, \808]
)
).add;

SynthDef(\vplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, atk=0.0, sus=1, rel= 0, pos=0;
		var sig, env;
		sig = Pan2.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2),pan);
		env = EnvGen.ar(Env.linen(atk,sus,rel,1),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,sig);
}).add;


SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env ;
		sig = Mix.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,Pan2.ar(sig,pan));
}).add;

SynthDef(\ring1,
	{
		arg f = 45, a = 9, d = 0.6, pan = 0, amp = 1, out = 0;
		var sig, env;
		env = Line.kr(0,1,d);
		env = FreeSelfWhenDone.kr(env);
		sig = Impulse.ar(0);
		sig = Ringz.ar(sig,f,d,a);
		Out.ar(out,Pan2.ar(sig.tanh,pan) * amp)
	};
).add;
SynthDef(\ring2,
	{
		arg f = 9000, a = 2, d = 0.1, amp = 1, pan = 2, out = 0;
		var sig, env;
		env = Line.kr(0,1,d);
		env = FreeSelfWhenDone.kr(env);
		sig = Impulse.ar(0);
		sig = Ringz.ar(sig,f,d,a);
		Out.ar(out,Pan2.ar(sig.tanh,pan) * amp)
	};
).add;
SynthDef(\ring3,
	{
		arg f = 50, a = 3, d = 1, pan = 0, amp = 1, out = 0;
		var sig, env;
		env = Line.kr(0,1,d);
		env = FreeSelfWhenDone.kr(env);
		sig = Impulse.ar(0);
		sig = Ringz.ar(sig,f,d,a);
		Out.ar(out,Pan2.ar(sig.tanh,pan) * amp)
	};
).add;
SynthDef(\ring4,
	{
		arg f = 8000, a = 1, d = 0.3, pan = 0, amp = 1, out = 0;
		var sig, env;
		env = Line.kr(0,1,d);
		env = FreeSelfWhenDone.kr(env);
		sig = Impulse.ar(0);
		sig = Ringz.ar(sig,f,d,a);
		Out.ar(out,Pan2.ar(sig.tanh,pan) * amp)
	};
).add;

SynthDef("kickBlocks", {
	arg
	//Standard Values
	out = 0, pan = 2, amp = 0.4, curve = -4,
	//tone1 arguments
	t1freq = 400, t1harmonic = 2, t1glide = 0.01,
	t1att = 0.0005, t1rel = 0.01, t1curve = -4, t1del = 0, t1amp = 1,
	//tone2 arguments
	t2freq = 50, t2harmonic = 3.44, t2glide = 0.01,
	t2att = 0.0001, t2rel = 0.3, t2curve = \lin, t2del = 0.005, t2amp = 1,
	//hit1 arguments
	h1freq = 100, h1harmonic = 8, h1glide = 0.01, h1rq = 0.6,
	h1att = 0.001, h1rel = 0.02, h1curve = -4, h1del = 0.001, h1amp = 1,
	//hit2 arguments
	h2freq = 1320, h2harmonic = 1, h2glide = 0,
	h2att = 0.003, h2rel = 0.03, h2curve = -4, h2del = 0, h2amp = 0.5,
	//click arguments
	cfreq = 6100, crq = 1, camp = 1.41;

    var snd, noise, tone1, tone2, hit1, hit2, click;

	noise = Hasher.ar(Sweep.ar); //deterministic white noise

    tone1 = SinOsc.ar(
		freq: XLine.ar(start: t1freq * t1harmonic, end: t1freq, dur: t1glide),
		mul: Env.perc(attackTime: t1att, releaseTime: t1rel, level: t1amp, curve: t1curve).delay(t1del).ar);

	tone2 = SinOsc.ar(
		freq: XLine.ar(start: t2freq * t2harmonic, end: t2freq, dur: t2glide),
		mul: Env.perc(attackTime: t2att, releaseTime: t2rel, level: t2amp, curve: t2curve).delay(t2del).ar);

    hit1 = BPF.ar(
		in: noise,
		freq: XLine.ar(start: h1freq * h1harmonic, end: h1freq, dur: h1glide),
		rq: h1rq,
		mul: Env.perc(attackTime: h1att, releaseTime: h1rel, level: h1amp, curve: h1curve).delay(h1del).ar);

	hit2 = HPF.ar(
		in: noise,
		freq: XLine.ar(start: h2freq * h2harmonic, end: h2freq, dur: h2glide),
		mul: Env.perc(attackTime: h2att, releaseTime: h2rel, level: h2amp, curve: h2curve).delay(h2del).ar);

	click = BPF.ar(
		in: Impulse.ar(0) * SampleRate.ir / 48000,
		freq:  cfreq,
		rq: crq,
		mul: camp);

	snd = Mix.ar(tone1 + tone2 + hit1 + hit2 + click).tanh * amp;

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "originals by Nathan Ho aka snapizz",
	category: \drums,
	tags: [\bass]
	)
).add;

);



SynthDef("kick_oto309", {
	arg
	//Standard Values:
	out = 0, amp = 0.1, pan = 0, att = 0.005, rel = 0.29, curve = -4,
	//Other Controls:
	filterHarmonic = 1.5, preamp = 1.25, pulseAmp = 0.5, noiseAmp = 1, sineAmp = 1;

	var env, envp, snd;

	env = Env.new(levels: [0.5, 1, 0.5, 0], times: [att, rel * 0.2, rel * 0.9], curve: [curve, curve/2, curve]).kr(doneAction:2);
	envp = Env.new(levels: [110, 59, 29], times: [att, rel], curve: [curve, curve * 1.25]).kr.midicps;

	snd = LFPulse.ar(freq: envp).range(-1 * pulseAmp, pulseAmp);
	snd = snd + WhiteNoise.ar(mul: noiseAmp);
	snd = LPF.ar(in: snd, freq: envp * filterHarmonic, mul: env);
	snd = snd + SinOsc.ar(freq: envp, phase: 0.5, mul: env * sineAmp);

	snd = Mix.ar(snd) * preamp;
	snd = snd.clip2(1) * amp;

	Out.ar(out, Pan2.ar(snd));
},
metadata: (
	credit: "Originally from 08091500Acid309 by_otophilia",
	category: \drums,
	tags: [\kick, \drum, \percussion]
	)
).add;




////// SNARES //////////


SynthDef("oneclapThor", {
	arg
	//Standard Values
	out = 0, amp = 0.1, att = 0.003, rel = 0.00035, freq = 100, rq = 0.1, pan = 0,
	//Other Controls
	echohz1 = 33.333, echohz2 = 33.156, curve = -4, decay = 0.06, shelfFreq = 7000, rs = 0.5, db = -3,
	// Controls Ranging from 0 to 1
	size = 0.15, tone = 0.4, mix = 0.23, damp = 0.5;

	var env, snd, noise1, noise2, hpf1, hpf2, delay1, delay2;

	noise1 = GrayNoise.ar(1 - tone) + WhiteNoise.ar(tone);

	noise1 = noise1 + SinOsc.ar(freq: [freq / 2, freq / 2 + 4 ]);

	noise2 = PinkNoise.ar;

	noise2 = noise2 + SinOsc.ar(freq: [freq, (freq * 1.04)] * XLine.kr(start: 1, end: 0.01, dur: 3));

	hpf1 = RLPF.ar(in: noise1, freq: freq, rq: rq);

	hpf2 = RHPF.ar(in: noise1, freq: freq/2, rq: rq/4);

	env = Env.perc(attackTime: att, releaseTime: rel, curve: curve).kr;

	snd = Mix.ar(hpf1 + hpf2) * env;

	delay1 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz1, delaytime: 1/echohz1, decaytime: decay / 2);

	delay2 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz2, delaytime: 1/echohz2, decaytime: decay);

	snd = FreeVerb.ar(in: Mix.ar(delay1 + delay2), mix: mix, room: size, damp: damp, mul: amp);

	snd = BHiShelf.ar(in: snd, freq: shelfFreq, rs: rs, db: db);

	DetectSilence.ar(snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "original by thor",
	tags: [\clap, \handclap]
	)
).add;

// SNARE1

(
SynthDef("snare1", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var snd1 = WhiteNoise.ar(amp);
	var snd2 = SinOsc.ar(sinfreq,0,amp);
	var env = Env.perc(att, rel).kr(doneAction: 2);
	var mix = HPF.ar(snd1, ffreq) + snd2;
	mix = mix * env;
	Out.ar(out, Pan2.ar(mix, pan));
},
metadata: (
	credit: "Bruno Tucunduva Ruviaro",
	category: \drums,
	tags: [\percussion, \snare]
)
).add;

);


//snareElectro


SynthDef("snareElectro", {
    arg
	//Standard Values
	out = 0, pan = 0, amp = 0.4, att = 0.001, rel = 0.15, curve = -4,
	//Other Controls, blend ranges from 0 to 1
	popfreq = 160, sweep = 0.01, noisefreq = 810, rq = 1.6, blend = 0.41;

    var pop, popEnv, popSweep, noise, noiseEnv, snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popSweep = Env.new(levels: [20.4, 2.6, 1] * popfreq, times: [sweep / 2, sweep], curve: \exp).ar;

    popEnv = Env.perc(attackTime: att, releaseTime: 0.73 * rel, level: blend, curve: curve).kr;

	pop = SinOsc.ar(freq: popSweep, mul: popEnv);

    // bandpass-filtered white noise
    noiseEnv = Env.perc(attackTime: att, releaseTime: rel, level: 1 - blend, curve: curve).kr(doneAction: 2);

	noise = BPF.ar(in: WhiteNoise.ar, freq: noisefreq, rq: rq, mul: noiseEnv);

    snd = Mix.ar(pop + noise) * amp;

    Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Nathan Ho aka Snappizz",
	category: \organ,
	tags: [\pitched]
	)
).add;


////// TOMS //////////


// sosTom
SynthDef("sosTom", {
	arg out = 0, pan = 0, drumRel = 0.4, stickRel = 0.01, drumModeAmp = 0.25, freq = 250, timbreIndex = 0.77, amp = 1, att = 0.005, curve = -6;

	var drumMode, drumModeEnv, stick, stickEnv, snd;

	drumModeEnv = Env.perc(
		            attackTime: att,
		            releaseTime: drumRel,
		            level: 0.5,
		            curve: curve).kr(doneAction: 2);

	drumMode = PMOsc.ar(
		            carfreq: Saw.ar(freq: freq * 0.9),
					modfreq: freq * 0.85,
					pmindex: timbreIndex,
					mul: drumModeEnv * 10);

	drumMode = drumMode + SinOsc.ar(freq: [freq, freq * 0.8], mul: drumModeEnv);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	stick = Crackle.ar(chaosParam: 2.01);

	stickEnv = Env.perc(attackTime: att, releaseTime: stickRel, level: 3, curve: curve).kr;

	snd = Mix.ar(drumMode + stickEnv) * amp;

	snd = LeakDC.ar(snd);

    Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Renick Bell",
	category: \drums,
	tags: [\pitched, \tom, \sos]
	)
).add;



////// CLAPS ////////

//clapElectro




SynthDef("clapElectro", {
    arg
	//Standard Arguments
	out = 0, amp = 0.5, pan = 0, att = 0.02, rel = 0.2, curve = -4,
	//Other Controls: mix is 0 - 1, fadeTime is a fraction of noise1's length.
	mix = 0.6, fadeFreq = 4000, fadeTime = 0.52;

    var env1, env2, snd, noise1, noise2;

    // noise 1: four short repeats
    env1 = Env.new(
            levels: [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            times: [att / 20, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            curve: [0, curve, 0, curve, 0, curve, 0, curve]
        ).kr;

    noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(in: noise1, freq: 600);
    noise1 = LPF.ar(
		    in: noise1,
		    freq: XLine.kr(start: 7200, end: fadeFreq, dur: fadeTime * 0.058)
	    );
    noise1 = BPF.ar(in: noise1, freq: 1620, rq: 3);

    // noise 2: one longer single burst
	env2 = Env.perc(attackTime: att, releaseTime: rel, curve: [0, curve]).kr;

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(in: noise2, freq: 1000);
    noise2 = LPF.ar(in: noise2, freq: 7600);
    noise2 = BPF.ar(in: noise2, freq: 1230, rq: 0.7);

	//Mixing
	snd = Mix.ar((mix * noise1) + ((1 - mix) * noise2));
	snd = (snd * 2).softclip;
	snd = snd * amp;

	DetectSilence.ar(in: snd, doneAction: 2);

    Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Nathan Ho aka Snappizz, http://sccode.org/1-523",
	category: \drums,
	tags: [\unpitched, \clap, \electronic, \percussion]
	)
).add;


/// clapOto309




SynthDef("clapOto309", {
	arg out = 0, amp = 0.1, pan = 0;
	var env1, env2, snd, noise1, noise2;

	env1 = Env.new(
		levels: [0, 1, 0, 1, 0, 1, 0, 1, 0],
		times: [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03],
		curve: [0, -3, 0, -3, 0, -3, 0, -4]
	).ar;
	env2 = Env.new(
		levels: [0, 1, 0],
		times: [0.02, 0.3],
		curve: [0, -4]
	).ar(doneAction: 2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	snd = noise1 + noise2;
	snd = snd * 2;
	snd = snd.softclip * amp;

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "08091500Acid309 by otophilia",
	category: \drums,
	tags: [\clap, \percussion]
	)
).add;



////// CYMBALS ////////

//cymbalicMCLD




SynthDef(\cymbalicMCLD, {

	arg
	//Standard Values
	out = 0, pan = 0, amp = 0.5, att = 0.001, rel = 0.5, curve = -4,
	//Filter Frequencies
	lodriverMax = 20000, lodriverMin = 10, hidriverMax = 10001, hidriverMin = 1, hiAtt = 1, hiRel = 3, loAtt = 0.5, loRel = 5;

	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, snd, thwack, env;

	locutoffenv = Env.perc(attackTime: loAtt, releaseTime: loRel, level: (lodriverMax - lodriverMin), curve: curve).kr;

	lodriver = LPF.ar(WhiteNoise.ar(0.1), (locutoffenv + lodriverMin));

	hicutoffenv = Env.perc(attackTime: hiAtt, releaseTime: hiRel, level: (hidriverMax - hidriverMin), curve: curve).kr;

	hidriver = HPF.ar(WhiteNoise.ar(0.1), (hidriverMax - hicutoffenv));
	hidriver = hidriver * Env.perc(attackTime: hiAtt, releaseTime: 2/3 * hiRel, level: 0.25).kr;

	thwack = Env.perc(attackTime: att, releaseTime: att).kr;

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	freqs = {exprand(300, 20000)}.dup(100);

	env = Env.new(levels: [0, amp, amp, 0], times: [att, (loRel + hiRel), rel]).kr(doneAction: 2);

	snd = Ringz.ar(in: lodriver + hidriver + thwack, freq: freqs).mean;
	snd = Mix.ar([(snd * 1), (lodriver * 2), thwack]);
	snd = snd * env;
	snd = Limiter.ar(snd, amp);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Dan Stowell",
	category: \drums,
	tags: [\percussion, \cymbal, \gong, \inharmonic, \additive, \subtractive]
	)
).add;



// cymbal808



SynthDef(\cymbal808, {
	arg
	//Standard Values:
	out = 0, pan = 0, att = 0.002, dec = 0.25, rel = 0.05, amp = 0.1,
	//Other Controls:
	freqMultiplier = 4.09, decLevel = 0.4, reverb = 0.33, size = 0.5, damp = 0.5;

	var snda, sndb, snd, env, pulseEnv, freqs;

	freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];

	env = Env.new(
		levels: [0, 1, decLevel, 0],
		times: [att, dec, rel],
		curve: [0, -0.5, 0]
	).kr;

	pulseEnv = Env.new(
		levels: [1.0, 0.6],
		times: dec,
		curve: -0.5
	).kr;

	snd = Mix.ar(LFPulse.ar(freq: freqs * 4.09));

	snd = (BinaryOpUGen('==', snd, 6.0) * 0.6) + (BinaryOpUGen('==', snd, 2.0) * 0.2) + (BinaryOpUGen('==', snd, 1.0) * 0.9);

	snd = (snd * pulseEnv) + Mix.ar(LFPulse.ar(freq: freqs, width: 0.55, mul: 0.9));

	snd = RLPF.ar(in: snd, freq: 7000, rq: 0.6);
 	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 1200, rq: 1.5);

	snd = snd + FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp);
	snd = Mix.ar(snd);
	snd = snd * env * amp;

	DetectSilence.ar(in: snd, doneAction: 2);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Published on sc-users 2007-08-25 by Ryan Brown",
	category: \drums,
	tags: [\808, \hihat, \percussion, \cymbal, \unpitched]
	)
).add;


// hashercymbal



SynthDef("hashercymbal", {
    arg
	//Standard Values
	out = 0, pan = 0, amp = 0.1, att = 0.001, rel = 0.25, crv = -6,
    //Other controls
	timbre = 0, looprate = 10000, samplerate = 18500;

	var env, snd;

	// Envelope
	env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp,
		curve: crv).ar(doneAction: 2);

	// Generating a loop of the same scrambled values to use as a noise source
	snd = Impulse.ar(freq: looprate, mul: 2, add: -1);
	snd = Sweep.ar(snd) + timbre;
	snd = Hasher.ar(in: snd);

	// Aliasing the noise and filtering out low frequencies
	snd = Latch.ar(
		in: snd,
		trig: Impulse.ar(
			freq: samplerate.clip(20, SampleRate.ir/2),
			mul: 2,
			add: -1));
	snd = HPF.ar(
		in: snd,
		freq: [62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000],
		mul: [1/9, 2/9, 3/9, 4/9, 5/9, 6/9, 7/9, 8/9, 9/9]);

	// Output stuff
	snd = Mix.ar(snd) * env;
	snd = Limiter.ar(snd);

	Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Josh Mitchell",
	category: \drums,
	tags: [\unpitched, \cymbal, \noisy]
	)
).add;



////// HIHAT ///////

//hihat1

(
SynthDef("hihat1", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var snd = WhiteNoise.ar(amp);
	var env = Env.perc(att, rel).kr(doneAction: 2);
	snd = HPF.ar(snd * env, ffreq);
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Bruno Tucunduva Ruviaro",
	category: \drums,
	tags: [\percussion, \hihat]
)
).add;





// hihatElectro



SynthDef("hihatElectro", {
    arg out = 0, pan = 0, amp = 0.3, att = 0.001, rel = 0.3, curve = -8, filterFreq = 4010, rq = 0.56;

    var env, snd;

    // noise -> resonance -> exponential dec envelope
    env = Env.perc(attackTime: att, releaseTime: rel, curve: curve).kr(doneAction: 2);

	snd = ClipNoise.ar(amp);
	snd = BPF.ar(
		in: snd,
		freq: [1, 1.035] * filterFreq,
		rq: [0.27, 1] * rq,
		mul: [1.0, 0.6]
	);
	snd = Mix(snd) * env;

    Out.ar(out, Pan2.ar(snd, pan));

	},
metadata: (
	credit: "By Nathan Ho aka Snappizz",
	category: \drums,
	tags: [\clap, \percussion, \hihat]
	)
).add;




////// BASS ////////////

SynthDef(\bass, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	freq = SinOsc.ar(freq*\fmfreq.kr(1).lag(0.3)) * \fmrange.kr(0.5).lag(0.3) * LFNoise1.kr(1/7).range(0.9,1.1) + 1 * freq;
	sig = SinOsc.ar(freq.lag(0.1) * [1,8,2,4,1.002]);
	sig1 = LFPulse.ar(freq * [1,4,1.001,2 * LFNoise1.kr(1/10).range(0.999,1.001),1/2], mul:1.00);
	sig = sig + sig1;
	sig = sig.fold2(SinOsc.kr(1/13).range(0.9,1));
	sig = sig.wrap2(SinOsc.kr(1/14).range(0.9,1));
	sig = RLPF.ar(sig, \lpf.kr(500).lag(0.4) * LFNoise1.kr(1/9).range(0.9,1.1), \rq.kr(0.5));
	sig = HPF.ar(sig, \hpf.kr(40));
	sig = sig * EnvGen.ar(\iadsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),\igate.kr(1),doneAction:0);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:doneAction);
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;

//doubleBass




SynthDef("doubleBass", {
	arg
	// Standard Values
	out = 0, pan = 0, amp = 1.0, freq = 440, att = 0.01, rel = 1.0 , crv = -30, vel = 1.0,
	// Other Controls
	freqDev = 2, op1mul = 0.1, op2mul = 0.1, op3mul = 0.1, sprd = 0.5, subAmp = 0.1;

	var env, op1, op2, op3, op4, snd, sub;

	// Percussive Envelope
	env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		curve: crv
	).ar(doneAction: 2);

	// Overtones
	op1 = SinOsc.ar(
		freq: freq * 4,
		mul: vel / 2 + op1mul);

	op2 = SinOsc.ar(
		freq: freq * 3,
		phase: op1,
		mul: vel / 2 + op2mul);

	op3 = SinOsc.ar(
		freq: freq * 2,
		phase: op2,
		mul: vel / 2 + op3mul);

	// Fundamental Frequency
	op4 = SinOsc.ar(
		freq: freq + NRand(-1 * freqDev, freqDev, 3),
		phase: op3,
		mul: vel);

	// Delay Line with Multi-Channel Expansion
	snd = {
		DelayN.ar(
			in: op4,
			maxdelaytime: 0.06,
			delaytime: Rand(0.03, 0.06)
		)} !8;

	// High Pass Filter
	snd = LeakDC.ar(snd);

	// Stereo Spread
	snd = Splay.ar(
		inArray: snd,
		spread: sprd,
		level: 0.6,
		center: pan);

	// Add a sub
	sub = SinOsc.ar(
		freq: freq/2,
		mul: env * subAmp);
	sub = Pan2.ar(sub, pan);
	snd = snd + sub;

	//Ouput Stuff
	snd = snd * env;
	snd = snd * amp;
	snd = Limiter.ar(snd);
	Out.ar(out, snd);
},
metadata: (
	credit: "Matias Monteagudo",
	category: \bass,
	tags: [\pitched, \bass]
)
).add;



//ksBass



SynthDef("ksBass", {
    arg
	// Standard Values
	out = 0, pan = 0, freq = 100, amp = 1, rel = 1.5,
    // Parameters for the impulse shape
	impulseAtt = 0.5, impulseSus = 1, impulseDec = 0.5, impulseHold = 1,
	// Filter and compressor parameters, thresh goes from 0 to 1.
	filtermin = 250, filtermax = 5000, rq = 0.35, thresh = 0.4, ratio = 2.5;

	var total, exciter, snd;

	// Rescale impulse values for the frequency of the note
	total = (impulseAtt + impulseSus + impulseDec + impulseHold) * freq;

	// Initial impulse
	exciter = Env.new(
		levels: [0, 1, 1, 0, 0],
		times: [impulseAtt, impulseSus, impulseDec, impulseHold]/total).ar;

	// Delay line
	snd = CombN.ar(
		in: exciter,
		maxdelaytime: 0.06,
		delaytime: 1/freq,
		decaytime: rel);

	// LPF
	snd = RLPF.ar(
		in: snd,
		freq: LinExp.ar(Amplitude.ar(in: snd), 0, 1, filtermin, filtermax),
		rq: rq);

	// Compressor for fun
	snd = CompanderD.ar(
		in: snd,
		thresh: thresh,
		slopeBelow: 1,
		slopeAbove: 1/ratio);

	// Output stuff
	snd = Mix.ar(snd) * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

    Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Josh Mitchell",
	category: \bass,
	tags: [\pitched, \bass]
	)
).add;

// noQuarterBass




SynthDef("noQuarter", {
	arg
	// Standard Arguments
	out = 0, freq = 440, amp = 0.1, pan = 0, att = 0, rel = 1, curve = -4;

	var subfreq = freq / 2;

	// Envelopes
	var subenv = Env.perc(attackTime: att, releaseTime: rel, level: amp, curve: curve).kr(doneAction: 2);
	var env = Env.perc(att, rel/2, amp, curve).kr;

	// Component synthesis
	var pluck = Pluck.ar(
		in: PinkNoise.ar,
		trig: 1,
		maxdelaytime: 0.2,
		delaytime: subfreq.reciprocal
	) * subenv * 2;
	var tri = VarSaw.ar(freq) * env;
	var sin = SinOsc.ar(freq) * env;
	var sub = (SinOsc.ar([subfreq, subfreq - 2, subfreq + 2]).sum * subenv).tanh;
	var click = RLPF.ar(
		in: Impulse.ar(0),
		freq: [2000, 8000],
		rq: 1
	).sum * 1000;

	// Initial signal
	var snd = pluck + tri + sub + click;

	// Resonant LPFs
	snd = RLPF.ar(
		in: snd,
		freq: XLine.ar(freq * 100, freq * 10, 0.15)
	);
	snd = snd + (MoogFF.ar(in: snd, freq:  freq * 20, gain: 2.5) * 0.1);

	// EQ resulting signal
	snd = BPeakEQ.ar(snd, 400, 0.5, -9);
	snd = BPeakEQ.ar(snd, 2000, 0.5, 6);
	snd = BHiShelf.ar(snd, 8000, 1, 3);
	snd = BPeakEQ.ar(snd, 200, 1, 3);

	// Apply another envelope to dampen a bit more
	snd = snd * XLine.kr(1, 0.6, 0.1);

	// Tanh distortion / limiting
	snd = (snd * 1).tanh;

	// Another round of signal coloring, using another RLPF
	// and sine components
	snd = snd +
	RLPF.ar(
		in: snd,
		freq: XLine.ar(freq * 100, freq * 10, 0.15)
	) + sin + sub;

	// Another round of tanh distortion / limiting
	snd = (snd / 2.3).tanh;

	// Another resonant LPF
	snd = MoogFF.ar(
		in: snd,
		freq: XLine.ar(freq*150, freq*30, 0.1),
		gain:  0.1
	);

	snd = Pan2.ar(snd, pan);
	Out.ar(out, snd);
},
metadata: (
	credit: "by Eric Sluyter",
	category: \bass,
	tags: [\pitched, \bass, \karplus]
	)
).add;



// rubberBandBass



SynthDef(\rubberBand, {
	arg
	// Standard Values
	out = 0, amp = 1, freq = 75, pan = 0, att = 0, rel = 1,
	// Impulse arguments (onFraction goes from 0 to 1, coef from -1 to 1)
	bendMultiple = 0.25, bendTime = 0.075, impulseStartFreq = 800,
	impulseStopFreq = 120, onFraction = 1, coef = 0.125;

	var impulse, freqline, snd;

	// Stuff that gets sent into Pluck
	freqline = Line.ar(
		start: freq * bendMultiple,
		end: freq,
		dur: bendTime);

	impulse = SinOsc.ar(
		freq: Line.ar(
			start: impulseStartFreq,
			end: impulseStopFreq,
			dur: 1/freq * onFraction));

	// Pluck
    snd = Pluck.ar(
	    in: impulse,
	    trig: Impulse.ar(0),
	    maxdelaytime: 1/(freq * bendMultiple),
	    delaytime: 1/freqline,
	    decaytime: rel,
	    coef: coef,
		mul: amp);

	// Output Stuff
    DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Josh Mitchell",
	category: \bass,
	tags: [\pitched]
	)
).add;
//   plucking


SynthDef("plucking", {arg out = 0, amp = 0.1, freq = 440, decay = 5, coef = 0.1;
	var env, snd;
	env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
	snd = Pluck.ar(
		in: BrownNoise.ar(amp),
		trig: Impulse.kr(0),
		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: decay,
		coef: coef);
	snd = LeakDC.ar(snd).clip2;
	Out.ar(out, snd * env);
}).add;



// subBass2




SynthDef(\subBass2, {
    arg
	//Blend goes from 0 to 1
	out = 0, amp = 0.5, pan = 0, freq = 440, att = 0.001, rel = 1, curve = 8, blend = 0.5;

    var env, in, ina, synca, octa, inb, syncb, octb, octave, snd;

	//A slightly rounded percussive envelope
	env = Env.perc(att, rel, amp, [curve, -1 * curve]).kr(doneAction: 2);

	/*  Input wave +/- 90 degrees - To use SinOsc.ar, replace:
	        -"iphase:  0" with "phase: pi/2"
	        -"iphase:  1" with "phase: 0"
	        -"iphase: -1" with "phase: pi"   */
	in = LFPar.ar(freq: freq * 2, iphase: 0);
	ina = LFPar.ar(freq: freq * 2, iphase: 1);
	inb = LFPar.ar(freq: freq * 2, iphase: -1);

	//Two square waves exactly out of phase and an octave below the input wave
	synca = LFPulse.ar(freq: freq, iphase: 0);
	syncb = LFPulse.ar(freq: freq, iphase: 0.5);

	//This smoothly swaps between outputting the +90 degree wave and -90 degree wave
	octa = ina * synca;
	octb = inb * syncb;
	octave = Mix.ar([octa, octb]);

	//Mixer stage, volume adjustments, envelope, and output
	snd = Mix.ar([octave * blend, in * (blend - 1)]);
    snd = LeakDC.ar(snd);
	snd = Limiter.ar(in: snd, level: 1);
	snd = snd * env;


	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Josh Mitchell, 2019",
	category: \bass,
	tags: [\pitched, \sub]
	)
).add;

);


////// KEYBOARDS


// FMRhodes1




SynthDef(\FMRhodes1, {
    arg
    // standard meanings
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1, att = 0.001, rel = 1, lfoSpeed = 4.8, inputLevel = 0.2,
    // all of these range from 0 to 1
    modIndex = 0.2, mix = 0.2, lfoDepth = 0.1;

    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;

    env1 = Env.perc(att, rel * 1.25, inputLevel, curve: \lin).kr;
    env2 = Env.perc(att, rel, inputLevel, curve: \lin).kr;
    env3 = Env.perc(att, rel * 1.5, inputLevel, curve: \lin).kr;
    env4 = Env.perc(att, rel * 1.5, inputLevel, curve: \lin).kr;

    osc4 = SinOsc.ar(freq) * 6.7341546494171 * modIndex * env4;
    osc3 = SinOsc.ar(freq * 2, osc4) * env3;
    osc2 = SinOsc.ar(freq * 30) * 0.683729941 * env2;
    osc1 = SinOsc.ar(freq * 2, osc2) * env1;
    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
  	snd = snd * (SinOsc.ar(lfoSpeed).range((1 - lfoDepth), 1));

    snd = snd * Env.asr(0, 1, 0.1).kr(gate: gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
},
metadata: (
	credit: "Nathan Ho",
	category: \keyboards,
	tags: [\pitched, \piano, \fm]
)
).add;


// cs80leadMH



SynthDef("cs80leadMH", {
	arg
	//Standard Values
	freq = 440, amp = 0.5, gate = 1.0, pan = 0, out = 0,
	//Amplitude Controls
	att = 0.75, dec = 0.5, sus = 0.8, rel = 1.0,
	//Filter Controls
	fatt = 0.75, fdec = 0.5, fsus = 0.8, frel = 1.0, cutoff = 200,
	//Pitch Controls
	dtune = 0.002, vibspeed = 4, vibdepth = 0.015, ratio = 0.8, glide = 0.15;

	var env, fenv, vib, ffreq, snd;


	//Envelopes for amplitude and frequency:
	env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: 2);
	fenv = Env.adsr(fatt, fdec, fsus, frel, curve:2).kr(gate: gate);

	//Giving the input freq vibrato:
	vib = SinOsc.kr(vibspeed).range(1 / (1 + vibdepth), (1 + vibdepth));
	freq = Line.kr(start: freq * ratio, end: freq, dur: glide);
	freq = freq * vib;

	//See beatings.scd for help with dtune
	snd = Saw.ar([freq, freq * (1 + dtune)], mul: env * amp);
	snd = Mix.ar(snd);

	//Sending it through an LPF: (Keep ffreq below nyquist!!)
	ffreq = max(fenv * freq * 12, cutoff) + 100;
	snd = LPF.ar(snd, ffreq);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Mike Hairston",
	category: \keyboards,
	tags: [\lead, \modulation, \analog, \cs80, \vangelis, \bladerunner]
	)
).add;


// Harpsichord2


SynthDef(\harpsichord2, {
	arg
	//Standard Values
	out = 0, amp = 0.1, freq = 440, pan = 0, rel = 5,
	//Pluck arguments (blend goes from 0 to 1)
	trig = 1, coef = 0.1, blend = 0.6;

	var exciter, root, octave, snd;

        // You can use white noise here, but Pink is more realistic
	exciter = PinkNoise.ar(amp);

	// Fundamental
        root = Pluck.ar(
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 1/freq,
	        delaytime: 1/freq,
	        decaytime: rel,
	        coef: coef,
	        mul: blend
        );

	// Octave Above
	octave = Pluck.ar(
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 1/(2 * freq),
	        delaytime: 1/(2 * freq),
	        decaytime: rel,
	        coef: coef,
	        mul: (1 - blend)
        );

	// Output Stuff
	snd = Mix.ar(root + octave);
	snd = Limiter.ar(snd);

    DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Zé Craum",
	category: \keyboards,
	tags: [\pitched]
	)
).add;


/////////////// MISCELANIA

// Ping



SynthDef(\ping_mh,{

	arg freq = 440, amp = 0.2, dur = 1, att = 0.001, curve = -4, pan = 0, out = 0, rate = 4, depth = 0.03;

	var snd, lfo, env;

	lfo = LFNoise2.ar(rate).range(1 / (1 + depth), (1 + depth));

	env = Env.perc(attackTime: att, releaseTime: dur, level: amp, curve: curve).kr(doneAction:2);

	snd = SinOsc.ar(freq: [freq, freq * lfo], mul: env);

	Out.ar(out, Pan2.ar(snd, pan))
},
metadata: (
	credit: "Author Unknown",
	category: \misc,
	tags: [\percussive, \ping, \default, \simple, \stereo, \detuned, \tuned]
	)
).add;

// vintage synth


SynthDef(\vintageSine, {
	arg
	//Standard Definitions
	amp = 0.2, freq = 440, pan = 0, att = 0.001, sus = 1, rel = 0.5, gate = 1, out = 0,
	//Noise Arguments (mainsDepth is 0 to 1)
	noiseAmp = 0.06, mainsDepth = 0.1, mainsHz = 50,
	//Sine Arguments
	vrate = 2, vdepth = 0.005, sineClip = 0.825;

	var noise, env, snd, vibrato;

	env = Env.asr(att, amp, rel, curve: \lin).kr(gate: gate, doneAction: 2);

	noise = PinkNoise.ar(noiseAmp * LFPar.ar(mainsHz * 2).range((1 - mainsDepth), 1));
	noise = noise + LFPar.ar(freq: mainsHz, mul: noiseAmp/8);

	vibrato = freq * LFNoise2.ar(vrate).range(1/(1 + vdepth), (1 + vdepth));

	snd = Clip.ar(LFTri.ar(vibrato), -1 * sineClip, sineClip).softclip;
	snd = ((snd * amp) + noise) * env;
	Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Zé Craum; Josh Mitchell",
	category: \misc,
	tags: [\vintage, \pitched]
	)
).add;

// noysy


SynthDef("noisy", {arg out = 0, freq = 440, amp = 0.2, pan = 0.5;
	var snd, env;
	env = Env.perc(0.02, 0.1).kr(doneAction: 2);
	snd = Mix(LFPulse.ar(
		freq: freq * [1, 5/2],
		iphase: 0.0,
		width: 0.5,
		mul: amp));
	snd = snd * env ;
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

// Decimator


SynthDef("decimator", {
    arg
	//Standard Values
	out = 0, pan = 0, freq = 440, amp = 0.1, gate = 1,
	att = 0.001, dec = 0.1, sus = 0.9, rel = 1, crv = -2,
        //Other controls, filterswitch is 0 or 1
	preamp = 1, bitdepth = 16, samplerate = 10000, filterswitch = 0, filtermult = 0.5;

	var rate, env, snd, clock, remainder;

	//Set up the sample rate (Weird things happen above half of supercollider's sample rate)
    rate = samplerate.clip(20, SampleRate.ir/2);

	//Simple adsr envelope
	env = Env.adsr(
		attackTime: att,
		decayTime: dec,
		sustainLevel: sus,
		releaseTime: rel,
		curve: crv).ar(gate: gate, doneAction: 2);

	// Fix the input signal range
	snd = SinOsc.ar(freq: freq, mul: 0.5 * preamp, add: 0.5);
	snd = snd * env;

	//Input filtering to simulate a very cheap adc
	snd = Select.ar(
		which: filterswitch,
		array: [snd, LPF.ar(in: snd, freq: rate * filtermult)]);

	//Sampe Rate Reduction
	clock = LFPulse.ar(freq: rate, width: 0.001) - 0.5;
	snd = Latch.ar(snd, clock);

	//Bit Depth Reduction
	remainder = 2.pow(bitdepth).mod(1);
	snd = Clip.ar(
		in: snd,
		lo: 0,
		hi: 1);
	snd = XFade2.ar(
		inA: snd.round(1/(2.pow(bitdepth).floor)),
		inB: snd.round(1/(2.pow(bitdepth).ceil)),
		pan: (remainder * 2) - 1);

	//Output filtering to simulate a very cheap dac (and other output stuff)
	snd = Mix.ar(((snd * 2) - 1)) * amp;
	snd = Select.ar(
		which: filterswitch,
		array: [snd, LPF.ar(in: snd, freq: rate * filtermult)]);
	snd = LeakDC.ar(snd);
	snd = Limiter.ar(snd);

	Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Josh Mitchell",
	category: \misc,
	tags: [\pitched, \noisy]
	)
).add;

// Blip

(
SynthDef("blip1", {arg out = 0, freq = 25, numharm = 10, att = 0.01, rel = 1, amp = 0.1, pan = 0;
	var snd, env;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = Blip.ar(
		freq: freq * [1, 1.01],
		numharm: numharm,
		mul: env
	);
	snd = LeakDC.ar(snd);
	snd = Mix.ar(snd);
	snd = Pan2.ar(snd, pan);
	Out.ar(out, snd);
},

metadata: (
	credit: "unknown",
	category: \pads,
	tags: [\pitched]
)
).add;



/////////////////// sintesis granular ///////////////////

SynthDef(\grainbuf, {
	var sig, env;

	env = Env([0,1,1,0], [\atk.ir(1),\sus.ir(4),\rel.ir(1)], [1,0,-1]).kr(2);

	sig = GrainBuf.ar(
		numChannels:2,
		trigger:Dust.kr(40), // 40 granos por segundo
		dur:0.05,
		sndbuf: \buf.kr(0),
		rate:BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		pos: Line.kr(0,1,BufDur.kr(\buf.kr(0))* \timescale.kr(5)),
		interp:2,
		pan:0,
		envbufnum:-1,
		maxGrains:\mgra.kr(512),

	);
	sig = sig * env ;


	Out.ar(\out.kr(0), sig);

}).add;

/////////////////////////   buffer //////////

SynthDef(\bufsynth, {
	var sig, env;
	env = Env.linen(\atk.ir(0.5),\sus.ir(0.5),\rel.ir(0.5),1,\cur.ir(-2)).ar(2);
	sig = PlayBuf.ar(1, \buf.ir(0), \rate.ir(1),1,\spos.ir(0.0));
	sig = Pan2.ar(sig, \pan.ir(0),\amp.ir(0.5));
	sig = sig * env;

	Out.ar(\out.ir(0), sig);
}).add;

SynthDef(\pbufm,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env ;
		sig = Mix.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,Pan2.ar(sig,pan));
}).add;

SynthDef(\pbufs,
	{arg out = 0, buf = 0, rate = 1, amp = 1, pan = 0, pos = 0, rel=15;
		var sig,env ;
		sig = Mix.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,Pan2.ar(sig,pan));
}).add;

SynthDef(\bufchina, { |out, gate = 1, bufnum, startSec, rate = 1, amp = 0.1, pan = 0|
	var sig = PlayBuf.ar(
		1, bufnum,
		rate * BufRateScale.kr(bufnum),
		startPos: startSec * BufSampleRate.kr(bufnum)
	);
	var eg = EnvGen.ar(Env.asr(0.005, 1, 0.005, \lin), gate, doneAction: 2);
	Out.ar(out, Pan2.ar(sig * (eg * amp), pan))
}).add;


 SynthDef(\buf, {
        arg out = 0, bufnum;
        var sig,env;
		env = Env.linen(
			\atk.ir(1),\sus.ir(1),\rel.ir(1),1,\curve.ir(-6)
	).ar(2);

        sig = PlayBuf.ar(1, \buf.ir(0),\rate.ir(1),1,\spos.ir(0) ,loop: 1);
	sig = Pan2.ar(sig,\pos.ir(0.0),\amp.ir(1));
        Out.ar(out, sig);
    }).add;

/// buffer

SynthDef(\buffer, {
  arg bufnum, start = 0, end = 16, mul = 0.1, rate = 1;
  var sig, env, duration;

  duration = (end - start) * BufDur.kr(bufnum) * rate.reciprocal;
  env = Env.linen(0.01, duration - 0.02, 0.01, mul,[\curve1.ir(1),\curve2.ir(2)]).ar(2);

  sig = PlayBuf.ar(1, bufnum, rate * BufRateScale.kr(bufnum), startPos: start * BufFrames.kr(bufnum));

  sig = sig * env;
  sig = Pan2.ar(sig,\pos.ir(0));
	Out.ar(0, sig);
}).add;

// Jamshark synth
SynthDef(\bufseg1, { |out, gate = 1, bufnum, startSec, rate = 1, amp = 1, pan = 0|
	var sig = PlayBuf.ar(
		1, bufnum,
		rate * BufRateScale.kr(bufnum),
		startPos: startSec * BufSampleRate.kr(bufnum)
	);
	var eg = EnvGen.ar(Env.asr(0.005, 1, 0.005, \lin), gate, doneAction: 2);
	Out.ar(out, Pan2.ar(sig * (eg * amp), pan))
}).add;


///////////////////////// Drones /////////// ///////////////////////////////////////////

SynthDef(\droneFM, {
	arg f1Freq=0.1, f2Freq=1.1, f3Freq=2.2, nFreq=440, m1Ratio=1, m2Ratio=2, m3Ratio=3, amp=0.1, dur=55, ampM=0.84 , pan=0;

	var sig, car1, mod1, car2, mod2, car3, mod3, env, index;
	index = LFNoise1.kr(0.2).range(2, 12);
	env = EnvGen.kr(Env.new([0, 0.70, 0.70, 0], [dur*0.333, dur*0.333, dur*0.333]), doneAction:2);
	mod1 = SinOsc.ar([nFreq * m1Ratio, nFreq+0.7 * m1Ratio], mul:nFreq * m1Ratio * index) * ampM;
	car1 = SinOsc.ar(f1Freq + mod1);

	mod2 = SinOsc.ar([nFreq * m2Ratio, nFreq+1.4 * m2Ratio], mul:nFreq * m2Ratio * index) * ampM;
	car2 = SinOsc.ar(f2Freq + mod2);

	mod3 = SinOsc.ar([nFreq * m3Ratio, nFreq+0.35 * m3Ratio], mul:nFreq * m3Ratio * index) * ampM;
	car3 = SinOsc.ar(f3Freq + mod3) * 0.4;
	sig = car1 + car2 + car3 * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;




// \droneFMPulse

SynthDef(\droneFMPulse, {
    var sig, sig1, sig2, sig3, mod1, mod2, mod3, env, index;
    index = LFNoise1.kr(0.5).range(2,12);

    env = Env.new([0,0.70,0.70,0], [\dur.ir(55)*0.333,\dur.ir*0.333,\dur.ir*0.333]).ar(2);


    mod1 = SinOsc.ar([\nfreq.kr(440)*\m1Ratio.kr(1), \nfreq.kr +1.4* \m1Ratio.kr], 0.0,\amp.kr(440)* \m1Ratio.kr * index) * \ampM.kr(0.84);
    sig1 = LFPulse.ar(\f1freq.kr(0.1) + mod1);

      mod2 = SinOsc.ar([\nfreq.kr(440)*\m2Ratio.kr(2), \nfreq.kr +0.7* \m2Ratio.kr], 0.0,\amp.kr* \m2Ratio.kr * index) * \ampM.kr(0.84);
    sig2 = LFPulse.ar(\f2freq.kr(1.1) + mod2);



         mod3 = SinOsc.ar([\nfreq.kr(440)*\m3Ratio.kr(3), \nfreq.kr +0.35* \m3Ratio.kr], 0.0,\amp.kr* \m3Ratio.kr * index) * \ampM.kr(0.84);
    sig3 = LFPulse.ar(\f3freq.kr(2.2) + mod3);

    sig = sig1 * sig2 *sig3 *env * 0.3;
    sig = Pan2.ar(sig, \pan.kr(0));

    Out.ar(\out.kr(0), sig1);
}).add;


//simpledron

SynthDef(\simpledron, {
    | freq = 440, amp = 0.5, dur = 60 |
    var sig, mod, env;
    mod = SinOsc.ar(5 , 0, 0.5,1);
     sig = Resonz.ar( Saw.ar(freq, amp),1000,\rq.ir(1));

    sig = sig + mod;
     env = EnvGen.kr(Env.linen(2, dur, 2), doneAction: 2);
    sig = sig * env;
    //sig = FreeVerb.ar(sig, 0.5, 3, 1);
    Out.ar(0, sig ! 2); // Salida estéreo
}).add;

// Para reproducir el dron
//Synth(\dron, [\freq, 80,\rq, 2]);




// Establece la frecuencia fundamental
~freqFundamental = 80;

// Crea un dron con DFM1
SynthDef(\dronDFM1, {
    var sig, filtro, env;
    // Genera una onda senoidal como fuente de sonido
    sig = SinOsc.ar([~freqFundamental, ~freqFundamental * 1.01], 0, 0.1);
    // Modula la resonancia del filtro para que entre y salga de la auto-oscilación
    filtro = DFM1.ar(
        sig,
        ~freqFundamental * 2, // Frecuencia de corte del filtro
        SinOsc.kr(0.05).range(0.9, 1.1), // Resonancia modulada
        1, // Ganancia de entrada
        0, // Tipo de filtro: 0 para paso bajo
        0.0003, // Nivel de ruido
        0.5 // Escala la salida
    );
    // Usa una envolvente para controlar la duración del dron
    env = EnvGen.kr(Env.linen(10, 60, 10), doneAction: 2);
    filtro = filtro * env;
    // Salida estéreo
    Out.ar(0, filtro ! 2);
}).add;



////////////////////// pad /////////////////////////////////////


//pad


SynthDef(\pad, {
    var sig, env;

    env = Env.asr(1.0,1,1.0).ar(Done.freeSelf, \gate.kr(1));

    sig = Saw.ar(\freq.kr(440)* (LFNoise2.kr(3!8)*0.2).midiratio* [1,2,1,2,2,1,2,1]);
    sig = BPF.ar(sig, {ExpRand(200,900)}!sig.size,0.2)*9.dbamp;
    sig = Splay.ar(sig, 0.3);
    sig = (sig * 10.dbamp).tanh;
    sig = Pan2.ar(sig , \pan.kr(0));
    sig = sig * env;
    sig = sig * -18.dbamp;
    Out.ar(\out.kr(0), sig)
}).add;



// pad ho
SynthDef(\pad_ho, {
	var sig;
	sig = Saw.ar(\freq.kr(440)*({LFNoise2.kr(8) } ! 16 * 0.1).midiratio);
	sig = DelayC.ar(sig, 0.01, {Rand(0,0.01) } ! sig.size);
	sig = Splay.ar(sig);
	sig = sig * Env.asr(\atk.ir(1),\sus.ir(1),\rel.ir(3)).ar(Done.freeSelf, \gate.kr(1));
	sig = sig *\amp.kr(-20.dbamp);
	sig = sig!2;
	Out.ar(\out.kr(0), sig);
}).add;


// apadMH



SynthDef(\apadMH, {
	arg
	//Standard Values:
	out = 0, pan = 0, freq = 880, amp = 0.5, att = 0.4, dec = 0.5, sus = 0.8, rel = 1.0, gate = 1,
	//Other Controls:
	vibratoRate = 4, vibratoDepth = 0.015, tremoloRate = 5,
	//These controls go from 0 to 1:
	tremoloDepth = 0.5, reverbMix = 0.5, roomSize = 1, damp = 0.5;

	var env, snd, vibrato, tremolo, mod2, mod3;

	env = Env.adsr(att, dec, sus, rel).kr(gate: gate);
	vibrato = SinOsc.kr(vibratoRate).range(freq * (1 - vibratoDepth), freq * (1 + vibratoDepth));
	tremolo = LFNoise2.kr(1).range(0.2, 1) * SinOsc.kr(tremoloRate).range((1 - tremoloDepth), 1);

	snd = SinOsc.ar(freq: [freq, vibrato], mul:(env * tremolo * amp)).distort;
	snd = Mix.ar([snd]);
	snd = FreeVerb.ar(snd, reverbMix, roomSize, damp);

	DetectSilence.ar(snd, 0.0001, 0.2, doneAction: 2);
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata:(
	credit: "Mike Hairston",
	tags: [\pad, \vibrato, \sustained]
	)
).add;


// feedbackPad1



SynthDef(\feedbackPad1, {
	arg out = 0, amp = 1, gate = 1, freq = 75, pan = 0,
	// Controls for ampEnv
	att = 2, dec = 1, sus = 1, rel = 4, crv = 0,
	// Controls for fbEnv
	fbStartStop = 0, fbAtt = 3, fbPeak = 0.8, fbDec = 2, fbSus = 0.67, fbRel = 5,
	// Confrols for delEnv
	delStartStop = 0.55, delAtt = 1, delPeak = 0, delDec = 2, delSus = 0.25, delRel = 3.5;

	var snd, fbIn, fbOut, ampEnv, fbEnv, delEnv;

	// Set up the Envelopes
	ampEnv = Env.adsr(
		attackTime: att,
		decayTime: dec,
		sustainLevel: sus,
		releaseTime: rel,
		curve: crv).ar(gate: gate);

	fbEnv = Env.adsr(
		attackTime: fbAtt,
		decayTime: fbDec,
		sustainLevel: fbSus,
		releaseTime: fbRel,
		peakLevel: fbPeak,
		curve: \lin,
		bias: fbStartStop).ar(gate: gate);

	delEnv = Env.adsr(
		attackTime: delAtt,
		decayTime: delDec,
		sustainLevel: delSus,
		releaseTime: delRel,
		peakLevel: delPeak,
		curve: \lin,
		bias: delStartStop).ar(gate: gate);

	// Receive the feedback
	fbIn = LocalIn.ar;

	// The Sound (yup, that's all it is)
	snd = SinOsc.ar(
		freq: freq,
		phase: fbIn * pi);

	// Delay the feedback
	fbOut = DelayC.ar(
		in: snd,
		maxdelaytime: delStartStop.max(delPeak.max(delSus)),
		delaytime: delEnv,
		mul: fbEnv);

	// Send the feedback
	LocalOut.ar(fbOut);

	// Output Stuff
	snd = Mix.ar(snd) * ampEnv * amp;
	snd = Limiter.ar(snd);

    DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Josh Mitchell",
	category: \pads,
	tags: [\pitched]
	)
).add;


// feedbackPad3



SynthDef(\feedbackPad3, {
	arg
	// Standard Values
	out = 0, amp = 0.15, gate = 1, freq = 100, pan = 0,
	// Envelope Controls
	att = 3, dec = 1, sus = 1, rel = 5, crv = 0,
	// Reverb Controls (all go from 0 to 1)
	reverbMix = 0.75, roomSize = 0.9, damp = 0.5,
	// Other Controls (interval is in semitones)
	sampleRate = 20, notes = 6, interval = 7;

	var env, fbIn, snd;

	// Set up the Envelopes
	env = Env.adsr(
		attackTime: att,
		decayTime: dec,
		sustainLevel: sus,
		releaseTime: rel,
		curve: crv).ar(gate: gate);

	// Receive and Sample the feedback
	fbIn = Latch.ar(
		in: (LocalIn.ar + 1)/2,
		trig: Impulse.ar(
			freq: sampleRate));
	fbIn = (fbIn * notes.abs * env).round(1);
	fbIn = (fbIn * interval).midiratio;

	// Make The Sound
	snd = LFTri.ar(
		freq: freq * fbIn,
		mul: env);

	// Feedback the Sound
	LocalOut.ar(snd);

	// Reverb the Sound
	snd = FreeVerb.ar(
		in:  snd,
		mix: reverbMix,
		room: roomSize,
		damp: damp);

	//Filter the Sound
	snd = RHPF.ar(
		in: snd,
		freq: freq,
		rq: 0.5);
	snd = LPF.ar(
		in: snd,
		freq: [62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000],
		mul: 1/9);

	// Output Stuff
	snd = Mix.ar(snd) * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Josh Mitchell",
	category: \pads,
	tags: [\pitched]
	)
).add;



// superSaw



SynthDef(\superSaw, {
	arg
	//Standard Values
	out = 0, pan = 0, gate = 1, amp = 0.5, freq = 40,
	att = 0.1, dec = 0.2, sus = 0.9, rel = 5, crv = 0,
	// Detune Controls (spread goes from 0 to 1)
	detuneRatio = 1.025, numberOscs = 100, spread = 1, detuneFade = 0.25,
	// Filter Controls (preamp > 0)
	filterLo = 80, filterHi = 8000, rq = 0.8, preamp = 2,
	fAtt = 3, fDec = 3, fSus = 0.8, fRel = 5;

	var detuneHz, stepSize, faArray, freqArray, ampArray, phaseArray, env, fEnv, snd;

	// Scale detuneRatio and numberOscs
	detuneHz = (detuneRatio - 1) * freq;
	stepSize = (2 * detuneHz)/(numberOscs - 1);

	// An Array used for freqArray and ampArray
	faArray = Array.fill2D(100, 2, {
		arg i, j;
		if (j == 1)
		{ (numberOscs - i).tanh.clip(0, 1).sign }
		{ ((stepSize * i) + (freq - detuneHz)).clip(20, 20000) }
	});
	faArray = faArray.scramble.flop;

	// Generate the Frequencies of all the Saws
	freqArray = faArray[0];

	// Generate the Amplitudes of all the Saws
	ampArray = abs(freq - freqArray);
	ampArray = (detuneHz - ampArray)/detuneHz;
	ampArray = ampArray.pow(detuneFade) * 0.1;
	ampArray = ampArray * faArray[1];

	// Generate the Phases of all the Saws
	phaseArray = {TRand.ar(
		lo: 0.000,
		hi: 2.000,
		trig: Impulse.ar(0))}.dup(100);

	// Envelopes for Volume and LPF
	env = Env.adsr(
		attackTime: att,
		decayTime: dec,
		sustainLevel: sus,
		releaseTime: rel,
		curve: crv).ar(doneAction: 2, gate: gate);
	fEnv = Env.adsr(
		attackTime: fAtt,
		decayTime: fDec,
		sustainLevel: fSus,
		releaseTime: fRel,
		curve: crv).ar(gate: gate);

	// Make the Saws
	snd = LFSaw.ar(
		freq: freqArray,
		iphase: phaseArray,
		mul: ampArray);
	snd = HPF.ar(
		in: snd,
		freq: freqArray);

	//Mix the Saws down to Stereo
	snd = Splay.ar(inArray: snd, spread: spread);
	snd = Normalizer.ar(
		in: snd,
		level: 1,
		dur: 0.02);

	// Filter the Saws
	snd = RLPF.ar(
		in: snd,
		freq: LinExp.ar(
			in: fEnv,
			srclo: 0, srchi: 1,
			dstlo: filterLo, dsthi: filterHi),
		rq: rq,
		mul: (preamp/2).clip(0.0001, inf));
	snd = snd.softclip;
	snd = snd/((preamp/2).clip(0.0001, inf).softclip);

	// Output Stuff
	snd = snd * amp * env;
	snd = Limiter.ar(snd);
	snd = Balance2.ar(
		left: snd[0],
		right: snd[1],
		pos: pan);

	Out.ar(out, snd);
},
metadata: (
	credit: "Josh Mitchell",
	category: \pads,
	tags: [\pitched]
	)
).add;



/////////// PERCUSION

// abstractDrum




SynthDef(\abstractDrum, {
	arg
	// Standard values
	out = 0, freq = 140, amp = 1, pan = 0, att = 0.001, dec = 0.01, rel = 1,
	// Other Controls (position goes from 0 to 1)
	position = 0.5, ampSlope = 3, decCoef = 0.15, hiFreqSus = 0;

	var freqarray, amparray, decarray, exciter, snd;

	// Setting up arrays for Klank
	freqarray = Array.fill(8, {
		arg i = 1;
		(
			Array.fill((i + 1), {
				arg j;
				(j + 1).pow(2)
			}) +
			(i + 1).pow(2)
		).sqrt

	});
	freqarray = freqarray.flatten/(2.sqrt);

	amparray = Array.fill(36, {
		arg i;
		if (freqarray[i] > 20000)
			{ 0 }
			{
			    sin(((i + 1) * pi) * position) *
		        (ampSlope * (freqarray[i]).log2).dbamp
		    }
	});
	amparray = amparray/ampSlope;

	decarray = Array.fill(36, {
		arg i;
		exp(-1 * i * decCoef) + hiFreqSus
	});
	decarray = decarray/decarray[0];

	// Exciter
	exciter = Decay2.ar(
		in: Impulse.ar(0),
		attackTime: att,
		decayTime: dec,
		mul: 0.005); // This keeps the volume at a sane level

	// The actual sound-makey part
	snd = Klank.ar(
		specificationsArrayRef:
		    Ref.new([freqarray, amparray, decarray]),
		input: exciter,
		freqscale: freq,
		decayscale: rel);

	// Output Stuff
	snd = Mix.ar(snd * amp * 2);
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "by Josh Mitchell",
	category: \percussion,
	tags: [\pitched, \modal]
)
).add;


// frameDrum



SynthDef(\frameDrum, {
	arg
	// Standard values
	out = 0, pan = 0, freq = 170, amp = 0.5, att = 0.0025, dec = 0.0025, rel = 5, crv = 0,
	// Other controls (position goes from 0 to 1, blend from -1 to 1)
	decCoef = 0.225, position = 0.8, thumpAmp = 0.5, thumpDec = 0.2, exBlend = 0;

	var exciter, freqArray, ampRowArray, ampArray, decArray, snd;

	// An Array of bessel function solutions, normalized to 1 at the fundamental
	freqArray = [
		[ 0.6276, 1, 1.3403, 1.6651, 1.9804, 2.2892, 2.5931, 2.8933,
		  3.1905, 3.4852, 3.7778, 4.0686, 4.3579, 4.6458, 4.9325, 5.2182 ],
		[ 1.4406, 1.8309, 2.1967, 2.5474, 2.8877, 3.2201, 3.5465, 3.8681,
		  4.1855, 4.4996, 4.8108, 5.1194, 5.4258, 5.7301, 6.0328, 6.3338 ],
		[ 2.2585, 2.6551, 3.0326, 3.3967, 3.7509, 4.0974, 4.4377, 4.7727,
		  5.1033, 5.4302, 5.7538, 6.0745, 6.3927, 6.7085, 7.0223, 7.3342 ],
		[ 3.0774, 3.4772, 3.8615, 4.234, 4.5974, 4.9534, 5.3033, 5.648,
		  5.9882, 6.3246, 6.6575, 6.9873, 7.3144, 7.6391, 7.9615, 8.2818 ],
		[ 3.8967, 4.2985, 4.6872, 5.0655, 5.4354, 5.7984, 6.1555, 6.5075,
          6.8551, 7.1988, 7.539, 7.8761, 8.2104, 8.5422, 8.8716, 9.1988 ],
		[ 4.7162, 5.1194, 5.5111, 5.8936, 6.2685, 6.6368, 6.9995, 7.3573,
		  7.7108, 8.0605, 8.4067, 8.7497, 9.0899, 9.4276, 9.7628, 10.0958 ],
		[ 5.5358, 5.9399, 6.334, 6.7198, 7.0984, 7.471, 7.8382, 8.2007,
		  8.5591, 8.9136, 9.2648, 9.6128, 9.9581, 10.3007, 10.6409, 10.9789 ],
		[ 6.3555, 6.7603, 7.1562, 7.5445, 7.9262, 8.3022, 8.6732, 9.0396,
          9.402, 9.7607, 10.1161, 10.4684, 10.8179, 11.1649, 11.5094, 11.8517 ],
		[ 7.1753, 7.5807, 7.978, 8.3683, 8.7525, 9.1314, 9.5054, 9.8752,
		  10.241, 10.6033, 10.9623, 11.3183, 11.6715, 12.0222, 12.3706, 12.7167 ],
		[ 7.995, 8.4009, 8.7993, 9.1914, 9.5777, 9.959, 10.3357, 10.7082,
          11.077, 11.4424, 11.8046, 12.1638, 12.5203, 12.8744, 13.226, 13.5755 ],
		[ 8.8148, 9.221, 9.6205, 10.0139, 10.4021, 10.7854, 11.1643, 11.5394,
          11.9107, 12.2788, 12.6438, 13.0059, 13.3653, 13.7223, 14.0769, 14.4294 ],
		[ 9.6346, 10.0412, 10.4414, 10.8361, 11.2257, 11.6108, 11.9918, 12.3689,
		  12.7426, 13.113, 13.4805, 13.8451, 14.2072, 14.5668, 14.9241, 15.2793 ],
		[ 10.4545, 10.8612, 11.2622, 11.6579, 12.0489, 12.4356, 12.8183, 13.1973,
		  13.573, 13.9455, 14.3152, 14.6821, 15.0465, 15.4085, 15.7683, 16.1259 ],
		[ 11.2743, 11.6813, 12.0829, 12.4795, 12.8716, 13.2597, 13.6439, 14.0246,
		  14.4021, 14.7766, 15.1482, 15.5172, 15.8837, 16.2479, 16.6099, 16.9697 ],
		[ 12.0941, 12.5013, 12.9034, 13.3009, 13.694, 14.0833, 14.4689, 14.8512,
		  15.2303, 15.6064, 15.9799, 16.3507, 16.7192, 17.0853, 17.4493, 17.8112 ],
		[ 12.914, 13.3214, 13.7239, 14.1221, 14.5162, 14.9065, 15.2933, 15.677,
		  16.0575, 16.4353, 16.8103, 17.1829, 17.5531, 17.921, 18.2869, 18.6507 ],
	];

	// Amplitudes corresponding to nodes that look like slices
	ampRowArray = Array.fill(16, {
		arg i;
		if (i == 0)
			{ thumpAmp }
			{
			    (
				    ((3pi).pow(2) - (24pi * i * sin((pi/2)/i))) *
		            (
			        	((4 * i) * sin((pi/2)/i)).pow(2)/(3 * pi) -
		                ((4 * i) * sin((pi/2)/i))
		            ).pow(-2)
	            ) *
		        (
			        position.pow(3) - position +
			        (
			        	(position - position.pow(2)) *
					    ((16/3 * (i * sin((pi/2)/i)).pow(2)) - pi.pow(2))/
					    ((8pi/3 * i * sin((pi/2)/i)) - pi.pow(2))
			        )
		        )
		    }
	});

	// Amplitudes corresponding to nodes that have rings
	ampArray = Array.fill2D(16, 16, {
		arg i, j;
		(if (freqArray[i][j] > 20000)
	    	{ 0 }
		    {
				cos(position * ((i * pi) + pi/2)) * ampRowArray[j]
		    }
		)
	});

	// Decay times
	decArray = Array.fill2D(16, 16, {
		arg i, j;
		(
			if (j == 0)
		        { thumpDec }
		        { 1 }
		) *
		exp(-1 * (i + j) * decCoef)
	});

	// Exciter
	exciter = Env.perc(
		attackTime: att,
		releaseTime: dec,
		level: 0.05,
		curve: crv).ar;
	exciter = XFade2.ar(
		inA: exciter,
		inB: BrownNoise.ar(exciter),
		pan: exBlend);

	// Bank of resonators
	snd = Array.fill(16, {
		arg i;
			Klank.ar(
		        specificationsArrayRef:
		    	    Ref.new([freqArray[i], ampArray[i], decArray[i]]),
		        input: exciter,
		        freqscale: freq,
		        decayscale: rel
	        )
	});

	// Output stuff
	snd = Mix.ar(snd) * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, amp: 0.00025, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "by Josh Mitchell",
	category: \percussion,
	tags: [\unpitched, \modal]
)
).add;


// Marimba


SynthDef(\marimba1, {
	arg
	// Standard values
	freq = 440, out = 0, amp = 0.4, pan = 0, rq = 0.02,
        // Controls for BLowShelf
	shelffreq = 220, rs = 0.81, shelfamp = 2;

	var snd;

	snd = BPF.ar(
		in: Saw.ar(0),
		freq: freq,
		rq: rq);

	snd = BLowShelf.ar(
		in: snd,
		freq: shelffreq,
		rs: rs,
		db: shelfamp.ampdb);

	snd = Limiter.ar(snd) * amp;

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "unknown",
	category: \percussion,
	tags: [\percussion, \marimba, \pitched, \keyboard]
)
).add;


);

// metalPlate



SynthDef(\metalPlate, {
	arg
	// Standard values
	out = 0, freq = 3000, amp = 0.5, rel = 2, pan = 0, crv = 0,
	// Other controls (ratio goes from >0 to 1)
	ratio = 1, decCoef = 0.31, xpos = 0.5, ypos = 0.5, thumpDec = 0.75;

	var exciter, freqArray, ampArray, decArray, snd;

	// Frequencies
	freqArray = Array.fill2D(16, 16, {
		arg i, j;
		(i + 1).pow(2) + (ratio * (j + 1)).pow(2)
	});
	freqArray = freqArray/(freqArray[0][1]);
	freqArray = freqArray * freq;

	// Amplitudes
	ampArray = Array.fill2D(16, 16, {
		arg i, j;
		((1 - ((freqArray[i][j] - 19000)/1000).tanh)/2) *
		sin(((i + 1) * pi) * xpos) *
		sin(((j + 1) * pi) * ypos)
	});

	// Decay Times
	decArray = Array.fill2D(16, 16, {
		arg i, j;
		(
			if (j == 0)
		        { thumpDec }
		        { 1 }
		) *
		exp(-1 * (i + j) * decCoef)
	});

	// Hit the plate
	exciter = Impulse.ar(0);

	// The Plate
	snd = Klank.ar(
		specificationsArrayRef:
		    Ref.new([freqArray.flatten, ampArray.flatten, decArray.flatten]),
		input: exciter,
		decayscale: rel);

	// Output Stuff
	snd = HPF.ar(
		in: snd,
		freq: [freq, freq * 2, freq * 4, freq * 8, freq * 16, freq * 32, freq * 64]);
	snd = Mix.ar(snd/7) * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "by Josh Mitchell",
	category: \percussion,
	tags: [\pitched, \modal]
)
).add;


// modalmarimba



SynthDef(\modalMarimba, {
	arg
	// Standard values
	out = 0, freq = 440, amp = 0.1, att = 0.001, dec = 0.1, rel = 0.5, pan = 0,
	// Other controls, position goes from 0 to 1
	decCoef = 2, position = 0.414, ampSlope = 3;

	var freqarray, amparray, decarray, mallet, snd;

	// Array of frequencies, determined by solutions to the dynamic beam equation
	freqarray = Array.fill(30, { arg i; i + 1.5});
        freqarray[0] = 1.50561873;
	    freqarray[1] = 2.49975267;
	    freqarray = freqarray/1.50561873; // Normalize to freqarray[0] = 1

	// Array of amplitudes
	amparray = Array.fill(30, { arg i;
		if (freqarray[i] > 20000)
		    { 0 }
		    {
		        sin(((i + 1) * pi) * position) *
		        (ampSlope * (freqarray[i]).log2).dbamp
		    }
	});

	// Array of Decay times
	decarray = Array.fill(30, { arg i;
		exp(-1 * i * decCoef)
	}); // The decay times are dropping off exponentially

	// Hit the object
	mallet = Decay2.ar(
		in: Impulse.ar(0),
		attackTime: att,
		decayTime: dec,
		mul: 0.1);

	// Bank of resonators
	snd = Klank.ar(
		specificationsArrayRef: Ref.new([freqarray, amparray, decarray]),
		input: mallet,
		freqscale: freq,
		decayscale: rel);

	// Output stuff
	snd = Mix.ar(snd) * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "by Josh Mitchell",
	category: \percussion,
	tags: [\pitched, \modal]
)).add;

// crotales




SynthDef("pmCrotales", {
	arg out = 0, freq = 261, tone = 3, att = 0, rel = 2, curve = -6, amp = 0.8, pan = 0, modLo = 5.25, modHi = 5.5;

	var env, snd, mod;

	env = Env.perc(attackTime: 0, releaseTime: rel, curve: curve).kr(doneAction: 2);

	mod = Rand(modLo, modHi);

	snd = PMOsc.ar(
	    	carfreq: freq,
	    	modfreq: mod * freq,
	    	pmindex: env * tone,
	    	mul: env * amp
	    );

	snd = HPF.ar(snd, freq / 2);

	snd = Mix.ar(snd) * 0.1;

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Author Unknown",
	category: \percussion,
	tags: [\pitched, \bell]
	)
).add;

//////////////////////// FX /////////////////////////////////////


SynthDef(\fx, {
    var sig, fb;
    sig = In.ar(\out.kr(0),2);
    [0.2,0.3,0.35].do{ |windowSize|

        sig = sig + PitchShift.ar(sig * ToggleFF.ar(Dust.ar(4))* -123.dbamp, windowSize, 2);
    };

    sig = sig + LocalIn.ar(2);
    fb = sig;
    fb = DelayC.ar(fb, 3.0, [2.0,3.0]);
    fb = LPF.ar(fb, 3000);
    fb = HPF.ar(fb, 100);
    fb = fb* -2.dbamp;
    fb = Limiter.ar(fb);
    LocalOut.ar(fb);
    sig = LeakDC.ar(sig);
    sig = Limiter.ar(sig);
    ReplaceOut.ar(\out.kr(0), sig)
}).add;

SynthDef(\setPerc2,
    {arg out = 0, buf = 0, amp = 0.5, pan = 0, rel=15, dur = 8;
        var sig,env ;
        sig = Mix.ar(PlayBuf.ar(2,buf,\rate.ir(1),1,0,loop:0,doneAction:2));
        env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:2);
        sig = sig * env;
        sig = sig * amp;
        Out.ar(out,Pan2.ar(sig,pan));
}).add;



///////////// STRINGS


// strings


SynthDef(\strings, {
	arg
	//Standard Definitions
	out = 0, freq = 440, amp = 1, gate = 1, pan = 0, freqLag = 0.2, att = 0.001, dec = 0.1, sus = 0.75, rel = 0.3,
	//Other Controls (mix ranges from 0 - 1)
	rq = 0.001, combHarmonic = 4, sawHarmonic = 1.5, mix = 0.33;

	var env, snd, combFreq;

	combFreq = 1 / (Lag.kr(in: freq, lagTime: freqLag / 2) * combHarmonic);

	env = Env.adsr(att, dec, sus, rel, amp).kr(gate: gate, doneAction: 2);

	snd = SyncSaw.ar(syncFreq: freq * WhiteNoise.kr().range(1/1.025, 1.025), sawFreq: freq * sawHarmonic, mul: 8);
	snd = (snd * (1 - mix)) + PinkNoise.ar(180 * mix);
	snd = CombL.ar(snd, combFreq, combFreq, -1); //Try positive 1 for decay time as well.
	snd = Resonz.ar(snd, Lag.kr(in: freq, lagTime: freqLag), rq).abs;
	snd = snd * env;
	snd = Limiter.ar(snd, amp);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Original from Julian Rohrhuber, 2007",
	category: \strings,
	tags: [\pitched]
	)
).add;

// violin



SynthDef(\violin, {
	arg
	//Standard Definitions
	freq = 440, gate = 1, amp = 1, pan = 0, out = 0, att = 0.1, dec = 0.1, sus = 0.5, rel = 0.1,
	//Vibrato Controls
	vRate = 4.6, vDepth = 0.02, vAtt = 0.15, vRateVar = 0.25, vDepthVar = 0.05,
	//PWM Controls (pwmMax and pwmMin are 0 - 1)
	pwmVarRate = 2, pwmMin = 0.7, pwmMax = 0.8, pwmRate = 5,
	//Other Controls
	bridgeFreq = 2500, scratchDepth = 0.15;

	var scratch, env, pwm, snd;

	scratch = 1.015 + Env.perc(att, dec * 1.25, scratchDepth).kr;

	env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: 2);

	freq = Vibrato.kr(
		            freq: freq,
		            rate: vRate,
		            depth: vDepth,
	            	delay: (att + dec),
		            onset: vAtt,
		            rateVariation: vRateVar,
		            depthVariation: vDepthVar
            	);

	pwm = SinOsc.kr(freq: pwmRate, phase: Rand(0.0, 1.0)).range(pwmMin, pwmMax);
	pwm = pwm * LFNoise2.kr(pwmVarRate).range(0.2, 0.8);

	snd = VarSaw.ar(
		freq: Lag.kr(freq) * LFPulse.ar(freq * 1.5).range(1/scratch, scratch),
		width: pwm,
		mul: amp
	);

	snd = (snd * 0.7) + BPF.ar(snd, bridgeFreq, 2, 2);
	snd = snd + HPF.ar(snd, bridgeFreq * 2);
	snd = snd * env;
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Original by nicolaariutti, modified by Josh Mitchell",
	category: \strings,
	tags: [\bowed, \pitched, \violin]
	)
).add;

////////// WINDS



// waveguideFlute

SynthDef("waveguideFlute", { arg scl = 0.2, freq = 440, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 1, gate = 1, amp = 2;

	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;

	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;

	ifqc = freq;

	// noise envelope
	kenv1 = EnvGen.kr(Env.new(
		[ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' )
	);
	// overall envelope
	kenv2 = EnvGen.kr(Env.new(
		[ 0.0, amp, amp, 0.0 ], [ 0.1, dur - 0.02, 0.1 ], 'linear' ), doneAction: 2
	);
	// vibrato envelope
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1, 1, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear') );

	// create air flow and vibrato
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar( 5, 0, 0.1 * kenvibr );

	asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;

	fdbckArray = LocalIn.ar( 1 );

	aflute1 = fdbckArray;
	asum2 = asum1 + ( aflute1 * ifeedbk1 );

	//ax = DelayL.ar( asum2, ifqc.reciprocal * 0.5, afqc * 0.5 );
	ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );

	apoly = ax - ( ax.cubed );
	asum3 = apoly + ( aflute1 * ifeedbk2 );
	avalue = LPF.ar( asum3, 2000 );

	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );

	fdbckArray = [ aflute1 ];

	LocalOut.ar( fdbckArray );

	signalOut = avalue;

	OffsetOut.ar( 0, [ signalOut * kenv2, signalOut * kenv2 ] );

}).add;


///////// GUITARS


// pluck



SynthDef("waveguideFlute", { arg scl = 0.2, freq = 440, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 1, gate = 1, amp = 2;

	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;

	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;

	ifqc = freq;

	// noise envelope
	kenv1 = EnvGen.kr(Env.new(
		[ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' )
	);
	// overall envelope
	kenv2 = EnvGen.kr(Env.new(
		[ 0.0, amp, amp, 0.0 ], [ 0.1, dur - 0.02, 0.1 ], 'linear' ), doneAction: 2
	);
	// vibrato envelope
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1, 1, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear') );

	// create air flow and vibrato
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar( 5, 0, 0.1 * kenvibr );

	asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;

	fdbckArray = LocalIn.ar( 1 );

	aflute1 = fdbckArray;
	asum2 = asum1 + ( aflute1 * ifeedbk1 );

	//ax = DelayL.ar( asum2, ifqc.reciprocal * 0.5, afqc * 0.5 );
	ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );

	apoly = ax - ( ax.cubed );
	asum3 = apoly + ( aflute1 * ifeedbk2 );
	avalue = LPF.ar( asum3, 2000 );

	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );

	fdbckArray = [ aflute1 ];

	LocalOut.ar( fdbckArray );

	signalOut = avalue;

	OffsetOut.ar( 0, [ signalOut * kenv2, signalOut * kenv2 ] );

}).add;



// modalElectricGuitar



SynthDef(\electricguitar, {
	arg
	// Standard values
	out = 0, pan = 0, freq = 440, amp = 0.3, rel = 5,
	// String controls (pickPos goes from 0 to 1)
	decayCoef = 0.125, dampCoef = 0.0002, pickPos = 0.414, openFreq = 82.5, muteSus = 5.5,
	// Pickup Controls (pickupPos goes from 0 to 1)
	pickupPos = 0.17, pickupWidth = 0.75, resFreq = 4000, rq = 0.5, toneFreq = 3250;

	var exciter, freqArray, ampArray, decArray, constant, mute, snd;

	// Make a Constant from pickupWidth for ampArray
	constant = pickupWidth/25.5; // The scale length is set to 25.5 inches
	constant = constant * pi/2;
	constant = constant/openFreq;

	// Stiff String Model for Frequencies
	freqArray = Array.fill(50, {
		arg i;
		(i + 1) * sqrt(1 + ((i + 1).pow(2) * 0.00001))
	});
	freqArray = freqArray/freqArray[0];

	// Decay Times
	decArray = Array.fill(50, {
		arg i;
		exp(
			(-1 * i)/
			(
				(1/decayCoef) +
				((dampCoef/10) * freq.pow(2)) +
				(dampCoef * freqArray[i].pow(2))
		    )
		)
	});
	decArray = decArray/decArray[0];

	// Rescale freqArray for ampArray and Klank
	freqArray = freqArray * freq;

	// Effects of Pick Position and Pickup Placement
	ampArray = Array.fill(50, {
		arg i;
		((1 - ((freqArray[i] - 19000)/1000).tanh)/2) *
		sin(((i + 1) * pi) * pickPos) *
		(
			sin(pi * pickupPos * freqArray[i]/openFreq) *
			(
			    (
					sin(constant * freqArray[i])/
					(constant * freqArray[i])
				) - cos(constant * freqArray[i])
			)
		)/(freqArray[i].pow(2))
	});
	ampArray = ampArray * 2/(constant.pow(2));

	// The Pick
	exciter = Impulse.ar(0) * 0.1;

	// The String
	snd = Klank.ar(
		specificationsArrayRef:
		    Ref.new([freqArray, ampArray, decArray]),
		input: exciter,
		decayscale: rel
	);

	snd = Mix.ar(snd);

	// The Pickup
	snd = RLPF.ar(
		in: snd,
		freq: resFreq,
		rq: rq);

	snd = LPF.ar(
		in: snd,
		freq: toneFreq);

	// An Envelope for Muting the String
	mute = Env.new(
		levels: [1, 1, 0, 0],
		times: [muteSus, 0.05, 0.01]).ar(doneAction: 2);

	// Mute the String
	snd = LPF.ar(
		in: snd,
		freq: LinExp.ar(
			in: mute,
			srclo: 0, srchi: 1,
			dstlo: 20, dsthi: 20000));

	// Output Stuff
	snd = snd * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "by Josh Mitchell",
	category: \guitar,
	tags: [\pitched, \modal]
)
).add;


// distiorted guitar



SynthDef(\distortedGuitar, {
	arg
	//Standard Values
	out = 0, pan = 0, amp = 0.1, freq = 220, rel = 4, crv = -3,
	// String and Plucking Hand Controls
	coef = 0.75, openStringFreq = 110, pickPos = 0.5, muteSus = 0.5,
	// Pickup Controls
	pickupPos = 0.17, pickupResfreq = 8000, pickupResrq = 0.5, pickupHPF = 250, pickupHPFrq = 0.8,
	// Distortion Controls
	preDistHPF = 600, postDistLPF = 2000, gain = 75;

	var mute, snd;

	// The Pick
	snd = Hasher.ar(Sweep.ar(Impulse.ar(0)));
	snd = snd - DelayN.ar(
		in: snd,
		maxdelaytime: pickPos.clip(0, 1)/freq,
		delaytime: pickPos.clip(0, 1)/freq);

	// The String
	snd = Pluck.ar(
		in: snd,
		trig: Impulse.ar(0),
		maxdelaytime: 1/freq,
		delaytime: 1/freq,
		decaytime: rel,
		coef: coef.clip(-1, 1));
	snd = LeakDC.ar(snd);

	// An Envelope for Muting the String
	mute = Env.new(
		levels: [1, 1, 0, 0],
		times: [muteSus, 0.075, 0.025]).ar(doneAction: 2);

	// Mute the String
	snd = snd * mute;
	snd = HPF.ar(
		in: snd,
		freq: LinExp.ar(
			in: mute,
			srclo: 0, srchi: 1,
			dstlo: 100, dsthi: 20));
	snd = LPF.ar(
		in: snd,
		freq: LinExp.ar(
			in: mute,
			srclo: 0, srchi: 1,
			dstlo: 20, dsthi: 10000));

	// The Pickup
	snd = snd - DelayN.ar(
		in: snd,
		maxdelaytime: pickupPos.clip(0, 1)/openStringFreq,
		delaytime: pickupPos.clip(0, 1)/openStringFreq);
	snd = RHPF.ar(
		in: snd,
		freq: pickupHPF,
		rq: pickupHPFrq);
	snd = BLowPass4.ar(
		in: snd,
		freq: pickupResfreq,
		rq: pickupResrq);

	snd = LeakDC.ar(snd);

	// The Distortion
	snd = HPF.ar(
		in: snd,
		freq: preDistHPF);
	snd = snd * gain;
	snd = snd.tanh;
	snd = LPF.ar(
		in: snd,
		freq: postDistLPF);

	// Output Stuff
	snd = snd * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Josh Mitchell",
	category: \guitar,
	tags: [\pitched]
	)
).add;


//  SIMPLE SYNTHDEF

// simpleSin

SynthDef(\simpleSin, {
	var sig, env;

	env = Env.perc(\atk.ir(0.05),\rel.ir(1),\level.ir(1), \curve.ir(-4)).ar(2);
	sig = SinOsc.ar(\freq.ir(220),\phase.ir(0),\amp.ir(1));

	sig = sig *env;
	sig = Pan2.ar(sig, \pos.ir(0));

	Out.ar(\out.kr(0), sig);
}).add;

// simpleSaw

SynthDef(\simpleSaw, {
	var sig, env;

	env = Env.perc(\atk.ir(0.05),\rel.ir(1),\level.ir(1), \curve.ir(-4)).ar(2);
	sig = Saw.ar(\freq.ir(220),\amp.ir(1));

	sig = sig *env;
	sig = Pan2.ar(sig,\pos.ir(0));

	Out.ar(\out.kr(0), sig);
}).add;

// bpfsaw

SynthDef(\bpfsaw, {
    arg atk = 2, sus = 0, rel = 3, c1 = 1, c2 = -1, freq = 500, detune = 0.2, cfhzmin = 0.1, cfhzmax = 0.3, cfmin = 500, cfmax = 2000, rqmin = 0.1, rqmax = 0.2, lsf = 200, ldb = 0, pan = 0, amp = 1, out = 0;

    var sig, env;

    env = Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]).ar(2);

    sig = Saw.ar(freq * { LFNoise1.kr(0.5, detune).midiratio } ! 2);

    sig = BPF.ar(
        sig,
        { LFNoise1.kr(LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)).exprange(cfmin, cfmax) } ! 2,
        { LFNoise1.kr(0.1).exprange(rqmin, rqmax) } ! 2
    );
    sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
    sig = Balance2.ar(sig[0], sig[1], pan);

    sig = sig * env * amp;
    Out.ar(out, sig);
}).add;






// simpleLftri

SynthDef(\simpleLftri, {
	var sig, env;

	env = Env.perc(\atk.ir(0.05),\rel.ir(1),\level.ir(1), \curve.ir(-4)).ar(2);
	sig = LFTri.ar(\freq.ir(220),\iphase.ir(0),\amp.ir(1));

	sig = sig *env;
	sig = Pan2.ar(sig, \pos.ir(0));

	Out.ar(\out.kr(0), sig);
}).add;


// simplePulse

SynthDef(\simplePulse, {
	var sig, env;

	env = Env.perc(\atk.ir(0.05),\rel.ir(1),\level.ir(1), \curve.ir(-4)).ar(2);
	sig = RLPF.ar(Pulse.ar([100,250],0.5,0.1), XLine.kr(8000,400,5), 0.05);

	sig = sig *env;
	sig = Pan2.ar(sig, \pos.ir(0));

	Out.ar(\out.kr(0), sig);

}).add;



/// reverbbus

b = Bus.audio(s,1);

SynthDef("reverbBus", { arg outBus = 0, inBus, wet = 0.1;
	var input, rev;
	input = In.ar(inBus,1);
	rev = JPverb.ar(input * wet, t60:6, damp:0.5);
	DetectSilence.ar(rev, doneAction: Done.freeSelf);
    Out.ar(outBus, input + (rev));
}).add;


// Glitch

SynthDef(\chaosGlitch2, {
	arg len = 10, fundFreq = 40, henA = 2, henB = 0.4, t = 1, gate = 1;
	var mainEnv = EnvGen.kr(Env.triangle(len,1), gate, doneAction:2);
	var speed = Array.geom(4, t, [1.75, 1.25].choose);
	var freq = Array.geom(8, fundFreq*2, 1.5);
	var pulse = {|rat1,rat2|LFPulse.ar(rat1, [0,0.5,1].choose)*LFPulse.ar(rat2)};
	var a = Lag.ar(HenonN.ar(
		speed.choose*(mainEnv*10000.rand),
		henA, henB,
	), 0.01);
	var bass = SinOsc.ar(fundFreq!2*(a*1.0.rand), 0, Lag.ar(pulse.(t, speed.choose), 0.001));
	var tone1 = SinOsc.ar([(fundFreq+Rand(0,5))*a,(fundFreq+Rand(0,5))*a], 0, 0.01*pulse.(speed.choose, speed.choose));
	var tone2 = Pan2.ar(SinOsc.ar(freq.choose*a, 0, 0.1*pulse.(speed.choose, t)), a);
	var tone3 = SinOsc.ar([freq.choose,freq.choose*a], 0, 0.05*pulse.(speed.choose, t))*mainEnv.round(0.25);
	var noise = Pan2.ar(PinkNoise.ar(a*0.1*pulse.(t,t)), a);
	var impulse = RLPF.ar(Impulse.ar(pulse.(t, speed.choose), a), freq.choose+(a*10), 0.01, 0.1).tanh;

	Out.ar(0, (bass+tone1+tone2+tone3+noise+impulse)*\amp.ir(1).tanh);
	}
).store;


SynthDef(\hasherTest,
{
arg rate = 1, freq = 60, index = 1000, tRate = 100,
out = 0, fRate = 0.1;

var t_trig = LFPulse.kr(0.5/fRate, 0.5);
var random = LFNoise0.ar(rate, add:1);
var noise = Hasher.ar(random);
var sound = Saw.ar((freq+(noise*index)), Decay.kr(Impulse.kr(tRate), noise*0.001)).tanh;
sound = Pan2.ar(sound, noise-0.3*2);
FreeSelf.kr(t_trig);
Out.ar(out, sound);
}).store;





//// ritmo


(
// Basic drum kit

SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef("snare", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;

SynthDef("kick", {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var env, snd, ramp;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	ramp = XLine.kr(
		start: sinfreq,
		end: sinfreq * glissf,
		dur: rel
	);
	snd = SinOsc.ar(freq: ramp, mul: env);
	snd = Pan2.ar(snd, pan);
	Out.ar(out, snd);
}).add;

// Basic saw synth for chords and bass
SynthDef("sawSynth", { arg freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000;
    var env, snd;
    env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
    snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
    snd = Splay.ar(snd);
    Out.ar(0, snd);
}).add;
);



SynthDef(\pulse, {
	var sig, env, freq, cf;

	freq = \freq.kr(100);
	freq = freq * { Rand(-0.1, 0.1).midiratio }.dup(4);
	cf = freq * \harm.ir(4);

	sig = Pulse.ar(freq, \width.ir(0.5)).sum * 0.1;
	sig = LPF.ar(sig, cf.clip(20, 20000));

	env = EnvGen.kr(
		Env.adsr(\atk.ir(0.02), \dec.ir(0.3), \slev.ir(0.3), \rel.ir(1)),
		\gate.kr(1),
		doneAction: 2
	);

	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.2));
	sig = sig * env;
	Out.ar(\out.kr(0), sig);
}).add;


///////////////


// //// ///// Basic drum kit

SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef("snare", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;

SynthDef("kick", {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var env, snd, ramp;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	ramp = XLine.kr(
		start: sinfreq,
		end: sinfreq * glissf,
		dur: rel
	);
	snd = SinOsc.ar(freq: ramp, mul: env);
	snd = Pan2.ar(snd, pan);
	Out.ar(out, snd);
}).add;

// Basic saw synth for chords and bass
SynthDef("sawSynth", { arg freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000;
    var env, snd;
    env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
    snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
    snd = Splay.ar(snd);
    Out.ar(0, snd);
}).add;

