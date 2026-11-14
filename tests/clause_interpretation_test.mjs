import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {clauseInterpretationPlan,composeSentenceDisjunction,composeSentenceConditional,composeSentenceSequence,composeSentenceConjunction} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeNominalMassRestrictions} from '../pages/reference_property_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const load=async id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority};
const standard=n=>({dimension:'mass',threshold:String(n),scale:'kilogram'});
const choices=[{destination:'spatial',viewpoint:'ongoing',interpretation:'mass_standard',standard:standard(10)},{destination:'spatial',viewpoint:'habitual',interpretation:'mass_standard',standard:standard(30)}];
for(const state of [0,1,2]){
 const left=`Pip carries the heavy box to Ada [${state}]`,right=`Ben carries the light shelf to the gate [${(state+1)%3}]`;
 for(const [input,compose] of [[`${left}, then ${right}.`,composeSentenceSequence],[`${left} and ${right}.`,composeSentenceConjunction],[`If ${left}, then ${right}.`,composeSentenceConditional]]){
  const r=await compose(input,load,choices);results.push(r);assert.deepEqual(r.selected_clauses.map(c=>c.options),choices);
  const ir=r.semantic_ir;assert.equal(ir.nodes.find(n=>n.node_id==='s000_p').target_id,'CMP:763faa4465065477220f6f06');assert.equal(ir.nodes.find(n=>n.node_id==='s001_p').target_id,'CMP:74d98d19808f74d0b8196951');
  assert.equal(ir.nodes.find(n=>n.node_id==='s000_b').property_restriction.magnitude,'10');assert.equal(ir.nodes.find(n=>n.node_id==='s001_b').property_restriction.magnitude,'30');
  const d=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
  assert(d.tokens.some(t=>t.root_id==='MOV:111'&&t.runtime_state===state));assert(d.tokens.some(t=>t.root_id==='MOV:110'&&t.runtime_state===(state+1)%3));
  const restrictions=decodeNominalMassRestrictions(midiFromFormal(r.formal),authority.atoms).restrictions;assert.deepEqual([...new Set(restrictions.map(x=>x.magnitude))],['10','30']);
  assert(r.semantic_note.includes('Clause 1:'));assert(r.semantic_note.includes('Clause 2:'));
 }
 const conditional=`If the box is heavy [${state}], carry it to Ada [${(state+1)%3}].`;
 const r=await composeSentenceConditional(conditional,load,[{interpretation:'mass_standard',standard:standard(12)},{destination:'spatial'}]);results.push(r);
 assert.equal(r.semantic_ir.speech_act,'command');assert.equal(r.semantic_ir.nodes.find(n=>n.node_id==='s000_a').referent_id,r.semantic_ir.nodes.find(n=>n.node_id==='s001_b').referent_id);
 const d=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);assert.equal(d.speech_act,'command');assert(d.tokens.some(t=>t.marker==='conditional_open_open'));
 const future=await composeSentenceSequence(`The pump is hot [${state}], then Ada will be carrying the box tomorrow [${(state+1)%3}].`,load,[{interpretation:'thermal_standard',standard:{dimension:'thermodynamic_temperature',threshold:'30',scale:'celsius'}},{interpretation:'future_assertion'}]);results.push(future);
 assert.equal(future.semantic_ir.nodes.find(n=>n.node_id==='s000_measure').magnitude,'303.15');assert.equal(future.semantic_ir.nodes.find(n=>n.node_id.startsWith('s001_')&&n.kind==='time_anchor'&&n.day_offset!==undefined).day_offset,'1');
}
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:50_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
const input='Pip carries the heavy box to Ada, then Ben carries the light shelf to the gate.';
for(const invalid of [[],[choices[0]],{},[choices[0],choices[1],{}],[choices[0],null],[choices[0],{unexpected:true}]])await assert.rejects(()=>composeSentenceSequence(input,load,invalid),/one interpretation-options object per clause/);
await assert.rejects(()=>composeSentenceSequence(input,load,[choices[0],{}]),e=>e.clause_index===1&&e.code==='carrying_viewpoint_required');
await assert.rejects(()=>composeSentenceSequence(input,load,[choices[0],{...choices[1],destination:'recipient'}]),e=>e.clause_index===1&&e.code==='carrying_destination_required');
// A shared rejected template must not have its error mutated by both clauses.
const sharedError=new Error('shared template failure');sharedError.code='template_failed';
await assert.rejects(()=>composeSentenceSequence(input,async()=>{throw sharedError},choices),e=>e!==sharedError&&e.code==='template_failed'&&e.clause_index===0&&e.message==='Clause 1: shared template failure');
assert.equal(sharedError.message,'shared template failure');assert.equal(sharedError.clause_index,undefined);
// Snapshot caller-owned options before waiting for template loading.
let release;const deferred=new Promise(resolve=>release=resolve),mutable=structuredClone(choices);
const pending=composeSentenceSequence(input,async id=>{await deferred;return load(id)},mutable);mutable[0].standard.threshold='999';release();assert.equal((await pending).selected_clauses[0].options.standard.threshold,'10');
// Real UI handler: separate clause fields and no stale completion/error publish.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showClauseInterpretations('),app.indexOf('function showCarryingViewpoint('));
const element=tag=>({tag,value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element(id)]));elements.sourceInput.value=input;
const state={mode:'english',wordSelections:new Map()};let shown=null;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},composeSentenceConditional,composeSentenceSequence,composeSentenceConjunction,sentenceTemplate:load,showResolution:async r=>shown=r});
const plan=clauseInterpretationPlan(input),show=()=>{ctx.plan=plan;vm.runInContext(handler+';showClauseInterpretations('+JSON.stringify(input)+',plan);',ctx);const card=elements.candidateList.children.at(-1);return {card,fields:card.children.slice(0,2).map(section=>Object.fromEntries(section.children.filter(c=>c.tag==='label').map(c=>[c.textContent,c.children[0]]))),button:card.children.at(-1),status:card.children.at(-2)};};
const fill=ui=>ui.fields.forEach((fields,i)=>{fields[`Clause ${i+1} carrying meaning`].value=i?'habitual':'ongoing';fields[`Clause ${i+1} meaning of to`].value='spatial';fields[`Clause ${i+1} mass threshold`].value=i?'30':'10';});
let ui=show();assert.equal(ui.fields[0]['Clause 1 carrying meaning'].value,'');assert.equal(ui.fields[1]['Clause 2 mass threshold'].value,'');await ui.button.click();assert.equal(shown,null);
fill(ui);await ui.button.click();assert.equal(shown.selected_clauses[1].options.standard.threshold,'30');
for(const change of ['choice','input','detached']){
 ui=show();fill(ui);
 // Use one shared gate because both clauses load concurrently.
 let gateRelease;const gate=new Promise(resolve=>gateRelease=resolve);ctx.sentenceTemplate=async id=>{await gate;return load(id)};
 const pending=ui.button.click(),newer={newer:change};shown=newer;state.resolution=newer;
 if(change==='choice')ui.fields[1]['Clause 2 mass threshold'].value='40';if(change==='input')elements.sourceInput.value='Changed';if(change==='detached')ui.card.isConnected=false;
 gateRelease();await pending;assert.equal(shown,newer);assert.equal(state.resolution,newer);elements.sourceInput.value=input;
}
ui=show();fill(ui);let fail;const failure=new Promise((_,reject)=>fail=reject);ctx.sentenceTemplate=()=>failure;const bad=ui.button.click();ui.card.isConnected=false;fail(new Error('late failure'));await bad;assert.equal(ui.status.textContent,'');
console.log(`Clause interpretations: ${results.length} sequence/conjunction/conditional/runtime cases preserve per-clause viewpoints, destinations, mass/temperature standards and future readings with Ruby/browser formal/MIDI parity. Complete choices, local it, caller snapshots and stale UI results/errors are checked.`);
// Novel combinations: every clause retains its own selected physical standard.
const contextualChoices=[{interpretation:'luminance_standard',standard:{kind:'contextual',dimension:'luminance'}},{interpretation:'mass_standard',standard:{kind:'contextual',dimension:'mass'}}];
for(const state of [0,1,2])for(const [text,compose] of [
 [`The lamp is bright [${state}] and the box is heavy [${(state+1)%3}].`,composeSentenceConjunction],
 [`The lamp is bright [${state}], then the box is heavy [${(state+1)%3}].`,composeSentenceSequence],
 [`If the lamp is bright [${state}], then the box is heavy [${(state+1)%3}].`,composeSentenceConditional]]){
 const r=await compose(text,load,contextualChoices),decoded=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
 assert.deepEqual(decoded.tokens.filter(t=>/^contextual_.*_open$/.test(t.marker||'')).map(t=>t.marker),['contextual_bright_open','contextual_heavy_open']);
 assert.deepEqual(r.semantic_ir.nodes.filter(n=>n.kind==='lexical_occurrence').map(n=>n.runtime_state.code),[state,(state+1)%3]);
 assert(!r.semantic_ir.nodes.some(n=>n.kind==='measurement'));
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(r.semantic_ir),encoding:'utf8'}));
 assert.deepEqual(r.formal,ruby.formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby.midi);
}
const combination='The lamp is bright and the box is heavy.';
elements.sourceInput.value=combination;ctx.sentenceTemplate=load;ctx.plan=clauseInterpretationPlan(combination);shown=null;
vm.runInContext(handler+';showClauseInterpretations('+JSON.stringify(combination)+',plan);',ctx);
const combinedCard=elements.candidateList.children.at(-1),sections=combinedCard.children.slice(0,2);
for(const [i,section] of sections.entries()){
 const fields=Object.fromEntries(section.children.filter(c=>c.tag==='label').map(c=>[c.textContent,c.children[0]]));
 fields[`Clause ${i+1} standard type`].value='contextual';fields[`Clause ${i+1} standard type`].change();
 assert.equal(fields[`Clause ${i+1} ${i?'mass':'luminance'} threshold`].disabled,true);
}
await combinedCard.children.at(-1).click();assert.ok(shown);assert.equal(shown.selected_clauses[0].options.standard.dimension,'luminance');assert.equal(shown.selected_clauses[1].options.standard.kind,'contextual');
console.log('PASS 9 contextual multi-clause runtime combinations, Ruby/MIDI parity and actual per-clause no-number UI.');

for(const disjunction of ['any_of','exactly_one']){
 const r=await composeSentenceDisjunction('The lamp is dim or the box is heavy.',load,[contextualChoices[0],{interpretation:'mass_standard',standard:standard(7)}],{disjunction});
 const decoded=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
 assert(decoded.tokens.some(t=>t.marker==='contextual_dim_open'));
 assert(r.semantic_ir.nodes.some(n=>n.kind==='measurement'&&n.magnitude==='7'));
 assert.equal(r.selected_clauses[0].options.standard.kind,'contextual');
}
// Changing the standard mode while loading must invalidate the pending UI result.
let resumeContext;const contextualGate=new Promise(resolve=>resumeContext=resolve);
ctx.sentenceTemplate=async id=>{await contextualGate;return load(id)};
shown=null;const pendingContext=combinedCard.children.at(-1).click();
const firstMode=sections[0].children.find(c=>c.textContent==='Clause 1 standard type').children[0];firstMode.value='numeric';firstMode.change();
resumeContext();await pendingContext;assert.equal(shown,null);
console.log('PASS mixed numeric/contextual disjunctions and stale standard-mode UI protection.');

// Texture has a contextual physical reading only: no fake numerical or Celsius fields.
const textureInput='The stone is rough and the lamp is bright.';
elements.sourceInput.value=textureInput;ctx.sentenceTemplate=load;ctx.plan=clauseInterpretationPlan(textureInput);shown=null;
vm.runInContext(handler+';showClauseInterpretations('+JSON.stringify(textureInput)+',plan);',ctx);
const textureCard=elements.candidateList.children.at(-1),textureSection=textureCard.children[0],lightSection=textureCard.children[1];
assert.equal(textureSection.children.filter(c=>c.tag==='label').length,1);
assert.equal(textureSection.children.find(c=>c.tag==='label').children[0].value,'contextual');
assert(!textureSection.children.some(c=>/threshold|temperature scale/.test(c.textContent||'')));
const lightMode=lightSection.children.find(c=>c.textContent==='Clause 2 standard type').children[0];lightMode.value='contextual';lightMode.change();
await textureCard.children.at(-1).click();
assert.equal(shown.selected_clauses[0].options.standard.dimension,'surface_texture');
assert.deepEqual(shown.semantic_ir.nodes.filter(n=>n.standard==='contextual').map(n=>n.norm),['rough','bright']);
for(const stale of ['input','detached']){
 let release;const gate=new Promise(r=>release=r);ctx.sentenceTemplate=async id=>{await gate;return load(id)};
 shown=null;textureCard.isConnected=true;elements.sourceInput.value=textureInput;
 const pending=textureCard.children.at(-1).click();
 if(stale==='input')elements.sourceInput.value='The stone is smooth.';else textureCard.isConnected=false;
 release();await pending;assert.equal(shown,null);
}
console.log('PASS mixed texture/luminance UI has no spurious numerical texture controls and rejects stale input/detached results.');
// Independently choose contextual mass restrictions for two modified nouns.
elements.sourceInput.value=input;ctx.sentenceTemplate=load;shown=null;
ui=show();fill(ui);
for(const [i,fields] of ui.fields.entries()){const mode=fields[`Clause ${i+1} standard type`];assert(mode);mode.value='contextual';mode.change();assert(fields[`Clause ${i+1} mass threshold`].disabled);}
await ui.button.click();assert(shown);
assert(shown.selected_clauses.every(c=>c.options.standard.kind==='contextual'));
assert.equal(shown.semantic_ir.nodes.filter(n=>n.property_restriction?.standard==='contextual').length,2);
console.log('PASS per-clause contextual noun restrictions remain independently selected.');
