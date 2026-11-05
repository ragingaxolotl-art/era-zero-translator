import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composePronounSentence,pronounInterpretationPlan} from '../pages/pronouns.mjs';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {composeUnderstandingContent} from '../pages/understanding_content.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority};
const bindings={ref0:{referent:'Nora',number:'singular'}};let count=0;
for(const state of [0,1,2])for(const [source,target] of [
 ["They aren't swimming.",'Nora is not swimming.'],
 ["Aren't they swimming?",'Is Nora not swimming?'],
 ["They don’t care for Eli.",'Nora does not care for Eli.'],
 ["Don't they care for Eli?",'Does Nora not care for Eli?'],
 ["They weren't running yesterday.",'Nora was not running yesterday.'],
 ['Did they care for Eli?','Did Nora care for Eli?'],
 ["Didn't they care for Eli?",'Did Nora not care for Eli?']
]){
 const text=source+` [${state}]`;assert(pronounInterpretationPlan(text),text);
 const a=await composePronounSentence(text,load,bindings),named=target+` [${state}]`,b=await composeNamedSentence(named,await load(parseNamedSentence(named).predicate));
 assert.deepEqual(a.semantic_ir,b.semantic_ir);assert.deepEqual(midiFromFormal(a.formal),midiFromFormal(b.formal));count++;
}
for(const source of ["They don't understand Nora.","Don't they understand Nora?"]){
 const target=source.startsWith('They')?'Eli does not understand Nora.':'Does Eli not understand Nora?';
 assert.deepEqual(await composeUnderstandingContent(source,{allowDraft:true,interpretation:'perspective',bindings:{ref0:{referent:'Eli',number:'singular'}}}),await composeUnderstandingContent(target,{allowDraft:true,interpretation:'perspective'}));
}
console.log(`PASS ${count} neutral contracted/past-inverted meaning and MIDI cases; negation preserved, plus understanding contraction equivalence.`);
const modal=await composePronounSentence('May they enter the archive?',load,bindings,{interpretation:'entry_possible'}),namedModal=await composeNamedSentence('May Nora enter the archive?',{authority},{interpretation:'entry_possible'});assert.deepEqual(modal.formal,namedModal.formal);
const first=await composePronounSentence("They aren't swimming.",load,{ref0:{referent:'I',number:'singular'}}),firstNamed=await composeNamedSentence('I am not swimming.',{authority});assert.deepEqual(first.formal,firstNamed.formal);
console.log('PASS modal inversion retains bare verb and speaker binding retains am-not negation.');

let affirmativeCount=0;
for(const state of [0,1,2])for(const apostrophe of ["'",'’'])for(const [referent,target] of [['Nora','Nora is'],['I','I am'],['you','you are']]){
 const source=`They${apostrophe}re not swimming. [${state}]`,explicit=`${target} not swimming. [${state}]`;
 const plan=pronounInterpretationPlan(source);assert(plan,source);
 assert.equal(source.slice(plan.occurrences[0].start,plan.occurrences[0].end),'They');
 const actual=await composePronounSentence(source,load,{ref0:{referent,number:'singular'}}),expected=await composeNamedSentence(explicit,{authority});
 assert.equal(actual.resolved_input,explicit);assert.deepEqual(actual.semantic_ir,expected.semantic_ir);assert.deepEqual(midiFromFormal(actual.formal),midiFromFormal(expected.formal));affirmativeCount++;
}
assert.equal(pronounInterpretationPlan('"Theyre" is swimming.'),null);
await assert.rejects(composePronounSentence("They're swimming.",load,{ref0:{referent:'Nora',number:'plural'}}),/Group reference/);
assert.equal(pronounInterpretationPlan("They'd swim."),null);
console.log(`PASS ${affirmativeCount} contracted-they cases retain explicit participant, negation and runtime 0/1/2; plural and ambiguous contractions are not guessed.`);
