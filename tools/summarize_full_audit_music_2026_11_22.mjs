import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const dir=new URL('../reports/full_audit_2026_11_22/',import.meta.url);
const read=p=>JSON.parse(fs.readFileSync(new URL(p,dir)));
const midi=p=>new Uint8Array(fs.readFileSync(new URL('midi/'+p,dir)));
const initial=read('initial.json'),clarified=read('clarified.json');
const observed=new Map(initial.results.map(r=>[r.id,r]));for(const r of clarified.results)observed.set(r.id,r);
const audio=read('audio_current_decoder.json');
const p=notesFromMidi(midi('audit-01-chords.mid'),{allowPolyphony:true});
const tuples=p.notes.map(n=>[n.start_tick*480/p.division,n.end_tick*480/p.division,n.midi]).sort((a,b)=>a[0]-b[0]||a[2]-b[2]||a[1]-b[1]);
assert.equal(createHash('sha256').update(JSON.stringify(tuples)).digest('hex'),audio.note_sha256);
assert.deepEqual(audio.meaning,observed.get('audit-01').heard);
const sharedPrefix=(left,right)=>{
 const grouping=bytes=>{
  const p=notesFromMidi(bytes,{allowPolyphony:true}),groups=[];
  for(const n of p.notes){const item=[n.midi,n.end_tick/p.division];if(groups.at(-1)?.at!==n.start_tick/p.division)groups.push({at:n.start_tick/p.division,notes:[]});groups.at(-1).notes.push(item);}
  return groups;
 };
 const a=grouping(left),b=grouping(right);let i=0;
 while(i<a.length&&i<b.length&&JSON.stringify(a[i])===JSON.stringify(b[i]))i++;
 return {identical_attacks:i,seconds_before_first_difference:Math.min(a[i]?.at??Infinity,b[i]?.at??Infinity)*.5};
};
const pairs=[[2,9],[13,14],[25,26]].map(([a,b])=>{
 const left='audit-'+String(a).padStart(2,'0'),right='audit-'+String(b).padStart(2,'0');
 return {left,right,left_text:observed.get(left).text,right_text:observed.get(right).text,...sharedPrefix(midi(left+'-chords.mid'),midi(right+'-chords.mid'))};
});
const experiment=read('music_experiment.json').results;
const median=values=>{const sorted=values.toSorted((a,b)=>a-b),n=sorted.length;return n%2?sorted[(n-1)/2]:(sorted[n/2-1]+sorted[n/2])/2;};
const frames=experiment.filter(r=>r.beats===.25),slow=experiment.filter(r=>r.beats===.5);
const report={sentence_performances:frames.length,shared_prefix_pairs:pairs,
 median_reduction_from_existing_chords_sixteenth:median(frames.map(r=>1-r.experimental_seconds/r.compact_seconds)),
 median_reduction_from_existing_chords_eighth:median(slow.map(r=>1-r.experimental_seconds/r.compact_seconds)),
 first_root_seconds_in_existing_chords: [...observed.values()].filter(r=>r.root_onset_seconds!==undefined).map(r=>({id:r.id,seconds:r.root_onset_seconds})),
 clean_reference_audio:{input:'audio/hatch-chords.wav',decoder_arguments:'WAV path only; fixed public reference voice/tempo and language',
  source:'Synthetic Web Audio PCM, no physical room capture',exact_notes_and_timing:true,exact_meaning:true,notes:audio.notes},
 experimental_audio:{input:'audio/hatch-frame-16th.wav',current_decoder_result:'rejected: The recording does not give one complete, supported musical reading.',
  decision:'Keep the profile experimental; a shorter exact-MIDI encoding is not yet a working recorded-audio language.'},
 measurements_scope:'Pitches, timing, duration, invertibility and selected corrupted-note rejection. Not a human listening preference study or an unrestricted noisy-audio evaluation.'};
fs.writeFileSync(new URL('music_summary.json',dir),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));
