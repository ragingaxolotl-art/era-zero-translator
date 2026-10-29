import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeDestinationCarryingMidi} from '../pages/carrying_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const standard={dimension:'mass',threshold:'20',scale:'kilogram'},results=[];
for(const state of [0,1,2])for(const text of ['Carry the box to Ada.','Do not carry the box to Ada.','Carry the heavy box to Ada.','Do not carry the light box to the gate.','Carry the box to me.','Carry Ada to the box.']){
 const input=text+` [${state}]`,parsed=parseNamedSentence(input);assert(parsed?.requiredDestination,input);assert.equal(parsed.requiredViewpoint,undefined);assert.equal(parsed.aspect,undefined);
 const options={destination:'spatial',...(parsed.requiredInterpretation?{interpretation:'mass_standard',standard}:{})};
 await assert.rejects(()=>composeNamedSentence(input,template,{...options,destination:undefined}),e=>e.code==='carrying_destination_required');
 const r=await composeNamedSentence(input,template,options);results.push(r);
 const inverse=decodeDestinationCarryingMidi(midiFromFormal(r.formal),authority.atoms);
 assert.equal(inverse.speech_act,'command');assert.equal(inverse.runtime_state,state);assert.equal(inverse.predicate,'completed_destination_carrying');
 assert.deepEqual(inverse.scopes,text.startsWith('Do not')?[{operator:'negation'}]:[]);
 assert.deepEqual(inverse.participants.carrier,{kind:'deictic',role:'addressee'});
 if(text.includes(' to me'))assert.deepEqual(inverse.participants.destination,{kind:'deictic',role:'speaker'});
 if(parsed.requiredInterpretation)assert.deepEqual(inverse.participants.load.property,{dimension:'mass',comparison:parsed.adjective==='heavy'?'greater_than':'less_than',magnitude:'20',unit:'kilogram'});
 assert(!r.semantic_ir.nodes.some(n=>n.operator==='aspect'||n.kind==='time_anchor'));assert(r.semantic_note.includes('not an assertion'));
}
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:30_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
const statement=await composeNamedSentence('You carried the box to Ada.',template,{destination:'spatial'});
assert.notDeepEqual(midiFromFormal(statement.formal),midiFromFormal(results[6].formal));
for(const text of ['Carry you to Ada.','Carry the box to you.','Carry the box to Ada quickly.','Carry exactly two boxes to Ada.','Carry the box to Ada and Ben.'])assert.equal(parseNamedSentence(text),null,text);
await assert.rejects(()=>composeNamedSentence('Carry the box to Ada.',template,{destination:'recipient'}),e=>e.code==='carrying_destination_required');
// The existing combined form must show destination + mass, without inventing a
// present-tense viewpoint question for an imperative.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showCarryingViewpoint('),app.indexOf('function showAdjectiveStandard('));
const element=tag=>({tag,value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element(id)]));
const input='Carry the heavy box to Ada.';elements.sourceInput.value=input;let shown=null;
const state={mode:'english',wordSelections:new Map()},ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:async()=>template,composeNamedSentence,showResolution:async r=>shown=r});
vm.runInContext(handler+';showCarryingViewpoint('+JSON.stringify(input)+');',ctx);
const card=elements.candidateList.children.at(-1),field=name=>card.children.find(c=>c.textContent===name)?.children[0],button=card.children.at(-1),status=card.children.at(-2);
assert.equal(field('Carrying meaning'),undefined);assert.equal(field('Meaning of to').value,'');assert.equal(field('Mass threshold').value,'');
await button.click();assert.equal(shown,null);assert(status.textContent.includes('spatial'));
field('Meaning of to').value='spatial';await button.click();assert.equal(shown,null);assert(status.textContent.includes('threshold'));
field('Mass threshold').value='20';await button.click();assert.equal(shown.semantic_ir.speech_act,'command');assert.equal(shown.selected_viewpoint,undefined);
console.log(`Destination commands: ${results.length} runtime/negation/property/participant variants match Ruby formal and MIDI; MIDI-only inverse recovers imperative contour and addressee without tense/aspect or actual-arrival inference. Form requires destination and property choices only.`);
