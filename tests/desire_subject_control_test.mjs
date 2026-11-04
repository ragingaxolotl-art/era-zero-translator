import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
import {validateFoundationIR} from '../pages/foundation_ir.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true});
let checked;
for(const source of ['I want to care for Nora.','You want to care for Nora.','Nora wants to care for Eli.','The teacher wants to care for Eli.','Nora does not want to care for Eli.','Does Nora want to care for Eli?'])for(const state of [0,1,2]){
 const r=await compose(source.replace(/[.?]$/,'')+` [${state}]`+(source.endsWith('?')?'?':'.'));checked=r;
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};f=EraZeroRenderer.render(x['ir'],**o);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))})"],{cwd:root,input:JSON.stringify({ir:r.semantic_ir,records}),encoding:'utf8'}));
 assert.deepEqual(r.formal,ruby.formal);const bytes=midiFromFormal(r.formal);assert.equal(Buffer.from(bytes).toString('base64'),ruby.midi);
 const decoded=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
 assert.equal(decoded.meaning.arguments.content.proposition.arguments.actor.reference.binding,'parent_desire_experiencer');
 assert.equal(decoded.meaning.runtime_state,state);
}
const bad=structuredClone(checked.semantic_ir);bad.edges.find(e=>e.type==='corefers_with').to='desired:b';
await assert.rejects(validateFoundationIR(bad,records,{allowDraft:true}));
const separate=await compose('Nora wants Nora to care for Eli.');
const independent=await decodeFoundationSentenceMidi(midiFromFormal(separate.formal),authority.atoms,records,{allowDraft:true});
assert.equal(independent.meaning.arguments.content.proposition.arguments.actor.reference.kind,'phonemic');
assert.notDeepEqual(midiFromFormal(separate.formal),midiFromFormal((await compose('Nora wants to care for Eli.')).formal));
console.log('PASS 18 desire subject-control sentences preserve explicit identity in Ruby/browser formal, MIDI and independent decoding.');
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_foundation_ir','-rjson','-e',"x=JSON.parse(STDIN.read);begin;EraZeroFoundationIR.validate!(x['ir'],x['records'],allow_draft:true);puts 'false';rescue ArgumentError;puts 'true';end"],{cwd:root,input:JSON.stringify({ir:bad,records}),encoding:'utf8'}));
assert.equal(rejected,true);
const {visemePlanFromFormal}=await import('../pages/visemes.mjs');
const {soundPlanFromFormal,createBundle,verifyBundle}=await import('../pages/engine.mjs');
const plan=visemePlanFromFormal(checked.formal,{mode:'strict'}),sound=soundPlanFromFormal(checked.formal);
assert.deepEqual(plan.cues.map(c=>c.note),[...sound.lexical_events.flatMap(e=>[...e.family_opening,...e.address_path,...e.runtime_ending]),...sound.sentence_contour]);
assert.equal((await verifyBundle(await createBundle(checked))).vocabulary_status,'candidate');

const {subjectControlEvent}=await import('../pages/subject_control.mjs');
const controlled=checked.semantic_ir.nodes.find(n=>n.reference_type==='desire_subject');
for(const anchor of [24,128,60.5])assert.throws(()=>subjectControlEvent(controlled,anchor),/range/);
const rubyRange=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_subject_control','-rjson','-e',"n=JSON.parse(STDIN.read);puts JSON.generate([24,128,60.5].map{|a|begin;EraZeroSubjectControl.event(n,a);false;rescue ArgumentError;true;end})"],{cwd:root,input:JSON.stringify(controlled),encoding:'utf8'}));assert.deepEqual(rubyRange,[true,true,true]);
// Reuse the reviewed mobility capacity inside desire without asserting actual motion.
const mobilityResults=[];
for(const outerState of [0,1,2])for(const innerState of [0,1,2])for(const innerNegation of [false,true]){
 const r=await compose(`Nora wants to be ${innerNegation?'not ':''}able to move [${innerState}] [${outerState}].`);
 const ir=r.semantic_ir,bytes=midiFromFormal(r.formal),decoded=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
 assert.equal(decoded.meaning.runtime_state,outerState);
 const desired=decoded.meaning.arguments.content;
 assert.equal(desired.content_status,'intensional');assert.equal(desired.proposition.predicate.root_id,'MOV:201');assert.equal(desired.proposition.runtime_state,innerState);
 assert.equal(desired.proposition.arguments.bearer.reference.binding,'parent_desire_experiencer');
 assert.deepEqual(desired.proposition.scopes,innerNegation?[{operator:'negation'}]:[]);
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};f=EraZeroRenderer.render(x['ir'],**o);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))})"],{cwd:root,input:JSON.stringify({ir,records}),encoding:'utf8'}));
 assert.deepEqual(r.formal,ruby.formal);assert.equal(Buffer.from(bytes).toString('base64'),ruby.midi);mobilityResults.push(r);
}
assert.equal(new Set(mobilityResults.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,18);
for(const text of ['I want to be able to move.','You want to be able to move.','Does Nora want to be able to move?','Nora does not want to be able to move.']){
 const r=await compose(text),d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
 assert.equal(d.meaning.arguments.content.proposition.arguments.bearer.reference.binding,'parent_desire_experiencer');
 assert.equal(d.speech_act,text.startsWith('Does')?'question':'assertion');
 assert.deepEqual(d.meaning.scopes,text.includes('does not')?[{operator:'negation'}]:[]);
}
const explicitMobility=await compose('Nora wants Eli to be able to move.');
const explicitMeaning=await decodeFoundationSentenceMidi(midiFromFormal(explicitMobility.formal),authority.atoms,records,{allowDraft:true});
assert.equal(explicitMeaning.meaning.arguments.content.proposition.arguments.bearer.reference.kind,'phonemic');
assert.notDeepEqual(midiFromFormal(explicitMobility.formal),midiFromFormal(mobilityResults[8].formal));
const wrongRole=structuredClone(mobilityResults[0].semantic_ir);wrongRole.edges.find(e=>e.from==='desired:a'&&e.type==='fills_role').role='actor';
await assert.rejects(validateFoundationIR(wrongRole,records,{allowDraft:true}));
for(const text of ['Nora wants to move.','Nora wants to be able to move the box.','Nora wants to be able to move quickly.'])await assert.rejects(compose(text));
assert.equal((await verifyBundle(await createBundle(mobilityResults[0]))).vocabulary_status,'candidate');
console.log('PASS desire for mobility: 18 independent outer/inner state and inner-negation contrasts, explicit/control subjects, question/outer negation, Ruby/MIDI inverse and draft-bundle checks.');
const sameNameMobility=await compose('Nora wants Nora to be able to move.');
assert.equal((await decodeFoundationSentenceMidi(midiFromFormal(sameNameMobility.formal),authority.atoms,records,{allowDraft:true})).meaning.arguments.content.proposition.arguments.bearer.reference.kind,'phonemic');
assert.notDeepEqual(midiFromFormal(sameNameMobility.formal),midiFromFormal((await compose('Nora wants to be able to move.')).formal));
const wrongMobilityRoleRuby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_foundation_ir','-rjson','-e',"x=JSON.parse(STDIN.read);begin;EraZeroFoundationIR.validate!(x['ir'],x['records'],allow_draft:true);puts 'false';rescue ArgumentError;puts 'true';end"],{cwd:root,input:JSON.stringify({ir:wrongRole,records}),encoding:'utf8'}));assert.equal(wrongMobilityRoleRuby,true);
