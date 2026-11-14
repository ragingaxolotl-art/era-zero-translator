import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,composeSentenceSequence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeContextualStandardMidi} from '../pages/contextual_standard_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=async id=>JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const forms=[['hot','thermodynamic_temperature','thermal_standard','greater_than'],['cold','thermodynamic_temperature','thermal_standard','less_than'],['heavy','mass','mass_standard','greater_than'],['light','mass','mass_standard','less_than'],['bright','luminance','luminance_standard','greater_than'],['dim','luminance','luminance_standard','less_than'],['rough','surface_texture','texture_standard','greater_than'],['smooth','surface_texture','texture_standard','less_than']],results=[],sounds=new Set();
for(const [adjective,dimension,interpretation,relation] of forms)for(const state of [0,1,2])for(const neg of [false,true]){
 const r=await composeNamedSentence(`The lamp is ${neg?'not ':''}${adjective} [${state}].`,await load('MAT:010'),{interpretation,standard:{kind:'contextual',dimension}});results.push(r);
 assert(!r.semantic_ir.nodes.some(n=>n.kind==='measurement'));
 const bytes=midiFromFormal(r.formal),d=decodeContextualStandardMidi(bytes,authority.atoms);sounds.add(Buffer.from(bytes).toString('base64'));
 assert.equal(d.dimension,dimension);assert.equal(d.standard.norm,adjective);assert.equal(d.relation,relation);assert.equal(d.runtime_state,state);assert.deepEqual(d.scopes,neg?[{operator:'negation'}]:[]);
}
assert.equal(sounds.size,48);
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:12_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
for(const text of ['Is the lamp hot?','It is possible that the lamp is hot.','The lamp is hot today.']){
 const r=await composeNamedSentence(text,await load('MAT:010'),{interpretation:'thermal_standard',standard:{kind:'contextual',dimension:'thermodynamic_temperature'}});
 const d=decodeContextualStandardMidi(midiFromFormal(r.formal),authority.atoms);
 assert.equal(d.standard.norm,'hot');
 if(text.startsWith('Is'))assert.equal(d.speech_act,'question');
 if(text.includes('possible'))assert.equal(d.scopes[0].operator,'modality');
 if(text.includes('today'))assert.deepEqual(d.scopes,[{operator:'time',relation:'current_day'}]);
}

await assert.rejects(composeNamedSentence('The stone is rough.',await load('MAT:010')),e=>e.code==='texture_standard_required');
await assert.rejects(composeNamedSentence('The stone is rough.',await load('MAT:010'),{interpretation:'texture_standard',standard:{dimension:'surface_texture',threshold:'1',scale:'millimeter'}}));
console.log('PASS 48 selected contextual adjective contrasts including physical rough/smooth; Ruby/browser MIDI parity and independent inverse.');
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showAdjectiveStandard('),app.indexOf('function showFoundationPreview('));
const element=()=>({children:[],value:'',classList:{add(){},remove(){}},append(...n){this.children.push(...n)},setAttribute(){},addEventListener(t,f){this[t]=f},scrollIntoView(){}}),elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
elements.sourceInput.value='The stone is rough.';let shown=null;const ctx=vm.createContext({state:{mode:'general',wordSelections:new Map()},$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:load,composeNamedSentence,showResolution:async r=>shown=r,toast:()=>{}});
vm.runInContext(handler+";showAdjectiveStandard('The stone is rough.');",ctx);const button=elements.candidateList.children[0].children[2];await button.click();assert.equal(shown.selected_standard.kind,'contextual');

assert.equal(shown.selected_standard.dimension,'surface_texture');assert.equal(elements.candidateList.children[0].children.length,3);

const sequence=await composeSentenceSequence('The stone is rough, then the stone is smooth.',load,[{interpretation:'texture_standard',standard:{kind:'contextual',dimension:'surface_texture'}},{interpretation:'texture_standard',standard:{kind:'contextual',dimension:'surface_texture'}}]);
assert.deepEqual(sequence.semantic_ir.nodes.filter(n=>n.standard==='contextual').map(n=>n.norm),['rough','smooth']);
assert(midiFromFormal(sequence.formal).length>0);
