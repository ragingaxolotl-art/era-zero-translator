import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {pronounInterpretationPlan,composePronounSentence} from '../pages/pronouns.mjs';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeRunningMidi} from '../pages/running_decoder.mjs';
import {decodePropertyComparisonMidi} from '../pages/property_comparison_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const load=async id=>authority.compound_plans[id]?{authority}:{...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority};
const cases=[
 ['It is brighter than that lamp.',{ref0:'this lamp'},{interpretation:'luminance_comparison'}],
 ['She runs to the gate.',{ref0:'Nora'},{viewpoint:'habitual'}],
 ['He carries it to the gate.',{ref0:'Nora',ref1:'the box'},{viewpoint:'ongoing',destination:'spatial'}],
 ['It is heavy.',{ref0:'the radio'},{interpretation:'mass_standard',standard:{kind:'contextual',dimension:'mass'}}],
 ['It is hot.',{ref0:'the radio'},{interpretation:'thermal_standard',standard:{dimension:'thermodynamic_temperature',threshold:'30',scale:'celsius'}}],
 ['It is rough.',{ref0:'the stone'},{interpretation:'texture_standard',standard:{kind:'contextual',dimension:'surface_texture'}}],
 ['She will care for him tomorrow.',{ref0:'Nora',ref1:'Eli'},{interpretation:'future_assertion'}],
 ['It is not the case that she cared for him yesterday.',{ref0:'Nora',ref1:'Eli'},{}]
];
for(const state of [0,1,2])for(const [input,bindings,options] of cases){
 const text=input+` [${state}]`,plan=pronounInterpretationPlan(text);assert.equal(plan.occurrences.length,Object.keys(bindings).length);
 const r=await composePronounSentence(text,load,bindings,options);results.push(r);
 const direct=await composeNamedSentence(r.resolved_input,await load(parseNamedSentence(r.resolved_input).predicate),options);
 assert.deepEqual(r.formal,direct.formal);assert.deepEqual(midiFromFormal(r.formal),midiFromFormal(direct.formal));
 assert.equal(r.source_input,text);assert.deepEqual(r.resolved_pronouns.map(x=>x.referent),Object.values(bindings));
 if(input.includes('brighter')){const d=decodePropertyComparisonMidi(midiFromFormal(r.formal));assert.equal(d.participants.bearer.reference_mode,'proximal_nominal');assert.equal(d.participants.comparison_standard.reference_mode,'distal_nominal');assert.equal(d.runtime_state,state);}
 if(input.includes('runs')){const d=decodeRunningMidi(midiFromFormal(r.formal),authority.atoms);assert(d.scopes.some(s=>s.operator==='aspect'&&s.aspect==='habitual'));assert.equal(d.runtime_state,state);}
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:40_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
let release;const options={viewpoint:'habitual'},bindings={ref0:'Nora'};
const pending=composePronounSentence('She runs to the gate.',()=>new Promise(resolve=>release=resolve),bindings,options);options.viewpoint='ongoing';bindings.ref0='Eli';release({authority});const frozen=await pending;assert.equal(frozen.selected_viewpoint,'habitual');assert.equal(frozen.resolved_pronouns[0].referent,'Nora');
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showPronounReferents('),app.indexOf('function showClauseInterpretations('));
const element=tag=>({tag,value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element()]));
const input='It is brighter than that lamp.';elements.sourceInput.value=input;const state={mode:'general',wordSelections:new Map()};let shown;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},composePronounSentence,sentenceTemplate:load,showResolution:async r=>shown=r});vm.runInContext(handler,ctx);
ctx.showPronounReferents(input,pronounInterpretationPlan(input));let card=elements.candidateList.children.at(-1);card.children[0].children[0].value='this lamp';await card.children.at(-1).click();assert.equal(shown,undefined);
card.children[1].children[0].value='luminance_comparison';await card.children.at(-1).click();assert.equal(shown.resolved_input,'this lamp is brighter than that lamp.');
for(const changed of ['referent','meaning']){
 ctx.showPronounReferents(input,pronounInterpretationPlan(input));card=elements.candidateList.children.at(-1);const reference=card.children[0].children[0],meaning=card.children[1].children[0];reference.value='this lamp';meaning.value='luminance_comparison';let finish;ctx.sentenceTemplate=()=>new Promise(resolve=>finish=resolve);const old=shown,work=card.children.at(-1).click();if(changed==='referent')reference.value='the lantern';else meaning.value='';finish(await load('MAT:010'));await work;assert.equal(shown,old);
}
console.log(`PASS ${results.length} pronoun-plus-interpretation cases with exact named and Ruby/MIDI parity; option/binding snapshots, dummy-it exclusion and actual UI combined-choice/stale-result checks.`);
