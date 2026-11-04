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
