import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeDrinkingSentence} from '../pages/drinking_sentences.mjs';
import {midiFromDrinking,decodeDrinkingMidi} from '../pages/drinking_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-drinking-')),cases=[];
for(const [phrase,materialReading,viewpoint,state,bindings] of [['Was Nora not drinking this tea? [2]','contextual_portion','ongoing',2],['Eli drank the water. [0]','contextual_portion','bounded',0],['I habitually drink tea. [1]','kind','habitual',1],["They’re not drinking it. [2]",'contextual_portion','ongoing',2,{ref0:{referent:'Nora',number:'singular'},ref1:'this tea'}]]){
 const d=await composeDrinkingSentence(phrase,{allowDraft:true,interpretation:'literal_drinking',materialReading,bindings}),bytes=await midiFromDrinking(d,authority,{allowDraft:true}),expected=decodeDrinkingMidi(bytes,authority.atoms,{allowDraft:true});
 const wav=path.join(directory,`drinking-${cases.length}.wav`);
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
 // Only waveform path and draft permission enter the decoder process.
 const result=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:3000000}));
 assert.deepEqual(result.meaning,expected);assert.equal(result.meaning.viewpoint,viewpoint);assert.equal(result.meaning.runtime_state,state);assert.equal(result.meaning.material.reading,materialReading);assert.equal(result.meaning.whole_amount_consumption,'not_asserted');assert.equal(result.meaning.thirst_commitment,'not_entailed');
 if(cases.length===0){assert.equal(result.meaning.speech_act,'question');assert.deepEqual(result.meaning.scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'}]);assert.equal(result.meaning.material.reference.reference_mode,'proximal_nominal');}
 if(bindings){const named=await composeDrinkingSentence('Nora is not drinking this tea. [2]',{allowDraft:true,interpretation:'literal_drinking',materialReading});assert.deepEqual(d,named);assert.deepEqual(result.meaning.scopes,[{operator:'negation'}]);}
 if(cases.length===2)assert.deepEqual(result.meaning.drinker,{kind:'deictic',role:'speaker'});
 cases.push({phrase,materialReading,wav,meaning:result.meaning,checksum:result.checksum});
}
fs.writeFileSync(new URL('../reports/drinking_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Four authored clean synthetic WAVs, including explicitly bound contracted singular they and a separate object pronoun. Decoder receives no original text, semantic document, selected reading or expected notes. No physical recordings or channel perturbations.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS four blind drinking WAV recoveries preserve viewpoint, material reading, participants, past/negated question and runtime.');
