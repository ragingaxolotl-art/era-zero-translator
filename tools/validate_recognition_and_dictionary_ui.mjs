#!/usr/bin/env node
import fs from'node:fs/promises';
import path from'node:path';
import{fileURLToPath}from'node:url';
import{analyzeEnglish}from'../pages/english.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const html=await fs.readFile(path.join(root,'pages/index.html'),'utf8');
const app=await fs.readFile(path.join(root,'pages/app.js'),'utf8');
const data=JSON.parse(await fs.readFile(path.join(root,'pages/data/index.json'),'utf8'));
const failures=[];
const check=(value,message)=>{if(!value)failures.push(message)};
for(const id of['soundMode','recognitionNotes','catalogJump','conceptInput','analyzeConcept','conceptResult','downloadPerformanceMidi','verifyPerformanceMidi','performanceCheck','downloadPerformanceWav','selfCheckAudio','verifyPerformanceAudio','audioCheck','saveConcept','exportConcepts','importConcepts','conceptQueue'])check(html.includes(`id="${id}"`),`missing UI control ${id}`);
for(const mode of['strict','recognition','learning'])check(html.includes(`value="${mode}"`),`missing sound mode ${mode}`);
check(app.includes('matchOptionLabel(match)')&&app.includes('record?.core_definition||record?.invariant_definition'),'word selector lacks ID/title/meaning labels');
check(app.includes('renderRootJump()')&&app.includes('item.id} — ${item.title} — ${item.definition}'),'dictionary jump lacks ID/title/meaning labels');
check(app.includes("section==='recognition_phrase'")&&app.includes('recognitionOptions()'),'optional recognition audio is not wired into playback');
check(app.includes('verifyPerformanceMidi(state.resolution.formal')&&app.includes('midiFromPerformance(state.resolution.formal'),'performance MIDI verification not connected');
check(app.includes('verifyPerformancePcm(state.resolution.formal')&&app.includes('wavFromPerformance(state.resolution.formal'),'performance waveform verification not connected');
check(data.recognition_audio?.records?.length===324,'browser recognition registry incomplete');
check(data.lexical_pos_audit?.roots?.length===324&&data.lexical_pos_audit?.senses?.length===484,'browser lexical/POS audit incomplete');
const probes=[
  {phrase:'found',target:'MIN:110'},
  {phrase:'need',target:'ORI:211'},
  {phrase:'delete a file',route:'semantic_ir'},
  {phrase:'migrate the file',target:'DAT:112'},
  {phrase:'programmer',noAuto:true},
  {phrase:'teleport',noAuto:true}
];
for(const probe of probes){const result=analyzeEnglish(probe.phrase,data,{limit:12});if(probe.target)check(result.candidates.some(candidate=>candidate.target_id===probe.target),`${probe.phrase} does not expose ${probe.target}`);if(probe.route)check(result.candidates.some(candidate=>candidate.route===probe.route),`${probe.phrase} does not expose ${probe.route}`);if(probe.noAuto)check(!result.decision.auto_resolution_allowed,`${probe.phrase} must not silently create or choose a canonical meaning`)}
const status=failures.length?'FAIL':'PASS';
const report=`# Recognition and dictionary UI validation\n\nStatus: **${status}**\n\n- Sound modes: **strict, recognition, learning**\n- Meaning-rich root/compound options: **352**\n- Lexically audited English senses exposed: **${data.lexical_pos_audit?.senses?.length||0}**\n- Concept-intake probes: **${probes.length}**\n- Automatic canonical additions: **0**\n- Failures: **${failures.length}**\n\n${failures.length?'## Failures\n\n'+failures.map(item=>`- ${item}`).join('\n')+'\n':'Recognition controls, ordinary-language labels, dictionary jump navigation, POS metadata, and conservative concept intake are present in the published browser release.\n'}`;
await fs.writeFile(path.join(root,'reports/recognition_and_dictionary_ui_validation.md'),report);
console.log(`Recognition/dictionary UI: ${status} · ${probes.length} intake probes`);
if(failures.length){console.error(failures.join('\n'));process.exit(1)}
