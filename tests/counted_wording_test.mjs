import assert from 'node:assert/strict';
import fs from 'node:fs';
import {parseNominal,NOMINAL_PATTERN} from '../pages/nominals.mjs';
import {composeQuantifiedPropertySentence as compose,parseQuantifiedPropertySentence as parse} from '../pages/quantified_sentences.mjs';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeQuantifiedPropertyMidi} from '../pages/quantified_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=id=>JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'];
let cases=0;
for(const runtime of [0,1,2])for(const [short,long,inner,outer] of [
 ["Exactly three lamps aren't physically energized.",'Exactly three lamps are not physically energized.',true,false],
 ["Aren’t exactly three children conscious?",'Are exactly three children not conscious?',true,false],
 ["It isn't the case that at least two radios are damaged.",'It is not the case that at least two radios are damaged.',false,true],
 ["It isn’t the case that exactly three lamps aren’t physically energized.",'It is not the case that exactly three lamps are not physically energized.',true,true],
 ["Exactly one lamp isn't physically energized.",'Exactly one lamps are not physically energized.',true,false],
 ["Isn't at most one child conscious?",'Are at most one children not conscious?',true,false]
]){
 const source=short+` [${runtime}]`,a=await compose(source,load,{allowDraft:true}),b=await compose(long+` [${runtime}]`,load,{allowDraft:true});
 assert.deepEqual(a.formal,b.formal,source);assert.deepEqual(midiFromFormal(a.formal),midiFromFormal(b.formal));assert.equal(a.source_input,source);
 const decoded=decodeQuantifiedPropertyMidi(midiFromFormal(a.formal),authority.atoms,{allowDraft:true});
 assert.equal(decoded.predicate_negated,inner);assert.equal(decoded.proposition_negated,outer);assert.equal(decoded.predicate.runtime_state,runtime);cases++;
}
for(const [single,plural] of [['Exactly one lamp','Exactly one lamps'],['At least 1 child','At least 1 children'],['At most 001 person','At most 001 people']]){
 assert(new RegExp(`^${NOMINAL_PATTERN}$`).test(single));assert.deepEqual(parseNominal(single),parseNominal(plural));
}
for(const input of ['Exactly two lamp','At least zero child','At most 10 person']){assert.equal(parseNominal(input),null);assert(!new RegExp(`^${NOMINAL_PATTERN}$`).test(input));}
for(const input of ["Exactly three lamps weren't physically energized.","Exactly three lamps aren't active.","Exactly three lamps aren't physically energized yesterday."])assert.equal(parse(input),null);
// Singular count phrases are shared by ordinary participant composition too.
for(const [single,plural] of [['Nora is repairing exactly one radio.','Nora is repairing exactly one radios.'],['Exactly one child is conscious.','Exactly one children are conscious.']]){
 const a=parseNamedSentence(single),b=parseNamedSentence(plural);assert(a,single);assert(b,plural);
 const ra=await composeNamedSentence(single,load(a.predicate)),rb=await composeNamedSentence(plural,load(b.predicate));assert.deepEqual(ra.formal,rb.formal);assert.deepEqual(midiFromFormal(ra.formal),midiFromFormal(rb.formal));
}
console.log(`PASS ${cases} counted contraction/singular cases: full formal and MIDI equivalence, independent negation/runtime recovery, singular count validation and ordinary participant composition.`);
