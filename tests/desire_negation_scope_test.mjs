import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true});
const cases=[];
for(const body of ['care for Eli','be able to move'])for(const state of [0,1,2]){
 const sounds=new Set();
 for(const outerNegation of [false,true])for(const innerNegation of [false,true]){
  const start=outerNegation?'Nora does not want':'Nora wants';
  const r=await compose(`${start} ${innerNegation?'not ':''}to ${body} [${state}].`);cases.push(r);
  const bytes=midiFromFormal(r.formal),meaning=(await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true})).meaning;
  assert.deepEqual(meaning.scopes,outerNegation?[{operator:'negation'}]:[]);
  assert.deepEqual(meaning.arguments.content.proposition.scopes,innerNegation?[{operator:'negation'}]:[]);
  assert.equal(meaning.runtime_state,state);assert.equal(meaning.arguments.content.content_status,'intensional');
  sounds.add(Buffer.from(bytes).toString('base64'));
  if(innerNegation){
   const variant=await compose(`${start} to not ${body} [${state}].`);
   assert.deepEqual(variant.semantic_ir,r.semantic_ir);assert.deepEqual(midiFromFormal(variant.formal),bytes);
  }
 }
 assert.equal(sounds.size,4);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-rjson','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,**o);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))}})"],{cwd:root,input:JSON.stringify({irs:cases.map(r=>r.semantic_ir),records}),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of cases.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
for(const [text,role,kind] of [
 ['I want not to care for Eli.','actor','bound'],
 ['You want to not be able to move.','bearer','bound'],
 ['Nora wants Eli not to be able to move.','bearer','phonemic'],
 ['Does Nora want not to care for Eli?','actor','bound']]){
 const r=await compose(text),d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
 assert.equal(d.meaning.arguments.content.proposition.arguments[role].reference.kind,kind);
 assert.deepEqual(d.meaning.arguments.content.proposition.scopes,[{operator:'negation'}]);
}
for(const text of ['Nora wants not to not care for Eli.','Nora wants not to be not able to move.','Nora wants to never care for Eli.','Nora wants not to care for Eli tomorrow morning.'])await assert.rejects(compose(text));
console.log('PASS 24 desire/inner-negation/runtime scope contrasts with equivalent infinitive forms, Ruby/MIDI parity, independent decoding, deictic/explicit subjects and unsupported-scope rejection.');
