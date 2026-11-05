import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composePainComparisonSentence} from '../pages/pain_comparison_sentences.mjs';
import {midiFromPainComparison,decodePainComparisonMidi} from '../pages/pain_comparison_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set();
for(const interpretation of ['actual_causation','expected_outcome','disposition'])for(const word of ['more','less','equally'])for(const state of [0,1,2]){
 const text=`Is "Treatment A" not ${word} painful for Nora ${word==='equally'?'as':'than'} "Treatment B"? [${state}]`;
 const d=await composePainComparisonSentence(text,{allowDraft:true,interpretation,context:'this session'}),bytes=await midiFromPainComparison(d,authority,{allowDraft:true}),r=decodePainComparisonMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(r.relation,d.relation);assert.equal(r.runtime_state,state);assert.equal(r.left.relation,interpretation);assert.equal(r.right.relation,interpretation);assert.deepEqual(r.left.stimulus.phonemes,d.left.stimulus.name.phonemes);assert.deepEqual(r.right.stimulus.phonemes,d.right.stimulus.name.phonemes);assert.deepEqual(r.context.phonemes,d.context.name.phonemes);assert.equal(r.speech_act,'question');assert.deepEqual(r.scopes,[{operator:'negation'}]);assert.equal(r.scale,'ordinal_no_numeric_score');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);assert.throws(()=>decodePainComparisonMidi(bytes,authority.atoms));
 assert.deepEqual(decodePainComparisonMidi(await midiFromPainComparison(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,27);console.log('PASS 27 pain comparison MIDI contrasts retain ordered outcomes, context, mode, negated question and runtime through shared inverse/transposition.');
