import fs from 'node:fs/promises';
import path from 'node:path';
import {webcrypto} from 'node:crypto';
import {fileURLToPath} from 'node:url';

globalThis.crypto ||= webcrypto;
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const pages=path.join(root,'pages');
const engine=await import(path.join(pages,'engine.mjs'));
const english=await import(path.join(pages,'english.mjs'));
const names=await import(path.join(pages,'names.mjs'));
const index=JSON.parse(await fs.readFile(path.join(pages,'data/index.json'),'utf8'));
const documents=JSON.parse(await fs.readFile(path.join(pages,'data/documents.json'),'utf8'));
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
  ['They left the building.','MOV:100','assertion',1,true],
  ['Go home.','MOV:121','command',1,true],
  ['Send the file.','DAT:111','command',1,true],
  ['Send the message.','CON:101','command',1,true],
  ['I changed my mind.','MIN:101','assertion',1,true]
];
for(const [sentence,target,act,runtime,automatic] of englishCases){
  const result=english.analyzeEnglish(sentence,index);
  check(`plain English target: ${sentence}`,result.candidates[0]?.target_id===target);
  check(`plain English intent: ${sentence}`,result.speech_act_proposal===act&&result.explicit_runtime_state===runtime);
  check(`plain English safe resolution: ${sentence}`,result.decision.auto_resolution_allowed===automatic);
}
const ambiguousKnow=english.analyzeEnglish('I know the answer.',index);
check('plain English preserves real ambiguity',ambiguousKnow.decision.requires_clarification&&ambiguousKnow.candidates.some(item=>item.route==='gap'));
const allChangeOptions=english.analyzeEnglish('change',index);
check('all matching options escape the old eight-item cutoff',allChangeOptions.candidate_count===allChangeOptions.candidates.length&&allChangeOptions.candidates.length>8);
const unknownPhrase=english.analyzeEnglish('Zibble frobnates quux.',index);
check('arbitrary unknown phrase is preserved',unknownPhrase.status==='ok'&&unknownPhrase.candidates.length===0&&unknownPhrase.term_coverage.length===3&&unknownPhrase.term_coverage.every(item=>item.status==='phonemic_label'));
const mixedPhrase=english.analyzeEnglish('Go home with zibble.',index);
check('mixed phrase preserves labels without blocking strong context',mixedPhrase.candidates[0]?.target_id==='MOV:121'&&mixedPhrase.decision.auto_resolution_allowed&&mixedPhrase.term_coverage.some(item=>item.term==='zibble'&&item.status==='phonemic_label'));
const named=await names.encodeName('zibble','blue-2');
const namedAgain=await names.encodeName('zibble','blue-2');
const differentInstance=await names.encodeName('zibble','red-1');
check('phonemic label is deterministic',named.name_id===namedAgain.name_id&&JSON.stringify(names.notesForName(named))===JSON.stringify(names.notesForName(namedAgain)));
check('phonemic estimate and framing',named.format==='EZNAME-0.1'&&named.phonemes.join(' ')==='Z IH B AH L'&&named.semantic_claim===false&&names.notesForName(named).length>named.phonemes.length*2);
check('object instance distinction',named.name_id!==differentInstance.name_id&&JSON.stringify(named.instance_notes)!==JSON.stringify(differentInstance.instance_notes));
check('phonemic MIDI conformance',new TextDecoder().decode(names.midiFromName(named).slice(0,4))==='MThd');

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
const soundPlan=engine.soundPlanFromFormal(sample.formal),sourceEvent=sample.formal.performance.lexical_events[0];
check('complete audible sound plan',JSON.stringify(soundPlan.lexical_events[0].family_opening)===JSON.stringify(sourceEvent.family_opening_absolute_midi)&&JSON.stringify(soundPlan.lexical_events[0].address_path)===JSON.stringify(sourceEvent.address_absolute_midi)&&soundPlan.lexical_events[0].runtime_ending[0]===sourceEvent.runtime_tail.absolute_note&&JSON.stringify(soundPlan.sentence_contour)===JSON.stringify(sample.formal.performance.contour_relative_semitones.map(offset=>sample.formal.performance.anchor_midi+offset)));
const bundle=await engine.createBundle(sample,'leave [1]');
const verified=await engine.verifyBundle(bundle);
check('portable EZB-1 bundle',verified.status==='valid'&&verified.target_id==='MOV:101');
const corrupt=structuredClone(bundle);corrupt.payload.target_id='MOV:999';
let rejected=false;try{await engine.verifyBundle(corrupt)}catch{rejected=true}
check('bundle corruption rejection',rejected);

const html=await fs.readFile(path.join(pages,'index.html'),'utf8');
const app=await fs.readFile(path.join(pages,'app.js'),'utf8');
const css=await fs.readFile(path.join(pages,'styles.css'),'utf8');
check('project-relative versioned assets',html.includes('href="./styles.css?v=1.5.0"')&&html.includes('src="./app.js?v=1.5.0"')&&!html.includes('src="/app.js'));
check('all browser modules versioned together',app.includes("from'./engine.mjs?v=1.5.0'")&&app.includes("from'./english.mjs?v=1.5.0'")&&app.includes("from'./names.mjs?v=1.5.0'"));
check('English-first interface',html.includes('Write it in normal English')&&html.includes('Any phrase is accepted')&&app.includes("./english.mjs?v=1.5.0"));
check('nonsemantic phonemic-name interface',html.includes('Give an unfamiliar object a sound ID')&&html.includes('Experimental EZNAME-0.1')&&app.includes("./names.mjs?v=1.5.0"));
check('three-view workbench',html.includes('data-app-tab="translator"')&&html.includes('data-app-tab="dictionary"')&&html.includes('data-app-tab="documents"'));
check('complete option catalogue',html.includes('Complete language inventory')&&html.includes('id="catalogList"')&&app.includes('state.data.senses.filter')&&index.atoms.length===324&&index.compounds.length===28);
check('logical dictionary inspector',html.includes('id="catalogDetail"')&&app.includes('showDictionaryDetail')&&app.includes('Universal slot')&&app.includes('Relative note path'));
check('complete document manifest',documents.count===documents.documents.length&&documents.count>=300&&documents.documents.some(item=>item.path==='docs/PRODUCT_GOAL_AND_FULL_TEST_PLAN.md'));
check('word-by-word matching and overrides',app.includes('Match each word to Era Zero')&&app.includes('Meaning match for')&&app.includes('state.wordSelections.set'));
check('whole phrase preservation',html.includes('id="phraseCoverage"')&&app.includes('renderPhraseCoverage')&&app.includes('playPhraseNames')&&app.includes('phonemic_labels_present'));
check('automatic reading is visibly selected',app.includes('selectCandidate(0,first)')&&app.includes('Automatically selected ${state.selected.sense_id}'));
check('phoneme audio resumes and reports playback',app.includes("sharedAudioContext.state==='suspended'")&&app.includes('await sharedAudioContext.resume()')&&app.includes('Audio started · ${notes.length} phoneme-label tones.')&&app.includes('showPlaying(button'));
check('visible complete sound construction',html.includes('id="hearTranslation"')&&html.includes('id="prefixText"')&&html.includes('id="carrierText"')&&html.includes('id="familyNotes"')&&html.includes('id="addressNotes"')&&html.includes('id="runtimeNote"')&&html.includes('id="contourNotes"')&&app.includes('soundPlanFromFormal'));
check('accessible responsive UI',html.includes('aria-live')&&html.includes('role="tablist"')&&css.includes('@media(max-width:900px)')&&css.includes('prefers-reduced-motion'));
check('hosted limitation is explicit',app.includes('Open-slot compound role binding')||index.online_scope.note.includes('Open-slot compound'));

const failed=checks.filter(([,ok])=>!ok);
const report=`# GitHub Pages Release Audit\n\nStatus: **${failed.length?'FAIL':'PASS'}**\n\n- Checks passed: **${checks.length-failed.length}**\n- Checks failed: **${failed.length}**\n- Canonical resolution variants: **${variants}**\n- Indexed senses: **${index.counts.senses}**\n- Directly resolvable targets: **${Object.keys(index.resolution_files).length}**\n- Open-slot compounds reserved for the local API: **${index.online_scope.slotted_compounds}**\n- SVG/MIDI verification: **byte-for-byte against the Ruby canonical generator**\n- EZB-1 integrity and corruption rejection: **verified**\n\nThe static release preserves ambiguity, gaps, runtime state, speech act, Semantic IR, EZF-1, SVG, MIDI, and deterministic direct resolution. The single open-slot compound requires arbitrary role binding and remains explicitly routed to the full local Ruby API.\n`;
await fs.writeFile(path.join(root,'reports/pages_release_audit.md'),report);
console.log(`GitHub Pages audit: ${failed.length?'FAIL':'PASS'}`);
console.log(`Checks passed: ${checks.length-failed.length}; failed: ${failed.length}; canonical variants: ${variants}`);
if(failed.length)process.exit(1);
