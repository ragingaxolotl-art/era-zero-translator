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
const decode=r=>decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
const performances=new Set();let sample;
for(const [condition,id] of [['damaged','WRN:001'],['restored','REP:001'],['able to pay attention','MIN:201']]){
 for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negative of [false,true]){
  const r=await compose(`Nora wants to be ${negative?'not ':''}${condition} [${inner}] [${outer}].`);sample=r;
  const d=await decode(r),content=d.meaning.arguments.content;
  assert.equal(d.meaning.runtime_state,outer);assert.equal(content.content_status,'intensional');
  assert.equal(content.proposition.predicate.root_id,id);assert.equal(content.proposition.runtime_state,inner);
  assert.deepEqual(content.proposition.scopes,negative?[{operator:'negation'}]:[]);
  assert.deepEqual(content.proposition.arguments.bearer.reference,{kind:'bound',binding:'parent_desire_experiencer'});
  const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};f=EraZeroRenderer.render(x['ir'],**o);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))})"],{cwd:root,input:JSON.stringify({ir:r.semantic_ir,records}),encoding:'utf8'}));
  assert.deepEqual(r.formal,ruby.formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby.midi);performances.add(ruby.midi);
 }
 const explicit=await compose(`Nora wants Nora to be ${condition}.`),controlled=await compose(`Nora wants to be ${condition}.`);
 assert.equal((await decode(explicit)).meaning.arguments.content.proposition.arguments.bearer.reference.kind,'phonemic');
 assert.notDeepEqual(midiFromFormal(explicit.formal),midiFromFormal(controlled.formal));
 for(const holder of ['I','You','The teacher']){
  const r=await compose(`${holder} ${holder==='I'||holder==='You'?'want':'wants'} to be ${condition}.`);
  assert.equal((await decode(r)).meaning.arguments.content.proposition.arguments.bearer.reference.binding,'parent_desire_experiencer');
 }
 const nested=await compose(`Nora wants that Eli wants to be ${condition}.`);
 assert.equal((await decode(nested)).meaning.arguments.content.proposition.arguments.content.proposition.arguments.bearer.reference.binding,'parent_desire_experiencer');
 const question=await compose(`Did Nora want to be ${condition}?`),q=await decode(question);
 assert.equal(q.speech_act,'question');assert(q.meaning.scopes.some(s=>s.relation==='before_speech'));
}
assert.equal(performances.size,54);
assert.deepEqual(midiFromFormal((await compose('Nora wants to be damaged.')).formal),midiFromFormal((await compose('Nora wants to be impaired.')).formal));
const wrong=structuredClone(sample.semantic_ir);wrong.edges.find(e=>e.from==='desired:a'&&e.type==='fills_role').role='actor';
await assert.rejects(validateFoundationIR(wrong,records,{allowDraft:true}));
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_foundation_ir','-rjson','-e',"x=JSON.parse(STDIN.read);begin;EraZeroFoundationIR.validate!(x['ir'],x['records'],allow_draft:true);puts 'false';rescue ArgumentError;puts 'true';end"],{cwd:root,input:JSON.stringify({ir:wrong,records}),encoding:'utf8'}));assert.equal(rejected,true);
for(const text of ['Nora wants to be repaired by Eli.','Nora wants to be able to pay attention to Eli.','Nora wants to be damaged badly.'])await assert.rejects(compose(text));
console.log('PASS desired atomic conditions: 54 distinct state/negation performances with Ruby parity and independent MIDI meaning recovery; explicit, controlled, nested and deictic subjects; wrong-role rejection.');
