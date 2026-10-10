#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {analyzeEnglish} from '../pages/english.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const data=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json'),'utf8'));
const plain=data.plain_english;
const failures=[];
const check=(ok,message)=>{if(!ok)failures.push(message)};

check(plain?.format==='EZ-PLAIN-ENGLISH-1','plain-English format');
check(plain?.status==='noncanonical_discovery_layer','plain-English authority status');
check(plain?.canonical_semantic_changes===0,'canonical semantics unchanged');
check(data.counts.atoms===324&&data.counts.compounds===28&&data.counts.senses===436,'canonical inventory unchanged');
check(plain?.counts?.atoms===324&&plain?.counts?.compounds===28&&plain?.counts?.entries===352,'plain-English inventory counts');

const entries=plain?.entries||[],ids=entries.map(entry=>entry.target_id),unique=new Set(ids);
check(unique.size===352,'one plain-English record per target');
for(const atom of data.atoms)check(unique.has(atom.canonical_id),`missing atom ${atom.canonical_id}`);
for(const compound of data.compounds)check(unique.has(compound.compound_id),`missing compound ${compound.compound_id}`);
for(const entry of entries){
  check(entry.mapping_status==='discovery_only_noncanonical',`${entry.target_id} noncanonical status`);
  check(entry.plain_label&&entry.plain_explanation&&entry.authority_note,`${entry.target_id} explanatory fields`);
  check(Array.isArray(entry.ordinary_terms)&&entry.ordinary_terms.length>0,`${entry.target_id} ordinary terms`);
  check(Array.isArray(entry.match_phrases)&&entry.match_phrases.length>0,`${entry.target_id} match phrases`);
}

let exactTop=0;
for(const entry of entries){
  const result=analyzeEnglish(entry.plain_label,data,{limit:8});
  if(result.candidates[0]?.target_id===entry.target_id)exactTop+=1;
  else failures.push(`${entry.target_id} plain label ranked ${result.candidates[0]?.target_id||'nothing'} first`);
}

const probes=[
  ['sent information','DAT:110'],
  ['send information','DAT:111'],
  ['will send information','DAT:112'],
  ['ongoing movement through the surroundings','MOV:121'],
  ['finished learning or changing an idea','MIN:110'],
  ['active dependence on a requirement','ORI:211'],
  ['file','DAT:000']
];
const probeResults=probes.map(([phrase,target])=>{const result=analyzeEnglish(phrase,data,{limit:8}),actual=result.candidates[0]?.target_id||null;check(actual===target,`“${phrase}” expected ${target}, got ${actual}`);return{phrase,expected:target,actual,auto_resolution_allowed:result.decision.auto_resolution_allowed}});
const ambiguous=analyzeEnglish('send',data,{limit:8});
check(!ambiguous.decision.auto_resolution_allowed,'bare “send” remains ambiguous without a data/message object');

const report=`# Plain-English matching validation\n\n- Result: **${failures.length?'FAIL':'PASS'}**\n- Canonical atoms unchanged: **${data.counts.atoms}**\n- Approved compounds unchanged: **${data.counts.compounds}**\n- Existing indexed senses unchanged: **${data.counts.senses}**\n- Noncanonical plain-English mappings: **${entries.length}**\n- Plain labels ranking their intended target first: **${exactTop}/${entries.length}**\n- Bare ambiguous “send” auto-resolved: **${ambiguous.decision.auto_resolution_allowed?'yes (failure)':'no'}**\n\n## Phrase probes\n\n${probeResults.map(item=>`- \`${item.phrase}\` → ${item.actual} (expected ${item.expected}; auto ${item.auto_resolution_allowed?'yes':'no'})`).join('\n')}\n\n## Authority boundary\n\nThe plain-English index is a noncanonical discovery and matching layer. It does not replace invariant definitions, alter generated forms, or authorize a semantic meaning that is absent from the canonical atom and compound records.\n${failures.length?`\n## Failures\n\n${failures.map(item=>`- ${item}`).join('\n')}\n`:''}`;
fs.writeFileSync(path.join(root,'reports/plain_english_validation.md'),report);
if(failures.length){console.error(failures.join('\n'));process.exit(1)}
console.log(`Plain-English matching: PASS (${exactTop}/${entries.length} labels; ${entries.length} complete mappings)`);
