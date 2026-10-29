import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,composeSentenceSequence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=async id=>authority.compound_plans[id]?.required_roles.length?{authority}:JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const results=[];
for(const state of [0,1,2])for(const sentence of ['Nora will care for Eli tomorrow','Nora will not care for Eli tomorrow','Ada will be carrying the box tomorrow']){
 const input=`${sentence} [${state}].`,parsed=parseNamedSentence(input),template=await load(parsed.predicate);
 assert.equal(parsed.requiredInterpretation,'future_assertion');
 await assert.rejects(()=>composeNamedSentence(input,template),e=>e.code==='future_interpretation_required');
 for(const interpretation of ['promise','intention','willingness'])await assert.rejects(()=>composeNamedSentence(input,template,{interpretation}),/not available/);
 const r=await composeNamedSentence(input,template,{interpretation:'future_assertion'});results.push(r);
 assert.equal(r.selected_interpretation,'future_assertion');
 assert.equal(r.semantic_ir.nodes.find(n=>n.kind==='time_anchor').day_offset,'1');
 assert.equal(r.semantic_ir.nodes.find(n=>n.node_id==='p').runtime_state.code,state);
 const decoded=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
 assert(decoded.tokens.some(t=>t.marker==='time_next_day_open'));
 assert.equal(decoded.tokens.find(t=>t.root_id===(sentence.includes('carrying')?'MOV:121':'LIF:211')).runtime_state,state);
 assert(!r.semantic_ir.nodes.some(n=>n.operator==='modality'));
}
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:8_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
await assert.rejects(()=>composeSentenceSequence('Nora will care for Eli tomorrow, then Ada is conscious.',load),e=>e.code==='future_interpretation_required');
// Exercise the actual UI handler with a small DOM boundary, including stale input.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8');
const handler=app.slice(app.indexOf('function showFutureInterpretation('),app.indexOf('function showAnalysis('));
const element=()=>({children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const input='Nora will care for Eli tomorrow.';elements.sourceInput.value=input;
let calls=0,shown=null;
const state={mode:'english',resolution:{old:true},wordSelections:new Map()};
const context=vm.createContext({state,escapeHtml:value=>String(value),$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:load,composeNamedSentence:async(...args)=>{calls++;return composeNamedSentence(...args)},showResolution:async r=>shown=r,showError:e=>{throw e},toast:()=>{}});
vm.runInContext(handler+';showFutureInterpretation('+JSON.stringify(input)+');',context);
assert.equal(state.resolution,null);assert.equal(calls,0);
const button=elements.candidateList.children[0].children[1];
elements.sourceInput.value='Changed';await button.click();assert.equal(calls,0);
elements.sourceInput.value=input;await button.click();assert.equal(calls,1);assert.equal(shown.selected_interpretation,'future_assertion');
assert(app.includes('if(parseNamedSentence(input)?.requiredInterpretation){showFutureInterpretation(input);return}'));
for(const outcome of ['success','failure']){
 vm.runInContext('showFutureInterpretation('+JSON.stringify(input)+');',context);
 const oldCard=elements.candidateList.children.at(-1),oldButton=oldCard.children[1];
 let complete;context.sentenceTemplate=()=>new Promise((resolve,reject)=>{complete=outcome==='success'?resolve:reject});
 const pending=oldButton.click();oldCard.isConnected=false;
 const newer={newer:true};state.resolution=newer;shown=newer;
 complete(outcome==='success'?await load('LIF:211'):new Error('Late request failed'));
 await pending;assert(state.resolution===newer);assert(shown===newer);
}

state.resolution={old:true};state.selected={old:true};state.phraseNames=['old'];
vm.runInContext(app.split('\n').find(line=>line.startsWith('function showError('))+";showError({code:'future_interpretation_required',message:'Choose an interpretation.'});",context);
assert.equal(state.resolution,null);assert.equal(state.selected,null);assert.equal(state.phraseNames.length,0);
assert.equal(elements.decisionSummary.textContent,'Nothing was translated.');
console.log('Future interpretation: 9 state/negation/bound-compound cases require explicit selection, then preserve tomorrow and runtime independently with reference/MIDI parity. UI does not compose before selection and rejects stale input; unresolved clause groups produce no partial translation.');
