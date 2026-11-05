import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeDesiredOwnership} from '../pages/desired_ownership.mjs';
import {midiFromDesiredOwnership,decodeDesiredOwnershipMidi} from '../pages/desired_ownership_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_candidates.json',import.meta.url))).records,sounds=new Set();
for(const subject of ['','Eli '])for(const outer of [0,1,2])for(const inner of [0,1,2]){
 const d=await composeDesiredOwnership(`Does Nora not want ${subject}to not own this tea [${inner}]? [${outer}]`,{allowDraft:true,framework:'"Harbor charter"'}),midi=await midiFromDesiredOwnership(d,authority,{allowDraft:true}),r=decodeDesiredOwnershipMidi(midi,authority.atoms,{allowDraft:true});
 assert.equal(r.runtime_state,outer);assert.equal(r.content.runtime_state,inner);assert.equal(r.speech_act,'question');assert.equal(r.content.speech_act,'assertion');assert.equal(r.content_status,'intensional');assert.equal(r.outcome_commitment,'desired_not_asserted');assert.deepEqual(r.scopes,[{operator:'negation'}]);assert.deepEqual(r.content.scopes,[{operator:'negation'}]);assert.equal(r.subject_binding,d.subject_binding);assert.deepEqual(r.content.framework.phonemes,d.content.framework.name.phonemes);
 if(subject)assert.notDeepEqual(r.holder,r.content.owner);else assert.deepEqual(r.holder,r.content.owner);
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(midi,authority.atoms,records,{allowDraft:true}),r);assert.deepEqual(decodeDesiredOwnershipMidi(await midiFromDesiredOwnership(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);assert.throws(()=>decodeDesiredOwnershipMidi(midi,authority.atoms));sounds.add(Buffer.from(midi).toString('base64'));
}
assert.equal(sounds.size,18);console.log('PASS 18 desired ownership musical contrasts preserve subject control, scoped ownership framework, separate negations and runtime pairs; unique shared inverse and transposition verified.');
