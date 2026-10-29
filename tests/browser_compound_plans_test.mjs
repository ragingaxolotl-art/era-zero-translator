import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {renderLexicalOccurrences,lexicalGloss} from '../pages/bound_compounds.mjs';
const read=async path=>JSON.parse(await readFile(new URL(path,import.meta.url),'utf8'));
const authority=await read('../pages/data/index.json');
let checked=0;
for(const relative of Object.values(authority.resolution_files)){
 const document=await read('../pages/'+relative);
 for(const resolution of Object.values(document.variants)){
  const formal=resolution.formal;
  const events=await renderLexicalOccurrences(formal.semantic_ir,authority);
  assert.deepEqual(events,formal.performance.lexical_events,formal.formal_id);
  assert.equal(lexicalGloss(events,authority),formal.literal_gloss);
  checked++;
 }
}
assert.equal(checked,Object.keys(authority.resolution_files).length*15);
console.log(`Browser compiled plans: ${checked} released forms preserve exact reference lexical events and glosses.`);
