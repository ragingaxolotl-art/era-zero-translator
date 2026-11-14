import assert from 'node:assert/strict';
import fs from 'node:fs';
import {encodeName,notesForName} from '../pages/names.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),names=await Promise.all(['Participant 0','Participant 1','Participant 2','Participant 01','Participant 10','R2D2'].map(s=>encodeName(s)));
assert.equal(new Set(names.map(n=>n.name_id)).size,6);assert.equal(new Set(names.map(n=>JSON.stringify(notesForName(n)))).size,6);
assert.equal(names[3].normalized_label,'participant zero one');assert.equal(names[5].normalized_label,'r two d two');
assert.equal((await encodeName('Nora')).name_id,'EZNAME:aef7e0fd69c93b44');assert.equal((await encodeName('this tea')).name_id,'EZNAME:af97836c87cbf4b5');
for(const name of names){const rebuilt=await encodeName(name.normalized_label,'',name.phonemes.join(' '));assert.equal(rebuilt.name_id,name.name_id);}
const first=await contextualContentReference('"Participant 1"'),second=await contextualContentReference('"Participant 2"');assert.notEqual(first.referent_id,second.referent_id);
const x=await renderLexicalOccurrences({nodes:[first],edges:[]},a),y=await renderLexicalOccurrences({nodes:[second],edges:[]},a);assert.notDeepEqual(x[0].address_absolute_midi,y[0].address_absolute_midi);
console.log('PASS numeric identifier labels preserve digit order/leading zeroes and distinct reference music; existing alphabetic identities unchanged.');
