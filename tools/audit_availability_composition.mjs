// Probe reusable modal propositions; none is automatically an availability sense.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeCustodyAcquisitionMidi} from '../pages/custody_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),cases=[];
const possibility={operator:'modality',mode:'possible'},negation={operator:'negation'},past={operator:'time',relation:'before_speech'};
for(const state of [0,1,2])for(const [phrase,scopes] of [
 ['It is possible that Nora acquired physical custody of the tea.',[possibility,past]],
 ['It is not the case that it is possible that Nora acquired physical custody of the tea.',[negation,possibility,past]],
 ['It is possible that Nora did not acquire physical custody of the tea.',[possibility,past,negation]]
]){
 const source=phrase+` [${state}]`,document=await composeNamedSentence(source,{authority}),meaning=decodeCustodyAcquisitionMidi(midiFromFormal(document.formal),authority.atoms);
 assert.equal(meaning.runtime_state,state);assert.deepEqual(meaning.scopes,scopes);assert.equal(meaning.meaning.ownership_asserted,false);
 cases.push({source,meaning});
}
const unresolved=[];
for(const source of ['Nora can acquire physical custody of the tea.','It is possible that Nora acquires physical custody of the tea.','The tea is available to Nora.','The tea is available for Nora to drink.']){
 const parsed=parseNamedSentence(source);let status='unparsed',diagnostic=null;
 if(parsed){try{const d=await composeNamedSentence(source,{authority});decodeCustodyAcquisitionMidi(midiFromFormal(d.formal),authority.atoms);status='acquisition_inverse_available';}catch(error){status='incomplete';diagnostic=error.message;}}
 unresolved.push({source,status,...(diagnostic?{diagnostic}:{})});
}
const report={status:'PASS',scope:'Nine authored existing modal-acquisition compositions, not translations of availability.',completion_proven:false,cases,prospective_probes:unresolved,reusable:['strict modality/negation/time nesting','distinct holder/object references','custody acquisition phase contract','runtime states independent of lexical and scope semantics'],missing:['explicit modal basis or access conditions','prospective opportunity without past-event assertion wording','prospective user and selected activity for bare availability','scheduling intervals and offer/permission senses'],conclusion:'Do not alias availability to generic possibility or past acquisition. Reuse these scope and reference mechanisms in an explicit contextual opportunity model.'};
fs.writeFileSync(new URL('../reports/availability_composition_audit.json',import.meta.url),JSON.stringify(report,null,2)+'\n');console.log('PASS nine modal custody-acquisition probes; possible-not and not-possible remain distinct at every runtime. Availability-specific context remains missing.');
