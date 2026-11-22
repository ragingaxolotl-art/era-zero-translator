import {notesFromMidi} from './performance_codec.mjs?v=contextual-width-2';
import {scheduleVoiceTone,voiceProfile} from './voices.mjs';

function openAudioContext() {
 const Engine = globalThis.AudioContext || globalThis.webkitAudioContext;
 if (!Engine) throw new Error('This browser does not provide audio playback.');
 return new Engine({latencyHint: 'interactive'});
}

export function createLocalCompoundPlayer({
 audioContextFactory = openAudioContext, scheduleTone = scheduleVoiceTone,
 getVoice = () => 'era_zero', onStatus = () => {}
} = {}) {
 let context, bus, finishTimer;
 let handles = [], generation = 0;

 function stop() {
  generation++;
  clearTimeout(finishTimer);
  const wasPlaying = handles.length > 0;
  for (const handle of handles) handle.stop();
  handles = [];
  if (wasPlaying) onStatus('Playback stopped.');
 }

 async function play(bytes,{chords=false}={}) {
  stop();
  const token = generation;
  const {notes, division} = notesFromMidi(bytes,{allowPolyphony:chords});
  if (!context || context.state === 'closed') {
   context = audioContextFactory();
   bus = context.createGain();
   bus.gain.value = .78;
   const limiter = context.createDynamicsCompressor();
   limiter.threshold.value = -9;
   limiter.knee.value = 12;
   limiter.ratio.value = 4;
   limiter.attack.value = .004;
   limiter.release.value = .18;
   bus.connect(limiter).connect(context.destination);
  }
  if (context.state === 'suspended') await context.resume();
  if (token !== generation) return;
  if (context.state !== 'running') throw new Error('Audio is paused. Press Play again.');
  const start = context.currentTime + .1, voice = getVoice();
  let end = start;
  try {
   for (const note of notes) {
    const at = start + note.start_tick * .5 / division;
    const duration = (note.end_tick - note.start_tick) * .5 / division;
    const handle = scheduleTone(context, bus, note.midi, at, {voice, duration,...(chords?{gainLevel:.085}:{})});
    handles.push(handle);
    end = Math.max(end, handle.end_time ?? at + duration);
   }
  } catch (error) {
   stop();
   throw error;
  }
  onStatus('Playing '+notes.length+' tones · '+voiceProfile(voice).label+'.');
  finishTimer = setTimeout(() => {
   if (generation !== token) return;
   handles = [];
   onStatus('Playback finished.');
  }, (end - context.currentTime) * 1000);
 }
 return {stop, play};
}
