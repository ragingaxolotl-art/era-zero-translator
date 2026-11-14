import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {canonicalDigest,midiFromFormal} from '../pages/engine.mjs';
import {deicticReference,deicticEvent} from '../pages/references.mjs';
import {visemePlanFromFormal} from '../pages/visemes.mjs';
const samples=[];
for(const roles of [['speaker','addressee'],['addressee','speaker']]){
 const ir={ir_version:'1.0',root_clause:'c',speech_act:'assertion',nodes:[{node_id:'c',kind:'clause',clause_type:'predication'},
 {node_id:'p',kind:'lexical_occurrence',target_type:'atom',target_id:'LIF:211',runtime_state:{code:1}},deicticReference(roles[0],'a'),deicticReference(roles[1],'b')],
 edges:[{edge_id:'e0',type:'centers',from:'p',to:'c'},{edge_id:'e1',type:'fills_role',from:'a',to:'p',role:'actor'},{edge_id:'e2',type:'fills_role',from:'b',to:'p',role:'target'}],discourse_constraints:{}};
 const digest=await canonicalDigest(ir);ir.utterance_id=`UTT:${digest.slice(0,24)}`;ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
 const sample=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','ir=JSON.parse(STDIN.read);f=EraZeroRenderer.render(ir);raise "roundtrip" unless EraZeroRenderer.decode(f)==ir;puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(ir),encoding:'utf8'}));
 const events=sample.formal.performance.lexical_events;
 assert.deepEqual(events[0],deicticEvent(ir.nodes[2],'low'));
 assert.deepEqual(events[1],deicticEvent(ir.nodes[3],'high'));
 assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
 const cues=visemePlanFromFormal(sample.formal,{mode:'strict'}).cues.filter(cue=>cue.section==='deictic_reference');
 assert.equal(cues.length,8);assert(cues.every(cue=>cue.nucleus_viseme==='REST'));
 assert(events.slice(0,2).every(event=>event.runtime_tail===undefined&&event.formal_carrier===''));
 samples.push(sample);
}
assert.notEqual(samples[0].midi,samples[1].midi);
assert.throws(()=>deicticReference('she','a'),/Unknown discourse role/);
assert.throws(()=>deicticEvent({...deicticReference('speaker','a'),referent_id:'discourse:addressee'},'low'),/Invalid discourse reference/);
console.log('Discourse references: speaker/addressee anchors retain distinct roles and sound, match Ruby events/MIDI, and use neutral mouth cues without lexical runtime.');
