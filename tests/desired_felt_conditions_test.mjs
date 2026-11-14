import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal,createBundle,verifyBundle} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority};
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true});
const profiles={sad:['sad_felt_mood',[19,18,11]],happy:['happy_felt_mood',[13,12,11]],hungry:['felt_hunger',[15,14,11]],thirsty:['felt_thirst',[16,14,11]],tired:['felt_fatigue',[17,11]]},results=[];
for(const [adjective,[name,codes]] of Object.entries(profiles))for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negation of [false,true]){
 const r=await compose(`I want ${negation?'not ':''}to be ${adjective} [${inner}] [${outer}].`);results.push(r);
 const d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true}),felt=d.meaning.arguments.content.proposition;
 assert.equal(d.meaning.runtime_state,outer);assert.equal(d.meaning.arguments.content.content_status,'intensional');
 assert.equal(felt.predicate.name,name);assert.deepEqual(felt.predicate.convention_codes,codes);assert.equal(felt.runtime_state,inner);
 assert.deepEqual(felt.scopes,negation?[{operator:'negation'}]:[]);assert.equal(felt.arguments.experiencer.reference.binding,'parent_desire_experiencer');
 assert.equal(felt.meaning.consciously_felt_self_condition,true);assert.equal(felt.meaning.measured_physiological_deficit_asserted,false);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-rjson','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,**o);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))}})"],{cwd:root,input:JSON.stringify({irs:results.map(r=>r.semantic_ir),records}),encoding:'utf8',maxBuffer:80_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,90);
for(const text of ['Nora wants Eli to be happy.','Nora wants that Eli is thirsty.','Nora wants that Eli wants not to be tired.','Did Nora want to be happy?']){
 const r=await compose(text);await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
 assert.equal((await verifyBundle(await createBundle(r))).vocabulary_status,'candidate');
}
const direct=await compose('Nora wants Nora to be happy.'),bound=await compose('Nora wants to be happy.');
assert.notDeepEqual(midiFromFormal(direct.formal),midiFromFormal(bound.formal));
assert.equal((await decodeFoundationSentenceMidi(midiFromFormal(direct.formal),authority.atoms,records,{allowDraft:true})).meaning.arguments.content.proposition.arguments.experiencer.reference.kind,'phonemic');
for(const text of ['Nora wants to be happy with Eli.','Nora wants to be hungry for power.','Nora wants to be tired of the task.'])await assert.rejects(compose(text));
console.log('PASS 90 desired felt-condition/runtime/negation contrasts preserve nested compounds, bound experiencers and intensional meaning with Ruby/MIDI parity and independent decoding; explicit/nested subjects, bundles and figurative rejection checked.');
const {validateFoundationIR}=await import('../pages/foundation_ir.mjs');
const badSlot=structuredClone(bound.semantic_ir);badSlot.nodes.find(n=>n.target_type==='compound').compound_bindings[0].slot_path=['s-experiencer'];
await assert.rejects(validateFoundationIR(badSlot,records,{allowDraft:true}));
const rubyBadSlot=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_foundation_ir','-rjson','-e',"x=JSON.parse(STDIN.read);begin;EraZeroFoundationIR.validate!(x['ir'],x['records'],allow_draft:true);puts 'false';rescue ArgumentError;puts 'true';end"],{cwd:root,input:JSON.stringify({ir:badSlot,records}),encoding:'utf8'}));assert.equal(rubyBadSlot,true);
assert(!bound.formal.performance.lexical_events.some(e=>e.occurrence_id==='desired:a'));
const {visemePlanFromFormal}=await import('../pages/visemes.mjs');
const {soundPlanFromFormal}=await import('../pages/engine.mjs');
const animation=visemePlanFromFormal(bound.formal,{mode:'strict'}),sound=soundPlanFromFormal(bound.formal);
assert.deepEqual(animation.cues.map(c=>c.note),[...sound.lexical_events.flatMap(e=>[...e.family_opening,...e.address_path,...e.runtime_ending]),...sound.sentence_contour]);
