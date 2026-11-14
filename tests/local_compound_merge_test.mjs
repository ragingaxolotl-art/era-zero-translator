import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound,mergeLocalCompounds} from '../pages/local_compounds.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),d={label:'first test word',definition:'Test-only definition.',part_of_speech:'adjective',roles:[],components:a.atoms.slice(0,2).map((v,i)=>({target_id:v.canonical_id,relation:i?'qualifies':'head'}))};
const base=await addLocalCompound(emptyLocalCompounds(),d,a),incoming=await addLocalCompound(base,{...d,label:'nested test word',components:[{target_id:base.entries[0].compound_id,relation:'head'},d.components[1]]},a),existing=await addLocalCompound(base,{...d,label:'other local word'},a),before=JSON.stringify(existing);
const merged=await mergeLocalCompounds(existing,incoming,a);assert.equal(merged.entries.length,3);assert.deepEqual(merged.entries.slice(0,2),existing.entries);assert.deepEqual(merged.entries[2],incoming.entries[1]);assert.deepEqual(await mergeLocalCompounds(merged,incoming,a),merged);
const conflict=await addLocalCompound(emptyLocalCompounds(),{...d,definition:'Different meaning under same name.'},a);await assert.rejects(mergeLocalCompounds(existing,conflict,a),/different saved definition/);assert.equal(JSON.stringify(existing),before);
const broken=structuredClone(incoming);broken.entries.reverse();await assert.rejects(mergeLocalCompounds(existing,broken,a));assert.equal(JSON.stringify(existing),before);
console.log('PASS merging preserves existing words, nested dependencies and identities; repeats are idempotent and conflicts/malformed imports leave input unchanged.');
