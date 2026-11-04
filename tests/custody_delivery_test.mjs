import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConditional} from '../pages/sentences.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeCustodyDeliveryMidi} from '../pages/delivery_decoder.mjs';
import {decodeDestinationCarryingMidi} from '../pages/carrying_decoder.mjs';
import {decodeCustodyTransferMidi} from '../pages/custody_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const id='CMP:5200738177777915abb3f42e',results=[],standard={dimension:'mass',threshold:'20',scale:'kilogram'};
const cases=[['Pip carries the heavy box to Ada.','bounded'],['Pip carries the heavy box to Ada.','ongoing'],['Pip carries the heavy box to Ada.','habitual'],['Pip carried the box to Ada.'],['Ada carried the box to Pip.'],['I carried the box to you.'],['Pip did not carry the box to Ada.'],['Did Pip carry the light box to Ada?'],['Carry the heavy box to Ada.'],['Do not carry the box to Ada.'],['Pip was carrying the box to Ada.'],['It is possible that Pip is carrying the box to Ada.']];
for(const state of [0,1,2])for(const [text,viewpoint] of cases){
 const input=text+` [${state}]`,parsed=parseNamedSentence(input),options={destination:'custody_delivery',...(viewpoint?{viewpoint}:{}),...(parsed.requiredInterpretation?{interpretation:'mass_standard',standard}:{})};
 const r=await composeNamedSentence(input,template,options);results.push(r);assert.equal(r.target_id,id);assert.equal(r.selected_destination,'custody_delivery');
 const bytes=midiFromFormal(r.formal),d=decodeCustodyDeliveryMidi(bytes,authority.atoms);
 assert.equal(d.runtime_state,state);assert.deepEqual(d.convention_codes,[10,6,5,4,3,9,7,8,7]);
 const command=/^(Carry|Do not carry)/.test(text),negative=/not carry/.test(text),aspect=viewpoint||parsed.aspect;
 assert.equal(d.speech_act,command?'command':text.startsWith('Did ')?'question':'assertion');
 assert.deepEqual(d.scopes,[...(text.startsWith('It is possible')?[{operator:'modality',mode:'possible'}]:[]),...(parsed.speechTime?[{operator:'time',relation:'before_speech'}]:[]),...(negative?[{operator:'negation'}]:[]),...(aspect?[{operator:'aspect',aspect}]:[])]);
 const name=phonemes=>({kind:'phonemic',reference_mode:'name',phonemes,instance_code:null});
 assert.deepEqual(d.participants,{carrier:command?{kind:'deictic',role:'addressee'}:text.startsWith('I ')?{kind:'deictic',role:'speaker'}:name(text.startsWith('Ada ')?['AE','D','AE']:['P','IH','P']),object:{kind:'phonemic',reference_mode:'definite_nominal',phonemes:['B','AA','K','S'],instance_code:null,...(parsed.requiredInterpretation?{property:{dimension:'mass',comparison:parsed.adjective==='heavy'?'greater_than':'less_than',magnitude:'20',unit:'kilogram'}}:{})},recipient:text.includes('to you')?{kind:'deictic',role:'addressee'}:name(text.includes('to Pip')?['P','IH','P']:['AE','D','AE'])});
 assert.deepEqual(d.meaning,{same_object:true,carrier_is_transfer_source:true,destination_referent_is_recipient:true,arrival_culminates_in_transfer:true,same_delivery_event:true,source_custody_before_transfer:true,source_custody_at_culmination:false,recipient_custody_before_transfer:false,recipient_custody_at_culmination:true,ownership_asserted:false,willingness_asserted:false,persistence_after_culmination_asserted:false});
 const roots=decodeStrictMusicMidi(bytes,authority.atoms).tokens.filter(t=>t.kind==='root');assert.equal(roots.at(-1).root_id,'ORI:110');assert.equal(roots.at(-1).runtime_state,state);assert(roots.slice(0,-1).every(t=>t.runtime_state===null));
 assert.throws(()=>decodeDestinationCarryingMidi(bytes,authority.atoms));assert.throws(()=>decodeCustodyTransferMidi(bytes,authority.atoms));
 // The spatial reading of this identical sentence must not acquire a recipient.
 const spatial=await composeNamedSentence(input,template,{...options,destination:'spatial'});assert.throws(()=>decodeCustodyDeliveryMidi(midiFromFormal(spatial.formal),authority.atoms));assert.equal(decodeDestinationCarryingMidi(midiFromFormal(spatial.formal),authority.atoms).meaning.receipt_asserted,false);
}
const ruby=String.raw`puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})`;
const refs=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e',ruby],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:65_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,refs[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(refs[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
for(const path of ['h/q-prior/s-source','h/q-prior/s-target','h/h/q-custody/s-source']){
 const bad=structuredClone(results[0].semantic_ir),bindings=bad.nodes.find(n=>n.target_id===id).compound_bindings,b=bindings.find(b=>b.slot_path.join('/')===path);b.argument_id=b.argument_id==='a'?'d2':'a';await assert.rejects(()=>renderLexicalOccurrences(bad,authority),/same argument|distinct arguments/);
}
// Keep strict musical structure valid while altering the transfer source,
// transferred object or recipient independently of the carrying participants.
for(const suffix of ['q-prior/s-source','q-prior/s-target','h/q-custody/s-source']){
 const f=structuredClone(results[3].formal),event=f.performance.lexical_events.find(e=>e.kind==='phonemic_label'&&e.binding_path.join('/')===`h/${suffix}`);
 assert(event,suffix);const replacement=f.performance.lexical_events.find(e=>e.kind==='phonemic_label'&&e.target_id!==event.target_id);event.address_absolute_midi=replacement.address_relative_semitones.map(n=>n+event.base_midi);
 const bytes=midiFromFormal(f);decodeStrictMusicMidi(bytes,authority.atoms);assert.throws(()=>decodeCustodyDeliveryMidi(bytes,authority.atoms),/custody-delivery/);
}
// Give all three entity participants lexical meanings with independent states.
const lexical=[];
for(const state of [0,1,2]){
 const ir=structuredClone(results[state*cases.length].semantic_ir),p=ir.nodes.find(n=>n.target_id===id);
 const ids=['q-arrival/q-path/q-carry/q-support/s-source','q-arrival/s-load','q-arrival/s-destination'].map(path=>p.compound_bindings.find(b=>b.slot_path.join('/')===path).argument_id);
 ids.forEach((nodeId,i)=>{const index=ir.nodes.findIndex(n=>n.node_id===nodeId);ir.nodes[index]={node_id:nodeId,kind:'lexical_occurrence',target_type:'atom',target_id:['LIF:010','MAT:010','LIF:000'][i],runtime_state:{code:[0,2,1][i]},value_type:'entity'};});
 delete ir.serialization;delete ir.utterance_id;lexical.push(ir);
}
const lr=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e',ruby.replace('f=EraZeroRenderer.render(ir);',"digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']={'content_digest'=>digest};f=EraZeroRenderer.render(ir);")],{cwd:root,input:JSON.stringify(lexical),encoding:'utf8',maxBuffer:8_000_000}));
for(const [state,r] of lr.entries()){assert.deepEqual(await renderLexicalOccurrences(r.formal.semantic_ir,authority),r.formal.performance.lexical_events);const d=decodeCustodyDeliveryMidi(Buffer.from(r.midi,'base64'),authority.atoms);assert.equal(d.runtime_state,state);assert.deepEqual(d.participants,{carrier:{kind:'lexical',root_id:'LIF:010',runtime_state:0},object:{kind:'lexical',root_id:'MAT:010',runtime_state:2},recipient:{kind:'lexical',root_id:'LIF:000',runtime_state:1}});}
for(const rootId of ['MOV:110','MAT:211','ORI:110']){
 const f=structuredClone(results[cases.length].formal),e=f.performance.lexical_events.find(e=>e.target_id===rootId);e.address_absolute_midi=authority.atoms.find(a=>a.canonical_id===({'MOV:110':'MOV:111','MAT:211':'MAT:212','ORI:110':'ORI:111'}[rootId])).note_path_semitones.map(n=>n+e.base_midi);
 const bytes=midiFromFormal(f);decodeStrictMusicMidi(bytes,authority.atoms);assert.throws(()=>decodeCustodyDeliveryMidi(bytes,authority.atoms),/custody-delivery/);
}
const loadTemplate=async id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority};
const conditional=await composeSentenceConditional('If the box is heavy, carry it to Ada.',loadTemplate,[{interpretation:'mass_standard',standard},{destination:'custody_delivery'}]);
assert(conditional.semantic_ir.nodes.some(n=>n.target_id===id));
const cf=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e','puts JSON.generate(EraZeroRenderer.render(JSON.parse(STDIN.read)))'],{cwd:root,input:JSON.stringify(conditional.semantic_ir),encoding:'utf8',maxBuffer:5_000_000}));assert.deepEqual(cf,conditional.formal);
execFileSync('ruby',['-Itools/lib','-rera_zero_validation','-e',String.raw`
 d=EraZeroValidation.load_yaml('lexicon/compound_dictionary.yaml')['entries'];m=EraZeroValidation.load_yaml('migrations/custody_delivery_2026_11_04.yaml');old=d.reject{|e|e['compound_id']==m['added_compound_id']}
 raise 'Prior 42 compounds changed' unless old.length==42 && EraZeroValidation.fingerprint(old)==m['before_dictionary_fingerprint']
`],{cwd:root,encoding:'utf8'});
// Exercise the actual UI handler: choice is explicit, semantic output is delivery.
const app=fs.readFileSync(new URL('pages/app.js',root),'utf8'),handler=app.slice(app.indexOf('function showCarryingViewpoint('),app.indexOf('function showAdjectiveStandard('));
const element=tag=>({tag,value:'',children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},setAttribute(){},addEventListener(type,fn){this[type]=fn},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','results','resolutionPanel','decisionSummary','candidateList','phraseCoverage'].map(id=>[id,element(id)]));
const input='Pip carries the heavy box to Ada.';elements.sourceInput.value=input;const state={mode:'english',wordSelections:new Map()};let shown=null;
const ctx={$:id=>elements[id],state,document:{createElement:element},parseNamedSentence,composeNamedSentence,sentenceTemplate:async()=>template,showResolution:async r=>{shown=r},showError:e=>{throw e},focusOutput(){}};vm.createContext(ctx);vm.runInContext(handler,ctx);ctx.showCarryingViewpoint(input);
const card=elements.candidateList.children.at(-1),labels=card.children.filter(e=>e.tag==='label'),field=text=>labels.find(e=>e.textContent===text).children[0],button=card.children.find(e=>e.tag==='button');
assert.equal(field('Meaning of to').value,'');assert(field('Meaning of to').children.some(e=>e.value==='custody_delivery'));
field('Carrying meaning').value='bounded';field('Meaning of to').value='custody_delivery';field('Mass threshold').value='20';await button.click();assert.equal(shown.target_id,id);assert.equal(decodeCustodyDeliveryMidi(midiFromFormal(shown.formal),authority.atoms).participants.recipient.phonemes.join(' '),'AE D AE');
console.log(`Custody delivery: ${results.length} sentence/state cases with full Ruby/browser parity, independently decoded event linkage, contrasting spatial-only readings, corrupted participant rejection, conditional command and explicit UI selection; all 42 preceding compounds preserved.`);
