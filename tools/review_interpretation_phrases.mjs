import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeRouteLearning} from '../pages/route_learning.mjs';
import {midiFromRouteLearning,decodeRouteLearningMidi} from '../pages/route_learning_music.mjs';
import {composeUnderstandingContent} from '../pages/understanding_content.mjs';
import {midiFromUnderstanding,decodeUnderstandingMidi} from '../pages/understanding_music.mjs';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL(p,import.meta.url))),authority=read('../pages/data/index.json'),records=read('../pages/data/foundation_preview_candidates.json').records;
const signature=b=>JSON.stringify(notesFromMidi(b).notes.map(n=>[n.midi,n.start_tick,n.end_tick]));
const reviews=[];
for(const reading of ['memorization','navigation','familiarity']){
 const input='Nora learned the route.',d=await composeRouteLearning(input,{allowDraft:true,interpretation:reading}),bytes=await midiFromRouteLearning(d,authority,{allowDraft:true}),r=await decodeRouteLearningMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(d.result_state.experiencer.name.normalized_label,'nora');assert.equal(d.result_state.route.name.normalized_label,'route');assert.equal(d.result_state.route.reference_mode,'definite_nominal');assert.equal(d.result_assertion,'at_culmination_only');assert.equal(d.phase_contract.after,'unspecified');assert.deepEqual(d.event_scopes,['before_speech']);
 assert.equal(r.result_state.reading,reading);assert.equal(r.result_state.content_commitment,d.result_state.content_commitment);assert.equal(r.transition_runtime,d.transition_runtime);assert.equal(r.result_state.runtime_state,d.result_state.runtime_state);assert.deepEqual(r.result_state.experiencer.phonemes,d.result_state.experiencer.name.phonemes);assert.deepEqual(r.result_state.route.phonemes,d.result_state.route.name.phonemes);
 reviews.push({input,reading,checks:['Nora learns the definite route','Past acquisition, not merely revision','Result holds at culmination; persistence is not asserted','Selected result criterion and independent runtime states preserved in MIDI'],criterion:d.result_state.criterion,content_commitment:d.result_state.content_commitment,signature:signature(bytes)});
}
assert.equal(new Set(reviews.map(r=>r.signature)).size,3);
await assert.rejects(composeRouteLearning('Nora learned the route.',{allowDraft:true}),e=>e.code==='route_learning_interpretation_required');
for(const reading of ['communicated_content','reasons','perspective']){
 const input='Eli understands Nora.',d=await composeUnderstandingContent(input,{allowDraft:true,interpretation:reading}),bytes=await midiFromUnderstanding(d,authority,{allowDraft:true}),r=await decodeUnderstandingMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(d.experiencer.name.normalized_label,'eli');assert.equal(d.content.anchor.name.normalized_label,'nora');assert.equal(d.content.assertion_commitment,'none');assert.equal(r.content.content_kind,reading);assert.equal(r.criterion,d.criterion);assert.deepEqual(r.experiencer.phonemes,d.experiencer.name.phonemes);assert.deepEqual(r.content.anchor.phonemes,d.content.anchor.name.phonemes);
 reviews.push({input,reading,checks:['Eli is the experiencer; Nora anchors the content','No truth assertion about the understood content','Selected content kind and criterion preserved in MIDI'],criterion:d.criterion,signature:signature(bytes)});
}
assert.equal(new Set(reviews.slice(3).map(r=>r.signature)).size,3);
await assert.rejects(composeUnderstandingContent('Eli understands Nora.',{allowDraft:true}),e=>e.code==='understanding_interpretation_required');
const load=id=>!authority.resolution_files[id]?{authority}:{...read('../pages/'+authority.resolution_files[id]).variants['assertion:1'],authority};
const preferences=[];
for(const [left,right] of [['tea','coffee'],['coffee','tea']]){
 const d=await composeFoundationSentence(`Nora prefers ${left} to ${right}.`,authority,records,load,{allowDraft:true}),ir=d.semantic_ir;
 const label=role=>ir.nodes.find(n=>n.node_id===ir.edges.find(e=>e.type==='fills_role'&&e.role===role)?.from)?.name?.normalized_label;
 assert.equal(label('experiencer'),'nora');assert.equal(label('target'),left);assert.equal(label('comparison_standard'),right);preferences.push(signature(midiFromFormal(d.formal)));
}
assert.notEqual(...preferences);
reviews.push({input:'Nora prefers tea to coffee.',reading:'declared preference foundation',checks:['Nora is the experiencer','Tea is preferred; coffee is the comparison alternative','Reversing preference direction changes performed notes']});
const report={status:'verified_for_declared_readings_after_explicit_draft_selection',automatic_translation:false,reviews:reviews.map(({signature,...r})=>r),limitations:['These are implementation-authored diagnostic cases, not held-out examples.','A user must select the intended reading and accept draft meanings.','MIDI recovery is not recorded-audio recovery.','No browser interaction or listening test was performed.']};
fs.writeFileSync(new URL('../reports/interpretation_phrase_reviews.json',import.meta.url),JSON.stringify(report,null,2)+'\n');console.log('PASS preference direction plus three route-learning and three understanding readings; unresolved readings reject and performed notes distinguish choices.');
