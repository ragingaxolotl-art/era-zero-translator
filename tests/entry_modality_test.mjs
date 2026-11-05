import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,clauseInterpretationPlan,composeSentenceConjunction} from '../pages/sentences.mjs';
import {entryModalChoices} from '../pages/entry_modality.mjs';
import {composePronounSentence,pronounInterpretationPlan} from '../pages/pronouns.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodePhysicalEntryMidi} from '../pages/physical_entry_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),load=async()=>({authority}),results=[];
const neg={operator:'negation'},possible={operator:'modality',mode:'possible'},permitted={operator:'modality',mode:'permitted'};
const expected={entry_possible:[possible],entry_permitted:[permitted],entry_possible_not:[possible,neg],entry_not_permitted:[neg,permitted],entry_permitted_not:[permitted,neg]};
for(const ongoing of [false,true])for(const state of [0,1,2])for(const negative of [false,true])for(const [choice] of entryModalChoices(negative))for(const question of [false,true]){
 const text=`${question?'May Nora':'Nora may'} ${negative?'not ':''}${ongoing?'be entering':'enter'} the archive [${state}]${question?'?':'.'}`;
 await assert.rejects(()=>composeNamedSentence(text,{authority}),e=>e.code==='entry_modality_required');
 const r=await composeNamedSentence(text,{authority},{interpretation:choice});results.push(r);
 const d=decodePhysicalEntryMidi(midiFromFormal(r.formal),authority.atoms);assert.deepEqual(d.scopes,expected[choice]);assert.equal(d.runtime_state,state);assert.equal(d.speech_act,question?'question':'assertion');assert.equal(d.predicate,ongoing?'ongoing_physical_entry':'completed_physical_entry');assert.equal(d.phases.culmination,ongoing?'not_asserted':'interior');
 assert(!r.semantic_ir.nodes.some(n=>n.entryModal));assert(!r.semantic_ir.edges.some(e=>e.type==='time_relation'));
}
for(const state of [0,1,2])for(const [text,choice,scopes] of [
 ['Nora is permitted to enter the archive','physical_entry',[permitted]],
 ['Nora is not permitted to enter the archive','physical_entry',[neg,permitted]],
 ['Nora is permitted not to enter the archive','physical_entry',[permitted,neg]],
 ['Nora is permitted to not enter the archive','physical_entry',[permitted,neg]],
 ['Nora is permitted to physically enter the archive',undefined,[permitted]],
 ['Nora is permitted to be entering the archive','physical_entry',[permitted]],
 ['Nora is not permitted to be entering the archive','physical_entry',[neg,permitted]],
 ['Nora is permitted not to be physically entering the archive',undefined,[permitted,neg]],
 ['It is possible that Nora may enter the archive','entry_permitted',[possible,permitted]],
 ['It is not the case that Nora may not enter the archive','entry_permitted_not',[neg,permitted,neg]]
]){
 const r=await composeNamedSentence(`${text} [${state}].`,{authority},choice?{interpretation:choice}:{});results.push(r);assert.deepEqual(decodePhysicalEntryMidi(midiFromFormal(r.formal),authority.atoms).scopes,scopes);
}
for(const [text,choice] of [['Nora may enter the archive.','entry_not_permitted'],['Nora may not enter the archive.','entry_permitted'],['Nora may enter the archive.','physical_entry']])await assert.rejects(()=>composeNamedSentence(text,{authority},{interpretation:choice}),e=>e.code==='entry_modality_required');
for(const text of ['Nora may enter the archive tomorrow.','Nora is permitted by Eli to enter the archive.','Nora may have entered the archive.','With 50% confidence, Nora may enter the archive.'])assert.equal(parseNamedSentence(text),null);
for(const state of [0,1,2]){
 const r=await composeSentenceConjunction(`Nora may enter the archive [${state}] and Eli may not enter the room [${(state+1)%3}].`,load,[{interpretation:'entry_possible'},{interpretation:'entry_not_permitted'}]);results.push(r);
 const pronoun=await composePronounSentence(`She may not enter the archive [${state}].`,load,{ref0:'Nora'},{interpretation:'entry_permitted_not'});results.push(pronoun);
 assert.deepEqual(decodePhysicalEntryMidi(midiFromFormal(pronoun.formal),authority.atoms).scopes,[permitted,neg]);
}
for(const [choice,explicit] of [['entry_permitted','Nora is permitted to enter the archive.'],['entry_not_permitted','Nora is not permitted to enter the archive.'],['entry_permitted_not','Nora is permitted not to enter the archive.']]){
 const implicit=await composeNamedSentence(`Nora may ${choice==='entry_permitted'?'':'not '}enter the archive.`,{authority},{interpretation:choice});
 const unambiguous=await composeNamedSentence(explicit,{authority},{interpretation:'physical_entry'});assert.deepEqual(implicit.formal,unambiguous.formal);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:60_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.slice(0,60).map(r=>r.midi)).size,60);
// A possible ongoing prefix need not have any completed-entry continuation in
// the relevant alternatives. Possible(progress) is not possible(completion).
const alternatives=[{ongoing:true,completed:false}];
assert(alternatives.some(w=>w.ongoing));assert(!alternatives.some(w=>w.completed));
// Independently specified permission/epistemic alternatives. Neither implies
// occurrence, and permission to abstain is not prohibition of the action.
function evaluate(scopes,model,entry=true){if(!scopes.length)return entry;const [s,...rest]=scopes;if(s.operator==='negation')return !evaluate(rest,model,entry);return model[s.mode].some(value=>evaluate(rest,model,value));}
const optional={permitted:[true,false],possible:[true],occurred:false};
assert.equal(evaluate(expected.entry_permitted_not,optional),true);assert.equal(evaluate(expected.entry_not_permitted,optional),false);
assert.equal(evaluate(expected.entry_possible_not,optional),false);
for(const model of [{permitted:[false],possible:[true]},{permitted:[true],possible:[false]}])assert.notEqual(evaluate(expected.entry_possible,model),evaluate(expected.entry_permitted,model));
assert.equal(evaluate(expected.entry_permitted,optional),true);assert.equal(optional.occurred,false);
// Direct UI requires a choice and snapshots it while a template loads.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8');
const element=()=>({value:'',children:[],classList:{add(){},remove(){}},append(...n){this.children.push(...n)},setAttribute(){},addEventListener(t,f){this[t]=f},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const input='Nora may enter the archive.';elements.sourceInput.value=input;const state={mode:'general',wordSelections:new Map()};let shown;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},entryModalChoices,parseNamedSentence,sentenceTemplate:load,composeNamedSentence,showResolution:async r=>shown=r});
vm.runInContext(app.slice(app.indexOf('function showEntryModality('),app.indexOf('function showPhysicalEntry(')),ctx);ctx.showEntryModality(input);let card=elements.candidateList.children.at(-1);await card.children.at(-1).click();assert.equal(shown,undefined);card.children[1].value='entry_permitted';await card.children.at(-1).click();assert.equal(shown.selected_interpretation,'entry_permitted');
for(const change of ['input','choice','detached']){elements.sourceInput.value=input;ctx.showEntryModality(input);card=elements.candidateList.children.at(-1);card.children[1].value='entry_permitted';let finish;ctx.sentenceTemplate=()=>new Promise(resolve=>finish=resolve);const previous=shown,pending=card.children.at(-1).click();if(change==='input')elements.sourceInput.value='Changed';else if(change==='choice')card.children[1].value='entry_possible';else card.isConnected=false;finish({authority});await pending;assert.equal(shown,previous);}
// Combined clause and pronoun flows preserve the chosen modal scope too.
const groupInput='Nora may enter the archive and Eli may not enter the room.';elements.sourceInput.value=groupInput;ctx.sentenceTemplate=load;ctx.composeSentenceConjunction=composeSentenceConjunction;
ctx.composeSentenceSequence=ctx.composeSentenceConditional=ctx.composeSentenceDisjunction=()=>{throw new Error('Unexpected group type');};
vm.runInContext(app.slice(app.indexOf('function showClauseInterpretations('),app.indexOf('function showCarryingViewpoint(')),ctx);ctx.showClauseInterpretations(groupInput,clauseInterpretationPlan(groupInput));
const group=elements.candidateList.children.at(-1),choices=group.children.slice(0,2).map(s=>s.children[1].children[0]);choices[0].value='entry_possible';choices[1].value='entry_not_permitted';await group.children.at(-1).click();assert.deepEqual(Array.from(shown.selected_clauses,c=>c.options.interpretation),['entry_possible','entry_not_permitted']);
const pronounInput='She may not enter the archive.';elements.sourceInput.value=pronounInput;ctx.composePronounSentence=composePronounSentence;
vm.runInContext(app.slice(app.indexOf('function showPronounReferents('),app.indexOf('function showClauseInterpretations(')),ctx);ctx.showPronounReferents(pronounInput,pronounInterpretationPlan(pronounInput));
card=elements.candidateList.children.at(-1);const controls=card.children.filter(n=>n.children?.length).map(n=>n.children[0]);controls[0].value='Nora';controls[1].value='entry_permitted_not';await card.children.at(-1).click();assert.equal(shown.selected_interpretation,'entry_permitted_not');assert.deepEqual(decodePhysicalEntryMidi(midiFromFormal(shown.formal),authority.atoms).scopes,[permitted,neg]);
console.log(`PASS ${results.length} modal entry cases: Ruby/MIDI parity, independently recovered modal/negative scopes, semantic countermodels and direct/group/pronoun UI choices.`);

const ongoingInput='Nora may be entering the archive.';elements.sourceInput.value=ongoingInput;ctx.sentenceTemplate=load;ctx.showEntryModality(ongoingInput);card=elements.candidateList.children.at(-1);
assert(card.children[1].children.some(option=>option.textContent==='Physical entry may be in progress'));
card.children[1].value='entry_possible';await card.children.at(-1).click();
const ongoingDecoded=decodePhysicalEntryMidi(midiFromFormal(shown.formal),authority.atoms);assert.equal(ongoingDecoded.predicate,'ongoing_physical_entry');assert.equal(ongoingDecoded.phases.culmination,'not_asserted');assert.deepEqual(ongoingDecoded.scopes,[possible]);
console.log('PASS ongoing-modal UI uses progress-specific wording and retains the unasserted culmination.');
