
("../Setup/Setup.scd").loadRelative;



s.boot;
// algún código que podamos querer usar más tarde...
~algo = {Pulse.ar(80)*EnvGen.ar(Env.perc, doneAction:2)};
// cuando llegue el momento, ¡llámalo por su nombre y reprodúcelo!
~algo.play



SystemClock.sched(2,{"foo".postln});

// "foo" se repite cada segundo
SystemClock.sched(0, {"foo".postln; 1.0 });
// "bar" se repite con un retardo aleatorio
SystemClock.sched(0, {"bar".postln; 1.0.rand });
// borrar todos los eventos programados
SystemClock.clear;


// causa un error de "la operación no puede ser llamada desde este Proceso"
SystemClock.sched(1, { SCWindow.new.front });

// aplazar reprograma el código GUI en el AppClock, así que esto funciona
SystemClock.sched(1,{{SCWindow.new.front}.defer});


//TempoClock
(
t = TempoClock.new; // hacer un nuevo TempoClock
t.sched(0, {"¡Hola!".postln; 1});
)
t.tempo = 2; // dos veces más rápido
t.clear;

(
// Rutina (
r = Routine({
"foo".yield;
"bar".yield;
});
)
r.value; // foo
r.value; // bar
r.value; // hemos llegado al final, por lo que devuelve nil
r.reset;











// Rutina en un reloj
(
r = Routine({
"foo".postln;
1.yield; // reprogramación después de 1 segundo
"bar".postln;
1.yield;
"foobar".postln;
});
SystemClock.sched(0, r);
)
// Figura 3.1 Una simple rutina que ilustra un uso musical de yield
// Fermata
(
r = Routine({
x = Synth(\default, [freq: 76.midicps]);
1.wait;
x.release(0.1);
y = Synth(\default, [freq: 73.midicps]);
"Esperando...".postln;
nil.yield;// fermata
y.release(0.1);
z = Synth(\default, [freq: 69.midicps]);
2.wait;
z.release;
});
)
// haz esto y luego espera la fermata
r.play;
// siente la dulce tónica...
r.play;

(
{
"algo".postln;
1.wait;
"algo más".postln;
}.fork;
)





// Figura 3.2 Usando Tarea para poder pausar la secuencia
(
t = Task({
loop({ // bucle de todo
3.do({ // hacer esto 3 veces
x.release(0.1);
x = Synth(\default, [freq: 76.midicps]);
0.5.wait;
x.release(0.1);
x = Synth(\default, [freq: 73.midicps]);
0.5.wait;
});
"Estoy esperando a que pulses reanudar".postln;
nil.yield;// fermata
1.wait;
x.release;
});
});
w = Window.new("Ejemplo de tarea", Rect(400, 400, 200, 30)).front;
w.view.decorator = FlowLayout(w.view.bounds);
Button.new(w, Rect(0, 0, 100, 20)).states_([["Reproducir/Reanudar",
Color.black, Color.clear]])
.action_({ t.resume(0);});
Button.new(w, Rect(0, 0, 40, 20)).states_([["Pausa", Color.black,
Color.clear]])
.action_({ t.pause;});
Button.new(w, Rect(0, 0, 40, 20)).states_([["Finalizar", Color.black,
Color.clear]])
.action_({
t.stop;
x.release(0.1);
w.close;
});
)





// Figura 3.3 Anidación de tareas dentro de rutinas
(
r = Routine({
c = TempoClock.new; // hacer un TempoClock
// iniciar un bucle "tamblory"
t = Task({
loop({
x.release(0.1);
x = Synth(\default, [freq: 61.midicps, amp: 0.2]);
			0.2.wait;
x.release(0.1);
x = Synth(\default, [freq: 67.midicps, amp: 0.2]);
rrand(0.075, 0.25).wait; // espera aleatoria de 0.1 a 0.25 segundos
});
}, c); // usar el TempoClock para reproducir esta tarea
t.start;
nil.yield;
// ahora añadir algunas notas
y = Synth(\default, [freq: 73.midicps, amp: 0.3]);
nil.yield;
y.release(0.1);
y = Synth(\default, [freq: 79.midicps, amp: 0.3]);
c.tempo = 2; // doble tiempo
nil.yield;
t.stop;
y.release(1);
x.release(0.1); // detener la tarea y los sintetizadores
});
)
r.next; // iniciar el bucle
r.next; // primera nota
r.next; // segunda nota; el bucle va a "doble tiempo"
r.next; // detener el bucle y el





// Figura 3.5 Gracias al polimorfismo podemos sustituir objetos que  entienden el mismo mensaje
(
p = 65; // una nota constante
q = Pseq([1, 2, 0.5], inf).asStream; // secuencia ordenada de  duraciones
t = Task({
loop({
x.release(2);
x = Synth(\default, [freq: p.value.midicps]);
q.value.wait;
});
});
t.start;
)
// ahora cambia p
p = Pseq([23,34,56], inf).asStream; // a un patrón: do re mi
p = { rrand(64, 76) }; // a una función: notas aleatorias de una  octava cromática
t.stop;
x.release(2);







(
SynthDef("ScoreSine",{ arg freq = 440;
Out.ar(0, SinOsc.ar(freq));
}).add;
x=[
// los args para s_new son synthdef, nodeID, addAction, targetID,  synth args ...
[0.0, [ \s_new, \ScoreSine, 1000, 0, 0,  \freq, 1413 ]],
[0.5, [ \s_new, \ScoreSine, 1001, 0, 0,  \freq, 712 ]],
[1.0, [ \s_new, \ScoreSine, 1002, 0, 0,  \freq, 417 ]],
[2.0, [\c_set, 0, 0]] // comando ficticio para marcar el final del  tiempo de síntesis NRT
	];
z = Score(x);
)
z.play;
z.clear(3)








// Figura 3.7 Ejecutando una línea a la vez
(
// aquí hay un synthdef que nos permite reproducir desde un buffer,  con un desvanecimiento
SynthDef("playbuf", { arg out = 0, buf, gate = 1;
Out.ar(out,
PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop: 1.0)
* Linen.kr(gate, doneAction: 2); // libera el sintetizador cuando el  desvanecimiento haya terminado
)
}).add;
// carga todas las rutas de la carpeta sounds/ en buffers
~algunosSonidos = "sounds/*".pathMatch.collect{ |path | Buffer.read(s,
path)};
)
// ahora aquí está la partitura, por así decirlo
// ejecuta estas una línea a la vez
~reproduciendoAhora = Synth("playbuf", [buf: ~algunosSonidos]);
~reproduciendoAhora.release;
~reproduciendoAhora = Synth("playbuf", [buf: ~algunosSonidos[1]]);
~reproduciendoAhora.release;
~reproduciendoAhora = Synth("playbuf", [buf: ~algunosSonidos[2]]);
~reproduciendoAhora.release;
// libera la memoria del buffer
~algunosSonidosBuffered.do(_.free);







~miBuffer = Buffer.read(s, "sounds/a11wlk01.wav"); // cargar un sonido
~miBuffer.play; // reproducirlo y notar que liberará el nodo después
de reproducirlo


s.boot;

(
Buffer.freeAll;
~path = PathName(thisProcess.nowExecutingPath).parentPath;
b = (
	g0: Buffer.read(s,~path ++ "g0.aiff"),
	g1: Buffer.read(s,~path ++ "g1.aiff"),
	g2: Buffer.read(s,~path ++ "g2.aiff"),
	)
)


(

SynthDef("playbuf", { arg out = 0, buf, gate = 1;
Out.ar(out,
PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop: 1.0)
* Linen.kr(gate, doneAction: 2) * 0.6;
// con 'doneAction: 2' liberamos el sintetizador cuando el fundido ha  terminado
)
}).add;
~algunosSonidos = "sounds/*".pathMatch.collect{ |path | Buffer.read(s,
~path)};
n = 0; // un contador
// aquí está nuestro código GUI
w = Window.new("Simple CuePlayer", Rect(400, 400, 200, 30)).front;
w.view.decorator = FlowLayout(w.view.bounds);
//esto reproducirá cada pista por turno
Button.new(w, Rect(0, 0, 80, 20)).states_([["Reproducir pista",
Color.black, Color.clear]]).action_({
if(n < ~algunosSonidos.size, {
if(n != 0, {~reproduciendoAhora.release;});
~reproduciendoAhora = Synth("playbuf", [buf: ~algunosSonidos[n]]);
n=n+1;
});
});
//esto establece el contador en la primera pista
Button.new(w, Rect(0, 0, 80, 20)).states_([["Detener / Reiniciar",
Color.black, Color.clear]]).action_({
n=0;
~reproduciendoAhora.release;
});
// libera los buffers cuando la ventana se cierra




VDiskIn

// Figura 3.9 Recopilación de archivos para pistas multicanal
// reunir todas las rutas de tus carpetas
//esto coincidirá con la ruta de cada carpeta de la colección, es decir, tendremos una colección de colecciones de rutas
~grupoDeCarpetasDePistasIndividuales = "/Users/sdcarr/Desktop/My-setup-sc-live-coding/samples/set1/".pathMatch.collect{ |
item | (item.asSymbol++"*").pathMatch };
Post << ~grupoDeCarpetasDePistasIndividuales; //¡verlas todas!
//comprobar cuántas pistas tendrás al final
~grupoDeCarpetasDePistasIndividuales.size;
//automatizar el proceso de almacenamiento en buffer para todas las pistas:
~pistasEnBuffer = ~grupoDeCarpetasDePistasIndividuales.collect{ |item,
i|
item.collect{|indivPath| Buffer.read(s, indivPath)};
};
//escuchar una de las pistas para comprobar que el proceso de buffering fue exitoso
~pistasEnBuffer;
//aquí está la pista 1
// verla en la ventana de publicación:
Post << ~pistasEnBuffer;
// reproducirlas todas en un grupo, utilizando nuestro synthdef anterior
// utilizamos bind aquí para asegurarnos de que comienzan simultáneamente
(
s.bind({
~reproduciendoAhora = Group.new(s); // un grupo para poner todos los sintetizadores de canal
~pistasEnBuffer.do({|pista| Synth("playbuf", [buf: pista],
~reproduciendoAhora)})
});
)
// desvanecerlas todas juntas enviando un mensaje de liberación al  grupo
~reproduciendoAhora.release;

Figura 3.9 Recopilación de archivos para pistas multicanal.

// Figura 3.10 Grabación de los resultados de hacer sonidos con  supercollider
s.boot; // asegúrate de que el servidor está en funcionamiento (
// primero evalúa esta sección
b = Buffer.read(s, "wood/w0.aiff"); // una fuente
s.prepareForRecord; // preparar el servidor para grabar (debes hacerlo
primero)
