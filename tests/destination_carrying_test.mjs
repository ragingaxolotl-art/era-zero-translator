import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,composeSentenceSequence} from '../pages/sentences.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeNominalMassRestrictions} from '../pages/reference_property_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const standard={dimension:'mass',threshold:'20',scale:'kilogram'},results=[];
const directed='CMP:763faa4465065477220f6f06',completed='CMP:74d98d19808f74d0b8196951';
const cases=[
 ['Pip carries the heavy box to Ada.','ongoing'],['Pip carries the heavy box to Ada.','bounded'],['Pip carries the heavy box to Ada.','habitual'],
 ['Pip is carrying the box to the gate.'],['Pip carried the box to the gate.'],['Pip habitually carries the box to the gate.'],
 ['Pip did not carry the box to Ada.'],['Did Pip carry the heavy box to Ada?'],['Does Pip habitually carry the box to Ada?'],
 ['Pip carried the box to Ada yesterday.'],['I am carrying the light box to you.'],['The shelf carried the box to the gate.'],
 ['The box carried the shelf to the gate.'],['It is possible that Pip is carrying the box to Ada.'],['Pip was carrying the box to Ada.']
];
for(const state of [0,1,2])for(const [text,viewpoint] of cases){
 const input=text+` [${state}]`,parsed=parseNamedSentence(input);assert(parsed?.requiredDestination,input);
 const options={destination:'spatial',...(viewpoint?{viewpoint}:{}),...(parsed.requiredInterpretation?{interpretation:'mass_standard',standard}:{})};
 await assert.rejects(()=>composeNamedSentence(input,template,{...options,destination:undefined}),e=>e.code==='carrying_destination_required');
 const r=await composeNamedSentence(input,template,options);results.push(r);
 const aspect=viewpoint||parsed.aspect,isCompleted=aspect!=='ongoing';assert.equal(r.target_id,isCompleted?completed:directed);
 const observed=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
 for(const code of [3,4,5,...(isCompleted?[6]:[])])assert(observed.tokens.some(t=>t.marker===`convention_${code}_open`));
 assert.equal(observed.tokens.some(t=>t.root_id==='MOV:110'),isCompleted);
 assert.equal(observed.tokens.find(t=>t.root_id===(isCompleted?'MOV:110':'MOV:111')).runtime_state,state);
 assert(observed.tokens.filter(t=>t.kind==='root'&&t.root_id!==(isCompleted?'MOV:110':'MOV:111')).every(t=>t.runtime_state===null));
 assert(!observed.tokens.some(t=>t.marker==='role_recipient_open'));
 assert(observed.tokens.some(t=>t.marker===`aspect_${aspect}_open`));
 const bindings=r.semantic_ir.nodes.find(n=>n.node_id==='p').compound_bindings;
 const loads=bindings.filter(b=>b.slot_path.at(-1)==='s-load'||b.slot_path.at(-1)==='s-target');assert(loads.length>=3);assert(loads.every(b=>b.argument_id==='b'));
 const destinations=bindings.filter(b=>b.slot_path.at(-1)==='s-destination');assert.equal(destinations.length,isCompleted?2:1);assert(destinations.every(b=>b.argument_id==='d2'));
 const refs=observed.tokens.filter(t=>['phonemic','deictic'].includes(t.kind));
 const goalRefs=refs.filter(t=>t.enclosing_scopes.some(i=>observed.tokens[i].marker==='role_destination_open'));assert.equal(goalRefs.length,isCompleted?2:1);
 if(parsed.requiredInterpretation){const props=decodeNominalMassRestrictions(midiFromFormal(r.formal),authority.atoms).restrictions;assert(props.length);assert(props.every(p=>p.magnitude==='20'));}
}
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:60_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
const bad=[];
for(const suffix of ['s-load','s-destination']){
 const ir=structuredClone(results[1].semantic_ir);ir.nodes.find(n=>n.node_id==='p').compound_bindings.find(b=>b.slot_path.length===1&&b.slot_path[0]===suffix).argument_id='a';bad.push(ir);
 await assert.rejects(()=>renderLexicalOccurrences(ir,authority),/same argument/);
}
const old=await composeNamedSentence('Pip carried the box toward Ada.',template);
assert(!decodeStrictMusicMidi(midiFromFormal(old.formal),authority.atoms).tokens.some(t=>t.root_id==='MOV:110'||t.marker==='convention_5_open'));
for(const [viewpoint,text] of [['ongoing','Pip is carrying the heavy box to Ada.'],['habitual','Pip habitually carries the heavy box to Ada.']]){
 const a=await composeNamedSentence('Pip carries the heavy box to Ada.',template,{viewpoint,destination:'spatial',interpretation:'mass_standard',standard});
 const b=await composeNamedSentence(text,template,{destination:'spatial',interpretation:'mass_standard',standard});assert.deepEqual(a.formal,b.formal);
}
await assert.rejects(()=>composeNamedSentence('Pip carries the heavy box to Ada.',template,{destination:'spatial',interpretation:'mass_standard',standard}),e=>e.code==='carrying_viewpoint_required');
await assert.rejects(()=>composeNamedSentence('Pip carries the heavy box to Ada.',template,{viewpoint:'ongoing',destination:'spatial'}),e=>e.code==='mass_standard_required');
await assert.rejects(()=>composeNamedSentence('Pip is carrying the box to Ada.',template,{destination:'recipient'}),e=>e.code==='carrying_destination_required');
await assert.rejects(()=>composeSentenceSequence('Pip is carrying the box to Ada, then Ben is carrying the shelf.',async()=>template),e=>e.code==='carrying_destination_required');
const controlled=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-e',String.raw`
 m=EraZeroValidation.load_yaml('migrations/destination_carrying_2026_10_28.yaml')
 dictionary=EraZeroValidation.load_yaml('lexicon/compound_dictionary.yaml')['entries']
 old=dictionary.select{|e|m['previous_compound_ids'].include?(e['compound_id'])}
 raise 'Previous compounds changed' unless old.length==37 && EraZeroValidation.fingerprint(old)==m['before_dictionary_fingerprint']
 JSON.parse(STDIN.read).each do |ir|
  begin;EraZeroRenderer.render(ir);raise 'Invalid binding accepted';rescue EraZeroRenderer::RenderError=>e;raise unless e.message.include?('invalid_compound_bindings');end
 end
 compiler=EraZeroControlledEnglish::Compiler.new
 outputs=[]
 ['ongoing destination-directed physical carrying','completed physical carrying to a destination'].each do |label|
  [0,1,2].each do |state|
   input=%Q{ASSERT "#{label}" [#{state}] ROLE source "distinct material object" [0] ROLE target "distinct material object" [1] ROLE actor REF target ROLE destination "distinct material object" [1].}
   result=compiler.compile(input);raise result.inspect unless result['status']=='ok'
   outputs<<EraZeroRenderer.render(result['semantic_ir'])
   raise 'Separate target accepted' unless compiler.compile(input.sub('ROLE actor REF target','ROLE actor "distinct material object" [1]'))['status']=='error'
  end
 end
 entry=dictionary.find{|e|e['compound_id']=='CMP:74d98d19808f74d0b8196951'}
 expanded=EraZeroCompoundExpansion::Expander.new(dictionary).expand(entry['compound_id'],entry['definition_version'])
 # The valid completed definition uses transitive identity through three levels.
 EraZeroCompoundBindingConstraints.unambiguous_role_paths(expanded)
 expanded['binding_constraints'].reject!{|c|c['slot_paths'].include?(['s-destination'])}
 begin;EraZeroCompoundBindingConstraints.unambiguous_role_paths(expanded);raise 'Unlinked duplicate destination accepted';rescue ArgumentError=>e;raise unless e.message.include?('Repeated scoped roles');end
 puts JSON.generate(outputs)
`],{cwd:root,input:JSON.stringify(bad),encoding:'utf8',maxBuffer:15_000_000}));
for(const [i,formal] of controlled.entries()){
 const decoded=decodeStrictMusicMidi(midiFromFormal(formal),authority.atoms),head=i<3?'MOV:111':'MOV:110';
 assert.equal(decoded.tokens.find(t=>t.root_id===head).runtime_state,i%3);
 assert(decoded.tokens.some(t=>t.root_id==='MAT:010'&&t.runtime_state===0));
 assert(decoded.tokens.some(t=>t.root_id==='MAT:010'&&t.runtime_state===1));
}

// Exercise the actual combined choice form, including stale destination choices.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showCarryingViewpoint('),app.indexOf('function showAdjectiveStandard('));
const element=tag=>({tag,value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element(id)]));
const input='Pip carries the heavy box to Ada.';elements.sourceInput.value=input;const state={mode:'english',wordSelections:new Map()};let shown=null;
const ctx=vm.createContext({state,$:id=>elements[id],document:{createElement:element},parseNamedSentence,sentenceTemplate:async()=>template,composeNamedSentence,showResolution:async r=>shown=r});
const show=()=>{vm.runInContext(handler+';showCarryingViewpoint('+JSON.stringify(input)+');',ctx);const card=elements.candidateList.children.at(-1),field=text=>card.children.find(c=>c.textContent===text)?.children[0];return {card,view:field('Carrying meaning'),destination:field('Meaning of to'),threshold:field('Mass threshold'),status:card.children.at(-2),button:card.children.at(-1)};};
let ui=show();assert.equal(ui.view.value,'');assert.equal(ui.destination.value,'');assert.equal(ui.threshold.value,'');
ui.view.value='habitual';ui.threshold.value='20';await ui.button.click();assert.equal(shown,null);assert(ui.status.textContent.includes('spatial'));
ui.destination.value='spatial';await ui.button.click();assert.equal(shown.target_id,completed);assert.equal(shown.selected_destination,'spatial');
ui=show();ui.view.value='ongoing';ui.destination.value='spatial';ui.threshold.value='20';let finish;ctx.sentenceTemplate=()=>new Promise(resolve=>finish=resolve);const pending=ui.button.click();const newer={newer:true};shown=newer;state.resolution=newer;ui.destination.value='';finish(template);await pending;assert.equal(shown,newer);assert.equal(state.resolution,newer);
console.log(`Destination carrying: ${results.length} sentence/runtime variants preserve nested event conventions, load/destination identity, aspect and mass restrictions with Ruby/browser formal/MIDI parity. Missing choices and wrong bindings reject; all prior compounds remain exact.`);
