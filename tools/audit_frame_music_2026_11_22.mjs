import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {isDeepStrictEqual} from 'node:util';
import {alphabet,packFrames,unpackFrames} from '../experiments/frame_chords.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url)));
const authority=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const output=new URL('../reports/full_audit_2026_11_22/',import.meta.url);
const n=(midi,start_tick,end_tick)=>({midi,start_tick,end_tick});
const notes=b=>notesFromMidi(b).notes.map(n=>[n.midi,n.start_tick,n.end_tick]);
const measure=b=>{const p=notesFromMidi(b,{allowPolyphony:true});return Math.max(...p.notes.map(n=>n.end_tick))/p.division*(p.tempos[0]?.value||500000)/1e6;};
const alphabetHash=createHash('sha256').update(JSON.stringify(alphabet)).digest('hex');
const report={profile:alphabet.profile,alphabet_sha256:alphabetHash,
 limitations:['Research prototype only, absent from deployed site.','No physical microphone decoding of this profile has been established.',
 'Exact MIDI inversion is not an audio robustness or subjective musical-quality result.',
 'Names, convention IDs and personal-word frames remain serial. Existing runtime, contour and root distinctions are preserved.'],
 alphabet_cases:0,corruption_checks:[],results:[]};
// Check the entire shared alphabet independently of the source sentences.
for(const anchor of [48,60,72])for(const beats of [.25,.5])for(const frame of alphabet.entries){
 const division=480,header=[-24,-12,-5,4,12].map(p=>n(anchor+p,0,120));
 const chord=(d,start)=>{const base=anchor-24+d%12;return [base,base+12,base+12+(d<12?4:3),base+19].map(p=>n(p,start,start+beats*division));};
 const input=midiFromNoteTimeline([...header,...chord(Math.floor(frame.code/24),120),...chord(frame.code%24,120+beats*division)],division,500000);
 const restored=unpackFrames(input,authority.atoms);
 assert.deepEqual(notes(restored),frame.path.map((p,i)=>[anchor+p,i*120,(i+1)*120]));report.alphabet_cases++;
}
const inputFiles=fs.readdirSync(new URL('midi/',output)).filter(p=>p.endsWith('-melody.mid'));
for(const file of inputFiles){
 const bytes=new Uint8Array(fs.readFileSync(new URL('midi/'+file,output))),id=file.replace('-melody.mid','');
 let expected;try{expected=await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true});}catch{}
 for(const beats of [.25,.5]){
  const {midi,replaced}=packFrames(bytes,authority.atoms,{beats}),restored=unpackFrames(midi,authority.atoms);
  assert.deepEqual(notes(restored),notes(bytes),id+' restored pitches, order, durations and rests');
  let sameMeaning=null;if(expected)sameMeaning=isDeepStrictEqual(expected,await decodeSupportedMeaningWithDrafts(restored,authority.atoms,records,{allowDraft:true}));
  if(expected)assert(sameMeaning,id);
  const name='midi/'+id+'-frame-'+(beats===.25?'16th':'8th')+'.mid';fs.writeFileSync(new URL(name,output),midi);
  report.results.push({id,beats,frame_count:replaced,melody_seconds:measure(bytes),
   compact_seconds:measure(new Uint8Array(fs.readFileSync(new URL('midi/'+id+'-chords.mid',output)))),
   experimental_seconds:measure(midi),notes_restored:true,meaning_restored:sameMeaning,path:name});
  if(id==='audit-01'&&beats===.25){
   const parsed=notesFromMidi(midi,{allowPolyphony:true});
   const firstFrame=parsed.notes.findIndex(n=>n.start_tick===120);
   for(const mutation of ['drop_voice','detune_voice','wrong_duration','missing_second_chord']){
    const changed=structuredClone(parsed.notes);
    if(mutation==='drop_voice')changed.splice(firstFrame+1,1);
    if(mutation==='detune_voice')changed[firstFrame+1].midi+=1;
    if(mutation==='wrong_duration')changed[firstFrame+1].end_tick-=1;
    if(mutation==='missing_second_chord')changed.splice(firstFrame+4,4);
    let rejected=false;try{await decodeSupportedMeaningWithDrafts(unpackFrames(midiFromNoteTimeline(changed,parsed.division,parsed.tempos[0].value),authority.atoms),authority.atoms,records,{allowDraft:true});}catch{rejected=true;}
    assert(rejected,mutation);report.corruption_checks.push({mutation,rejected});
   }
  }
 }
}
fs.writeFileSync(new URL('music_experiment.json',output),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({alphabet_cases:report.alphabet_cases,scored_profiles:report.results.length,notes_exact:report.results.every(r=>r.notes_restored),meanings_exact:report.results.filter(r=>r.meaning_restored!==null).every(r=>r.meaning_restored),corruptions_rejected:report.corruption_checks.length}));
