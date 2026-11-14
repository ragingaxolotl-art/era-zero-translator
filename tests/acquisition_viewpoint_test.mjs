import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeCustodyAcquisitionMidi} from '../pages/custody_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set(),documents=[];
for(const state of [0,1,2])for(const viewpoint of ['bounded','ongoing','habitual'])for(const negative of [false,true]){
 const input=`It is possible that Nora ${negative?'does not acquire':'acquires'} physical custody of this tea. [${state}]`;
 await assert.rejects(composeNamedSentence(input,{authority}),e=>e.code==='acquisition_viewpoint_required');
 const d=await composeNamedSentence(input,{authority},{viewpoint}),midi=midiFromFormal(d.formal),r=decodeCustodyAcquisitionMidi(midi,authority.atoms);
 documents.push(d);assert.equal(r.runtime_state,state);assert.deepEqual(r.scopes,[{operator:'modality',mode:'possible'},...(negative?[{operator:'negation'}]:[]),{operator:'aspect',aspect:viewpoint}]);assert.equal(r.participants.object.reference_mode,'proximal_nominal');assert.equal(r.meaning.ownership_asserted,false);assert(!d.semantic_ir.edges.some(e=>e.type==='time_relation'));sounds.add(Buffer.from(midi).toString('base64'));
}
assert.equal(sounds.size,18);
for(const input of ['I acquires physical custody of the tea.','Nora acquire physical custody of the tea.'])assert.equal(parseNamedSentence(input),null);
console.log('PASS 18 present acquisition modal/viewpoint/runtime contrasts without invented past time; viewpoint choice and agreement enforced.');

const rendered=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|Base64.strict_encode64(EraZeroPresentation.midi(EraZeroRenderer.render(ir)))})"],{input:JSON.stringify(documents.map(d=>d.semantic_ir)),encoding:'utf8',maxBuffer:16000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(midiFromFormal(d.formal)).toString('base64'),rendered[i]);
console.log('PASS independent Ruby performances match all 18 scoped acquisition meanings.');
