import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {analyzeEnglish,normalize} from '../pages/english.mjs';
import {encodeName,notesForName} from '../pages/names.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const data=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json'),'utf8'));
const documents=JSON.parse(fs.readFileSync(path.join(root,'pages/data/documents.json'),'utf8'));
const html=fs.readFileSync(path.join(root,'pages/index.html'),'utf8');
const app=fs.readFileSync(path.join(root,'pages/app.js'),'utf8');
const checks=[];
const check=(name,ok,detail='')=>checks.push({name,ok:Boolean(ok),detail});

const cases=[
  {phrase:'Go home.',target:'MOV:121',key:'spatial_movement',auto:true,act:'command'},
  {phrase:'Go offline.',key:'abstract_transition',route:'semantic_ir',auto:false},
  {phrase:'Send the file.',target:'DAT:111',key:'data_transfer',auto:true},
  {phrase:'Send the message.',target:'CON:101',key:'communicative_expression',auto:true},
  {phrase:'Receive the data.',target:'DAT:110',key:'data_transfer_completion',auto:true},
  {phrase:'Receive the warning.',target:'CON:111',key:'communicative_reception',auto:true},
  {phrase:'Change my mind.',target:'MIN:101',key:'mental_revision',auto:true},
  {phrase:'Change the file.',target:'DAT:101',key:'data_transformation',auto:true},
  {phrase:'Change the layout.',target:'STR:101',key:'structural_reconfiguration',auto:true},
  {phrase:'Run the program.',key:'program_execution',route:'semantic_ir',auto:false},
  {phrase:'Run the engine.',key:'machine_operation',route:'semantic_ir',auto:false},
  {phrase:'Run home.',key:'locomotion',route:'semantic_ir',auto:false},
  {phrase:'Return a value.',key:'function_result',route:'semantic_ir',auto:false},
  {phrase:'Return home.',key:'movement_to_prior_position',route:'semantic_ir',auto:false},
  {phrase:'I am leaving home now.',target:'MOV:101',key:'active_departure',auto:true},
  {phrase:'I left home.',target:'MOV:100',key:'completed_departure',auto:true},
  {phrase:'Approach the bridge.',target:'MOV:111',key:'active_target_approach',auto:true},
  {phrase:'She arrived at the station.',target:'MOV:110',key:'completed_target_arrival',auto:true},
  {phrase:'Create a tool.',target:'CRE:111',key:'active_artifact_generation',auto:true},
  {phrase:'Break the machine.',target:'WRN:111',key:'target_impairment',auto:true},
  {phrase:'Fix the machine.',target:'REP:111',key:'target_restoration',auto:true},
  {phrase:'Repair the machine.',target:'REP:110',key:'completed_target_restoration',auto:true},
  {phrase:'Are they approaching the bridge?',target:'MOV:111',act:'question',auto:true},
  {phrase:'I am not moving.',target:'MOV:121',state:0,auto:true},
  {phrase:'Maybe go home.',target:'MOV:121',act:'possibility',auto:true},
  {phrase:'Wait here.',key:'deferred_action',route:'semantic_ir',auto:false},
  {phrase:'Stop moving.',target:'MOV:121',auto:true},
  {phrase:'Continue moving.',target:'MOV:121',auto:true},
  {phrase:'Cross the bridge.',key:'boundary_traversal',route:'semantic_ir',auto:false},
  {phrase:'Follow the route.',key:'trajectory_tracking',route:'semantic_ir',auto:false},
  {phrase:'Transport the box.',key:'caused_target_movement',route:'semantic_ir',auto:false},
  {phrase:'Zibble frobnates quux.',candidates:0,unknown:3,auto:false},
  {phrase:'Go home with zibble.',target:'MOV:121',unknown:1,auto:true},
  {phrase:'Please send the data.',target:'DAT:111',act:'command',auto:true},
  {phrase:'Could you send the message?',target:'CON:101',act:'question',auto:true},
  {phrase:'The route is active.',target:'MOV:020'},
  {phrase:'A dormant machine.',target:'CMP:e152ea538409460a93b99b90'},
  {phrase:'A physical tool.',target:'CMP:111b772027accab2054f0415'},
  {phrase:'A message datum.',target:'CMP:608ecb4f3c515a9c9a3443ec'},
  {phrase:'A backup dataset.',target:'CMP:33c135410b0deef525b6770d'},
  {phrase:'A shared knowledge base.',target:'CMP:44173561806bc8f334a0b7c9'},
  {phrase:'A material hazard.',target:'CMP:cb0812face56f90b7ba139c5'},
  {phrase:'Food.',route:'gap',auto:false},
  {phrase:'Water.',route:'gap',auto:false},
  {phrase:'Friend.',route:'gap',auto:false},
  {phrase:'Safe.',route:'gap',auto:false},
  {phrase:'Think.',route:'gap',auto:false},
  {phrase:'True.',route:'gap',auto:false},
  {phrase:'Know.',auto:false},
  {phrase:'Have.',auto:false},
  {phrase:'Change.',auto:false},
  {phrase:'Send.',auto:false},
  {phrase:'Receive.',auto:false},
  {phrase:'Share.',auto:false},
  {phrase:'Return.',auto:false},
  {phrase:'Run.',auto:false},
  {phrase:'What is a route?',act:'question'},
  {phrase:'A route means an ordered path.',act:'definition'},
  {phrase:'They may approach the destination.',act:'possibility'},
  {phrase:'Go home [0].',target:'MOV:121',state:0},
  {phrase:'Go home [1].',target:'MOV:121',state:1},
  {phrase:'Go home [2].',target:'MOV:121',state:2},
  {phrase:'Go, home!',target:'MOV:121'},
  {phrase:'GO HOME.',target:'MOV:121'},
  {phrase:'Send the file to zibble.',target:'DAT:111',unknown:2},
  {phrase:'Change the data and send the message.',unknown:0},
  {phrase:'Zibble zibble.',candidates:0,unknown:2,auto:false},
  {phrase:'The zibble is moving.',target:'MOV:121',unknown:1},
  {phrase:'Do not send the message.',target:'CON:101',state:0},
  {phrase:'Will they arrive?',target:'MOV:110',act:'question'},
  {phrase:'Create the material artifact.',target:'CRE:111'},
  {phrase:'Restore the backup dataset.',target:'CMP:33c135410b0deef525b6770d'},
  {phrase:'Move the object.',target:'MOV:121'},
  {phrase:'The program is dormant.',target:'CMP:9e8b36f50570a0c3c362a968'},
  {phrase:'The body is active.',target:'CMP:3122dedcff0f85ad293e2580'}
];

const phraseRows=[];
for(const test of cases){
  const result=analyzeEnglish(test.phrase,data),top=result.candidates[0];
  let ok=result.status==='ok'&&result.term_coverage.every(item=>['function_word','phonemic_label'].includes(item.status)||item.matches.some(match=>match.sense_id===item.recommended_sense_id));
  if('target'in test)ok&&=top?.target_id===test.target;
  if('key'in test)ok&&=top?.sense_key===test.key;
  if('route'in test)ok&&=top?.route===test.route;
  if('auto'in test)ok&&=result.decision.auto_resolution_allowed===test.auto;
  if('act'in test)ok&&=result.speech_act_proposal===test.act;
  if('state'in test)ok&&=result.explicit_runtime_state===test.state;
  if('candidates'in test)ok&&=result.candidate_count===test.candidates;
  const unknown=result.term_coverage.filter(item=>item.status==='phonemic_label').length;
  if('unknown'in test)ok&&=unknown===test.unknown;
  phraseRows.push({test,result,top,unknown,ok});
  check(`phrase: ${test.phrase}`,ok,`${top?.target_id||top?.sense_key||'no semantic candidate'}; ${result.candidate_count} candidates; ${unknown} labels`);
}

const familyCounts=Object.groupBy(data.atoms,atom=>atom.family);
check('324 canonical dictionary roots',data.atoms.length===324&&new Set(data.atoms.map(atom=>atom.canonical_id)).size===324);
check('12 complete 27-root families',Object.keys(familyCounts).length===12&&Object.values(familyCounts).every(items=>items.length===27));
check('all generated root fields available',data.atoms.every(atom=>atom.canonical_id&&atom.universal_slot&&atom.local_compact_root&&atom.canonical_transliteration&&atom.formal_carrier&&atom.harmonic_signature_semitones.length>=3&&atom.note_path_semitones.length===4));
check('28 complete compound records',data.compounds.length===28&&data.compounds.every(entry=>entry.compound_id&&entry.invariant_definition&&entry.nodes.length&&entry.edges.length));
check('436 indexed dictionary options',data.senses.length===436);

const requiredDocuments=['docs/PRODUCT_GOAL_AND_FULL_TEST_PLAN.md','docs/SOURCE_PROVENANCE.md','spec/canonical_spec.yaml','spec/source_provenance.yaml','lexicon/all_atoms.yaml','lexicon/compound_dictionary.yaml','lexicon/english_sense_index.yaml','semantic_authority_status.md','reports/regression_run.md'];
check('document manifest count is exact',documents.count===documents.documents.length&&documents.count>=300,`${documents.count} records`);
check('every document path exists',documents.documents.every(document=>fs.existsSync(path.join(root,document.path))));
check('required authority documents are public',requiredDocuments.every(required=>documents.documents.some(document=>document.path===required)));
check('all evidence categories available',['Core documentation','Specifications','Lexicons and authority','Migrations and approvals','Semantic reviews','Validation reports','Test evidence','Examples and presentation','Source extraction'].every(category=>documents.categories.includes(category)));
check('conversation and integrated document linked',documents.sources.some(source=>source.url.includes('chatgpt.com/share/6a666'))&&documents.sources.some(source=>source.url.includes('docs.google.com/document/d/1btn')));
check('three-view workbench',html.includes('data-app-tab="translator"')&&html.includes('data-app-tab="dictionary"')&&html.includes('data-app-tab="documents"'));
check('word match selectors and overrides',app.includes('Match each word to Era Zero')&&app.includes('Meaning match for')&&app.includes('state.wordSelections.set'));
check('dictionary inspector exposes generated fields',app.includes('Universal slot')&&app.includes('Formal carrier')&&app.includes('Relative note path'));
check('document browser is searchable',html.includes('id="documentSearch"')&&app.includes('filterDocuments'));
check('audio engine resumes before playback',app.includes("sharedAudioContext.state==='suspended'")&&app.includes('await sharedAudioContext.resume()'));

const firstName=await encodeName('zibble'),secondName=await encodeName('zibble');
check('phonemic labels deterministic',firstName.name_id===secondName.name_id&&notesForName(firstName).join(',')===notesForName(secondName).join(','));
check('phonemic label has audible framed sequence',notesForName(firstName).length>firstName.phonemes.length*2);

const failed=checks.filter(item=>!item.ok),passed=checks.length-failed.length;
const lines=['# Full Translator Phrase, Dictionary, and Document Audit','',`Status: **${failed.length?'FAIL':'PASS'}**`,'',`- Checks passed: **${passed}**`,`- Checks failed: **${failed.length}**`,`- Phrase cases: **${cases.length}**`,`- Dictionary roots: **${data.atoms.length}**`,`- Compounds: **${data.compounds.length}**`,`- Indexed senses: **${data.senses.length}**`,`- Public document records: **${documents.count}**`,'','## Phrase matrix','','| Phrase | Primary result | Auto | Runtime | Speech act | Word handling | Status |','|---|---|---:|---:|---|---|---|'];
for(const row of phraseRows){lines.push(`| ${row.test.phrase.replaceAll('|','\\|')} | ${(row.top?.target_id||row.top?.sense_key||'phonemic labels only').replaceAll('|','\\|')} | ${row.result.decision.auto_resolution_allowed?'yes':'no'} | ${row.result.explicit_runtime_state} | ${row.result.speech_act_proposal} | ${row.result.term_coverage.map(item=>`${item.term}:${item.status}`).join(', ')} | ${row.ok?'PASS':'FAIL'} |`)}
lines.push('','## Non-phrase checks','');
for(const item of checks.slice(cases.length))lines.push(`- **${item.ok?'PASS':'FAIL'}** — ${item.name}${item.detail?`: ${item.detail}`:''}`);
lines.push('','## Boundary','','A word-level recommendation is not a new canonical meaning. Grammar and Semantic-IR routes remain structural, explicit gaps remain gaps, English-only function words make no lexical claim, and EZNAME remains a nonsemantic label channel.');
fs.writeFileSync(path.join(root,'reports/full_translator_audit.md'),`${lines.join('\n')}\n`);
console.log(`Full translator audit: ${failed.length?'FAIL':'PASS'}`);
console.log(`Checks passed: ${passed}; failed: ${failed.length}; phrase cases: ${cases.length}; documents: ${documents.count}`);
if(failed.length){for(const item of failed)console.error(`FAIL: ${item.name} — ${item.detail}`);process.exit(1)}
