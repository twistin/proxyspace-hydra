
var	sf, sfDisplay, envir;

envir = Environment.make {
	{
		var cond = CondVar.new;

		var startPath = Archive.at(\sampleAuditionPath) ?? {
			"~/".standardizePath
		};

		if(s.serverRunning.not) { s.waitForBoot; };
		0.2.wait;

		"Choose a soundfile inside the directory you want to audition".postln;
		FileDialog(inEnvir { |path|
			// check for avconv
			var pipe = Pipe("which ffmpeg", "r"), line, avconvPath;
			var statusBox;

			if(pipe.isOpen) {
				protect {
					while {
						line = pipe.getLine;
						avconvPath.isNil and: { line.notNil }
					} {
						if(line.contains("ffmpeg")) {
							avconvPath = line;
						}
					};
				} { pipe.close };
			};

			~dir = path.dirname;
			~aliases = Dictionary.new;

			~filters = ["\\.aif+$".matchRegexp(_), "\\.wav$".matchRegexp(_),
				"\\.flac$".matchRegexp(_), "\\.ogg$".matchRegexp(_), "\\.mp3$".matchRegexp(_),
				"\\.m4a$".matchRegexp(_)
			];

			if(avconvPath.notNil) {
				// ~filters = ~filters.add("\\.mp3$".matchRegexp(_));
				~preprocessors = [
					~filters.last -> { |fdesc, cond|
						var path = fdesc.path,
						// in theory it's possible to have "xyz.mp3" and "xyz1000.wav"
						// but I'll go with... not likely
						decoded = path.splitext[0] ++ UniqueID.next ++ ".wav", errWindow, sf;
						if(~aliases[path].isNil) {
							if(File.exists(decoded)) {
								// file exists, don't re-decode.
								// but we have to allow the caller to hang the condition
								// before unhanging
								{
									cond.test = true;
									cond.unhang;
								}.defer(0.01);
							} {
								"ffmpeg -i '%' '%'".format(path, decoded).unixCmd(inEnvir { |exit|
									if(exit == 0) {
										~aliases.put(path, decoded);
										sf = SoundFile.openRead(decoded);
										if(sf.notNil) {
											// (path: path, numChan: sf.numChannels, dur: sf.duration)
											fdesc.put(\numChan, sf.numChannels)
											.put(\dur, sf.duration);
											sf.close;
										};
										cond.test = true;
										cond.unhang;
									} {
										defer {
											errWindow = Window("MP3 decoding failed",
												Rect.aboutPoint(Window.screenBounds.center, 100, 50)
											);
											errWindow.layout = VLayout(
												StaticText().align_(\center)
												.string_("Decoding % failed".format(path.basename)),
												Button().states_([["OK"]]).action_({ errWindow.close })
											);
											errWindow.front;
										};
										cond.test = false;
										cond.unhang;
									};
								});
							};
						} {
							{
								cond.test = true;
								cond.unhang;
							}.defer(0.01);
						};
					}
				];
				~preprocessors = ~preprocessors.add(
					~filters[~filters.size-2] -> ~preprocessors.first.value
				);
			};

			~files = (~dir +/+ "*").pathMatch.select { |path|
				path = path.toLower;
				~filters.any(_.value(path))
			}.collect { |path|
				if((sf = SoundFile.openRead(path)).notNil) {
					sf.close;
					(path: path, numChan: sf.numChannels, dur: sf.duration)
				} {
					// "% couldn't be opened".format(path).warn;
					(path: path)
				};
			};

			if(~files.size > 0) {

				~volBus = Bus.control(s, 1).set(1);

				~window = Window("sample audition: " ++ ~dir.basename, Window.screenBounds);
				~window.layout = VLayout(
					HLayout(
						~playstop = StaticText().fixedSize_(Size(300, 20)).align_(\center)
						.string_("spc to play"),
						StaticText().fixedSize_(Size(80, 20)).align_(\right)
						.string_("volume"),
						~volNum = NumberBox().fixedSize_(Size(60, 20)).align_(\center)
						.value_(1)
						.keyDownAction_(inEnvir { |view, char|  // mods, unicode, keycode
							case
							{ char == $  } { ~togglePlay.(~files[view.value]) };
						})
						.action_(inEnvir { |view|
							var value = view.value.clip(0, 1);
							~volBus.set(view.value);
							~volSlider.value = \amp.asSpec.unmap(value);
						}),
						~volSlider = Slider().fixedHeight_(24).orientation_(\horizontal)
						.value_(1)
						.keyDownAction_(inEnvir { |view, char|  // mods, unicode, keycode
							case
							{ char == $  } { ~togglePlay.(~files[view.value]) };
						})
						.action_(inEnvir { |view|
							var value = \amp.asSpec.map(view.value);
							~volBus.set(value);
							~volNum.value = value;
						}),
						Button().fixedSize_(Size(120, 20))
						.states_([["sfview off"], ["sfview ON"]])
						.action_(inEnvir { |view|
							~enableSFView.(view.value > 0);
						}),
						nil
					),
					HLayout(
						~fileList = ListView().fixedWidth_(300),
						~sfv = SoundFileView().timeCursorColor_(Color.white)
					)
				);

				~fileList.items_(~files.collect({ |file| file.path.basename }))
				.action_(inEnvir { |view|
					~showSF.(~files[view.value]);
				})
				.keyDownAction_(inEnvir { |view, char|  // mods, unicode, keycode
					case
					{ char == $  } { ~togglePlay.(~files[view.value]) };
				})
				.beginDragAction_(inEnvir { |view|
					~files[view.value].path.asCompileString
				});


				// ~sfvContainer = CompositeView(~window, Rect(0, 0, ~window.view.decorator.indentedRemaining.width, Window.screenBounds.height - 150))
				// .background_(Color.blue(alpha: 0.1));
				// ~sfv = SoundFileView(~sfvContainer, ~sfvContainer.bounds.moveTo(0, 0).insetBy(2, 2))
				// .timeCursorColor_(Color.white);
				~showSF = { |fdesc|
					{
						var cond, preproc, path;
						preproc = ~preprocessors.detect { |assn|
							assn.key.value(fdesc.path.toLower)
						};
						if(preproc.notNil) {
							cond = Condition(false);
							preproc.value.value(fdesc, cond);
							cond.hang;
							if(cond.test.not) {
								~nowPlaying = nil;
								nil.alwaysYield;  // fail
							};
						};
						if(~aliases[fdesc.path].notNil) {
							path = ~aliases[fdesc.path]
						} {
							path = fdesc.path;
						};

						sfDisplay.tryPerform(\close);
						sfDisplay = SoundFile.openRead(path);
						~sfv.soundfile_(sfDisplay).read(0, sfDisplay.numFrames).refresh;
					}.fork(AppClock);
				};
				~sfPhaseResp = OSCFunc(inEnvir { |msg|
					defer(inEnvir { ~sfv.timeCursorPosition = msg[3] });
				}, '/phase', s.addr);

				~window//.recursiveResize
				.onClose_(inEnvir {
					~window.onClose_(nil);
					~freeCleanup.();
				})
				.front;

				~makeSynthDefs = {
					// ~files.collect(_.numChan).as(IdentitySet)
					(1..8).do { |numch|
						SynthDef("sampPlay" ++ numch, { |bufnum, gate = 1, amp = 1, vol = 1, start = 0, out|
							var	phase = Line.ar(0, BufFrames.kr(bufnum), BufDur.kr(bufnum), doneAction: 2),
							sig = BufRd.ar(numch, bufnum, phase, loop: 0, interpolation: 4),
							// sig = PlayBuf.ar(numch, bufnum, BufRateScale.ir(bufnum), startPos: start,
							// loop: 0, doneAction: 2),
							eg = EnvGen.kr(Env.asr(0.01, amp, 0.02), gate, doneAction: 2);
							SendReply.ar(Impulse.ar(15), '/phase', phase);
							sig = sig * eg * vol;
							if(numch == 1) { sig = sig ! 2 };
							Out.ar(out, sig);
						}).add;
					};
				};

				~togglePlay = { |file|
					var	sf, peaks, path;
					if(~nowPlaying.isNil) {
						~nowPlaying = file;
						Routine {
							if(~aliases[file.path].notNil) {
								path = ~aliases[file.path]
							} {
								path = file.path;
							};
							if(file.peak.isNil) {
								if((sf = SoundFile.openRead(path)).isOpen) {
									protect {
										// automatically catch channelPeaks status post
										if('StatusBox'.asClass.notNil) {
											statusBox = 'StatusBox'.asClass.new(
												nil,
												Rect.aboutPoint(Window.screenBounds.center, 200, 50)
											).front;
											0.01.wait;
										};
										"Please wait: determining peak value of %\n".postf(path.basename);
										0.01.wait;
										peaks = sf.channelPeaks(threaded: true);
										file.peak = peaks.maxItem;
									} {
										sf.close;
										if(statusBox.notNil) { statusBox.close };
									};
								} {
									"Couldn't open %\n".postf(path.basename);
								};
							};
							file.buf ?? {
								file.buf = Buffer.read(s, path);
								s.sync;
							};
							file.playNode = Synth("sampPlay" ++ file.numChan, [
								bufnum: file.buf, amp: file.peak.reciprocal, vol: ~volBus.asMap
							]);
							{
								~playstop.string_("spc to stop");
								~sfv.timeCursorOn = true;
							}.defer;
							// OSCpathResponder(s.addr, ['/n_end', file.playNode.nodeID], e { |time, resp, msg|
							OSCFunc(inEnvir {
								(inEnvir {
									~playstop.string_("spc to play");
									~sfv.timeCursorOn = false;
								}).defer;
								~nowPlaying = nil;
								// resp.remove;
							}, '/n_end', s.addr, argTemplate: [file.playNode.nodeID]).add;
						}.play(AppClock);
					} {
						(inEnvir { ~playstop.string_("spc to play") }).defer;
						~nowPlaying.playNode.release;
						~nowPlaying = nil;
					};
				};

				~freeCleanup = {
					~nowPlaying !? { ~togglePlay.() };
					~volBus.free;
					~sfPhaseResp.free;
					// some buffers don't get freed without pausing?
					fork {
						~files.do { |file|
							file.buf.free;
							0.01.wait;
						};
						~aliases.do { |alias|
							// "rm '%'".format(alias).postln.unixCmd;
							File.delete(alias);
							0.01.wait;
						};
						sfDisplay.tryPerform(\close);
						envir.clear;  // only after all buffers are gone
					};
				};

				~makeSynthDefs.();
				~showSF.(~files[0]);
				~fileList.focus;
				Archive.put(\sampleAuditionPath, path.dirname);
			} {
				"No files in '%' matching valid soundfile extensions.".format(path).warn;
			};
		}, fileMode: 1, acceptMode: 0, stripResult: true, path: startPath);
	}.fork(AppClock);
};
