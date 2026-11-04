import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConjunction,clauseInterpretationPlan} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {composePronounSentence,pronounInterpretationPlan} from '../pages/pronouns.mjs';
import {decodePhysicalEntryMidi} from '../pages/physical_entry_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const option={interpretation:'physical_entry'},time=relation=>({operator:'time',relation}),neg={operator:'negation'},possible={operator:'modality',mode:'possible'};
for(const state of [0,1,2])for(const [input,scopes,act] of [
 ['Nora entered the archive',[time('before_speech')],'assertion'],
 ['Nora did not enter the archive',[time('before_speech'),neg],'assertion'],
 ['Nora entered the archive yesterday',[time('previous_day')],'assertion'],
 ['Did Nora enter the archive',[time('before_speech')],'question'],
 ['Did Nora not enter the archive',[time('before_speech'),neg],'question'],
 ['It is possible that Nora entered the archive',[possible,time('before_speech')],'assertion'],
 ['It is not the case that Nora entered the archive',[neg,time('before_speech')],'assertion'],
 ['Enter the archive',[],'command'],
 ['Do not enter the archive',[neg],'command']
]){
 const text=`${input} [${state}]${act==='question'?'?':'.'}`;
 await assert.rejects(()=>composeNamedSentence(text,{authority}),e=>e.code==='physical_entry_required');
 const r=await composeNamedSentence(text,{authority},option);results.push(r);
 const d=decodePhysicalEntryMidi(midiFromFormal(r.formal),authority.atoms);
 assert.equal(d.runtime_state,state);assert.deepEqual(d.scopes,scopes);assert.equal(d.speech_act,act);
 assert.deepEqual(d.phases,{before:'exterior',culmination:'interior',after:'unspecified'});
 if(act==='command')assert.deepEqual(d.actor,{kind:'deictic',role:'addressee'});else assert.deepEqual(d.actor.phonemes,['N','AO','R','AE']);
 assert.equal(d.region.reference_mode,'definite_nominal');
}
for(const text of ['Nora didn’t enter the archive.','Nora physically entered this archive.','Did Nora physically enter that archive?']){
 const r=await composeNamedSentence(text,{authority},parseNamedSentence(text).requiredInterpretation?option:{});results.push(r);decodePhysicalEntryMidi(midiFromFormal(r.formal),authority.atoms);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:30_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.slice(0,27).map(r=>r.midi)).size,27);
const inside=await composeNamedSentence('Nora is inside the archive.',{authority});assert.throws(()=>decodePhysicalEntryMidi(midiFromFormal(inside.formal),authority.atoms));
for(const text of ['Nora is entering the archive.','Nora entered the archive slowly.'])assert.equal(parseNamedSentence(text),null);
for(const text of ['Nora entered the competition.','Enter the data.'])await assert.rejects(()=>composeNamedSentence(text,{authority}),e=>e.code==='physical_entry_required');
// Inconsistent phase bindings must fail both renderers, even with valid references.
const invalid=[];
for(const slot of ['s-bearer','s-region']){
 const ir=structuredClone(results[0].semantic_ir),node=ir.nodes.find(n=>n.compound_bindings),binding=node.compound_bindings.find(b=>b.slot_path.join('/')===`q-1-after/${slot}`),other=node.compound_bindings.find(b=>b.slot_path.join('/')===`q-1-after/${slot==='s-bearer'?'s-region':'s-bearer'}`);
 binding.argument_id=other.argument_id;invalid.push(ir);await assert.rejects(()=>renderLexicalOccurrences(ir,authority),/binding|argument/i);
}
execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e',String.raw`
 JSON.parse(STDIN.read).each{|ir|begin;EraZeroRenderer.render(ir);raise 'Accepted mismatched entry phases';rescue EraZeroRenderer::RenderError => e;raise unless e.message.include?('invalid_compound_bindings');end}
 v=EraZeroValidation;m=v.load_yaml('migrations/physical_entry_2026_11_04.yaml');d=v.load_yaml('lexicon/compound_dictionary.yaml')['entries'];old=d.select{|e|m['previous_compound_ids'].include?(e['compound_id'])}
 raise 'Prior meanings changed' unless old.length==61 && v.fingerprint(old)==m['before_dictionary_fingerprint']
`],{cwd:root,input:JSON.stringify(invalid),encoding:'utf8'});
// Splice a valid differently bound name into just the culmination phase of MIDI.
// The inverse has no IR or English to consult and must catch the inconsistency.
for(const [text,slot] of [['Eli physically entered the archive.','s-bearer'],['Nora physically entered the room.','s-region']]){
 const alternate=await composeNamedSentence(text,{authority}),base=await composeNamedSentence('Nora physically entered the archive.',{authority});
 const select=e=>e.kind==='phonemic_label'&&e.binding_path?.includes('q-1-after')&&e.binding_path.at(-1)===slot;
 const index=base.formal.performance.lexical_events.findIndex(select);assert(index>=0);
 base.formal.performance.lexical_events[index]=alternate.formal.performance.lexical_events.find(select);
 assert.throws(()=>decodePhysicalEntryMidi(midiFromFormal(base.formal),authority.atoms),/entry/);
}
// Independent event model: endpoint location alone cannot establish entry.
const entered=e=>e.before==='exterior'&&e.culmination==='interior'&&e.displacement&&e.crossed&&e.sameActor&&e.sameRegion&&e.sameCriterion&&e.sameEvent;
const entry={before:'exterior',culmination:'interior',displacement:true,crossed:true,sameActor:true,sameRegion:true,sameCriterion:true,sameEvent:true,after:'exterior'};
assert.equal(entered(entry),true); // Later exit does not undo historical entry.
for(const change of [{before:'interior'},{culmination:'boundary'},{displacement:false},{crossed:false},{sameActor:false},{sameRegion:false},{sameCriterion:false},{sameEvent:false}])assert.equal(entered({...entry,...change}),false);
// Actual direct UI handler: no default inference; stale asynchronous results discarded.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showPhysicalEntry('),app.indexOf('function showBrightnessComparison('));
const element=()=>({value:'',children:[],classList:{add(){},remove(){}},append(...n){this.children.push(...n)},setAttribute(){},addEventListener(t,f){this[t]=f},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const input='Nora entered the archive.';elements.sourceInput.value=input;const state={mode:'general',wordSelections:new Map()};let shown;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:async()=>({authority}),composeNamedSentence,showResolution:async r=>shown=r});
vm.runInContext(handler,ctx);ctx.showPhysicalEntry(input);assert.equal(shown,undefined);let card=elements.candidateList.children.at(-1);assert.equal(card.children.at(-1).textContent,'Use physical entry');await card.children.at(-1).click();assert.equal(shown.selected_interpretation,'physical_entry');
for(const change of ['input','detached']){ctx.showPhysicalEntry(input);card=elements.candidateList.children.at(-1);let finish;ctx.sentenceTemplate=()=>new Promise(resolve=>finish=resolve);const previous=shown,pending=card.children.at(-1).click();if(change==='input')elements.sourceInput.value='Changed';else card.isConnected=false;finish({authority});await pending;assert.equal(shown,previous);elements.sourceInput.value=input;}
console.log(`PASS ${results.length} entry cases with Ruby/MIDI parity, independent phase/identity/runtime/scope recovery, binding rejection, event countermodels and explicit UI sense choice.`);

const groupInput='Nora entered the archive and Eli entered the room.';
elements.sourceInput.value=groupInput;ctx.sentenceTemplate=async()=>({authority});ctx.composeSentenceConjunction=composeSentenceConjunction;
ctx.composeSentenceSequence=ctx.composeSentenceConditional=ctx.composeSentenceDisjunction=()=>{throw new Error('Unexpected group type');};
vm.runInContext(app.slice(app.indexOf('function showClauseInterpretations('),app.indexOf('function showCarryingViewpoint(')),ctx);
ctx.showClauseInterpretations(groupInput,clauseInterpretationPlan(groupInput));
const group=elements.candidateList.children.at(-1),choices=group.children.slice(0,2).map(section=>section.children[1].children[0]),previous=shown;
await group.children.at(-1).click();assert.equal(shown,previous);
choices.forEach(c=>c.value='physical_entry');await group.children.at(-1).click();assert.equal(shown.selected_clauses.length,2);
assert(shown.selected_clauses.every(c=>c.options.interpretation==='physical_entry'));
const pronounInput='She entered the archive.';elements.sourceInput.value=pronounInput;ctx.composePronounSentence=composePronounSentence;
vm.runInContext(app.slice(app.indexOf('function showPronounReferents('),app.indexOf('function showClauseInterpretations(')),ctx);
ctx.showPronounReferents(pronounInput,pronounInterpretationPlan(pronounInput));
const pronounCard=elements.candidateList.children.at(-1),controls=pronounCard.children.filter(n=>n.children?.length).map(n=>n.children[0]);
controls[0].value='Nora';const previousPronoun=shown;await pronounCard.children.at(-1).click();assert.equal(shown,previousPronoun);
controls[1].value='physical_entry';await pronounCard.children.at(-1).click();assert.equal(shown.selected_interpretation,'physical_entry');assert.equal(shown.resolved_pronouns[0].referent,'Nora');
console.log('PASS entry sense selection in actual multi-clause and pronoun UI handlers.');
