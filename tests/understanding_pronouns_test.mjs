import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeUnderstandingContent as compose,understandingPronounPlan as plan} from '../pages/understanding_content.mjs';
import {midiFromUnderstanding,decodeUnderstandingMidi} from '../pages/understanding_music.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
let count=0;
for(const state of [0,1,2])for(const reading of ['communicated_content','reasons','perspective']){
 const options={allowDraft:true,interpretation:reading};
 const named=await compose(`Nora understands Eli [${state}].`,options),expected=await midiFromUnderstanding(named,authority,{allowDraft:true});
 for(const [text,bindings] of [['She understands him.',{ref0:'Nora',ref1:'Eli'}],['He understands her.',{ref0:'Nora',ref1:'Eli'}],['They understand them.',{ref0:{referent:'Nora',number:'singular'},ref1:{referent:'Eli',number:'singular'}}]]){
  const doc=await compose(`${text} [${state}]`,{...options,bindings});assert.deepEqual(doc,named);
  const bytes=await midiFromUnderstanding(doc,authority,{allowDraft:true});assert.deepEqual(bytes,expected);
  const meaning=await decodeUnderstandingMidi(bytes,authority.atoms,{allowDraft:true});assert.deepEqual(meaning.experiencer.phonemes,named.experiencer.name.phonemes);count++;
 }
}
assert.equal(plan('They understand them.').occurrences.length,2);
assert.equal(plan('"They" understands "Them".'),null);
for(const bindings of [undefined,{ref0:'Nora',ref1:'Eli'},{ref0:{referent:'Nora',number:'plural'},ref1:{referent:'Eli',number:'singular'}},{ref0:{referent:'Nora',number:'singular',gender:'female'},ref1:{referent:'Eli',number:'singular'}}])await assert.rejects(()=>compose('They understand them.',{allowDraft:true,interpretation:'perspective',bindings}),e=>e.code==='pronoun_referents_required');
const d=await compose('They did not understand her.',{allowDraft:true,interpretation:'reasons',bindings:{ref0:{referent:'this robot',number:'singular'},ref1:'Nora'}});assert.equal(d.experiencer.reference_mode,'proximal_nominal');assert.equal(d.scopes.length,2);
console.log(`PASS ${count} gender-neutral reference/meaning/MIDI equivalences; singular they explicit, plural not collapsed, unresolved/extra fields rejected, quoted names preserved.`);
