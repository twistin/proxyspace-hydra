(
// RESET
Buffer.freeAll;
ServerTree.removeAll;
ServerQuit.removeAll;
Server.killAll;
Tdef.removeAll;
StageLimiter.deactivate;

// SERVER OPTIONS
s.options.device = "Scarlett 2i2 USB"; // AJUSTA esto si tu dispositivo tiene otro nombre exacto
s.options.sampleRate = 48000;
s.options.blockSize = 64;
s.options.hardwareBufferSize = 128;
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 128;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.latency = 0.3;

// MIDI
MIDIIn.connectAll;
m = MIDIOut.new(0);
m.latency = 0;
CmdPeriod.add({
    (0..127).do({ |n| m.noteOff(0,n); });
});

// INICIAR SERVIDOR
s.waitForBoot({
    // Abrir Logic (de forma asíncrona)
    "open -a '/Applications/Logic Pro X.app/'".unixCmd;
    "Logic Pro ahora deberá estar abierto...".postln;

    // Scope
    s.scope;

    // GUI protegida
    AppClock.sched(1.0, {
        v = View(nil, Rect(0, 0, 300, 400)).front.alwaysOnTop_(true);
        s.plotTreeView(parent: v);
        nil
    });

    // ProxySpace
    p = ProxySpace.push(s);
    p.makeTempoClock;
    t = p.clock.tempo_(90/60);
    p.fadeTime_(2.5);
    p.quant_(4);

    // CARGA DE SAMPLES Y SCRIPTS
    Task({
        var d = Dictionary.new;
        var foldernames = PathName(thisProcess.nowExecutingPath.dirname +/+ "../samples/set1").entries;

        d.add(\foldernames -> foldernames);

        foldernames.do { |dir|
            var files = dir.entries;
            d.add(dir.folderName -> files.collect({ |sf|
                Buffer.read(s, sf.fullPath);
            }));
        };

        s.sync; // Esperar a que se carguen todos los buffers

        "SynthDefs.scd".loadRelative;
        "Snippets.scd".loadRelative;

        2.wait;

        StageLimiter.activate;

        "✔️ Setup completado sin errores ni retrasos.".postln;
    }).start;
});
)
