import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true});
const decode=r=>decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
const sounds=new Set();
for(const state of [0,1,2])for(const leftState of [0,1,2])for(const rightState of [0,1,2]){
 const r=await compose(`Nora prefers that Eli is happy [${leftState}] rather than that Eli is tired [${rightState}] [${state}].`);
 const d=await decode(r),m=d.meaning;
 assert.equal(m.runtime_state,state);
 for(const [role,expectedState,quality] of [['target',leftState,'happy'],['comparison_standard',rightState,'tired']]){
  assert.equal(m.arguments[role].type,'proposition');assert.equal(m.arguments[role].content_status,'intensional');
  assert.equal(m.arguments[role].proposition.runtime_state,expectedState);
  assert.equal(m.arguments[role].proposition.meaning.quality,quality==='tired'?'physical_or_mental_weariness':'glad_or_content_mood');
 }
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};f=EraZeroRenderer.render(x['ir'],**o);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))})"],{cwd:root,input:JSON.stringify({ir:r.semantic_ir,records}),encoding:'utf8'}));
 assert.deepEqual(r.formal,ruby.formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby.midi);sounds.add(ruby.midi);
}
assert.equal(sounds.size,27);
const forward=await compose('Nora prefers that Eli is happy rather than that Eli is tired.');
const reverse=await compose('Nora prefers that Eli is tired rather than that Eli is happy.');
assert.notDeepEqual(midiFromFormal(forward.formal),midiFromFormal(reverse.formal));
const negative=await decode(await compose('Nora does not prefer that Eli is not happy rather than that Eli is tired.'));
assert.deepEqual(negative.meaning.scopes,[{operator:'negation'}]);
assert.deepEqual(negative.meaning.arguments.target.proposition.scopes,[{operator:'negation'}]);
assert.deepEqual(negative.meaning.arguments.comparison_standard.proposition.scopes,[]);
const time=await decode(await compose('Nora preferred that Eli was happy yesterday rather than that Eli is tired today.'));
assert.deepEqual(time.meaning.scopes,[{operator:'time',relation:'before_speech'}]);
assert(time.meaning.arguments.target.proposition.scopes.some(s=>s.relation==='previous_day'));
assert(time.meaning.arguments.comparison_standard.proposition.scopes.some(s=>s.relation==='current_day'));
const nested=await decode(await compose('Nora prefers that Eli wants to be happy rather than that Orin is tired.'));
assert.equal(nested.meaning.arguments.target.proposition.arguments.content.proposition.arguments.experiencer.reference.binding,'parent_desire_experiencer');
for(const s of ['Nora prefers that happy rather than that tired.','Nora prefers that Eli is happy rather than that Eli is tired rather than that Eli is hungry.'])await assert.rejects(compose(s));
console.log('PASS 27 independent preference/alternative runtime contrasts with Ruby parity and MIDI inverse; order, nested desire, negation and separate time scopes preserved.');

const question=await decode(await compose('Did Nora not prefer that Eli is happy rather than that Orin is tired?'));
assert.equal(question.speech_act,'question');
assert(question.meaning.scopes.some(s=>s.operator==='negation'));
assert(question.meaning.scopes.some(s=>s.relation==='before_speech'));
