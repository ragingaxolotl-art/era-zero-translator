import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationMusicMidi} from '../pages/foundation_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const records=JSON.parse(fs.readFileSync(new URL('../reviews/foundation_extension_candidates.json',import.meta.url))).records;
const ref=(id,role)=>({node_id:id,kind:'deictic_reference',value_type:'entity',deictic_role:role,referent_id:`discourse:${role}`});
const edge=(from,to,role)=>({edge_id:`${from}-${to}`,type:'fills_role',from,to,role});
const ir={root_clause:'main',nodes:[{node_id:'main',kind:'clause'},{node_id:'want',kind:'lexical_occurrence',target_type:'foundation',target_id:records[0].foundation_id,foundation_version:'1.0.0',runtime_state:{code:1}},ref('holder','speaker'),{node_id:'desired',kind:'clause',clause_type:'content',content_status:'intensional',value_type:'proposition'},{node_id:'care',kind:'lexical_occurrence',target_type:'atom',target_id:'LIF:211',runtime_state:{code:1}},ref('carer','addressee'),ref('cared-for','speaker')],edges:[{edge_id:'center',type:'centers',from:'want',to:'main'},edge('holder','want','experiencer'),edge('desired','want','content'),{edge_id:'content-center',type:'centers',from:'care',to:'desired'},edge('carer','care','actor'),edge('cared-for','care','target')]};
await assert.rejects(renderLexicalOccurrences(ir,authority));
const sounds=new Set();let cases=0;
for(const state of [0,1,2])for(const inner of [0,1,2]){
 const input=structuredClone(ir);input.nodes[1].runtime_state.code=state;input.nodes[4].runtime_state.code=inner;
 const events=await renderLexicalOccurrences(input,authority,{foundationRecords:records,allowDraftFoundations:true});
 // A candidate scheduled sentence probe, not yet a reference-renderer-validated EZF artifact.
 const probe={semantic_ir:input,performance:{anchor_midi:60,lexical_events:events,contour_relative_semitones:[0,0]}};
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-e','puts JSON.generate(EraZeroPresentation.scheduled_lexical_events(JSON.parse(STDIN.read)))'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(probe),encoding:'utf8'}));
 assert.deepEqual(scheduledLexicalEvents(probe),ruby);
 const bytes=midiFromFormal(probe);
 sounds.add(Buffer.from(bytes).toString('base64'));
 const observed=await decodeFoundationMusicMidi(bytes,authority.atoms,records,{allowDraft:true});
 const outer=observed.tokens.find(t=>t.kind==='foundation'),care=observed.tokens.find(t=>t.root_id==='LIF:211');
 assert.equal(outer.runtime_state,state);assert.equal(care.runtime_state,inner);
 const opening=observed.tokens.findIndex(t=>t.marker==='proposition_content_open');
 const closing=observed.tokens[opening].closing_token;
 assert(opening>=0&&closing>opening);
 assert(observed.tokens.indexOf(care)>opening&&observed.tokens.indexOf(care)<closing);
 assert(!(observed.tokens.indexOf(outer)>opening&&observed.tokens.indexOf(outer)<closing));
 assert(observed.tokens.some(t=>t.marker==='role_experiencer_open'));
 assert(observed.tokens.some(t=>t.marker==='role_content_open'));
 cases++;
}
assert.equal(sounds.size,9);
console.log(`PASS ${cases} candidate sentence musical scopes: desire and embedded care retain independent 0/1/2 endings.`);
