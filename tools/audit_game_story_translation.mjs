import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {analyzeEnglish} from '../pages/english.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const data=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json'),'utf8'));
const corpus=JSON.parse(fs.readFileSync(path.join(root,'tests/game_story_translation_cases.json'),'utf8'));
const intentBundle=JSON.parse(fs.readFileSync(path.join(root,'examples/game_dialogue_intents.json'),'utf8'));
const checks=[];
const check=(name,ok,detail='')=>checks.push({name,ok:Boolean(ok),detail});
const canonicalTargets=new Set([...data.atoms.map(item=>item.canonical_id),...data.compounds.map(item=>item.compound_id)]);
const routes=data.game_story_senses||[];

check('canonical inventory unchanged',data.atoms.length===324&&data.compounds.length===28&&data.senses.length===436);
check('profile declares no semantic authority change',data.game_story_profile?.canonical_semantic_changes===0);
check('surface IDs unique',new Set(routes.map(item=>item.sense_id)).size===routes.length);
check('all direct routes use existing canonical targets',routes.filter(item=>['atom','compound'].includes(item.route)).every(item=>canonicalTargets.has(item.target_id)));
check('all labels are noun referents',routes.filter(item=>item.route==='label').every(item=>item.part_of_speech==='noun'&&item.noun_label_allowed===true));
check('every generalization is disclosed',routes.filter(item=>item.fidelity==='generalized').every(item=>item.generalization&&item.target_id));
check('gaps do not claim canonical targets',routes.filter(item=>item.route==='gap').every(item=>!item.target_id));
check('computer structural routes do not claim false atomic targets',routes.filter(item=>['instrumental_use_relation','requested_information_deletion','active_information_deletion','completed_information_deletion'].includes(item.sense_key)).every(item=>item.route==='semantic_ir'&&!item.target_id));
check('migration phases use the approved target-transfer triplet',routes.some(item=>item.sense_key==='pending_data_migration_generalized'&&item.target_id==='DAT:112')&&routes.some(item=>item.sense_key==='active_data_migration_generalized'&&item.target_id==='DAT:111')&&routes.some(item=>item.sense_key==='completed_data_migration_generalized'&&item.target_id==='DAT:110'));
check('game intents are unique',new Set(intentBundle.intents.map(item=>item.intent)).size===intentBundle.intents.length);
check('game intents use tested surface routes',intentBundle.intents.every(intent=>routes.some(route=>route.sense_id===intent.surface_sense_id&&route.target_id===intent.target_id)));
check('game intents use hosted canonical variants',intentBundle.intents.every(intent=>{const relative=data.resolution_files[intent.target_id];if(!relative)return false;const document=JSON.parse(fs.readFileSync(path.join(root,'pages',relative.replace(/^\.\//,'')),'utf8'));return Boolean(document.variants[`${intent.speech_act}:${intent.runtime_state}`])}));
check('game intent presentation choices are valid',intentBundle.intents.every(intent=>['happy','sad','angry'].includes(intent.eye_expression)&&[0,1,2].includes(intent.runtime_state)));

const rows=[];
for(const test of corpus.cases){
  const result=analyzeEnglish(test.phrase,data),top=result.candidates[0];
  let ok=result.status==='ok';
  if(test.target)ok&&=top?.target_id===test.target;
  if(test.route)ok&&=top?.route===test.route;
  if(test.sense_key)ok&&=top?.sense_key===test.sense_key;
  for(const [term,status] of Object.entries(test.statuses||{}))ok&&=result.term_coverage.some(item=>item.term===term&&item.status===status);
  if(test.must_not_auto)ok&&=!result.decision.auto_resolution_allowed;
  const unresolved=result.term_coverage.filter(item=>item.status==='unresolved_semantic').map(item=>item.term);
  const labels=result.term_coverage.filter(item=>['phonemic_label','labeled_entity'].includes(item.status)).map(item=>item.term);
  rows.push({test,result,top,unresolved,labels,ok});
  check(`phrase: ${test.phrase}`,ok,`${top?.target_id||top?.sense_key||'no semantic target'}; ${result.term_coverage.map(item=>`${item.term}:${item.status}`).join(', ')}`);
}

check('unknown verbs are never phonemic labels',rows.every(row=>!row.result.term_coverage.some(item=>item.status==='phonemic_label'&&item.semantic_kind==='verb')));
check('unknown descriptors are never phonemic labels',rows.every(row=>!row.result.term_coverage.some(item=>item.status==='phonemic_label'&&item.semantic_kind==='descriptor')));
check('unresolved semantic content blocks automatic translation',rows.every(row=>!row.unresolved.length||!row.result.decision.auto_resolution_allowed));
check('speaker and addressee words become participant references',rows.flatMap(row=>row.result.term_coverage).filter(item=>['i','me','we','us','you'].includes(item.term)).every(item=>item.status==='participant_reference'));

const failed=checks.filter(item=>!item.ok),passed=checks.length-failed.length;
const translated=rows.filter(row=>['atom','compound'].includes(row.top?.route)).length;
const gaps=rows.filter(row=>row.top?.route==='gap').length;
const unresolvedCases=rows.filter(row=>row.unresolved.length).length;
const labeledCases=rows.filter(row=>row.labels.length).length;
const lines=['# Game and Story Translation Audit','',`Status: **${failed.length?'FAIL':'PASS'}**`,'',`- Checks passed: **${passed}**`,`- Checks failed: **${failed.length}**`,`- Phrase cases: **${rows.length}**`,`- Prevalidated Cyber Pet intents: **${intentBundle.intents.length}**`,`- Canonically renderable generalized/direct predicates: **${translated}**`,`- Honest vocabulary-gap phrases: **${gaps}**`,`- Phrases blocked by unknown semantic content: **${unresolvedCases}**`,`- Phrases preserving one or more noun labels: **${labeledCases}**`,`- Canonical root changes: **0**`,'','## Phrase matrix','','| Phrase | Primary route | Word handling | Automatic | Result |','|---|---|---|---:|---|'];
for(const row of rows){lines.push(`| ${row.test.phrase.replaceAll('|','\\|')} | ${(row.top?.target_id||row.top?.sense_key||'none').replaceAll('|','\\|')} | ${row.result.term_coverage.map(item=>`${item.term}:${item.status}`).join(', ')} | ${row.result.decision.auto_resolution_allowed?'yes':'no'} | ${row.ok?'PASS':'FAIL'} |`)}
lines.push('','## Interpretation boundary','','A PASS means the analyzer handled the phrase according to the declared policy. It does not mean every English detail entered canonical Era Zero. Generalized routes preserve only the entailed canonical center and display the lost detail. Participant references are grammatical. EZNAME preserves noun identity only. Gap routes remain untranslated. Unknown verbs and descriptors block automatic translation.','','## Cyber Pet integration recommendation','','Use stable game-state intent keys rather than re-parsing display prose at runtime. For example, low Fullness may select the tested `hungry`/operative-dependence route, low Energy may select `tired`/operative-dependence, an injury may select the approved physical-injury compound, and a care request may select active living care. Keep the English subtitle beside the Era Zero performance so the disclosed generalization remains visible during development.');
fs.writeFileSync(path.join(root,'reports/game_story_translation_audit.md'),`${lines.join('\n')}\n`);

console.log(`Game/story translation audit: ${failed.length?'FAIL':'PASS'}`);
console.log(`Checks passed: ${passed}; failed: ${failed.length}; phrases: ${rows.length}`);
if(failed.length){for(const item of failed)console.error(`FAIL: ${item.name} — ${item.detail}`);process.exit(1)}
