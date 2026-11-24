import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {parseNamedSentence,composeNamedSentence,clauseInterpretationPlan,composeSentenceConjunction} from '../pages/sentences.mjs';
import {physicalComparativeMeaning} from '../pages/physical_comparatives.mjs';
import {pronounInterpretationPlan,composePronounSentence} from '../pages/pronouns.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeSupportedMeaningMidi} from '../pages/semantic_music_dispatch.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=async id=>({...JSON.parse(fs.readFileSync(new URL('../pages/'+a.resolution_files[id],import.meta.url))).variants['assertion:1'],authority:a});
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8');
const element=tag=>({tag,value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const state={mode:'general',wordSelections:new Map()};let shown;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},parseNamedSentence,composeNamedSentence,physicalComparativeMeaning,sentenceTemplate:load,showResolution:async r=>shown=r});
vm.runInContext(app.slice(app.indexOf('function showPhysicalComparison('),app.indexOf('function showBrightnessComparison(')),ctx);
const find=(node,match)=>[node,...node.children.flatMap(child=>find(child,()=>true))].filter(match);
for(const [input,label,dimension] of [['The cup is hotter than the plate.','Physical temperature','thermodynamic_temperature'],['The cup was lighter than the plate.','Physical mass','mass']]){
 state.mode='general';ctx.sentenceTemplate=load;elements.sourceInput.value=input;shown=null;ctx.showPhysicalComparison(input);
 let card=elements.candidateList.children.at(-1),physical=find(card,n=>n.textContent===label)[0],other=find(card,n=>n.textContent==='Another meaning')[0];
 assert.equal(shown,null);await other.click();assert.equal(shown,null);assert.equal(elements.sourceInput.value,input);
 assert(find(card,n=>/needs its own definition/.test(n.textContent||'')).length);
 await physical.click();assert.equal(shown.source_input,input);
 assert.equal(decodeSupportedMeaningMidi(midiFromFormal(shown.formal),a.atoms).dimension,dimension);
 for(const change of ['input','other','detached','mode']){
  state.mode='general';elements.sourceInput.value=input;ctx.sentenceTemplate=load;ctx.showPhysicalComparison(input);
  card=elements.candidateList.children.at(-1);physical=find(card,n=>n.textContent===label)[0];other=find(card,n=>n.textContent==='Another meaning')[0];
  let finish;ctx.sentenceTemplate=()=>new Promise(resolve=>finish=resolve);const previous=shown,pending=physical.click();
  if(change==='input')elements.sourceInput.value='Changed';
  if(change==='other')await other.click();
  if(change==='detached')card.isConnected=false;
  if(change==='mode')state.mode='controlled';
  finish(await load('MAT:010'));await pending;assert.equal(shown,previous,change);
 }
}
state.mode='general';ctx.sentenceTemplate=load;
vm.runInContext(app.slice(app.indexOf('function showPronounReferents('),app.indexOf('function showClauseInterpretations(')),ctx);
ctx.composePronounSentence=composePronounSentence;
const input='It is colder than that plate.';elements.sourceInput.value=input;shown=null;
ctx.showPronounReferents(input,pronounInterpretationPlan(input));let card=elements.candidateList.children.at(-1);
const reference=card.children[0].children[0],meaning=card.children[1].children[0];reference.value='the cup';
await card.children.at(-1).click();assert.equal(shown,null);meaning.value='temperature_comparison';await card.children.at(-1).click();
assert.equal(shown.resolved_input,'the cup is colder than that plate.');assert.equal(decodeSupportedMeaningMidi(midiFromFormal(shown.formal),a.atoms).relation,'less_than');
for(const number of ['singular','plural']){
 const text='They are heavier than the plate. [2]';
 if(number==='plural'){await assert.rejects(()=>composePronounSentence(text,load,{ref0:{referent:'Nora',number}},{interpretation:'mass_comparison'}));continue;}
 const result=await composePronounSentence(text,load,{ref0:{referent:'Nora',number}},{interpretation:'mass_comparison'});
 const decoded=decodeSupportedMeaningMidi(midiFromFormal(result.formal),a.atoms);assert.equal(decoded.runtime_state,2);assert(!JSON.stringify(decoded).includes('gender'));
}
ctx.composeSentenceConjunction=composeSentenceConjunction;
ctx.composeSentenceSequence=ctx.composeSentenceConditional=ctx.composeSentenceDisjunction=()=>{throw Error('Unexpected group type');};
vm.runInContext(app.slice(app.indexOf('function showClauseInterpretations('),app.indexOf('function showCarryingViewpoint(')),ctx);
const grouped='The cup is heavier than the plate and Nora is conscious.';elements.sourceInput.value=grouped;shown=null;
ctx.showClauseInterpretations(grouped,clauseInterpretationPlan(grouped));card=elements.candidateList.children.at(-1);
const choice=find(card,n=>n.tag==='select')[0];assert.equal(choice.value,'');await card.children.at(-1).click();assert.equal(shown,null);
choice.value='mass_comparison';await card.children.at(-1).click();assert.equal(shown.source_input,grouped);
assert.equal(decodeSupportedMeaningMidi(midiFromFormal(shown.formal),a.atoms).members.length,2);
console.log('PASS real comparison, pronoun and grouped-clause handlers: explicit meaning choices, another-meaning rejection, neutral singular pronoun, and eight stale-result scenarios.');
