import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound} from '../pages/local_compounds.mjs';
import {expandLocalCompound} from '../pages/local_compound_expansion.mjs';
import {localParticipantGroups} from '../pages/local_participant_groups.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),c=a.compounds.find(c=>c.display_title==='ongoing running toward a destination');assert(c);
const registry=await addLocalCompound(emptyLocalCompounds(),{label:'test nested running',definition:'Test-only structure.',part_of_speech:'verb',roles:[],components:[{target_id:c.compound_id,relation:'head'},{target_id:c.compound_id,relation:'qualifies'}]},a),expanded=await expandLocalCompound(registry.entries[0].compound_id,registry,a),groups=localParticipantGroups(expanded,a);
assert.equal(expanded.role_requirements.length,6);assert.equal(groups.length,4);assert.deepEqual(groups.map(g=>g.length).sort(),[1,1,2,2]);for(const g of groups)assert(g.every(r=>JSON.stringify(r.path)===JSON.stringify(g[0].path)));
console.log('PASS canonical shared-actor slots use one input per occurrence; separate nested actors and destinations remain independent.');
