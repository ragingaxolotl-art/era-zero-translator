import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,composeSentenceSequence} from '../pages/sentences.mjs';
import {midiFromFormal,soundPlanFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {recognitionForTarget} from '../pages/recognition.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeNominalMassRestrictions} from '../pages/reference_property_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const standard={dimension:'mass',threshold:'20',scale:'kilogram'},results=[];
for(const state of [0,1,2])for(const viewpoint of ['bounded','ongoing','habitual'])for(const sentence of [
 'Pip carries the box toward Ada.','Pip does not carry the box.','Does Pip carry the box?',
 'I carry the heavy box.','The light robot carries the box toward the gate.',
 'It is possible that Pip carries the box.','Pip carries the box today.'
]){
 const input=sentence+` [${state}]`,parsed=parseNamedSentence(input);assert(parsed?.requiredViewpoint,input);assert.equal(parsed.aspect,undefined);
 const options={viewpoint,...(parsed.requiredInterpretation?{interpretation:'mass_standard',standard}:{})};
 await assert.rejects(()=>composeNamedSentence(input,template),e=>e.code==='carrying_viewpoint_required');
 const r=await composeNamedSentence(input,template,options);results.push(r);assert.equal(r.selected_viewpoint,viewpoint);
 assert.equal(r.semantic_ir.nodes.find(n=>n.operator==='aspect').aspect,viewpoint);
 const observed=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
 assert(observed.tokens.some(t=>t.marker===`aspect_${viewpoint}_open`));assert.equal(observed.tokens.find(t=>t.root_id==='MOV:121').runtime_state,state);
 assert(!observed.tokens.some(t=>t.root_id==='MOV:110'||t.root_id==='MOV:122'||t.marker==='time_after_speech_open'));
 if(parsed.requiredInterpretation){const restrictions=decodeNominalMassRestrictions(midiFromFormal(r.formal),authority.atoms).restrictions;assert(restrictions.length);assert(restrictions.every(p=>p.magnitude==='20'));}
}
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:28_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
for(const [viewpoint,explicit] of [['ongoing','Pip is carrying the heavy box toward Ada.'],['habitual','Pip habitually carries the heavy box toward Ada.']]){
 const chosen=await composeNamedSentence('Pip carries the heavy box toward Ada.',template,{viewpoint,interpretation:'mass_standard',standard});
 const direct=await composeNamedSentence(explicit,template,{interpretation:'mass_standard',standard});assert.deepEqual(chosen.formal,direct.formal);
}
await assert.rejects(()=>composeNamedSentence('Pip carries the heavy box.',template,{viewpoint:'habitual'}),e=>e.code==='mass_standard_required');
await assert.rejects(()=>composeNamedSentence('Pip carries the heavy box.',template,{interpretation:'mass_standard',standard}),e=>e.code==='carrying_viewpoint_required');
for(const viewpoint of ['future','inactive','2',null])await assert.rejects(()=>composeNamedSentence('Pip carries the box.',template,{viewpoint}),e=>e.code==='carrying_viewpoint_required');
await assert.rejects(()=>composeNamedSentence('Pip carried the box.',template,{viewpoint:'habitual'}),/does not require/);
await assert.rejects(()=>composeSentenceSequence('Pip carries the box, then Ada is conscious.',async()=>template),e=>e.code==='carrying_viewpoint_required');
assert.equal(parseNamedSentence('Pip carries the heavy box to Ada.'),null);
// Exercise the actual UI: two independent choices must be complete, with no
// preselected viewpoint and no stale asynchronous result or error publication.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8');
assert(app.includes('if(parseNamedSentence(input)?.requiredViewpoint){showCarryingViewpoint(input);return}'));
const handler=app.slice(app.indexOf('function showCarryingViewpoint('),app.indexOf('function showAdjectiveStandard('));
const element=tag=>({tag,value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element(id)]));
const input='Pip carries the heavy box toward Ada.';elements.sourceInput.value=input;
const state={mode:'english',wordSelections:new Map(),resolution:{old:true}};let shown=null,calls=0;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:async()=>template,composeNamedSentence:async(...args)=>{calls++;return composeNamedSentence(...args)},showResolution:async r=>shown=r,toast(){}});
const show=()=>{vm.runInContext(handler+';showCarryingViewpoint('+JSON.stringify(input)+');',ctx);const card=elements.candidateList.children.at(-1);return {card,view:card.children[1].children[0],threshold:card.children[3].children[0],status:card.children[5],button:card.children[6]};};
let ui=show();assert.equal(state.resolution,null);assert.equal(calls,0);assert.equal(ui.view.value,'');assert.equal(ui.threshold.value,'');
await ui.button.click();assert.equal(shown,null);assert(ui.status.textContent.includes('Choose'));
ui.view.value='habitual';await ui.button.click();assert.equal(shown,null);assert(ui.status.textContent.includes('threshold'));
ui.threshold.value='20';await ui.button.click();assert.equal(shown.selected_viewpoint,'habitual');assert.equal(shown.selected_standard.threshold,'20');
for(const change of ['viewpoint','standard','input','detached']){
 ui=show();ui.view.value='ongoing';ui.threshold.value='20';const newer={newer:change};shown=newer;state.resolution=newer;
 let finish;ctx.sentenceTemplate=()=>new Promise(resolve=>finish=resolve);const pending=ui.button.click();
 if(change==='viewpoint')ui.view.value='bounded';if(change==='standard')ui.threshold.value='30';if(change==='input')elements.sourceInput.value='Changed';if(change==='detached')ui.card.isConnected=false;
 finish(template);await pending;assert.equal(shown,newer);assert.equal(state.resolution,newer);elements.sourceInput.value=input;
}
ui=show();ui.view.value='habitual';ui.threshold.value='20';let fail;ctx.sentenceTemplate=()=>new Promise((_,reject)=>fail=reject);const pending=ui.button.click();ui.card.isConnected=false;const newer={newer:'failure'};state.resolution=newer;fail(new Error('late failure'));await pending;assert.equal(state.resolution,newer);assert.equal(ui.status.textContent,'');
// The real browser revealed that convention/property markers reached a lexical
// checksum lookup and aborted showResolution before runtime/contour were shown.
const displayIds=['output','meaningTitle','sourceEcho','sourceInput','controlledText','readingLabel','targetBadge','utteranceId','formalId','roundTrip','prefixText','carrierText','familyNotes','addressNotes','recognitionNotes','runtimeNote','contourNotes','irCode','formalCode','glyphStage'];
const display=Object.fromEntries(displayIds.map(id=>[id,element(id)]));
for(const mode of ['recognition','strict','learning'])for(const code of [0,1,2]){
 const result=results.find(r=>r.source_input===`I carry the heavy box. [${code}]`&&r.selected_viewpoint==='habitual');
 const context=vm.createContext({state:{data:authority},$:id=>display[id],currentSoundMode:()=>mode,soundPlanFromFormal,svgFromFormal,recognitionForTarget:(target,...args)=>{assert(!/^EZGRAM:|^EZLEX:/.test(target));return recognitionForTarget(target,...args)}});
 vm.runInContext(app.split('\n').find(line=>line.startsWith('async function showResolution('))+';',context);
 await context.showResolution(result,{definition:result.semantic_note});
 assert(display.runtimeNote.textContent.includes(`MOV:121 [${code}]`));assert(display.contourNotes.textContent.startsWith('level:'));
 assert.equal(display.readingLabel.textContent,'Lexical gloss');assert.equal(display.controlledText.textContent,result.formal.literal_gloss);
 assert(display.glyphStage.innerHTML.includes('<svg'));assert.equal(JSON.parse(display.irCode.textContent).utterance_id,result.semantic_ir.utterance_id);
}
console.log(`Carrying viewpoint choice: ${results.length} interpretation/runtime/participant/question/modal/property cases match Ruby formal and MIDI; chosen ongoing/habitual readings equal explicit paraphrases. UI requires both viewpoint and applicable mass standard and discards stale results/errors.`);
