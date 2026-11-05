import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composePainComparisonSentence} from '../pages/pain_comparison_sentences.mjs';
import {midiFromPainComparison,decodePainComparisonMidi} from '../pages/pain_comparison_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set(),documents=[];
for(const interpretation of ['actual_causation','expected_outcome','disposition'])for(const word of ['more','less','equally'])for(const state of [0,1,2]){
 const text=`Is "Treatment A" not ${word} painful for Nora ${word==='equally'?'as':'than'} "Treatment B"? [${state}]`;
 const d=await composePainComparisonSentence(text,{allowDraft:true,interpretation,context:'this session'}),bytes=await midiFromPainComparison(d,authority,{allowDraft:true}),r=decodePainComparisonMidi(bytes,authority.atoms,{allowDraft:true});
 documents.push(d);
 assert.equal(r.relation,d.relation);assert.equal(r.runtime_state,state);assert.equal(r.left.relation,interpretation);assert.equal(r.right.relation,interpretation);assert.deepEqual(r.left.stimulus.phonemes,d.left.stimulus.name.phonemes);assert.deepEqual(r.right.stimulus.phonemes,d.right.stimulus.name.phonemes);assert.deepEqual(r.context.phonemes,d.context.name.phonemes);assert.equal(r.speech_act,'question');assert.deepEqual(r.scopes,[{operator:'negation'}]);assert.equal(r.scale,'ordinal_no_numeric_score');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);assert.throws(()=>decodePainComparisonMidi(bytes,authority.atoms));
 assert.deepEqual(decodePainComparisonMidi(await midiFromPainComparison(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,27);console.log('PASS 27 pain comparison MIDI contrasts retain ordered outcomes, context, mode, negated question and runtime through shared inverse/transposition.');
const {composePainMeaning}=await import('../pages/pain_meaning.mjs');
const {createPainStimulus}=await import('../pages/pain_stimulus.mjs');
const {createPainComparison}=await import('../pages/pain_comparison.mjs');
const base=await composePainComparisonSentence('The treatment is more painful for Nora than the injection.',{allowDraft:true,interpretation:'expected_outcome',context:'this session'});
// Vary each of five runtime positions independently around a shared baseline.
const positions=['comparison','left_relation','left_pain','right_relation','right_pain'],runtimeSounds=new Set();
for(const position of positions)for(const value of [0,1,2]){
 const values=Object.fromEntries(positions.map(p=>[p,p===position?value:1]));
 const make=async(side)=>createPainStimulus(base[side].stimulus,await composePainMeaning(`Nora is in bodily pain. [${values[side+'_pain']}]`,{allowDraft:true}),{allowDraft:true,relation:'expected_outcome',runtimeState:values[side+'_relation']});
 const d=await createPainComparison(await make('left'),await make('right'),base.context,{allowDraft:true,relation:'greater_than',runtimeState:values.comparison});
 documents.push(d);
 const bytes=await midiFromPainComparison(d,authority,{allowDraft:true}),r=decodePainComparisonMidi(bytes,authority.atoms,{allowDraft:true});
 assert.deepEqual([r.runtime_state,r.left.runtime_state,r.left.outcome.runtime_state,r.right.runtime_state,r.right.outcome.runtime_state],positions.map(p=>values[p]));assert.equal(r.relation,'greater_than');runtimeSounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(runtimeSounds.size,11);console.log('PASS five runtime positions vary independently without becoming pain intensity; 15 probes include five shared baselines.');

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_pain_comparison','-rjson','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroPainComparison.midi(d,allow_draft:true))})"],{input:JSON.stringify(documents),encoding:'utf8',maxBuffer:16000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(await midiFromPainComparison(d,authority,{allowDraft:true})).toString('base64'),ruby[i]);
console.log(`PASS ${documents.length} independent Ruby comparison performances match JavaScript, including independent nested runtime probes.`);
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_pain_comparison','-rjson','-e',`d=JSON.parse(STDIN.read);checks=[];begin;EraZeroPainComparison.midi(d);checks<<false;rescue ArgumentError;checks<<true;end;%w[scale basis operand_scope relation].each do |key|;x=Marshal.load(Marshal.dump(d));x[key]='altered';hash=EraZeroContextualContent.digest(x.reject{|k,_|%w[content_id content_digest].include?(k)});x['content_digest']=hash;x['content_id']="EZPAINCMP:#{hash[0,24]}";begin;EraZeroPainComparison.midi(x,allow_draft:true);checks<<false;rescue ArgumentError;checks<<true;end;end;puts JSON.generate(checks)`],{input:JSON.stringify(documents[0]),encoding:'utf8'}));assert.deepEqual(rejected,[true,true,true,true,true]);
console.log('PASS independent comparison validator rejects default draft use and rehashed scale, basis, scope and relation corruption.');
