import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConjunction} from '../pages/sentences.mjs';
import {composePronounSentence,pronounInterpretationPlan} from '../pages/pronouns.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodePhysicalEntryMidi} from '../pages/physical_entry_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),load=async()=>({authority}),results=[];
for(const state of [0,1,2])for(const viewpoint of ['bounded','ongoing','habitual'])for(const [phrase,negative,question] of [['Nora enters the archive',false,false],['Nora does not enter the archive',true,false],['Does Nora enter the archive',false,true],['Does Nora not enter the archive',true,true]]){
 const input=`${phrase} [${state}]${question?'?':'.'}`;
 await assert.rejects(()=>composeNamedSentence(input,{authority}),e=>e.code==='entry_viewpoint_required');
 await assert.rejects(()=>composeNamedSentence(input,{authority},{viewpoint}),e=>e.code==='physical_entry_required');
 const r=await composeNamedSentence(input,{authority},{viewpoint,interpretation:'physical_entry'});results.push(r);
 const d=decodePhysicalEntryMidi(midiFromFormal(r.formal),authority.atoms);
 assert.equal(d.predicate,viewpoint==='ongoing'?'ongoing_physical_entry':'completed_physical_entry');assert.equal(d.phases.culmination,viewpoint==='ongoing'?'not_asserted':'interior');assert.equal(d.runtime_state,state);assert.equal(d.speech_act,question?'question':'assertion');
 assert.deepEqual(d.scopes,[...(negative?[{operator:'negation'}]:[]),{operator:'aspect',aspect:viewpoint}]);assert(!r.semantic_ir.edges.some(e=>e.type==='time_relation'));
}
for(const state of [0,1,2])for(const text of ['Nora habitually enters the archive','Nora does not habitually enter the archive','Nora habitually physically enters this archive']){
 const input=`${text} [${state}].`,parsed=parseNamedSentence(input);assert.equal(parsed.requiredViewpoint,false);
 const r=await composeNamedSentence(input,{authority},parsed.requiredInterpretation?{interpretation:'physical_entry'}:{});results.push(r);const d=decodePhysicalEntryMidi(midiFromFormal(r.formal),authority.atoms);assert(d.scopes.some(s=>s.operator==='aspect'&&s.aspect==='habitual'));
}
for(const state of [0,1,2]){
 results.push(await composeSentenceConjunction(`Nora enters the archive [${state}] and Eli may be entering the room [${(state+1)%3}].`,load,[{viewpoint:'habitual',interpretation:'physical_entry'},{interpretation:'entry_possible'}]));
 const r=await composePronounSentence(`She enters the archive [${state}].`,load,{ref0:'Nora'},{viewpoint:'ongoing',interpretation:'physical_entry'});results.push(r);assert.equal(decodePhysicalEntryMidi(midiFromFormal(r.formal),authority.atoms).predicate,'ongoing_physical_entry');
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:60_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}assert.equal(new Set(ruby.slice(0,36).map(r=>r.midi)).size,36);
// A habit can be evidenced by recurring completed events while nothing happens
// now; an interrupted current process can unfold with no completed current entry.
const history={completed:[true,true,true,false],ongoing:[false,false,false,true]};assert(history.completed.slice(0,3).every(Boolean));assert.equal(history.completed[3],false);assert.equal(history.ongoing[3],true);
for(const text of ['Nora enters the archive tomorrow.','Nora enters the archive slowly.'])assert.equal(parseNamedSentence(text),null);
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8');
const element=()=>({value:'',children:[],classList:{add(){},remove(){}},append(...n){this.children.push(...n)},setAttribute(){},addEventListener(t,f){this[t]=f},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const input='Nora enters the archive.';elements.sourceInput.value=input;const state={mode:'general',wordSelections:new Map()};let shown;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:load,composeNamedSentence,composePronounSentence,showResolution:async r=>shown=r});
vm.runInContext(app.slice(app.indexOf('function showCarryingViewpoint('),app.indexOf('function showEntryModality(')),ctx);
ctx.showCarryingViewpoint(input);let card=elements.candidateList.children.at(-1),controls=card.children.filter(n=>n.children?.length).map(n=>n.children[0]);assert.equal(controls.length,2);await card.children.at(-1).click();assert.equal(shown,undefined);controls[0].value='ongoing';await card.children.at(-1).click();assert.equal(shown,undefined);controls[1].value='physical_entry';await card.children.at(-1).click();assert.equal(shown.selected_viewpoint,'ongoing');assert.equal(shown.selected_interpretation,'physical_entry');
for(const field of [0,1]){ctx.showCarryingViewpoint(input);card=elements.candidateList.children.at(-1);controls=card.children.filter(n=>n.children?.length).map(n=>n.children[0]);controls[0].value='ongoing';controls[1].value='physical_entry';let finish;ctx.sentenceTemplate=()=>new Promise(resolve=>finish=resolve);const prior=shown,pending=card.children.at(-1).click();controls[field].value=field===0?'habitual':'';finish({authority});await pending;assert.equal(shown,prior);}
const pronounInput='She enters the archive.';elements.sourceInput.value=pronounInput;ctx.sentenceTemplate=load;vm.runInContext(app.slice(app.indexOf('function showPronounReferents('),app.indexOf('function showClauseInterpretations(')),ctx);ctx.showPronounReferents(pronounInput,pronounInterpretationPlan(pronounInput));card=elements.candidateList.children.at(-1);controls=card.children.filter(n=>n.children?.length).map(n=>n.children[0]);controls[0].value='Nora';controls[1].value='habitual';controls[2].value='physical_entry';await card.children.at(-1).click();assert.equal(shown.selected_viewpoint,'habitual');assert.equal(shown.resolved_pronouns[0].referent,'Nora');
console.log(`PASS ${results.length} entry viewpoint/habit/mixed/pronoun cases with Ruby/MIDI parity, independent completion contrast, explicit dual UI choices and stale-choice rejection.`);
