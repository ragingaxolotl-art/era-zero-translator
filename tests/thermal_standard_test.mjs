import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,composeSentenceSequence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=async id=>JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const standard={dimension:'thermodynamic_temperature',threshold:'20',scale:'celsius'},results=[];
for(const state of [0,1,2])for(const adjective of ['hot','cold'])for(const negative of [false,true]){
 const input=`The radio is ${negative?'not ':''}${adjective} [${state}].`,parsed=parseNamedSentence(input),template=await load(parsed.predicate);
 assert.equal(parsed.requiredInterpretation,'thermal_standard');await assert.rejects(()=>composeNamedSentence(input,template),e=>e.code==='thermal_standard_required');
 const r=await composeNamedSentence(input,template,{interpretation:'thermal_standard',standard});results.push(r);
 const measure=r.semantic_ir.nodes.find(n=>n.kind==='measurement');assert.equal(measure.magnitude,'293.15');assert.equal(measure.unit,'kelvin');assert.equal(measure.comparison,adjective==='hot'?'greater_than':'less_than');
 assert.equal(r.semantic_ir.nodes.some(n=>n.operator==='negation'),negative);assert.equal(r.semantic_ir.nodes.find(n=>n.node_id==='p').runtime_state.code,state);
 const d=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);assert(d.tokens.some(t=>t.marker===`measure_compare_${measure.comparison}_open`));assert.equal(d.tokens.find(t=>t.root_id==='MAT:010').runtime_state,state);
}
for(const input of ['Is the radio hot?','I am cold.','It is possible that the radio is not hot.','The radio is hot today.','The radio was cold yesterday.']){const parsed=parseNamedSentence(input);results.push(await composeNamedSentence(input,await load(parsed.predicate),{interpretation:'thermal_standard',standard}));}
const reference=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:8_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,reference[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(reference[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
const input='The radio is hot.',template=await load('MAT:010');
const c=await composeNamedSentence(input,template,{interpretation:'thermal_standard',standard});
const k=await composeNamedSentence(input,template,{interpretation:'thermal_standard',standard:{...standard,threshold:'293.15',scale:'kelvin'}});assert.deepEqual(c.formal,k.formal);
const different=await composeNamedSentence(input,template,{interpretation:'thermal_standard',standard:{...standard,threshold:'50'}});assert.notDeepEqual(midiFromFormal(c.formal),midiFromFormal(different.formal));
for(const invalid of [undefined,{...standard,threshold:''},{...standard,dimension:'felt_warmth'},{...standard,scale:'fahrenheit'},{...standard,threshold:'2e1'}])await assert.rejects(()=>composeNamedSentence(input,template,{interpretation:'thermal_standard',standard:invalid}));
assert.equal(parseNamedSentence('The radio will be hot tomorrow.'),null);
await assert.rejects(()=>composeSentenceSequence('The radio is hot, then Ada is conscious.',load),e=>e.code==='thermal_standard_required');
// Actual UI handler: no default threshold, no audio before explicit selection,
// invalid values remain editable, and changed input cannot receive old results.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8');
const source=app.slice(app.indexOf('function showThermalStandard('),app.indexOf('function showFutureInterpretation('));
const element=()=>({value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','phraseCoverage','resolutionPanel','results','candidateList','decisionSummary'].map(id=>[id,element()]));elements.sourceInput.value=input;
const state={mode:'english',wordSelections:new Map(),resolution:{old:true}};let shown=null,calls=0;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:load,composeNamedSentence:async(...args)=>{calls++;return composeNamedSentence(...args)},showResolution:async r=>shown=r,toast(){}});
vm.runInContext(source+';showThermalStandard('+JSON.stringify(input)+');',ctx);assert.equal(calls,0);assert.equal(state.resolution,null);
const card=elements.candidateList.children[0],threshold=card.children[1].children[0],button=card.children[4];assert.equal(threshold.value,'');
await button.click();assert.equal(shown,null);assert(card.children[3].textContent.includes('threshold'));
threshold.value='20';elements.sourceInput.value='Changed';await button.click();assert.equal(calls,1);
elements.sourceInput.value=input;await button.click();assert.equal(shown.selected_standard.threshold,'293.15');assert.equal(shown.source_input,input);
shown=null;vm.runInContext('showThermalStandard('+JSON.stringify(input)+');',ctx);
const nextCard=elements.candidateList.children.at(-1),nextThreshold=nextCard.children[1].children[0],nextButton=nextCard.children[4];nextThreshold.value='20';
let release;ctx.sentenceTemplate=()=>new Promise(resolve=>{release=resolve});
const pending=nextButton.click();nextThreshold.value='30';release(template);await pending;assert.equal(shown,null);
console.log(`Thermal standards: ${results.length} hot/cold/negation/runtime/question/modal/deictic cases preserve the chosen threshold in meaning and MIDI. Missing sense/standard is unresolved; equivalent scales match; changed standards change sound. UI requires a supplied threshold and rejects stale input.`);
