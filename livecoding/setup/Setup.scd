//Boilerplate code for basic live coding functionality

(
Buffer.freeAll;
ServerTree.removeAll;
ServerQuit.removeAll;
Server.killAll;
Tdef.removeAll;
StageLimiter.deactivate;

//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 128;
//boot the server
s.boot;

// setup midi (controlador y Logic)

MIDIIn.connectAll;
m = MIDIOut.new(0);
m.latency = 0;
CmdPeriod.add({
	(0..127).do({
		arg n;
		m.noteOff(0,n);
	});
});

// display nodeTree

v = View(nil, Rect(0, 0, 300, 400)).front.alwaysOnTop_(true);
s.plotTreeView(parent: v);

//display the oscilloscope
s.scope;

// Abre Logic Pro X
"open -a '/Applications/Logic Pro X.app/'".unixCmd;
"Logic Pro ahora deberá estar abierto..".postln;

//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
t = p.clock.tempo_(90/60);

p.fadeTime_(2.5);
p.quant_(4);

s.waitForBoot({

Task({
	d = Dictionary.new;
        d.add(\foldernames -> PathName(thisProcess.nowExecutingPath.dirname +/+ "../samples/set1").entries);
	for (0, d[\foldernames].size-1,
		{arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
	("synthdefs.scd").loadRelative;
	//loads snippets from setup folder
	("Snippets.scd").loadRelative;
	//wait, because otherwise it won't work for some reason
	3.wait;
	//activate StageLimiter - Part of the BatLib quark
	StageLimiter.activate;

	"Setup done!".postln;
}).start;

})
)
