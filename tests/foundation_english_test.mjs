import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>!authority.resolution_files[id]?{authority}:({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=text=>composeFoundationSentence(text,authority,records,load,{allowDraft:true});
const cases=['Nora wants Eli to care for Orin.','Does Nora want Eli to care for Orin?','I want you to care for Nora.','Nora prefers tea to coffee.','Nora prefers coffee to tea.','I prefer tea to coffee.','You do not prefer tea to coffee.','Does Nora prefer tea to coffee?','Nora prefers the cup to the bowl.','Nora wants that Eli cares for Orin.','I want that you care for Nora.','Nora does not want that Eli cares for Orin.'];
let count=0;
for(const text of cases)for(const state of [0,1,2]){
 const input=text.replace(/[.?]$/,'')+` [${state}]`+(text.endsWith('?')?'?':'.');
 const result=await compose(input);assert.equal(result.status,'candidate_translation');
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};f=EraZeroRenderer.render(x['ir'],**o);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))})"],{cwd:root,input:JSON.stringify({ir:result.semantic_ir,records}),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);
 const midi=midiFromFormal(result.formal);assert.equal(Buffer.from(midi).toString('base64'),ruby.midi);
 const d=await decodeFoundationSentenceMidi(midi,authority.atoms,records,{allowDraft:true});
 assert.equal(d.meaning.runtime_state,state);assert.equal(d.speech_act,text.endsWith('?')?'question':'assertion');
 if(text.includes('want'))assert.equal(d.meaning.arguments.content.content_status,'intensional');
 if(text.includes('not'))assert.deepEqual(d.meaning.scopes,[{operator:'negation'}]);
 count++;
}
for(const text of ['Nora wants tea.','Nora prefers bright to rough.','Nora prefers tea.','Nora wants that she cares for Orin.'])await assert.rejects(compose(text));
await assert.rejects(composeFoundationSentence('Nora prefers tea to coffee.',authority,records,load));
console.log(`PASS ${count} candidate English sentences match Ruby formal/MIDI and recover meaning independently; ambiguous object desires remain unresolved.`);
// Reused compound clauses must retain their internal participant bindings after nesting.
for(const text of ['Nora wants that Eli is happy.','Nora wants that Eli is hungry.','Nora wants that Eli is carrying the box.']){
 const result=await compose(text);
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rjson','-e',"x=JSON.parse(STDIN.read);puts JSON.generate(EraZeroRenderer.render(x['ir'],foundation_records:x['records'],allow_draft_foundations:true))"],{cwd:root,input:JSON.stringify({ir:result.semantic_ir,records}),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby);
}
console.log('PASS 3 desired compound clauses preserve scoped bindings and reference-renderer formal parity.');
