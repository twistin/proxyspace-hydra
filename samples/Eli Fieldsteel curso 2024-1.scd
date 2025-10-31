//Eli Fieldsteel curso 2024

// Signal Processing - Week 10 Fall 2024 MUS 499C - Creative Audio Coding with SuperCollider


12,6 K suscriptores

Suscrito

3


Compartir





~f = {arg base, exp; base.pow(exp)};
~f.(2,4)

~ar = {rrand(40,80)}!10;
~newar = ~ar.collect({
	arg item;
	item + [0,2,7].choose
});


(

SynthDef(\gen, {
	var sig;
	sig = Saw.ar(\freq.ir(200)* [0, \dtn.ir(0.1)].midiratio);
	sig = LPF.ar(sig, \cf.ir(2000).clip(20,20000));
	sig = sig * Env.perc(\atk.ir(0.002), \rel.ir(0.25)).kr(2);
	sig = sig * \amp.ir(0.2);
	Out.ar(\out.ir(0),sig);
}).add;



SynthDef(\rev, {
	var sig, fx;
	sig = In.ar(\in.ir(0), 2);
	fx = FreeVerb2.ar(sig[0], sig[1], 1, 0.95);
	sig = sig.blend(fx, \mix.kr(0.15));
	Out.ar(\out.ir(0), sig)
}).add;




)


Synth(\rev, [in:37]);


Synth(\gen, [out:37, freq:rrand(40,70).midicps]);
s.meter;
s.scope;

//// Buses

s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.options.numAudioBusChannels ;
s.options.numControlBusChannels;
s.options.numPrivateAudioBusChannels


(

s.newBusAllocators; // para resetear la asignacion de buses
~revbus = Bus.audio(s,2);
~echobus = Bus.audio(s, 2);


)

~revbus = Bus.audio(s,2);


Synth(\rev, [\in, ~revbus, \out, 0]);

Synth(\gen, [\out, ~revbus, \freq, rrand(40,70).midicps]);





OffsetOut

ReplaceOut
SoundIn

///  Input/Output Ugens



(

SynthDef(\gen, {
	var sig;
	//sig = Saw.ar(\freq.ir(200)* [0, \dtn.ir(0.1)].midiratio);
	//sig = LPF.ar(sig, \cf.ir(2000).clip(20,20000));
	sig = In.ar(\in.ir(2));
	//sig = sig * Env.perc(\atk.ir(0.002), \rel.ir(0.25)).kr(2);
	sig = sig * \amp.ir(0.5);
	Out.ar(\out.ir(0),sig);
}).add;



SynthDef(\rev, {
	var sig, fx;
	sig = In.ar(\in.ir(2),2);
	fx = FreeVerb2.ar(sig[0], sig[1], 1, 0.95);
	sig = sig.blend(fx, \mix.kr(0.15));
	Out.ar(\out.ir(0), sig)
}).add;
)


Synth(\rev, [\in, ~revbus, \out, 0]);

Synth(\gen, [\out, ~revbus, \freq, rrand(40,70).midicps]);




// Order of Execution

(

SynthDef(\gen, {
	var sig,freq;
	freq = LFNoise0.ar(1!2).exprange(200,1000);
	sig = Saw.ar(freq * [0,\dtn.ir(0.1)].midiratio);
	sig = LPF.ar(sig, \cf.ir(2000).clip(20,20000));
	//sig = sig * Env.perc(\atk.ir(0.002), \rel.ir(0.25)).kr(2);
	sig = sig * \amp.ir(0.2);
	Out.ar(\out.ir(0),sig);
}).add;



SynthDef(\rev, {
	var sig, fx;
	sig = In.ar(\in.ir(0), 2);
	fx = FreeVerb2.ar(sig[0], sig[1], 1, 0.95);
	sig = sig.blend(fx, \mix.kr(0.15));
	Out.ar(\out.ir(0), sig)
}).add;




)



(

SynthDef(\gen, {
	var sig,freq;
	freq = LFNoise0.ar(8!2).exprange(40,1000).round(40);
	sig = Saw.ar(freq * [0,\dtn.ir(0.1)].midiratio);
	sig = LPF.ar(sig, \cf.ir(2000).clip(20,20000));
	//sig = sig * Env.perc(\atk.ir(0.002), \rel.ir(0.25)).kr(2);
	sig = sig * \amp.ir(0.2);
	Out.ar(\out.ir(0),sig);
}).add;



SynthDef(\rev, {
	var sig, fx;
	sig = In.ar(\in.ir(0), 2);
	fx = FreeVerb2.ar(sig[0], sig[1], 1, 0.95);
	sig = sig.blend(fx, \mix.kr(0.15));
	Out.ar(\out.ir(0), sig)
}).add;
)

x = Synth(\rev, [\in, ~revbus, \out, 0]);

y = Synth(\gen, [\out, ~revbus, \freq, rrand(40,70).midicps]);
x.free;
y.free;

/// Groups

x = Synth(\gen, [\out, ~revbus, \freq, rrand(40,70).midicps]);
y = Synth(\rev, [\in, ~revbus, \out, 0],x, \addAfter);


x.free;
y.free;
















