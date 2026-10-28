import fs from 'node:fs';
import assert from 'node:assert/strict';
import {analyzeEnglish} from '../pages/english.mjs';
const pages = new URL('../pages/', import.meta.url);
const data = JSON.parse(fs.readFileSync(new URL('data/index.json', pages)));
const compound = data.compounds.find(item => item.display_title === 'love');
assert(compound, 'Approved love compound must exist');
assert.deepEqual(compound.nodes.map(node => node.root_id).sort(), ['LIF:002', 'LIF:101', 'LIF:210']);
assert.equal(compound.nodes.find(node => node.node_id === compound.semantic_head).root_id, 'LIF:210');
for (const input of ['love', 'love [2]']) {
  const result = analyzeEnglish(input, data);
  assert(result.candidates.some(sense => sense.target_id === compound.compound_id));
  if (input.endsWith('[2]')) assert.equal(result.explicit_runtime_state, 2);
}
const resolution = JSON.parse(fs.readFileSync(new URL(data.resolution_files[compound.compound_id], pages)));
assert.equal(Object.keys(resolution.variants).length, 15);
for (const [key, variant] of Object.entries(resolution.variants)) {
  assert(variant.round_trip_equal);
  const events = variant.formal.performance.lexical_events;
  assert.equal(events.length, 3);
  assert(events.some(event => event.runtime_tail?.code === Number(key.split(':')[1])));
}
assert(analyzeEnglish('affection', data).candidates.some(sense => sense.route === 'gap'));
console.log('Love compound: PASS — lookup, three atoms, bond head, 15 exact variants, num, and separate affection reading.');
