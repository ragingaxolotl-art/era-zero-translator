import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound} from '../pages/local_compounds.mjs';
import {localCompoundMusic,localCompoundFrame} from '../pages/local_compound_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const d={label:'test local adjective',definition:'Test-only combination.',part_of_speech:'adjective',roles:[],components:a.atoms.slice(0,2).map((v,i)=>({target_id:v.canonical_id,relation:i?'qualifies':'head'}))};
let r=await addLocalCompound(emptyLocalCompounds(),d,a);const first=r.entries[0].compound_id;
r=await addLocalCompound(r,{...d,label:'nested test adjective',components:[{target_id:first,relation:'qualifies'},{target_id:first,relation:'head'}]},a);const id=r.entries[1].compound_id;
const sounds=new Set();
for(const runtimeState of [0,1,2]){
 const result=await localCompoundMusic(id,r,a,[],{runtimeState});
 assert(notesFromMidi(result.midi).notes.length>0);assert.deepEqual(result.registry,r);
 const frames=result.events.filter(e=>e.grammar_profile==='EZLOCAL-COMPOUND-MUSIC-1');assert.equal(frames.length,6);
 const stack=[];for(const frame of frames){if(frame.marker.endsWith('_open'))stack.push(frame.target_id);else assert.equal(stack.pop(),frame.target_id);}assert.equal(stack.length,0);
 assert.notDeepEqual(frames[1].address_absolute_midi,frames[3].address_absolute_midi);
 sounds.add(Buffer.from(result.midi).toString('base64'));
}
assert.equal(sounds.size,3);assert.notDeepEqual(localCompoundFrame(first,'head','open').address_absolute_midi,localCompoundFrame(id,'head','open').address_absolute_midi);
console.log('PASS portable local registry and nested framed MIDI export, identity/head contrasts and runtime 0/1/2. Audio inverse not claimed.');
