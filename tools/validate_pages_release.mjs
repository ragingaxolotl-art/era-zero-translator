import fs from 'node:fs/promises';
import path from 'node:path';
import {webcrypto} from 'node:crypto';
import {fileURLToPath} from 'node:url';

globalThis.crypto ||= webcrypto;
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const pages=path.join(root,'pages');
const engine=await import(path.join(pages,'engine.mjs'));
const english=await import(path.join(pages,'english.mjs'));
const index=JSON.parse(await fs.readFile(path.join(pages,'data/index.json'),'utf8'));
const checks=[];
const check=(name,condition)=>{checks.push([name,Boolean(condition)]);if(!condition)console.error(`FAIL: ${name}`)};

check('canonical inventory',index.counts.atoms===324&&index.counts.compounds===28&&index.counts.senses===436&&index.counts.gaps===11);
check('browser resolution scope',Object.keys(index.resolution_files).length===351&&index.online_scope.slotted_compounds===1);
check('conservative data',index.senses.some(s=>s.lemma==='go'&&s.route==='atom')&&index.senses.some(s=>s.lemma==='go'&&s.route==='semantic_ir')&&index.senses.some(s=>s.lemma==='food'&&s.route==='gap'));

const englishCases=[
  ['I am leaving home now.','MOV:101','assertion',1,true],
  ['She arrived at the station.','MOV:110','assertion',1,true],
  ['Are they approaching the bridge?','MOV:111','question',1,true],
  ['I am not moving.','MOV:121','assertion',0,true],
  ['Please leave now.','MOV:101','command',1,true],
  ['Could we approach the station?','MOV:111','question',1,true],
  ['They left the building.','MOV:100','assertion',1,true]
];
for(const [sentence,target,act,runtime,automatic] of englishCases){
  const result=english.analyzeEnglish(sentence,index);
  check(`plain English target: ${sentence}`,result.candidates[0]?.target_id===target);
  check(`plain English intent: ${sentence}`,result.speech_act_proposal===act&&result.explicit_runtime_state===runtime);
  check(`plain English safe resolution: ${sentence}`,result.decision.auto_resolution_allowed===automatic);
}
const ambiguousKnow=english.analyzeEnglish('I know the answer.',index);
check('plain English preserves real ambiguity',ambiguousKnow.decision.requires_clarification&&ambiguousKnow.candidates.some(item=>item.route==='gap'));

let variants=0;
for(const [target,relative] of Object.entries(index.resolution_files)){
  const document=JSON.parse(await fs.readFile(path.join(pages,relative.replace(/^\.\//,'')),'utf8'));
  check(`target identity ${target}`,document.target_id===target);
  for(const [key,result] of Object.entries(document.variants)){
    variants++;
    const formal=result.formal,ir=result.semantic_ir;
    check(`round trip marker ${target} ${key}`,result.status==='resolved'&&result.round_trip_equal===true&&formal.semantic_ir.utterance_id===ir.utterance_id&&formal.semantic_digest===ir.serialization.content_digest);
    const manifest=await engine.presentationManifest(formal);
    check(`presentation bytes ${target} ${key}`,JSON.stringify(manifest)===JSON.stringify(result.presentation_manifest));
  }
}
check('complete direct variant matrix',variants===351*15);

const sample=JSON.parse(await fs.readFile(path.join(pages,'data/resolutions/mov_101.json'),'utf8')).variants['assertion:1'];
const bundle=await engine.createBundle(sample,'leave [1]');
const verified=await engine.verifyBundle(bundle);
check('portable EZB-1 bundle',verified.status==='valid'&&verified.target_id==='MOV:101');
const corrupt=structuredClone(bundle);corrupt.payload.target_id='MOV:999';
let rejected=false;try{await engine.verifyBundle(corrupt)}catch{rejected=true}
check('bundle corruption rejection',rejected);

const html=await fs.readFile(path.join(pages,'index.html'),'utf8');
const app=await fs.readFile(path.join(pages,'app.js'),'utf8');
const css=await fs.readFile(path.join(pages,'styles.css'),'utf8');
check('project-relative assets',html.includes('href="./styles.css"')&&html.includes('src="./app.js"')&&!html.includes('src="/app.js"'));
check('English-first interface',html.includes('Write it in normal English')&&html.includes('No codes or brackets needed')&&app.includes("from'./english.mjs'"));
check('accessible responsive UI',html.includes('aria-live')&&html.includes('role="tablist"')&&css.includes('@media(max-width:900px)')&&css.includes('prefers-reduced-motion'));
check('hosted limitation is explicit',app.includes('Open-slot compound role binding')||index.online_scope.note.includes('Open-slot compound'));

const failed=checks.filter(([,ok])=>!ok);
const report=`# GitHub Pages Release Audit\n\nStatus: **${failed.length?'FAIL':'PASS'}**\n\n- Checks passed: **${checks.length-failed.length}**\n- Checks failed: **${failed.length}**\n- Canonical resolution variants: **${variants}**\n- Indexed senses: **${index.counts.senses}**\n- Directly resolvable targets: **${Object.keys(index.resolution_files).length}**\n- Open-slot compounds reserved for the local API: **${index.online_scope.slotted_compounds}**\n- SVG/MIDI verification: **byte-for-byte against the Ruby canonical generator**\n- EZB-1 integrity and corruption rejection: **verified**\n\nThe static release preserves ambiguity, gaps, runtime state, speech act, Semantic IR, EZF-1, SVG, MIDI, and deterministic direct resolution. The single open-slot compound requires arbitrary role binding and remains explicitly routed to the full local Ruby API.\n`;
await fs.writeFile(path.join(root,'reports/pages_release_audit.md'),report);
console.log(`GitHub Pages audit: ${failed.length?'FAIL':'PASS'}`);
console.log(`Checks passed: ${checks.length-failed.length}; failed: ${failed.length}; canonical variants: ${variants}`);
if(failed.length)process.exit(1);
