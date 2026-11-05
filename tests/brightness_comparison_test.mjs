import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConjunction,clauseInterpretationPlan} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodePropertyComparisonMidi} from '../pages/property_comparison_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const load=async id=>({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
for(const state of [0,1,2])for(const input of ['This lamp is brighter than that lamp.','That lamp is brighter than this lamp.','This lamp is dimmer than that lamp.','This lamp is not brighter than that lamp.',"This lamp isn't dimmer than that lamp.",'Is this lamp brighter than that lamp?','It is possible that this lamp is brighter than that lamp.','The lamp is brighter than the lantern.']){
 const text=input+` [${state}]`,parsed=parseNamedSentence(text);assert.equal(parsed.requiredInterpretation,'luminance_comparison');const template=await load(parsed.predicate);
 await assert.rejects(()=>composeNamedSentence(text,template),e=>e.code==='luminance_comparison_required');
 const r=await composeNamedSentence(text,template,{interpretation:'luminance_comparison'});results.push(r);const d=decodePropertyComparisonMidi(midiFromFormal(r.formal));
 assert.equal(d.dimension,'luminance');assert.equal(d.relation,input.includes('dimmer')?'less_than':'greater_than');assert.equal(d.runtime_state,state);
 assert.deepEqual(d.scopes,input.includes('not')||input.includes("isn't")?[{operator:'negation'}]:input.includes('possible')?[{operator:'modality',mode:'possible'}]:[]);
 assert.equal(d.speech_act,input.startsWith('Is ')?'question':'assertion');
 if(!input.startsWith('The')){
  assert.equal(d.participants.bearer.reference_mode,input.startsWith('That')?'distal_nominal':'proximal_nominal');assert.equal(d.participants.comparison_standard.reference_mode,input.startsWith('That')?'proximal_nominal':'distal_nominal');
 }
 assert(!r.semantic_ir.nodes.some(n=>n.kind==='measurement'));
}
for(const state of [0,1,2]){
 const r=await composeSentenceConjunction(`This lamp is brighter than that lamp [${state}] and Orin is conscious [${(state+1)%3}].`,load,[{interpretation:'luminance_comparison'},{}]);results.push(r);
 assert.deepEqual(r.selected_clauses.map(c=>c.options),[{interpretation:'luminance_comparison'},{}]);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:40_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
// Negated greater-than includes equality; it must not become less-than.
const notBrighter=decodePropertyComparisonMidi(midiFromFormal(results[3].formal)),dimmer=decodePropertyComparisonMidi(midiFromFormal(results[2].formal));
const holds=(d,a,b)=>d.scopes.some(s=>s.operator==='negation')?!(a>b):d.relation==='greater_than'?a>b:a<b;
assert.equal(holds(notBrighter,10,10),true);assert.equal(holds(dimmer,10,10),false);
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showBrightnessComparison('),app.indexOf('function showAdjectiveStandard('));
const element=()=>({value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const input='This lamp is brighter than that lamp.';elements.sourceInput.value=input;const state={mode:'general',wordSelections:new Map()};let shown;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:load,composeNamedSentence,showResolution:async r=>shown=r});
vm.runInContext(handler,ctx);ctx.showBrightnessComparison(input);assert.equal(shown,undefined);const card=elements.candidateList.children.at(-1);assert.equal(card.children.at(-1).textContent,'Use physical luminance');await card.children.at(-1).click();assert.equal(shown.selected_interpretation,'luminance_comparison');
for(const change of ['input','detached']){
 ctx.showBrightnessComparison(input);const c=elements.candidateList.children.at(-1);let finish;ctx.sentenceTemplate=()=>new Promise(resolve=>finish=resolve);const previous=shown,pending=c.children.at(-1).click();if(change==='input')elements.sourceInput.value='Changed';else c.isConnected=false;finish(await load('MAT:010'));await pending;assert.equal(shown,previous);elements.sourceInput.value=input;
}
console.log(`PASS ${results.length} brightness comparison and mixed-clause cases with Ruby/MIDI parity, independent direction/reference recovery, negated-comparison counterexample, explicit UI interpretation and stale-result guards.`);

const groupInput='This lamp is brighter than that lamp and Orin is conscious.';
elements.sourceInput.value=groupInput;ctx.sentenceTemplate=load;ctx.composeSentenceConjunction=composeSentenceConjunction;
ctx.composeSentenceSequence=ctx.composeSentenceConditional=ctx.composeSentenceDisjunction=()=>{throw new Error('Unexpected group type');};
vm.runInContext(app.slice(app.indexOf('function showClauseInterpretations('),app.indexOf('function showCarryingViewpoint(')),ctx);
ctx.showClauseInterpretations(groupInput,clauseInterpretationPlan(groupInput));
const group=elements.candidateList.children.at(-1),choice=group.children[0].children[1].children[0],previous=shown;
assert.equal(choice.value,'');await group.children.at(-1).click();assert.equal(shown,previous);
choice.value='luminance_comparison';await group.children.at(-1).click();assert.equal(shown.selected_clauses[0].options.interpretation,'luminance_comparison');
assert.deepEqual(shown.selected_clauses[1].options,{});
console.log('PASS actual multi-clause UI requires comparison choice without a numerical threshold.');
