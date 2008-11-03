// Turn the synth on and it kills itself when it's done
SynthDef(\chmod, {
	arg	note,
		level = 0.2
		;

	var	freq = note.midicps, 	
		amp_env = Line.kr(level, 0, 0.3, doneAction:2),
		sig = SinOsc.ar(
			freq,
			mul: amp_env
		)
		;

	Out.ar([0,1], sig);
}).send(s);


// Run continuously and change params accordingly 			
SynthDef(\anmod, {
	arg	rate = 11, 
		pan = 0,
		cut = 800,
		res = 0.8,
		level = 0
		;
	var	amp_mod = LFSaw.ar(rate, mul: 0.5, add: 0.5),
		tone = RLPF.ar(
			Formant.ar(41.midicps, 400, 400, mul: amp_mod),
			cut,
			res,
			mul: level
		),
		panned = Pan2.ar(tone, pan)
		;

	Out.ar(0, panned);
}).send(s);

SynthDef(\stmod, {
	arg 	gate = 1,
		note = 57,
		formfreq = 100,
		bwfreq = 100,
		level = 0.04
		;

	var	amp_env = Line.kr(level, 0, 0.2, doneAction:2),
		sig = Formant.ar(note.midicps, formfreq, bwfreq, amp_env)
		;

	Out.ar([0,1], sig);
}).send(s);
				


(
var 
	anmod = Synth(\anmod)
	;

// For triggering mode change button-press synth (\chmod)
OSCresponder(nil, '/chmod', {|t,r,msg,addr| Synth(\chmod, [\note, msg[1]])}).add;

// For changing paramters for the anchomr mod synth (L/R button-press) (\anmod)
// anmod synth left-panned
OSCresponder(nil, '/anmod_left', {|t,r,msg,addr| anmod.set(\pan, -1, \level, 0.1)}).add;
// anmod synth right-panned
OSCresponder(nil, '/anmod_right', {|t,r,msg,addr| anmod.set(\pan, 1, \level, 0.1)}).add;
// anmod synth muted
OSCresponder(nil, '/anmod_mute', {|t,r,msg,addr| anmod.set(\pan, 0, \level, 0)}).add;


OSCresponder(nil, '/stmod_on', {|t,r,msg,addr| 
					Synth(\stmod, [\note, msg[1], \formfreq, msg[2], \bwfreq, msg[3]])
				}
).add

)



