import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {objectDesirePlan,composeObjectDesire} from '../pages/object_desire.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../reviews/foundation_extension_candidates.json',import.meta.url))).records;
const load=id=>!authority.resolution_files[id]?{authority}:({...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority});
const compose=(input,desiredProposition)=>composeObjectDesire(input,authority,records,load,{allowDraft:true,desiredProposition});
assert.equal(objectDesirePlan('Nora wants tea.').automatic_relation,null);
await assert.rejects(compose('Nora wants tea.'),/Specify/);
await assert.rejects(compose('Nora wants tea.','Eli is happy.'),/original object/);
const sounds=new Set(),documents=[];
for(const form of ['Nora wants tea.','Nora does not want tea.','Does Nora want tea?'])for(const state of [0,1,2]){
 const input=form+` [${state}]`,r=await compose(input,'Eli has physical custody of the tea.'),bytes=midiFromFormal(r.formal),decoded=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
 documents.push(r);
 assert.equal(decoded.meaning.runtime_state,state);assert.equal(decoded.speech_act,form.endsWith('?')?'question':'assertion');assert.deepEqual(decoded.meaning.scopes,form.includes('not')?[{operator:'negation'}]:[]);assert.equal(decoded.meaning.arguments.content.content_status,'intensional');assert.equal(decoded.meaning.arguments.content.proposition.predicate.name,'practical_physical_custody');assert.equal(decoded.meaning.arguments.content.proposition.meaning.ownership_asserted,false);assert.equal(r.object_desire_resolution.relation_source,'explicit_user_clarification');assert(r.object_desire_resolution.matching_content_references.length);sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,9);console.log('PASS object desire requires explicit content, rejects unrelated outcomes, and preserves outer scope/runtime/question through existing music.');

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};puts JSON.generate(x['documents'].map{|d|f=EraZeroRenderer.render(d['semantic_ir'],**o);Base64.strict_encode64(EraZeroPresentation.midi(f,**o))})"],{input:JSON.stringify({records,documents}),encoding:'utf8',maxBuffer:16000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(midiFromFormal(d.formal)).toString('base64'),ruby[i]);
for(const [text,scope] of [['Yesterday, Nora wanted tea.','previous_day'],['Nora wanted tea.','before_speech']]){
 const d=await compose(text,'Eli does not have physical custody of the tea.'),r=await decodeFoundationSentenceMidi(midiFromFormal(d.formal),authority.atoms,records,{allowDraft:true});
 assert.deepEqual(r.meaning.scopes,[{operator:'time',relation:scope}]);assert.deepEqual(r.meaning.arguments.content.proposition.scopes,[{operator:'negation'}]);
}
console.log('PASS nine independent Ruby performances agree; outer past time remains distinct from desired-content negation.');
// Preserve reference mode rather than equating a proper name with a noun label.
await assert.rejects(compose('Nora wants this tea.','Eli has physical custody of that tea.'),/original object/);
await assert.rejects(compose('Nora wants the tea.','Eli cares for Tea.'),/original object/);
await assert.rejects(compose('Nora wants Tea.','Eli has physical custody of the tea.'),/original object/);
for(const outerState of [0,1,2])for(const innerState of [0,1,2]){
 const d=await compose(`Does Nora want this tea? [${outerState}]`,`Eli has physical custody of this tea [${innerState}].`);
 const r=await decodeFoundationSentenceMidi(midiFromFormal(d.formal),authority.atoms,records,{allowDraft:true});
 assert.equal(r.meaning.runtime_state,outerState);assert.equal(r.meaning.arguments.content.proposition.runtime_state,innerState);assert.equal(r.meaning.arguments.content.proposition.arguments.object.reference.reference_mode,'proximal_nominal');
}
const implicit=await compose('Nora wants tea.','Eli has physical custody of the tea [2].');
const inverse=await decodeFoundationSentenceMidi(midiFromFormal(implicit.formal),authority.atoms,records,{allowDraft:true});
assert.equal(inverse.meaning.runtime_state,1);assert.equal(inverse.meaning.arguments.content.proposition.runtime_state,2);
console.log('PASS noun/name and proximal/distal identity are not substituted; nine runtime pairs and default outer state preserve independent content runtime.');
