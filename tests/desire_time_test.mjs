import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true});
const cases=[
 ['Nora wanted to care for Eli.',['before_speech']],
 ['Nora did not want to care for Eli.',['before_speech','negation']],
 ['Did Nora want to care for Eli?',['before_speech']],
 ['Yesterday, Nora wanted to care for Eli.',['previous_day']],
 ['Yesterday, did Nora not want to care for Eli?',['previous_day','negation']],
 ['Today, Nora wants to be able to move.',['current_day']],
 ['Today, Nora wanted to be able to move.',['current_day','before_speech']]
],results=[];
for(const [text,scopes] of cases)for(const state of [0,1,2]){
 const r=await compose(text.replace(/[.?]$/,'')+` [${state}]`+(text.endsWith('?')?'?':'.'));results.push(r);
 const d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
 assert.deepEqual(d.meaning.scopes.map(s=>s.relation||s.operator),scopes);assert.equal(d.meaning.runtime_state,state);
 assert.equal(d.speech_act,text.endsWith('?')?'question':'assertion');
 assert.equal(d.meaning.arguments.content.content_status,'intensional');assert.deepEqual(d.meaning.arguments.content.proposition.scopes,[]);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,**o);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))}})"],{cwd:root,input:JSON.stringify({irs:results.map(r=>r.semantic_ir),records}),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
// Time inside the explicit desired proposition stays there, even with past desire.
const inner=await compose('Nora wanted that Eli cares for Orin today.');
const decoded=await decodeFoundationSentenceMidi(midiFromFormal(inner.formal),authority.atoms,records,{allowDraft:true});
assert.deepEqual(decoded.meaning.scopes,[{operator:'time',relation:'before_speech'}]);
assert.deepEqual(decoded.meaning.arguments.content.proposition.scopes,[{operator:'time',relation:'current_day'}]);
for(const text of ['Yesterday, Nora wants to care for Eli.','Nora wanted to care for Eli yesterday.','Nora wants Eli to care for Orin today.','Tomorrow, Nora wanted to care for Eli.'])await assert.rejects(compose(text));
console.log('PASS 21 desire time/runtime/negation/question cases with Ruby/MIDI parity; intensional content time stays separate and ambiguous trailing days reject.');
