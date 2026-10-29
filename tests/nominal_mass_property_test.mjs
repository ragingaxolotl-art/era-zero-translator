import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal,canonicalDigest} from '../pages/engine.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {decodeNominalMassRestrictions} from '../pages/reference_property_decoder.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const standard={dimension:'mass',threshold:'20.5',scale:'kilogram'},results=[];
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority};
for(const state of [0,1,2])for(const adjective of ['heavy','light'])for(const text of [
 `Pip is carrying the ${adjective} box toward Ada`,
 `Pip is not carrying the ${adjective} box toward Ada`,
 `The ${adjective} robot is carrying the box`,
 `Carry the ${adjective} box toward the gate`,
 `Is Pip carrying the ${adjective} box?`,
 `The ${adjective} box was damaged yesterday`]){
 const input=text+` [${state}]${text.endsWith('?')?'':'.'}`,parsed=parseNamedSentence(input);assert(parsed,input);
 await assert.rejects(()=>composeNamedSentence(input,load(parsed.predicate)),e=>e.code==='mass_standard_required');
 const result=await composeNamedSentence(input,load(parsed.predicate),{interpretation:'mass_standard',standard});results.push(result);
 const refs=result.semantic_ir.nodes.filter(n=>n.property_restriction);assert.equal(refs.length,1);assert.equal(refs[0].name.normalized_label,parseNamedSentence(input).nominalProperty.participantIndex===0?(text.includes('robot')?'robot':'box'):'box');
 assert.equal(result.semantic_ir.nodes.find(n=>n.node_id==='p').runtime_state.code,state);
 const midi=midiFromFormal(result.formal),decoded=decodeNominalMassRestrictions(midi,authority.atoms);
 assert(decoded.restrictions.length>=1);
 for(const r of decoded.restrictions){assert.equal(r.magnitude,'20.5');assert.equal(r.comparison,adjective==='heavy'?'greater_than':'less_than');assert.deepEqual(r.phonemes,refs[0].name.phonemes);}
 const observed=decodeStrictMusicMidi(midi,authority.atoms);assert.equal(observed.tokens.some(t=>t.marker==='negation_open'),text.includes('not carrying'));
 if(text.startsWith('Pip'))assert(decoded.restrictions.every(r=>r.enclosing_roles.includes('target')||r.enclosing_roles.includes('actor')));
 if(text.includes('toward Ada'))assert(decoded.restrictions.every(r=>!r.enclosing_roles.includes('destination')));
}
const reference=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,reference[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(reference[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
const input='Pip is carrying the heavy box toward Ada.',template=load(parseNamedSentence(input).predicate);
const a=await composeNamedSentence(input,template,{interpretation:'mass_standard',standard});
const b=await composeNamedSentence(input,template,{interpretation:'mass_standard',standard:{...standard,threshold:'20500',scale:'gram'}});assert.deepEqual(a.formal,b.formal);
const c=await composeNamedSentence(input,template,{interpretation:'mass_standard',standard:{...standard,threshold:'25'}});assert.notDeepEqual(midiFromFormal(a.formal),midiFromFormal(c.formal));
const transposed=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','ir=JSON.parse(STDIN.read);puts JSON.generate([48,72].map{|anchor|Base64.strict_encode64(EraZeroPresentation.midi(EraZeroRenderer.render(ir,anchor_midi:anchor)))})'],{cwd:root,input:JSON.stringify(a.semantic_ir),encoding:'utf8'}));
for(const midi of transposed)assert.deepEqual(decodeNominalMassRestrictions(Buffer.from(midi,'base64'),authority.atoms),decodeNominalMassRestrictions(midiFromFormal(a.formal),authority.atoms));
for(const input of ['Pip carries the heavy box to Ada.','Pip is carrying the heavy box to Ada.','Pip is carrying the heavy box toward the light robot.','The heavy box is carrying the box.','Pip is carrying the very heavy box.','Pip is carrying the heavy box tomorrow.'])assert.equal(parseNamedSentence(input),null,input);
const invalids=[];
for(const change of [p=>p.dimension='effort',p=>p.unit='gram',p=>p.magnitude='-1',p=>p.magnitude='20.0',p=>p.comparison='equal',p=>p.runtime_state=2]){
 const ir=structuredClone(a.semantic_ir);change(ir.nodes.find(n=>n.property_restriction).property_restriction);invalids.push(ir);
 await assert.rejects(()=>renderLexicalOccurrences(ir,authority),/property restriction/);
}
for(const ir of invalids){delete ir.utterance_id;delete ir.serialization;const digest=await canonicalDigest(ir);ir.utterance_id=`UTT:${digest.slice(0,24)}`;ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};}
const errors=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_semantic_validation','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|EraZeroSemanticValidation.validate(ir)})'],{cwd:root,input:JSON.stringify(invalids),encoding:'utf8'}));
assert(errors.every(e=>e.includes('invalid_nominal_property')));
const quoted='Pip is carrying "The heavy box".';
assert.equal(parseNamedSentence(quoted).requiredInterpretation,undefined);
const quotedResult=await composeNamedSentence(quoted,template);
assert.equal(quotedResult.semantic_ir.nodes.some(n=>n.property_restriction),false);
assert.equal(decodeNominalMassRestrictions(midiFromFormal(quotedResult.formal),authority.atoms).restrictions.length,0);
// Exercise the actual browser selection handler, not a parallel UI model.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8');
const handler=app.slice(app.indexOf('function showAdjectiveStandard('),app.indexOf('function showFutureInterpretation('));
const element=()=>({value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},scrollIntoView(){},addEventListener(type,fn){this[type]=fn}});
const elements=Object.fromEntries(['sourceInput','output','phraseCoverage','resolutionPanel','results','candidateList','decisionSummary'].map(id=>[id,element()]));elements.sourceInput.value=input;
let shown=null;const ctx=vm.createContext({state:{mode:'english',wordSelections:new Map()},$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:async id=>load(id),composeNamedSentence,showResolution:async r=>shown=r,toast(){}});
vm.runInContext(handler+';showAdjectiveStandard('+JSON.stringify(input)+');',ctx);
const card=elements.candidateList.children[0],threshold=card.children[1].children[0],button=card.children[4];
assert.equal(threshold.value,'');assert.equal(shown,null);threshold.value='20.5';await button.click();
assert.equal(shown.semantic_ir.nodes.find(n=>n.property_restriction).name.normalized_label,'box');
assert.equal(shown.selected_standard.threshold,'20.5');
console.log(`Nominal mass restrictions: ${results.length} adjective/participant/negation/question/command/past/runtime cases match Ruby formal and MIDI. Independent performance decoding retains the restriction on its noun; equivalent units match, different thresholds differ, and unsupported senses/frames remain incomplete.`);
