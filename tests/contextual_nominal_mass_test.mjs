import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeDestinationCarryingMidi} from '../pages/carrying_decoder.mjs';
import {decodeNominalMassRestrictions} from '../pages/reference_property_decoder.mjs';
import {validReferenceProperty} from '../pages/reference_properties.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const results=[],sounds=new Set();
for(const adjective of ['heavy','light'])for(const state of [0,1,2])for(const negative of [false,true]){
 const input=`Pip is ${negative?'not ':''}carrying the ${adjective} box to Ada [${state}].`;
 assert(parseNamedSentence(input));
 const r=await composeNamedSentence(input,{authority},{destination:'spatial',interpretation:'mass_standard',standard:{kind:'contextual',dimension:'mass'}});
 const ref=r.semantic_ir.nodes.find(n=>n.property_restriction);
 assert.equal(ref.name.normalized_label,'box');assert(validReferenceProperty(ref));
 const bytes=midiFromFormal(r.formal),d=decodeDestinationCarryingMidi(bytes,authority.atoms);
 assert.deepEqual(d.participants.load.property,{dimension:'mass',standard:'contextual',norm:adjective,comparison:adjective==='heavy'?'greater_than':'less_than'});
 assert(decodeNominalMassRestrictions(bytes,authority.atoms).restrictions.every(r=>r.norm===adjective&&r.standard==='contextual'));
 assert.equal(d.runtime_state,state);assert.equal(d.scopes.some(s=>s.operator==='negation'),negative);
 assert.equal(d.participants.carrier.property,undefined);assert.equal(d.participants.destination.property,undefined);
 for(const mutation of [{norm:'hot'},{comparison:adjective==='heavy'?'less_than':'greater_than'},{magnitude:'10'}])assert(!validReferenceProperty({...ref,property_restriction:{...ref.property_restriction,...mutation}}));
 sounds.add(Buffer.from(bytes).toString('base64'));results.push(r);
}
assert.equal(sounds.size,12);
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rjson','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir| f=EraZeroRenderer.render(ir); {formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:12000000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
console.log('PASS 12 contextual noun mass sentence contrasts, independent full MIDI recovery and Ruby parity; no numeric cutoff invented.');

// Exercise the actual adjective-choice handler with a restricted noun.
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8');
const handler=app.slice(app.indexOf('function showAdjectiveStandard('),app.indexOf('function showFoundationPreview('));
const element=()=>({children:[],value:'',classList:{add(){},remove(){}},append(...n){this.children.push(...n)},setAttribute(){},addEventListener(t,f){this[t]=f},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const input='Pip is carrying the heavy box toward Ada.';elements.sourceInput.value=input;let shown;
const ctx=vm.createContext({state:{mode:'general',wordSelections:new Map()},$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:async()=>({authority}),composeNamedSentence,showResolution:async r=>{shown=r},toast(){}});
vm.runInContext(handler+`;showAdjectiveStandard(${JSON.stringify(input)});`,ctx);
const button=elements.candidateList.children[0].children.find(n=>n.textContent?.includes('(no number)'));
assert(button);await button.click();assert.equal(shown.selected_standard.kind,'contextual');
assert.equal(shown.semantic_ir.nodes.find(n=>n.property_restriction).property_restriction.norm,'heavy');
shown=null;elements.sourceInput.value='Changed input';await button.click();assert.equal(shown,null);
console.log('PASS contextual noun standard UI choice and changed-input guard.');
