DDWSnippets.put("system-l","l = Prewrite(0.25,
    (
        0.25: #[0.25,0.25,0.25,0.5],
        0.5: #[0.25,0.5,0.125,0.125,0.125,0.125],
        0.125: #[0.375,0.125],
        0.375: #[0.375,0.375,1],
        1: #[0.75,0.25],
        0.75: #[16]
),60)");








DDWSnippets.put("audios","b = (); b.china = PathName(\"/Users/sdcarr/Documents/GitHub/My-setup-sc-live-coding/samples/set1/china/\").entries.collect({ |n| Buffer.readChannel(s,n.fullPath,channels:[0]);})");





DDWSnippets.put("filters","
~b1[1] = \\filter -> {|in|  in.clip};
~b1[2] = \\filter -> {|in|  in *SinOsc.ar(150*[1,0.995])};
~b1[3] = \\filter -> {|in|  LPF.ar(in,freq:600, mul:1, add:0)};
~b1[4] = \\filter -> {|in|  CombL.ar(in,maxdelaytime:0.2,delaytime:0.07,decaytime:1)};
~b1[5] = \\filter -> {|in|  RLPF.ar(in,freq:500,rq:0.07,mul:0.8)};
~b1[6] = \\filter -> {|in|  MoogFF.ar(in,freq:500,gain:0.07,reset:0,mul:1,add:0)};
~b1[7] = \\filter -> {|in|  GVerb.ar(in,roomsize:10,revtime:3,damping:0.5,inputbw:0.5,spread:15,drylevel:1,earlyreflevel:0.7, taillevel:0.5,maxroomsize:300,mul:1,add:0)};


~b.set(\\wet1,0);
~b.set(\\wet2, 0);
~b.set(\\wet3, 0);
~b.set(\\wet4, 0);
~b.set(\\wet5,0);
~b.set(\\wet6, 0);
~b.set(\\wet7, 0);
");

DDWSnippets.put("midi", "~midi[0] = Pbind(
	\\type, \\midi,
	\\midiout, m,
	\\midicmd, \\noteOn,
    //\\midinote, Pwhite(40,90,inf)
	\\octave, Pwhite(3,6,inf),
	\\degree, Pwhite(1,8,inf),
	\\detune, 0.5,
    \\dur,1/3,
    \\sustain, 0,
     \\amp, 1

)");





DDWSnippets.put("textura1", "~t1[0] = Pbind(
	\\instrument, \\bpfsaw,
	\\dur, 5,
	\\midinote, Pxrand([
		[72.0, 78.999999999972, 84.0, 88.99999999998, 96.0 ],
		[72.0, 78.999999999972, 84.0, 88.99999999998, 96.0 ]+9,
		[72.0, 78.999999999972, 84.0, 88.99999999998, 96.0 ]+4,
		[72.0, 78.999999999972, 84.0, 88.99999999998, 96.0 ],
	]-12,inf),
	\\detune, 0.08,
	\\cfmin,100,
	\\cfmax, 1500,
	\\atk,2,
	\\rel,8,
	\\ldb, 6,
	\\amp,0.2,
	\\out,0
)" );




DDWSnippets.put("textura2","~t2[0] = Pbind(
	\\instrument, \\droneFM,,
	\\dur, 6,
	\\nFreq, Pwhite([65.41,82.41,998],[65.41,82.41,998]-12,inf),
	\\pan , Prand([-0.8,0, 0.8],inf),
    \\m1Ratio,0.5,
	\\f1Freq,0.5,
	\\m2Ratio,0.1,
	\\f2Freq,0.9,
	\\m3Ratio,0.01,
	\\f3Freq,0.09,
     \ampM,0.85

)");
DDWSnippets.put("textura3", "~t3[0] = Pbind(
	\\instrument, \\simpledron,
	\\dur, 6,
	\\amp, -20.dbamp,
	\\rq, 1,
	\\freq , Pwhite([80,200,220],[80,240,250],inf),
)");

DDWSnippets.put("textura4", "~t4[0] = Pbind(
	\\instrument, \\pad_ho,
	\\dur,6,
	\\freq, Pxrand([[165,167],[69,70], [440,441],[1000,1100]].stutter(2),inf),
	\\detune, 0,
	\\atk,2,
	\\sus,1,
	\\rel,8,
	\\amp,0.2,
)");

DDWSnippets.put("textura5"," ~t5[0] = Pbind(
	\\instrument, \\feedbackPad1,
	\\dur,10,
	\\freq, Pxrand([[165,167],[69,70], [440,441],[1000,1100]].stutter(2),inf),
	\\dec,0.5,
	\\att,0.2,
	\\sus,1,
	\\rel,8,
	\\fbStartStop,0,
	\\fbAtt , 3,
	\\fbPeak,  0.8,
	\\fbDec, 2,
	\\fbSus , 0.67,
	\\fbRel,5,

	\\delStartStop , 0.55,
	\\delAtt,  1,
	\\delPeak, 0,
	\\delDec ,2,
	\\delSus ,0.25,
	\\delRel ,3.5,
	\\gate, 1
)");
DDWSnippets.put("textura6"," ~t6[0] =  Pbind(
	\\instrument, \\chaosGlitch2,
	\\amp, 0.7,
	\\dur,1,
	\\len,10,
	\\fundFreq , [40,80].choose,
	\\henA , 2,
	\\henB , 0.4,
	\\t , 1,
	\\gate, 1,
)");





DDWSnippets.put("ritmo1","~r1[0] = Pbind(
		\\instrument, \\bufsynth,

\\buf, Pxrand(d[\"glitch2\"],inf),
		\\dur, 1/4,
		\\rate, Pwhite(1.0,5.0,inf),
		\\spos,0,
		\\amp, 0.8,
		\\atk, 0,
		\\sus, Pwhite(0.0,0.15),
		\\rel, 0.01,
		\\cur,1,
		\\pan, Prand([-1,0, 1],inf)

)");
DDWSnippets.put("ritmo2","~r2[0] = Pbind(
		\\instrument, \\bufsynth,

\\buf, Pxrand(d[\"pajaros\"],inf),
		\\dur, 1/2,
		\\rate, Pwhite(1.0,5.0,inf),
		\\spos,0,
		\\amp, 0.8,
		\\atk, 0.5,
		\\sus, Pwhite(0.0,0.15),
		\\rel, 0.1,
		\\cur,1,
\\pan, Prand([-1,0, 1],inf)"
);


DDWSnippets.put("ritmo3","~r3[0] =Pbind(
		\\instrument, \\bufsynth,

\\buf, Pxrand(d[\"shout\"],inf),
		\\dur, 0.25,
		\\rate, Pwhite(1.0,5.0,inf),
		\\spos,0,
		\\amp, 14.dbamp,
		\\atk, 0.5,
		\\sus, Pwhite(0.0,0.15),
		\\rel, 0.1,
		\\cur,1,
        \\pan, Prand([-1,0, 1],inf)"
	);


DDWSnippets.put("ritmo4","~r4[0] =Pbind(
		\\instrument, \\bufsynth,

\\buf, Pxrand(d[\"voces\"],inf),
		\\dur, 1/4,
		\\rate, Pwhite(0.8,1.5,inf),
		\\spos,Pwhite(0.0,0.8,inf),
		\\amp, 2.dbamp,
		\\atk, 0.05,
		\\sus, Pwhite(0.0,0.15),
		\\rel, 0.1,
		\\cur,1,
        \\pan, Prand([-1,0, 1],inf)"
);
	DDWSnippets.put("ritmo5","~r5[0] =Pbind(
		\\instrument, \\bufsynth,

\\buf, Pxrand(d[\"etnico\"],inf),
		\\dur, 2,
		\\rate, Pwhite(0.8,1.5,inf),
		\\spos,Pwhite(0.0,0.8,inf),
		\\amp, 1.dbamp,
		\\atk, 0.5,
		\\sus, Pwhite(0.0,0.15),
		\\rel, 1,
		\\cur,1,
        \\pan, Prand([-1,0, 1],inf)"
);

	DDWSnippets.put("ritmo6","~r6[0] = Pbind(
	\\instrument, \\pulse,
	\\dur, 0.2,
	\\sustain, 0.2,
	\\degree, Pseq([0, 1, 2, 3,5], inf),
	\\db, -10,
	\\atk, 0.01,
	\\dec, 0.08,
	\\slev, 0,
	\\rel, 0,

)");

DDWSnippets.put("melodia1", "~m1[0] = Pbind(

	\\instrument, \\plucking,
	\\scale, Scale.yu.tuning_(\just),
	\\octave, 4,
	\\degree, Pseq([0, 3, 5, 7, 10], inf), // four main notes
	\\mtranspose, Pseq([Pseq([0],3),Pseq([-5],3)],inf), // switched mode every 3 notes (*2)

	\\gtranspose, Pseq([Pseq([0],36),Pseq([4],36),Pseq([[-3]],36),Pseq([2],36)],inf),
	\\ctranspose, Pser([Pseries(-4,1,6) +.x Pseq([0], 144)],1),

	\\coef, Pser([Prand([0.2,0.3,0.4,0.5],1), Prand([0.8,0.7,0.6,0.5],11)], inf),
	\\dur, Prand([0.25,0.26,0.24,0.255,0.255,0.25], inf) * 0.9,
	\\decay, Prand([1,2,3,4,5], inf),
	\\out, b,
	\\amp, 0.4,
)");


	DDWSnippets.put("melodia2"	,"~m2[0] = Pbind(

	\\instrument, \\plucking,
	\\scale, Scale.zhi.tuning_(\just),
	\\octave, 4,
	\\degree, Pseq([ 0, 2, 5, 7, 9 ], inf), // four main notes
	\\mtranspose, Pseq([Pseq([0],3),Pseq([-5],3)],inf), // switched mode every 3 notes (*2)

	\\gtranspose, Pseq([Pseq([0],36),Pseq([4],36),Pseq([[-3]],36),Pseq([2],36)],inf),
	\\ctranspose, Pser([Pseries(-4,1,6) +.x Pseq([0], 144)],1),

	\\coef, Pser([Prand([0.2,0.3,0.4,0.5],1), Prand([0.8,0.7,0.6,0.5],11)], inf),
	\\dur, Prand([0.25,0.26,0.24,0.255,0.255,0.25], inf) * 0.9,
	\\decay, Prand([1,2,3,4,5], inf),
	\\out, b,
    \\amp, 0.4,
)");



	DDWSnippets.put("melodia3",	"~m3[0] = Pbind(

	\\instrument, \\plucking,
	\\scale, Scale.gong.tuning_(\just),
	\\octave, 4,
	\\degree, Pseq([ 0, 2, 4, 7, 9 ], inf), // four main notes
	\\mtranspose, Pseq([Pseq([0],3),Pseq([-5],3)],inf), // switched mode every 3 notes (*2)

	\\gtranspose, Pseq([Pseq([0],36),Pseq([4],36),Pseq([[-3]],36),Pseq([2],36)],inf),
	\\ctranspose, Pser([Pseries(-4,1,6) +.x Pseq([0], 144)],1),

	\\coef, Pser([Prand([0.2,0.3,0.4,0.5],1), Prand([0.8,0.7,0.6,0.5],11)], inf),
	\\dur, Prand([0.25,0.26,0.24,0.255,0.255,0.25], inf) * 0.9,
	\\decay, Prand([1,2,3,4,5], inf),
	\\out, b,
    \\amp, 0.4,
)");


		DDWSnippets.put("melodia4",	"~m4[0] = Pbind(

	\\instrument, \\plucking,
	\\scale, Scale.chinese.tuning_(\just),
	\\octave, 4,
	\\degree, Pseq([ 0, 4, 6, 7, 11 ], inf), // four main notes
	\\mtranspose, Pseq([Pseq([0],3),Pseq([-5],3)],inf), // switched mode every 3 notes (*2)

	\\gtranspose, Pseq([Pseq([0],36),Pseq([4],36),Pseq([[-3]],36),Pseq([2],36)],inf),
	\\ctranspose, Pser([Pseries(-4,1,6) +.x Pseq([0], 144)],1),

	\\coef, Pser([Prand([0.2,0.3,0.4,0.5],1), Prand([0.8,0.7,0.6,0.5],11)], inf),
	\\dur, Prand([0.25,0.26,0.24,0.255,0.255,0.25], inf) * 0.9,
	\\decay, Prand([1,2,3,4,5], inf),
	\\out, b,
    \\amp, 0.4,
)");

	DDWSnippets.put("melodia5",	"~m5[0] = Pbind(

	\\instrument, \\plucking,
	\\scale, Scale.shang.tuning_(\just),
	\\octave, 4,
	\\degree, Pseq([ 0, 2, 5, 7, 10,7,5,2 ], inf), // four main notes
	\\mtranspose, Pseq([Pseq([0],3),Pseq([-5],3)],inf), // switched mode every 3 notes (*2)

	\\gtranspose, Pseq([Pseq([0],36),Pseq([4],36),Pseq([[-3]],36),Pseq([2],36)],inf),
	\\ctranspose, Pser([Pseries(-4,1,6) +.x Pseq([0], 144)],1),

	\\coef, Pser([Prand([0.2,0.3,0.4,0.5],1), Prand([0.8,0.7,0.6,0.5],11)], inf),
	\\dur, Prand([0.25,0.26,0.24,0.255,0.255,0.25], inf) * 0.9,
	\\decay, Prand([1,2,3,4,5], inf),
	\\out, b,
    \\amp, 0.4,
)");

	DDWSnippets.put("melodia6","~m6[0] = Pbind(

	\\instrument, \\plucking,
	\scale, Scale.chromatic.tuning_(\just),
	\\octave, 4,
	\\degree, Pseq([ 0, 2, 3, 5, 6,8,9,11 ], inf),
	\\mtranspose, Pseq([Pseq([0],3),Pseq([-5],3)],inf),
	\\gtranspose, Pseq([Pseq([0],36),Pseq([4],36),Pseq([[-3]],36),Pseq([2],36)],inf),
	\\ctranspose, Pser([Pseries(-4,1,6) +.x Pseq([0], 144)],1),

	\\coef, Pser([Prand([0.2,0.3,0.4,0.5],1), Prand([0.8,0.7,0.6,0.5],11)], inf),
	\\dur, Prand([0.25,0.26,0.24,0.255,0.255,0.25], inf) * 0.9,
	\\decay, Prand([1,2,3,4,5], inf),
	\\out, b,
    \\amp, 0.4,
)");


DDWSnippets.put("glitch1", "~g1[0] = Pbind(
	\\instrument, \\chaosGlitch2,
	\\dur, 1,
	\\len, Pseq([1, 1.5, 1.75, 2]+10,inf),
	\\henA, Pseq([2, 1.3, 1.29, 1.25], inf),
	\\henB, Pseq([0.2, 0.3], inf),
	\\t, Pseq([2, 4, 2, 6], inf),
	\\fundFreq, Pseq([40, 600, 8000, 200, 600, 6000], inf),
	\\amp,0.1
)");

DDWSnippets.put("glitch2","~g2[0] = Pbind(
\\instrument, \\hasherTest,
\\dur, Pxrand([2,5,7,9],inf),
\\rate, Pfuncn({100.rand}, inf),
\\freq, Pfuncn({10000.rand}, inf),
\\index, Pfuncn({20000.rand}, inf),
\\tRate, Pfuncn({1000.rand}, inf),
\\fRate, Pxrand([2,5,7,9],inf),
\\amp, 0.2
)");

DDWSnippets.put("glitch3", "~g3[0] = Pbind(
	\\instrument, \\bufsynth,
\\buf, Pxrand(d[\"glitch2\"], inf),
	\\dur, 1/2,
	\\rate, Pwhite(0.5,1.5,inf),
	\\amp, Pwhite(0.4,1.0,inf),
	\\atk, 0.05,
	\\sus, 0.04,
	\\rel, 0.005
)");
	DDWSnippets.put("glitch4","~g4[0] = Pbind(
	\\instrument, \\pbufs,
\\buf, Pxrand(d[\"rim\"], inf),
	\\dur, 1/2,
	\\rate, Pwhite(0.5,1.5,inf),
	\\amp, Pwhite(0.4,1.0,inf),
	\\atk, 0.5,
	\\sus, 0.4,
	\\rel, 0.05
)");
	DDWSnippets.put("glitch5","~g5[0] = Pbind(
	\\instrument, \\pbufs,
\\buf, Pxrand(d[\"pajaros\"], inf),
	\\dur, 1/2,
	\\rate, Pwhite(0.5,1.5,inf),
	\\amp, Pwhite(0.4,1.0,inf),
	\\atk, 2,
	\\sus, 2,
	\\rel, 0.5
)");
	DDWSnippets.put("glitch6","~g6[0] = Pbind(
	\\instrument, \\pbufs,
\\buf, Pxrand(d[\"orquesta\"], inf),
	\\dur, 1/2,
	\\rate, Pwhite(0.5,1.5,inf),
	\\amp, Pwhite(0.1,4.0,inf),
	\\atk, 2,
	\\sus, 2,
	\\rel, 0.5,

)");


DDWSnippets.put("bass1", "~b1[0] = Pbind(
	\\instrument, \\blip1,
	\\scale,  Scale.yu,
	\\degree, Pn(Pshuf([0,3,5,7,10],4),inf),
	\\octave, [2],
	\\dur, Pseq([0.25], inf),
	\\amp, 0.2,
	\\level, 1.5,
	\\atk, 0,
	\\sus, 0,
	\\rel, 0.75,
	\\curve,-6,
	\\pan,0
)");

DDWSnippets.put("bass2", "~b2[0]=  Pbind(
	\\instrument, \\ksBass,
	\\scale,  Scale.zhi,
	\\degree, Pn(Pshuf([0,2,5,7,9,7,5,2],4),inf),
	\\octave, [3],
	\\dur, Pseq([1/2], inf),
	\\amp, 0.2,
	\\level, 1.5,
	\\atk, 0,
	\\sus, 0,
	\\rel, 0.75,
	\\curve,-6,
	\\pan,0
)");
	DDWSnippets.put("bass3","~b3[0] = Pbind(
	\\instrument, \\bass,
	\\freq, 70 * Pseq([0,1].midiratio,inf).stutter(16) * Pseq([1,2],inf).stutter(64),
	\\fmrange, Pseq([0.5,1,1.5],inf),
	\\fmfreq, Pseq([0.5,1,2,4],inf),
	\\dur, 1/4,
	\\igate, Pseq([
		1,0,0,0,
		0,0,0,0,
	],inf),
	\\iadsr, Pseq([
		[ Env.adsr(0.1,0.1,0.8,4.1) ],
	],inf),
	\\lpf, Pkey(\\freq) * Pseq([
		2,1,4,8,
		2,1,4,8,
		2,1,4,8,
		4,2,2,4,
	],inf).stutter(8),
	\\hpf, Pkey(\\freq) / 2,

	\\amp, Pkey(\\amp) * 2,
	\\isRest, false,
)");

DDWSnippets.put("bass4","~b4[0] =  Pbind(
	\\instrument, \\subBass2,
	\\scale,  Scale.chinese,
	\\degree, Pn(Pshuf([0,4,6,7,11],4),inf),
	\\octave, [2],
	\\dur, Pseq([1], inf),
	\\amp, 0.09,
	\\level, 1.5,
	\\atk, 0,
	\\sus, 0,
	\\rel, 0.75,
	\\curve,-6,
	\\pan,0
)");
	DDWSnippets.put("bass5"," ~b5[0] = Pbind(
	\\instrument, \\subBass2,
	\\scale,  Scale.shang,
	\\degree, Pn(Pshuf([[0,2],[5,7],[10,2],[5,7]],4),inf),
	\\octave, [2,3,4],
	\\dur, Pseq([1], inf),
	\\amp, 0.09,
	\level, 1.5,
	\\atk, 0,
	\\sus, 0,
	\\rel, 0.75,
	\\curve,-6,
	\\pan,0
)");
	DDWSnippets.put("bass6","~b6[0] =Pbind(
	\\instrument, \\subBass2,
	\\scale, Scale.minorPentatonic,
	\\degree, Prand([0, [3,11], 7, [5,13],  10 ],inf),
	\\octave, [2,3,4],
	\\dur, Pseq([1], inf),
	\\amp, 0.09,
	\\level, 1.5,
	\\atk, 0,
	\\sus, 0,
	\\rel, 0.75,
	\\curve,-6,
	\\pan,0
)");

DDWSnippets.put("drones","
~r = {54};
~dfm1 = {arg mult = 1; DFM1.ar(SinOsc.ar([~r,~r*1.01]*mult,0,0.1),(~r*2)*mult,SinOsc.kr(0.05).range(0.9,1.1),1,0,0.0003,0.5)};
~dfm2 = {arg mult = 2; DFM1.ar(SinOsc.ar([~r,~r*1.01]*mult,0,0.1),(~r*2)*mult,SinOsc.kr(0.06).range(0.9,1.1),1,0,0.0003,0.5)};
~dfm3 = {arg mult = 3; DFM1.ar(SinOsc.ar([~r,~r*1.01]*mult,0,0.1),(~r*2)*mult,SinOsc.kr(0.056).range(0.9,1.1),1,0,0.0003,0.5)};
~dfm4 = {arg mult = 4; DFM1.ar(SinOsc.ar([~r,~r*1.01]*mult,0,0.1),(~r*2)*mult,SinOsc.kr(0.07).range(0.9,1.1),1,0,0.0003,0.5)};
~dfm5 = {arg mult = 4;DFM1.ar(SinOsc.ar([~r, ~r*1.02] * mult, 0, 0.1),(~r * 1.5) * mult,SinOsc.kr(0.1).range(0.8, 1.2),1,0,0.0004, 0.6)};
~dfm6 = {arg mult = 4;DFM1.ar(Pulse.ar([~r, ~r*1.03] * mult, 0.5, 0.1),(~r * 2.5) * mult,LFTri.kr(0.05).range(0.7, 1.3),1,0,0.0002,0.4)};
);
~dfm1.play;~dfm2.play;~dfm3.play;~dfm4.play;~dfm5.play;~dfm6.play");

DDWSnippets.put("droneFM01", "~f.play; ~f.awake_(false); ~f = {arg f1Freq=0.1,nFreq=440, m1Ratio=1,amp=0.1, dur=55, ampM=0.84 , pan=0;var sig, car1, mod1, env, index;index = LFNoise1.kr(0.2).range(2, 12);env = EnvGen.kr(Env.new([0, 0.70, 0.70, 0], [dur*0.333, dur*0.333, dur*0.333]), doneAction:2);mod1 = SinOsc.ar([nFreq * m1Ratio, nFreq+0.7 * m1Ratio], mul:nFreq * m1Ratio * index) * ampM;
car1 = SinOsc.ar(f1Freq + mod1); sig = car1* env * amp;sig = Pan2.ar(sig, pan);}");

DDWSnippets.put("reverb",
	"(
~mix.ar;
(
~verb = {
	XFade2.ar(
		LPF.ar(
			GVerb.ar(
				~mix.ar(1), 80,8, maxroomsize:1000),
			8500
		),
		~mix, \\pan.kr(0,0.5),\\rel.kr(0.15)
	)
};
~verb.play;
)
)");







//generic drum patterns
DDWSnippets.put("kick", "~k = Pbind(\\instrument,\\bplay,\\buf,d[\"k\"][0],\\dur,##1##,\\amp,1);");
DDWSnippets.put("hat","~h = Pbind(\\instrument,\\bplay,\\buf,d[\"ch\"][0],\\dur,##0.25##,\\amp,Pexprand(0.05,1));");
DDWSnippets.put("snare","~sn = Pbind(\\instrument,\\bplay,\\buf,d[\"s\"][0],\\dur,##2##,\\amp,1);");
DDWSnippets.put("clap","~c = Pbind(\\instrument,\\bplay,\\buf,d[\"c\"][0],\\dur,##0.75##,\\amp,1);");
DDWSnippets.put("oh","~oh = Pbind(\\instrument,\\bplay,\\buf,d[\"oh\"][1],\\dur,##Pseq([0.5,Pseq([1],inf)],inf)##,\\amp,1);");
DDWSnippets.put("backforth","~sn = Pbind(\\instrument,\\vplay,\\buf,d[\"s\"][0],\\dur,Pbjorklund2(Pwhite(1,6),16)/4,\\amp,1,\\rate,Prand([-1,1],inf),\\pos,Pkey(\\rate).linlin(-1,1,0.99,0));");
//rave drums
DDWSnippets.put("ravedrums","(
~kbk = Pbind(\\instrument,\\bplay,\\buf,Prand(d[\"breaks175\"],inf),\\dur,16,\\amp,1);
~kbk2 = Pbind(\\instrument,\\bplay,\\buf,Prand(d[\"breaks175\"],inf),\\dur,16,\\amp,1);
)");
//rave piano
DDWSnippets.put("ravepiano","(
~piano1 = Pbind(\\instrument,\\bplay,\\buf,d[\"piano\"][1],\\dur,16,\\amp,1);
~piano2 = Pbind(\\instrument,\\bplay,\\buf,d[\"piano\"][1],\\dur,32,\\amp,1,\\rate,0.5);
)");
//quarter note Piano Chop
DDWSnippets.put("pianochop","~pianoChop = Pbind(\\instrument,\\vplay,\\buf,d[\"piano\"][1],\\dur,0.25,\\atk,0,\\sus,0.04,\\rel,0,\\pos,Pexprand(0.2,0.5),\\amp,1,\\rate,2)");
//Rave piano stabs
DDWSnippets.put("pianostab","~ravestab2 = Pbind(\\instrument,\\bplay,\\buf,d[\"stab\"][2],\\dur,Pbjorklund2(3,8)/4,\\rate,Pseq([50,52,55,57].midicps/120,inf).stutter(6),\\amp,1)");
//strings
DDWSnippets.put("strings","~strings = Pbind(\\instrument,\\bplay,\\buf,d[\"strings\"][0],\\dur,10,\\rate,3,\\amp,2)");


//hi pass
DDWSnippets.put("hipass","~hipass = {HPF.ar(Mix.ar([~kbk.ar,~kbk2.ar]),1200,0.6)}");


//Specific pattern generators
DDWSnippets.put("Prand","Prand([##1,0##],inf)");
DDWSnippets.put("Pwrand","Pwrand([##1,0##],[10,1].normalizeSum,inf)");
DDWSnippets.put("e8", "Pbjorklund2(##3##,8)/4");
DDWSnippets.put("e16","Pbjorklund2(##3##,16)/4");
DDWSnippets.put("offbeat","Pseq([0.5,Pseq([1],inf)],inf)");
DDWSnippets.put("Pexprand","Pexprand(##0.001,1##)");
DDWSnippets.put("Pseq","Pseq([##1,2,3,4,5##],inf)");

//Scales
DDWSnippets.put("scale","Scale.chromatic(\\et53);");
DDWSnippets.put("root","~r = {0}");

//Modulation snippets
DDWSnippets.put("EnvPerc","EnvGen.ar(Env.perc(##0.01,1##),Impulse.kr(p.clock.tempo),1,0,1,0)");
DDWSnippets.put("LFN1","LFNoise1.kr(0.1).range(##100,3000##).round(100)");
DDWSnippets.put("SinOsc","{SinOsc.kr(0.1).range(##0.01,1.01##)}");

//instrument generators
//DFM1 drone
DDWSnippets.put("DFMDrone","{DFM1.ar(SinOsc.ar([##100,101##],0,0.1),200,SinOsc.kr(0.05).range(0.9,1.1),1,0,0.0003,0.5)};");
//'ring' acid bass sound
DDWSnippets.put("ring1","Pbind(\\instrument,\\ring1,\\f,Pkey(\\freq),\\scale,d[\\scale],\\root,Pkr(~r),\\degree,0,\\octave,4,\\dur,##1##,\\d,0.6,\\a,1,\\pan,0,\\amp,0.5);");
//ring sound with no scale
DDWSnippets.put("ring1f","Pbind(\\instrument,\\ring1,\\f,Pkr(~r2),\\dur,##1##,\\d,0.6,\\a,1,\\pan,0,\\amp,0.5);");
//sinfb Pbind - no scale
DDWSnippets.put("sinfb","Pbind(\\instrument,\\sinfb,\\freq,Pseq([##1,2,3,4,5##],inf)*Pkr(~r2),\\dur,0.25,\\amp,0.3,\\fb,0.1,\\rel,0.3);");
//sinfb Pbind - using a scale
DDWSnippets.put("sinfbscale","Pbind(\\instrument,\\sinfb,\\scale,d[\\scale],\\root,Pkr(~r),\\octave,4,\\degree,##0##,\\dur,0.25,\\amp,0.3,\\fb,0.1,\\rel,0.3);");
//henon Pbind
DDWSnippets.put("henon","Pbind(\\instrument,\\henon,\\freq,44100,\\dur,0.25,\\a,Pexprand(1.3,1.3),\\b,Pexprand(0.3,0.3),\\atk,0,\\sus,0,\\rel,Pexprand(##0.01,0.1##),\\amp,1);");
//RLPFD instrument - a drone using LFSaws. 'speed' argument is for quickness when setting up harmonic series sweeps
DDWSnippets.put("rlpfd","~rlpfd = {arg speed = 0.5; RLPFD.ar(Mix(LFSaw.ar([120, 180], 0, 0.33)), LinExp.kr(LFCub.kr(0.1, 0.5*pi), -1, 1, 280, 1500), 0.6, 0.5, mul:3).dup }");
//Streson instrument - a drone using LFSaws. 'speed' argument controls speed of sweep and min/max. res controls strength of the effect.
DDWSnippets.put("stresondrone","{ Streson.ar(LFSaw.ar([220, 180], 0, mul:EnvGen.kr(Env.asr(0.5, 1, 0.02), 1.0) * 0.2), LinExp.kr(LFCub.kr(0.1, 0.5*pi), -1, 1, 280, 377).reciprocal, 0.9, 0.3) }");
//rave stabs
DDWSnippets.put("ravestabs","~ravestab = Pbind(\\instrument,\\bplay,\\buf,d[\"stab\"][1],\\dur,Pbjorklund2(3,8)/4,\\rate,Pseq([1,1,1,1,1,1,0.9,1.1]##*1##,inf).stutter(3),\\amp,1)");
//warp1 - scrolls a buffer
DDWSnippets.put("warp1","~warp1 = {arg speed = 0.01, winsize = 0.2, rate = 1; Warp1.ar(2,##d[\"rhodes\"][0]##,LFTri.kr(speed),rate,winsize,-1,16,0.02,4,0.5)}");

//effects
//Low Pass Filter
DDWSnippets.put("LPF","
//Low Pass
~lpfSend = {Mix.ar([##~one##])};
~lpf = {RLPF.ar(NumChannels.ar([~lpfSend]),SinOsc.kr(0.1).range(440,440),0.1)};
~lpf.play;");
//Hi-Pass Filter
DDWSnippets.put("HPF","
//High Pass
~hpfSend = {Mix.ar([##~one##])};
~hpf = {RHPF.ar(NumChannels.ar([~lpfSend]),SinOsc.kr(0.1).range(440,440),0.1)};
~lpf.play;");
//Delay - CombC
DDWSnippets.put("Delay","
//delay
~delaySend = {Mix.ar([##~one##])};
~delay = {CombC.ar(NumChannels.ar([~delaySend]),p.clock.tempo*4,p.clock.tempo/16,1)};
~delay.play;");
//Reverb - GVerb
DDWSnippets.put("Reverb","
//delay
~reverbSend = {Mix.ar([##~one##])};
~reverb = {arg size = 10, time = 5, damping = 0.5, spread = 15, dry = 0, amp = 0.8; GVerb.ar(Mix.ar([~reverbSend.ar]),size,time,damping,0.5,spread,dry,mul:amp)}
~reverb.play;");
//low shelf on rave drums
DDWSnippets.put("lowshelf","~lsf = {LowShelf.ar(Mix.ar([~kbk.ar,~kbk2.ar]),200,1,##10##)}");

//Streson - speed controls speed of sweep and min/max control minimum and maximum values. Keep them low and with not a lot between for sensible effects and don't for silly ones. res controls the severity of the effect
DDWSnippets.put("stresonsend","
//streson
~stresonSend = {Mix.ar([##~one##])};
~streson = {arg speed = 0.01, min = 0.00001, max = 0.0001, res = 0.99; Streson.ar(NumChannels.ar([~stresonSend.ar]),SinOsc.kr(speed).range(min,max),res)};
~streson.play;");
//rlpfd filter
DDWSnippets.put("rlpfdFilter","
//rlpfd
~rlpfdSend = {Mix.ar([##~one##])};
~rlpfd = {arg speed = 0, min = 200, max = 500, res = 0.5, dist = 0.5; RLPFD.ar(NumChannels.ar([~rlpfdSend]),SinOsc.kr(speed).range(min,max),res,dist,3)};
~rlpfd.play;");
//DFM1 filter - freq, res, noise self-explanatory. type 0 = LPF 1 = HPF
DDWSnippets.put("dfm1Filter","
~dfm1Send = {Mix.ar([##~one##])};
~dfm1Filt = {arg freq = 1000, res = 0.7, noise = 0.0003, type = 0; DFM1.ar(NumChannels.ar([~dfm1Send]),freq,res,1,type,noise,1)};
~dfm1Filt.play;");




//generic Tdef snippet
DDWSnippets.put("Tdef","
(
Tdef(\\task,{
	loop{
		##stuff.do##
		1.wait;
}});
)
Tdef(\\task).play;");

//added on 22nd September 2017

//generic MIDI snippet
DDWSnippets.put("MIDI","
(
~midiPattern = Pbind(
    \\type, \\midi,
    \\midicmd, \\noteOn,
	\\midiout, d[\\m],
    \\chan, 0,
	\\scale,d[\\scale],
	\\degree, ##0##,
	\\octave, 3,
	\\dur, 1,
	\\legato, 0.1
)
)");

//generic Pitch Bend snippet for microtonal patterns
DDWSnippets.put("bend","
(
~midiBend = Pbind(
\\type,\\midi,
\\midicmd,\\bend,
\\midiout,d[\\m],
\\chan,0,
\\dur,1,
\\val,Pwhite(##8192,9182##)
)
)");

//offbeat cymbal
DDWSnippets.put("cym","~cym = Pbind(\\instrument,\\bplay,\\buf,d[\"cym\"][0],\\dur,Pseq([0.5,Pseq([1],inf)],inf),\\rel,##0.5##,\\amp,0.5)");

//toms
DDWSnippets.put("tom","~tom = Pbind(\\instrument,\\bplay,\\buf,d[\"t\"][0],\\dur,Pbjorklund2(3,16)/4,\\amp,1,\\rate,1)");

//synth verb
DDWSnippets.put("synthverb","~synth = {Pan2.ar(FreeVerb.ar(SoundIn.ar(0),0.33,##0.7##,0.5))}");

//looped sound
DDWSnippets.put("loop","~loop = Pbind(\\instrument,\\lplay,\\buf,d[\"breaks\"][0],\\dur,##8##,\amp,0.5)");

//enveloped warp1
DDWSnippets.put("warpenv","(
~warpEnv = {var env = EnvGen.ar(Env.perc(0.01,0.5,0.1),Impulse.kr(LFNoise1.kr(0.1).range(0.5,4)),1,0,1,0);
	Warp1.ar(2,##d[\"rhodes\"][0]##,LFTri.kr(0.01)+env,2,0.2,-1,32,0.01,4,env*4)}
)");

//Reverb send for external effects
DDWSnippets.put("reverbsend","(
~verbSend = {
	var array = [##~none.ar##];
	Out.ar(2,Mix.ar(array)!2)
}
)");