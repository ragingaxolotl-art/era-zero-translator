import {notesFromMidi} from './performance_codec.mjs';
import {scheduleVoiceTone} from './voices.mjs';
export function createLocalCompoundPlayer({audioContextFactory=()=>{const Engine=globalThis.AudioContext||globalThis.webkitAudioContext;if(!Engine)throw new Error('This browser does not provide audio playback.');return new Engine({latencyHint:'interactive'});},scheduleTone=scheduleVoiceTone}={}){
 let context,bus,handles=[],generation=0;
 const stop=()=>{generation++;for(const handle of handles)handle.stop();handles=[];};
 return {stop,async play(bytes){
  stop();const token=generation,{notes,division}=notesFromMidi(bytes);
  if(!context||context.state==='closed'){
   context=audioContextFactory();bus=context.createGain();bus.gain.value=.78;
   const limiter=context.createDynamicsCompressor();limiter.threshold.value=-9;limiter.knee.value=12;limiter.ratio.value=4;limiter.attack.value=.004;limiter.release.value=.18;bus.connect(limiter).connect(context.destination);
  }
  if(context.state==='suspended')await context.resume();if(token!==generation)return;
  if(context.state!=='running')throw new Error('Audio is paused. Press Play again.');
  const start=context.currentTime+.1;
  try{for(const note of notes)handles.push(scheduleTone(context,bus,note.midi,start+note.start_tick*.5/division,{voice:'era_zero',duration:(note.end_tick-note.start_tick)*.5/division}));}catch(error){stop();throw error;}
 }};
}
