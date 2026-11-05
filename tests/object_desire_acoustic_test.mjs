import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeObjectDesire} from '../pages/object_desire.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../reviews/foundation_extension_candidates.json',import.meta.url))).records,directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-object-desire-')),cases=[];
const load=id=>!authority.resolution_files[id]?{authority}:({...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority});
const probes=[
 {phrase:'Does Nora not want this tea? [2]',desiredProposition:'Eli did not deliver this tea to Nora. [0]',desiredDelivery:{destination:'custody_delivery'},predicate:'completed_carrying_custody_delivery',outer:2,inner:0,outerScopes:[{operator:'negation'}],innerScopes:[{operator:'time',relation:'before_speech'},{operator:'negation'},{operator:'aspect',aspect:'bounded'}]},
 {phrase:'Nora wants tea. [0]',desiredProposition:'Eli has physical custody of the tea.',predicate:'practical_physical_custody',outer:0,inner:1,outerScopes:[],innerScopes:[]},
 {phrase:'Does Nora not want the tea? [2]',desiredProposition:'Eli does not have physical custody of the tea.',predicate:'practical_physical_custody',outer:2,inner:1,outerScopes:[{operator:'negation'}],innerScopes:[{operator:'negation'}]},
 {phrase:'Does Nora want this tea? [2]',desiredProposition:'Eli is carrying this tea [0].',predicate:'physical_carrying',outer:2,inner:0,outerScopes:[],innerScopes:[{operator:'aspect',aspect:'ongoing'}]},
 {phrase:'Nora does not want the tea. [0]',desiredProposition:'Eli acquired physical custody of the tea [2].',predicate:'completed_physical_custody_acquisition',outer:0,inner:2,outerScopes:[{operator:'negation'}],innerScopes:[{operator:'time',relation:'before_speech'}]}
];
for(const probe of probes){
 const {phrase,desiredProposition}=probe;
 const document=await composeObjectDesire(phrase,authority,records,load,{allowDraft:true,desiredProposition,desiredDelivery:probe.desiredDelivery}),bytes=midiFromFormal(document.formal),expected=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
 const wav=path.join(directory,`desire-${cases.length}.wav`);
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
 // Only the waveform path and draft opt-in enter the independent decoder process.
 const result=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:3000000}));
 assert.deepEqual(result.meaning,expected);
 const content=result.meaning.meaning.arguments.content;assert.equal(content.content_status,'intensional');assert.equal(content.proposition.predicate.name,probe.predicate);assert.equal(content.proposition.meaning.ownership_asserted,false);
 assert.deepEqual(content.proposition.scopes,probe.innerScopes);assert.deepEqual(result.meaning.meaning.scopes,probe.outerScopes);assert.equal(result.meaning.meaning.runtime_state,probe.outer);assert.equal(content.proposition.runtime_state,probe.inner);
 if(probe.predicate==='physical_carrying'){assert.equal(content.proposition.meaning.same_load,true);assert.equal(content.proposition.meaning.arrival_asserted,false);assert.equal(content.proposition.arguments.load.reference.reference_mode,'proximal_nominal');}
 if(probe.predicate==='completed_physical_custody_acquisition'){assert.equal(content.proposition.meaning.custody_immediately_before,false);assert.equal(content.proposition.meaning.custody_at_culmination,true);assert.equal(content.proposition.meaning.persistence_after_culmination_asserted,false);}
 if(probe.desiredDelivery){assert.equal(content.proposition.meaning.arrival_culminates_in_transfer,true);assert.equal(content.proposition.arguments.object.reference.reference_mode,'proximal_nominal');assert.notDeepEqual(content.proposition.arguments.carrier,content.proposition.arguments.recipient);}
 cases.push({phrase,desiredProposition,wav,meaning:result.meaning,checksum:result.checksum});
}
fs.writeFileSync(new URL('../reports/object_desire_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Five authored clean synthetic WAVs. Decoder receives neither original text nor clarification, semantic document or expected notes. No physical recordings or channel perturbations.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS five blind object-desire WAV recoveries preserve custody delivery, custody, carrying and custody acquisition as intensional outcomes, including independent scope/runtime and reference mode.');
