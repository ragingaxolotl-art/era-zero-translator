import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeObjectDesire} from '../pages/object_desire.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json'),records=read('reviews/foundation_extension_candidates.json').records;
const load=()=>({authority}),sounds=new Set(),documents=[];
for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negative of [false,true]){
 const source=`Does Nora not want this tea? [${outer}]`,outcome=`Eli ${negative?'did not carry':'carried'} this tea to Nora. [${inner}]`;
 const result=await composeObjectDesire(source,authority,records,load,{allowDraft:true,desiredProposition:outcome,desiredDelivery:{destination:'custody_delivery'}});
 documents.push(result);
 const midi=midiFromFormal(result.formal),d=await decodeFoundationSentenceMidi(midi,authority.atoms,records,{allowDraft:true}),content=d.meaning.arguments.content;
 assert.equal(d.speech_act,'question');assert.equal(d.meaning.runtime_state,outer);assert.deepEqual(d.meaning.scopes,[{operator:'negation'}]);assert.equal(content.content_status,'intensional');
 const p=content.proposition;assert.equal(p.runtime_state,inner);assert.equal(p.predicate.name,'completed_carrying_custody_delivery');assert.deepEqual(p.scopes,[{operator:'time',relation:'before_speech'},...(negative?[{operator:'negation'}]:[]),{operator:'aspect',aspect:'bounded'}]);
 assert.equal(p.arguments.object.reference.reference_mode,'proximal_nominal');assert.notDeepEqual(p.arguments.carrier,p.arguments.recipient);assert.equal(p.meaning.ownership_asserted,false);assert.equal(p.meaning.arrival_culminates_in_transfer,true);sounds.add(Buffer.from(midi).toString('base64'));
}
assert.equal(sounds.size,18);
await assert.rejects(composeObjectDesire('Nora wants tea.',authority,records,load,{allowDraft:true,desiredProposition:'Eli carried the tea to Nora.'}),/Choose a spatial/);
await assert.rejects(composeObjectDesire('Nora wants tea.',authority,records,load,{allowDraft:true,desiredProposition:'Eli has physical custody of the tea.',desiredDelivery:{destination:'custody_delivery'}}),/direct carrying/);
console.log('PASS 18 desired custody-delivery scope/runtime contrasts; explicit interpretation required and unrelated content rejects.');

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};puts JSON.generate(x['documents'].map{|d|f=EraZeroRenderer.render(d['semantic_ir'],**o);Base64.strict_encode64(EraZeroPresentation.midi(f,**o))})"],{input:JSON.stringify({records,documents}),encoding:'utf8',maxBuffer:24000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(midiFromFormal(d.formal)).toString('base64'),ruby[i]);
console.log('PASS independent Ruby rendering of all 18 nested delivery meanings.');
for(const viewpoint of ['bounded','ongoing','habitual'])for(const state of [0,1,2]){
 const r=await composeObjectDesire('Nora wants tea.',authority,records,load,{allowDraft:true,desiredProposition:`Eli carries the tea to Nora. [${state}]`,desiredDelivery:{destination:'custody_delivery',viewpoint}}),d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
 const p=d.meaning.arguments.content.proposition;assert.equal(p.runtime_state,state);assert.deepEqual(p.scopes,[{operator:'aspect',aspect:viewpoint}]);assert.equal(d.meaning.arguments.content.content_status,'intensional');assert.deepEqual(r.object_desire_resolution.desired_delivery,{destination:'custody_delivery',viewpoint});
}
console.log('PASS nine explicitly selected desired-delivery viewpoints retain bounded, ongoing and habitual scope.');
