import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeSwimmingMidi} from '../pages/swimming_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority},results=[];
for(const state of [0,1,2])for(const viewpoint of ['bounded','ongoing','habitual'])for(const sentence of ['Eli swims.','Eli swims across the river.','I swim across the lake.','Eli does not swim across the river.','Does Eli swim across the river?','It is possible that Eli swims.']){
 const input=sentence+` [${state}]`;assert(parseNamedSentence(input)?.requiredViewpoint,input);
 await assert.rejects(()=>composeNamedSentence(input,template),e=>e.code==='swimming_viewpoint_required');
 const r=await composeNamedSentence(input,template,{viewpoint}),d=decodeSwimmingMidi(midiFromFormal(r.formal),authority.atoms);results.push(r);
 assert.equal(d.runtime_state,state);assert.equal(r.selected_viewpoint,viewpoint);
 assert(d.scopes.some(s=>s.operator==='aspect'&&s.aspect===viewpoint));
 assert.equal(d.scopes.some(s=>s.operator==='negation'),sentence.includes('not'));
 assert.equal(d.scopes.some(s=>s.operator==='modality'),sentence.includes('possible'));
 assert.equal(d.speech_act,sentence.startsWith('Does')?'question':'assertion');
 assert.equal(d.meaning.arrival_asserted,false);
 if(sentence.includes('across')){assert.equal(d.path.completion_asserted,false);assert.equal(d.path.region.reference_mode,'definite_nominal');}
 if(sentence.startsWith('I '))assert.deepEqual(d.actor,{kind:'deictic',role:'speaker'});
 else assert.deepEqual(d.actor.phonemes,['EH','L','IH']);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:40_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showCarryingViewpoint('),app.indexOf('function showAdjectiveStandard('));
const element=()=>({value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const input='Eli swims across the river.';elements.sourceInput.value=input;
const state={mode:'english',wordSelections:new Map()};let shown;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:async()=>template,composeNamedSentence,showResolution:async r=>shown=r,toast(){}});
vm.runInContext(handler,ctx);ctx.showCarryingViewpoint(input);
const card=elements.candidateList.children.at(-1),select=card.children[1].children[0],button=card.children.at(-1);
assert.equal(card.children[1].textContent,'Swimming meaning');assert.equal(select.value,'');await button.click();assert.equal(shown,undefined);
select.value='habitual';await button.click();assert.equal(shown.selected_viewpoint,'habitual');
for(const change of ['viewpoint','input','detached']){
 ctx.showCarryingViewpoint(input);const c=elements.candidateList.children.at(-1),s=c.children[1].children[0];s.value='ongoing';let finish;ctx.sentenceTemplate=()=>new Promise(resolve=>finish=resolve);const previous=shown,pending=c.children.at(-1).click();
 if(change==='viewpoint')s.value='bounded';if(change==='input')elements.sourceInput.value='Changed';if(change==='detached')c.isConnected=false;
 finish(template);await pending;assert.equal(shown,previous);elements.sourceInput.value=input;
}
console.log(`PASS ${results.length} swimming viewpoint/state/scope musical contrasts and Ruby parity; actual UI choice and stale-result guards.`);
