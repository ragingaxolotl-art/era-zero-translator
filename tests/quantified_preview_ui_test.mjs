import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8');
const handler=app.slice(app.indexOf('function showQuantifiedPreview('),app.indexOf('function showFoundationPreview('));
const element=()=>({children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const input='Exactly three lamps are not physically energized.';elements.sourceInput.value=input;
const state={mode:'general',data:{},resolution:{old:true},wordSelections:new Map()};
let calls=0,shown=null,errors=[];
const context=vm.createContext({foundationPronounPlan:()=>null,state,$:id=>elements[id],document:{createElement:element},fetch:async()=>({ok:true,json:async()=>({records:['candidate']})}),sentenceTemplate:()=>{},composeQuantifiedPropertySentence:async(...args)=>{calls++;assert.equal(args[2].allowDraft,true);return {status:'draft_quantified_translation'}},showResolution:async r=>{shown=r},showError:e=>errors.push(e)});
vm.runInContext(handler+';showQuantifiedPreview('+JSON.stringify(input)+');',context);
assert.equal(state.resolution,null);assert.equal(calls,0);
const button=elements.candidateList.children.at(-1).children[1];
elements.sourceInput.value='Changed';await button.click();assert.equal(calls,0);
elements.sourceInput.value=input;await button.click();assert.equal(calls,1);assert.equal(shown.status,'draft_quantified_translation');
for(const outcome of ['success','failure']){
 vm.runInContext('showQuantifiedPreview('+JSON.stringify(input)+');',context);
 const card=elements.candidateList.children.at(-1),button=card.children[1];let complete;
 context.composeQuantifiedPropertySentence=()=>new Promise((resolve,reject)=>complete=outcome==='success'?resolve:reject);
 const pending=button.click();await new Promise(resolve=>setImmediate(resolve));
 assert.equal(typeof complete,'function');card.isConnected=false;const newer={newer:true};state.resolution=newer;shown=newer;
 complete(outcome==='success'?{status:'draft_quantified_translation'}:new Error('late failure'));await pending;
 assert.equal(state.resolution,newer);assert.equal(shown,newer);assert.equal(errors.length,0);
}
assert(app.includes('if(!parseNamedSentence(input)&&parseQuantifiedPropertySentence(input)){showQuantifiedPreview(input);return}'));
vm.runInContext(app.split('\n').find(l=>l.startsWith('const recognitionOptions='))+';this.options=recognitionOptions;',context);
state.resolution={status:'draft_quantified_translation'};assert.equal(context.options().mode,'strict');
assert(app.includes("['candidate_translation','draft_quantified_translation'].includes(result.status)?'Draft preview'"));
console.log('PASS draft preview UI: explicit opt-in, stale input/results rejection, draft label and strict sound mode.');

const {quantifiedActivityPlan}=await import('../pages/quantified_sentences.mjs');
const active='Exactly three lamps are active.',interpretation=quantifiedActivityPlan(active);assert(interpretation);assert.equal(interpretation.interpreted_input,'Exactly three lamps are physically energized.');
for(const text of ['Exactly three lamps are active and bright.','Nora is active.','Exactly three "active" lamps are broken.'])assert.equal(quantifiedActivityPlan(text),null);
elements.sourceInput.value=active;let interpreted=null;context.composeQuantifiedPropertySentence=async text=>{interpreted=text;return {status:'draft_quantified_translation'}};
context.activityChoice=interpretation;vm.runInContext('showQuantifiedPreview('+JSON.stringify(active)+',activityChoice);',context);
assert.equal(interpreted,null);const activeCard=elements.candidateList.children.at(-1);assert.match(activeCard.children[0].textContent,/does not assert/);assert.equal(activeCard.children[1].textContent,'Use physically energized meaning');await activeCard.children[1].click();assert.equal(interpreted,interpretation.interpreted_input);assert.equal(shown.source_input,active);assert.equal(shown.interpretation_choice.reading,'physically_energized');
console.log('PASS counted active requires explicit physically-energized choice and preserves original wording; unsupported alternatives are not silently mapped.');
