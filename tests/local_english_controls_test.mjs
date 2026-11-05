import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound} from '../pages/local_compounds.mjs';
import {mountLocalEnglishControls} from '../pages/local_english_controls.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),registry=await addLocalCompound(emptyLocalCompounds(),{label:'glowsteady',definition:'Test-only quality.',part_of_speech:'adjective',roles:[{role:'bearer',definition:'Entity with quality.'}],components:a.atoms.slice(0,2).map((v,i)=>({target_id:v.canonical_id,relation:i?'qualifies':'head'}))},a);
const element=()=>({children:[],append(...v){this.children.push(...v)},replaceChildren(...v){this.children=v},addEventListener(t,f){this[t]=f}}),container=element(),downloads=[];let current=true;
assert(await mountLocalEnglishControls(container,"Wasn't Nora glowsteady? [2]",registry,a,{document:{createElement:element},download:b=>downloads.push(b),isCurrent:()=>current,onError:e=>{throw e}}));
await container.children.at(-2).click();const output=container.children.at(-1);assert.equal(output.children.length,2);output.children[1].click();const result=JSON.parse(await downloads[0].text());assert.equal(result.meaning.runtime_state,2);assert.equal(result.meaning.speech_act,'question');assert.equal(result.meaning.bindings[0].reference.name.normalized_label,'nora');assert.deepEqual(result.meaning.scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'}]);current=false;output.children[0].click();assert.equal(downloads.length,1);
console.log('PASS saved-English controls export full sentence meaning and reject stale source downloads.');
