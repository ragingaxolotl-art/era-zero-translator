import assert from 'node:assert/strict';
import fs from 'node:fs';
import {pronounInterpretationPlan,composePronounSentence} from '../pages/pronouns.mjs';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),one=referent=>({referent,number:'singular'});
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority};
let count=0;
for(const state of [0,1,2])for(const [input,named,bindings] of [
 ['They care for them.','Nora cares for Eli.',{ref0:one('Nora'),ref1:one('Eli')}],
 ['They are swimming.','Nora is swimming.',{ref0:one('Nora')}],
 ['Are they swimming?','Is Nora swimming?',{ref0:one('Nora')}],
 ['They were running yesterday.','Nora was running yesterday.',{ref0:one('Nora')}],
 ['Do they care for him?','Does Nora care for Eli?',{ref0:one('Nora'),ref1:'Eli'}],
 ['They do not care for Eli.','Nora does not care for Eli.',{ref0:one('Nora')}],
 ['They are swimming.','I am swimming.',{ref0:one('I')}],
 ['They are swimming.','you are swimming.',{ref0:one('you')}]
]){
 const text=input+` [${state}]`;assert(pronounInterpretationPlan(text),text);
 const r=await composePronounSentence(text,load,bindings),explicit=named+` [${state}]`,d=await composeNamedSentence(explicit,await load(parseNamedSentence(explicit).predicate));
 assert.deepEqual(r.semantic_ir,d.semantic_ir);assert.deepEqual(midiFromFormal(r.formal),midiFromFormal(d.formal));assert.equal(r.resolved_input,explicit);count++;
}
for(const ref0 of ['Nora',one('they'),{referent:'Nora',number:'plural'}])await assert.rejects(()=>composePronounSentence('They are swimming.',load,{ref0}),e=>e.code==='pronoun_referents_required');
assert.equal(pronounInterpretationPlan('"They" is swimming.'),null);
console.log(`PASS ${count} ordinary singular-they meaning/music cases with neutral roles, present/past/inverted agreement and explicit one/group resolution.`);
