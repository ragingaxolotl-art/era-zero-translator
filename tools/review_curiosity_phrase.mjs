// Review a declared interpretation; not a blind benchmark or audio test.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeCuriosity} from '../pages/curiosity.mjs';
import {midiFromCuriosity,decodeCuriosityMidi} from '../pages/curiosity_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const read=path=>JSON.parse(fs.readFileSync(new URL(path,import.meta.url))),authority=read('../pages/data/index.json'),records=read('../pages/data/foundation_preview_candidates.json').records;
const input='Orin is curious about the map.',document=await composeCuriosity(input,{allowDraft:true});
assert.equal(document.experiencer.name.normalized_label,'orin');assert.equal(document.inquiry.topic.anchor.name.normalized_label,'map');
assert.equal(document.inquiry.topic.anchor.reference_mode,'definite_nominal');
assert.equal(document.predicate,'epistemic_curiosity');assert.equal(document.outcome_commitment,'desired_not_asserted');
assert.equal(document.inquiry.answer_commitment,'none');assert.equal(document.inquiry.specific_question_supplied,false);
assert.equal(document.speech_act,'assertion');assert.deepEqual(document.scopes,[]);assert.equal(document.runtime_state,1);
const bytes=await midiFromCuriosity(document,authority,records,{allowDraft:true}),recovered=await decodeCuriosityMidi(bytes,authority.atoms,records,{allowDraft:true});
assert.equal(recovered.predicate,'epistemic_curiosity');assert.equal(recovered.outcome_commitment,'desired_not_asserted');assert.equal(recovered.inquiry.answer_commitment,'none');assert.equal(recovered.inquiry.specific_question_supplied,false);
assert.deepEqual(recovered.experiencer.phonemes,document.experiencer.name.phonemes);assert.deepEqual(recovered.inquiry.topic.anchor.phonemes,document.inquiry.topic.anchor.name.phonemes);
assert.equal(recovered.runtime_state,1);assert.equal(recovered.speech_act,'assertion');assert.deepEqual(recovered.scopes,[]);
const signature=b=>JSON.stringify(notesFromMidi(b).notes.map(n=>[n.midi,n.start_tick,n.end_tick]));
const contrasts=[];
for(const phrase of ['Orin is not curious about the map.','Nora is curious about the map.','Orin is curious about the map. [0]','Orin is curious about the map. [2]']){
 const other=await composeCuriosity(phrase,{allowDraft:true}),music=await midiFromCuriosity(other,authority,records,{allowDraft:true});assert.notEqual(signature(music),signature(bytes));contrasts.push(phrase);
}
await assert.rejects(composeCuriosity(input),/opt-in/);
const report={input,status:'verified_for_declared_epistemic_reading_after_draft_opt_in',automatic_translation:false,checks:['Orin is the experiencer','The map is a definite topic reference','Epistemic interest, not merely attention','Information gain is desired, not asserted','No answer or specific question invented','Assertion and runtime 1 preserved','MIDI-only recovery preserves tested meaning and participant phonemes'],performed_note_contrasts:contrasts,limitations:['Requires user acceptance of the draft epistemic reading.','Specific relevant questions remain contextual.','Does not establish sensory novelty seeking, oddness, or purely instrumental information demand.','MIDI-only recovery is not recorded-audio decoding.','Not a held-out phrase or a general-English coverage estimate.']};
fs.writeFileSync(new URL('../reports/curiosity_phrase_review.json',import.meta.url),JSON.stringify(report,null,2)+'\n');console.log('PASS declared curiosity meaning, MIDI recovery and four performed-note contrasts; explicit draft selection remains required.');
