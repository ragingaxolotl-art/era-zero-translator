import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const compose=s=>composeFoundationSentence(s,authority,records,()=>{throw new Error('Unexpected template request')},{allowDraft:true});
const cases=[['Nora preferred tea to coffee.',['before_speech']],['Nora did not prefer tea to coffee.',['before_speech','negation']],['Did Nora prefer tea to coffee yesterday?',['previous_day']],['Did Nora not prefer tea to coffee yesterday?',['previous_day','negation']],['Nora prefers tea to coffee today.',['current_day']],['Nora preferred tea to coffee today.',['current_day','before_speech']]];
for(const [text,scopes] of cases)for(const state of [0,1,2]){
 const result=await compose(text.replace(/[.?]$/,'')+` [${state}]`+(text.endsWith('?')?'?':'.'));
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};f=EraZeroRenderer.render(x['ir'],**o);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))})"],{cwd:root,input:JSON.stringify({ir:result.semantic_ir,records}),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);const bytes=midiFromFormal(result.formal);assert.equal(Buffer.from(bytes).toString('base64'),ruby.midi);
 const d=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
 assert.deepEqual(d.meaning.scopes.map(s=>s.relation||s.operator),scopes);assert.equal(d.meaning.runtime_state,state);assert.equal(d.speech_act,text.endsWith('?')?'question':'assertion');
}
for(const text of ['Nora prefers tea to coffee yesterday.','Nora preferred tea to coffee tomorrow.'])await assert.rejects(compose(text));
console.log('PASS 18 preference time/negation/runtime sentences match reference formal/MIDI and MIDI-only semantic scopes.');
