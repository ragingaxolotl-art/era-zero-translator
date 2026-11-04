import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {validateFoundationIR} from '../pages/foundation_ir.mjs';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal,createBundle,verifyBundle} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true});
const results=[];
for(const outer of [0,1,2])for(const inner of [0,1,2]){
 const r=await compose(`Nora wants Eli to prefer tea to coffee [${inner}] [${outer}].`);results.push(r);
 const d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
 assert.equal(d.meaning.runtime_state,outer);assert.equal(d.meaning.arguments.content.content_status,'intensional');
 const preference=d.meaning.arguments.content.proposition;
 assert.equal(preference.predicate.foundation_id,records.find(r=>r.sound_code===1).foundation_id);assert.equal(preference.runtime_state,inner);
 assert.equal(preference.arguments.target.type,'kind');assert.equal(preference.arguments.comparison_standard.type,'kind');
 assert.notDeepEqual(preference.arguments.target.reference.phonemes,preference.arguments.comparison_standard.reference.phonemes);
 assert(r.formal.literal_gloss.includes(records.find(r=>r.sound_code===1).display_title));
}
for(const text of ['Nora wants that Eli wants to care for Orin.','Nora wants that Eli wants to be able to move.','Nora does not want that Eli wants not to care for Orin.']){
 const r=await compose(text);results.push(r);
 const d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true}),nested=d.meaning.arguments.content.proposition;
 const final=nested.arguments.content.proposition,role=final.arguments.actor?'actor':'bearer';
 assert.equal(final.arguments[role].reference.binding,'parent_desire_experiencer');
 const link=r.semantic_ir.edges.find(e=>e.type==='corefers_with');assert.equal(link.to,'desired:holder');assert.notEqual(link.to,'holder');
 assert.equal(r.semantic_ir.nodes.filter(n=>n.content_status==='intensional').length,2);
 assert.equal((await verifyBundle(await createBundle(r))).vocabulary_status,'candidate');
}
for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negated of [false,true]){
 const r=await compose(`Nora wants ${negated?'not ':''}to prefer tea to coffee [${inner}] [${outer}].`);results.push(r);
 const d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
 const preference=d.meaning.arguments.content.proposition;
 assert.equal(d.meaning.runtime_state,outer);assert.equal(preference.runtime_state,inner);
 assert.equal(preference.arguments.experiencer.reference.binding,'parent_desire_experiencer');
 assert.deepEqual(preference.scopes,negated?[{operator:'negation'}]:[]);
 assert.equal(r.semantic_ir.edges.find(e=>e.type==='corefers_with').to,'holder');
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-rjson','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,**o);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))}})"],{cwd:root,input:JSON.stringify({irs:results.map(r=>r.semantic_ir),records}),encoding:'utf8',maxBuffer:30_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
const reversed=await compose('Nora wants Eli to prefer coffee to tea.');
const rev=(await decodeFoundationSentenceMidi(midiFromFormal(reversed.formal),authority.atoms,records,{allowDraft:true})).meaning.arguments.content.proposition;
const original=(await decodeFoundationSentenceMidi(midiFromFormal(results[4].formal),authority.atoms,records,{allowDraft:true})).meaning.arguments.content.proposition;
assert.deepEqual(rev.arguments.target,original.arguments.comparison_standard);assert.deepEqual(rev.arguments.comparison_standard,original.arguments.target);
assert.equal((await compose('Nora wants to prefer tea to coffee.')).status,'candidate_translation');
await assert.rejects(compose('Nora wants that '.repeat(10)+'Eli cares for Orin.'),/nesting depth/);
console.log('PASS 12 recursive desire/preference/control cases: independent states, intensional boundaries, nearest-holder identity, Ruby/MIDI parity, inverse direction, gloss identity, bundle and recursion limits.');

const sameName=await compose('Nora wants Nora to prefer tea to coffee.');
const controlled=await compose('Nora wants to prefer tea to coffee.');
assert.notDeepEqual(midiFromFormal(sameName.formal),midiFromFormal(controlled.formal));
assert.equal((await decodeFoundationSentenceMidi(midiFromFormal(sameName.formal),authority.atoms,records,{allowDraft:true})).meaning.arguments.content.proposition.arguments.experiencer.reference.kind,'phonemic');
assert.equal((await verifyBundle(await createBundle(controlled))).vocabulary_status,'candidate');
const invalid=structuredClone(controlled.semantic_ir);
invalid.edges.find(e=>e.type==='fills_role'&&e.from==='desired:holder').role='target';
await assert.rejects(validateFoundationIR(invalid,records,{allowDraft:true}));
const rubyInvalid=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_foundation_ir','-rjson','-e',"x=JSON.parse(STDIN.read);begin;EraZeroFoundationIR.validate!(x['ir'],x['records'],allow_draft:true);puts 'false';rescue ArgumentError;puts 'true';end"],{cwd:root,input:JSON.stringify({ir:invalid,records}),encoding:'utf8'}));assert.equal(rubyInvalid,true);
for(const text of ['I want to prefer tea to coffee.','You want not to prefer tea to coffee.','Nora wants that Eli wants to prefer tea to coffee.']){
 const r=await compose(text);await validateFoundationIR(r.semantic_ir,records,{allowDraft:true});
 const d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
 const desired=d.meaning.arguments.content.proposition;
 const preference=desired.arguments.content?desired.arguments.content.proposition:desired;
 assert.equal(preference.arguments.experiencer.reference.binding,'parent_desire_experiencer');
}
console.log('PASS 18 controlled preference state/negation combinations plus deictic/nested holders, same-name contrast, draft bundle and invalid-role rejection in both validators.');
