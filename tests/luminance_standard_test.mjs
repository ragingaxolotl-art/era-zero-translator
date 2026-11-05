import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeMaterialMeasurementMidi} from '../pages/material_measurement_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=async id=>JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const standard={dimension:'luminance',threshold:'100.00',scale:'candela_per_square_meter'},results=[];
for(const state of [0,1,2])for(const adjective of ['bright','dim'])for(const negative of [false,true]){
 const input=`The lamp is ${negative?'not ':''}${adjective} [${state}].`,template=await load('MAT:010');
 await assert.rejects(composeNamedSentence(input,template),e=>e.code==='luminance_standard_required');
 const r=await composeNamedSentence(input,template,{interpretation:'luminance_standard',standard});results.push(r);
 const d=decodeMaterialMeasurementMidi(midiFromFormal(r.formal),authority.atoms);
 assert.equal(d.dimension,'luminance');assert.deepEqual(d.measurement,{magnitude:'100',unit:'candela_per_square_meter',relation:adjective==='bright'?'greater_than':'less_than'});assert.equal(d.runtime_state,state);assert.deepEqual(d.scopes,negative?[{operator:'negation'}]:[]);
}
for(const text of ['Is the lamp bright?','It is possible that the lamp is bright.','The lamp is bright today.']){
 const r=await composeNamedSentence(text,await load('MAT:010'),{interpretation:'luminance_standard',standard});results.push(r);
 const d=decodeMaterialMeasurementMidi(midiFromFormal(r.formal),authority.atoms);assert.equal(d.measurement.magnitude,'100');assert.equal(d.dimension,'luminance');
 if(text.startsWith('Is'))assert.equal(d.speech_act,'question');
 if(text.startsWith('It'))assert.deepEqual(d.scopes,[{operator:'modality',mode:'possible'}]);
 if(text.includes('today'))assert.deepEqual(d.scopes,[{operator:'time',relation:'current_day'}]);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:8_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
for(const wrong of [{...standard,threshold:'-1'},{...standard,scale:'lux'},{...standard,dimension:'luminous_intensity'}])await assert.rejects(composeNamedSentence('The lamp is bright.',await load('MAT:010'),{interpretation:'luminance_standard',standard:wrong}));
const brighter=await composeNamedSentence('The lamp is bright.',await load('MAT:010'),{interpretation:'luminance_standard',standard:{...standard,threshold:'101'}});assert.notDeepEqual(midiFromFormal(brighter.formal),midiFromFormal(results[4].formal));
// Exercise the production choice panel, including its missing threshold and stale-input guards.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showAdjectiveStandard('),app.indexOf('function showFoundationPreview('));
const element=()=>({children:[],value:'',classList:{add(){},remove(){}},append(...n){this.children.push(...n)},setAttribute(){},addEventListener(t,f){this[t]=f},scrollIntoView(){}}),elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
elements.sourceInput.value='The lamp is bright.';let shown=null;
const ctx=vm.createContext({state:{mode:'general',wordSelections:new Map()},$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:load,composeNamedSentence,showResolution:async r=>shown=r,toast:()=>{}});
vm.runInContext(handler+";showAdjectiveStandard('The lamp is bright.');",ctx);
const card=elements.candidateList.children[0],threshold=card.children[1].children[0],button=card.children[4];await button.click();assert.equal(shown,null);
threshold.value='100';elements.sourceInput.value='Changed';await button.click();assert.equal(shown,null);
elements.sourceInput.value='The lamp is bright.';await button.click();assert.equal(shown.selected_standard.dimension,'luminance');
console.log('PASS 15 bright/dim state/negation contrasts with explicit standards, MIDI-only meaning recovery and actual UI guards.');
