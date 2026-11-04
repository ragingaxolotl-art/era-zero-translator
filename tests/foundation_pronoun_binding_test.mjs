import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {composeFoundationSentence,foundationPronounPlan} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=(input,bindings)=>composeFoundationSentence(input,authority,records,load,{allowDraft:true,...bindings?{bindings}:{}});
let count=0;
for(const state of [0,1,2])for(const [input,bindings,explicit] of [
 ['She prefers him to Nora.',{ref0:'Ada',ref1:'Eli'},'Ada prefers Eli to Nora.'],
 ['she wants to be happy.',{ref0:'Nora'},'Nora wants to be happy.'],
 ['Does Nora prefer her to him?',{ref0:'the robot',ref1:'you'},'Does Nora prefer the robot to you?'],
 ['Nora wants him to be happy.',{ref0:'Eli'},'Nora wants Eli to be happy.']
]){
 const text=input+` [${state}]`,a=await compose(text,bindings),b=await compose(explicit+` [${state}]`);
 assert.deepEqual(a.formal,b.formal);assert.deepEqual(midiFromFormal(a.formal),midiFromFormal(b.formal));assert.equal(a.source_input,text);assert.equal(a.resolved_pronouns.length,Object.keys(bindings).length);count++;
}
for(const bad of [{},{ref0:'Ada'},{ref0:'Ada',ref1:'him'},{ref0:'Ada',ref1:'Eli',extra:'Nora'}])await assert.rejects(()=>compose('She prefers him to Nora.',bad),e=>e.code==='pronoun_referents_required');
assert.equal(foundationPronounPlan('"She" prefers tea to coffee.'),null);
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showFoundationPreview('),app.indexOf('function showFutureInterpretation('));
const element=()=>({value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));const input='She prefers him to Nora.';elements.sourceInput.value=input;
const state={mode:'english',data:authority,wordSelections:new Map()};let shown,errors=[];
const ctx=vm.createContext({state,foundationPronounPlan,$:id=>elements[id],document:{createElement:element},fetch:async()=>({ok:true,json:async()=>({records})}),sentenceTemplate:load,composeFoundationSentence,showResolution:async r=>shown=r,showError:e=>errors.push(e)});
vm.runInContext(handler,ctx);
const show=()=>{ctx.showFoundationPreview(input);const card=elements.candidateList.children.at(-1);return {card,fields:card.children.slice(1,-1).map(l=>l.children[0]),button:card.children.at(-1)};};
let ui=show();assert.equal(ui.fields.length,2);assert(ui.fields.every(f=>f.value===''));await ui.button.click();assert.equal(shown,undefined);assert.equal(errors.at(-1).code,'pronoun_referents_required');
ui.fields[0].value='Ada';ui.fields[1].value='Eli';await ui.button.click();assert.equal(shown.resolved_input,'Ada prefers Eli to Nora.');
ui=show();ui.fields[0].value='Ada';ui.fields[1].value='Eli';let finish;ctx.fetch=()=>new Promise(resolve=>finish=resolve);const previous=shown,pending=ui.button.click();ui.fields[1].value='Orin';finish({ok:true,json:async()=>({records})});await pending;assert.equal(shown,previous);
console.log(`PASS ${count} explicit candidate pronoun bindings match full named-reference meanings/music; actual UI requires all bindings and discards edited pending results.`);
ctx.fetch=async()=>({ok:true,json:async()=>({records})});
elements.sourceInput.value='They prefer tea to coffee.';ctx.showFoundationPreview(elements.sourceInput.value);
const neutralCard=elements.candidateList.children.at(-1),neutralLabel=neutralCard.children[1],neutralButton=neutralCard.children.at(-1);assert.equal(neutralLabel.children.length,2);
neutralLabel.children[0].value='Nora';const beforeNeutral=shown;await neutralButton.click();assert.equal(shown,beforeNeutral);assert.equal(errors.at(-1).code,'pronoun_referents_required');
neutralLabel.children[1].value='singular';await neutralButton.click();assert.equal(shown.resolved_input,'Nora prefer tea to coffee.');
const singular=shown;neutralLabel.children[1].value='plural';await neutralButton.click();assert.equal(shown,singular);assert.equal(errors.at(-1).code,'pronoun_referents_required');
console.log('PASS foundation UI neutral reference: number required, singular binding submitted, plural not coerced.');
