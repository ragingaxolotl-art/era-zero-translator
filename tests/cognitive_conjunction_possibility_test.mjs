import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeCognitiveConjunction,cognitiveConjunctionPlan} from '../pages/cognitive_conjunction.mjs';
import {midiFromCognitiveConjunction} from '../pages/cognitive_conjunction_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records;
const prefixes=['It is possible that ','It is not possible that ','It is possible that it is not true that '],parity=[],meanings=[];
for(const runtime of [0,1,2])for(const [i,prefix] of prefixes.entries()){
 const d=await composeCognitiveConjunction(`${prefix}Orin is curious about the map [${runtime}] and Eli understands Nora’s reasons [${2-runtime}].`,{allowDraft:true});
 const midi=await midiFromCognitiveConjunction(d,authority,records,{allowDraft:true}),r=await decodeSupportedMeaningWithDrafts(midi,authority.atoms,records,{allowDraft:true});
 assert.deepEqual(r.scopes,d.scopes);assert.equal(r.members[0].runtime_state,runtime);assert.equal(r.members[1].runtime_state,2-runtime);assert.deepEqual(r.members[0].scopes,[]);assert.deepEqual(r.members[1].scopes,[]);
 parity.push({document:d,midi:Buffer.from(midi).toString('base64')});if(runtime===1)meanings[i]=r;
}
assert.equal(new Set(parity.map(p=>p.midi)).size,9);
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_cognitive_conjunction','-rbase64','-e',"p=JSON.parse(STDIN.read);puts JSON.generate(p['cases'].map{|c|Base64.strict_encode64(EraZeroCognitiveConjunction.midi(c['document'],p['records'],allow_draft:true))})"],{input:JSON.stringify({cases:parity,records}),encoding:'utf8'}));assert.deepEqual(ruby,parity.map(p=>p.midi));
// Independent finite-world model: scope determines the quantification over
// alternatives. Runtime is deliberately absent from this truth evaluation.
function evaluate(meaning,worlds){const walk=(index,world)=>index===meaning.scopes.length?world.every(Boolean):meaning.scopes[index].operator==='negation'?!walk(index+1,world):worlds.some(candidate=>walk(index+1,candidate));return walk(0,worlds[0]);}
const separate=[[true,false],[false,true]],mixed=[[true,true],[true,false]],bothOnly=[[true,true]];
assert.equal(separate.some(w=>w[0])&&separate.some(w=>w[1]),true);assert.equal(evaluate(meanings[0],separate),false);
for(const worlds of [separate,mixed,bothOnly]){
 assert.equal(evaluate(meanings[0],worlds),worlds.some(w=>w[0]&&w[1]));assert.equal(evaluate(meanings[1],worlds),!worlds.some(w=>w[0]&&w[1]));assert.equal(evaluate(meanings[2],worlds),worlds.some(w=>!(w[0]&&w[1])));
}
assert.notEqual(evaluate(meanings[1],mixed),evaluate(meanings[2],mixed));
const equivalent=await composeCognitiveConjunction('It is not true that it is possible that Orin is curious about the map [1] and Eli understands Nora’s reasons [1].',{allowDraft:true});assert.deepEqual(equivalent,parity[4].document);
assert.equal(cognitiveConjunctionPlan('It is possible that it is possible that Orin is curious about the map and Eli understands Nora.'),null);
console.log('PASS nine possibility/negation scope contrasts with Ruby/MIDI recovery and independent finite-world evidence: joint possibility differs from separate possibilities, and not-possible differs from possible-not.');
