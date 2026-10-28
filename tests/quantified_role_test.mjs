import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {registerFor} from '../pages/roles.mjs';
import {canonicalDigest,midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
for(const [role,expected] of [['actor','low'],['target','high'],['environment','sustained_background'],['experiencer','middle']]){
 const ir={ir_version:'1.0',root_clause:'c',speech_act:'assertion',nodes:[{node_id:'c',kind:'clause',clause_type:'predication'},{node_id:'p',kind:'lexical_occurrence',target_type:'atom',target_id:'LIF:211',runtime_state:{code:1}},{node_id:'a',kind:'lexical_occurrence',target_type:'atom',target_id:'LIF:010',runtime_state:{code:1}},{node_id:'q',kind:'scope_operator',operator:'quantifier',quantifier:'exact',value:'3'}],edges:[{edge_id:'e0',type:'centers',from:'p',to:'c'},{edge_id:'e1',type:'scopes',from:'a',to:'q'},{edge_id:'e2',type:'fills_role',from:'q',to:'p',role}],discourse_constraints:{}};
 const digest=await canonicalDigest(ir);ir.utterance_id=`UTT:${digest.slice(0,24)}`;ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
 assert.equal(registerFor('a',ir),expected);assert.equal(registerFor('p',ir),'middle');
 const sample=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(ir),encoding:'utf8'}));
 assert.equal(sample.formal.performance.lexical_events.find(e=>e.occurrence_id==='a').register,expected);
 assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
 const events=scheduledLexicalEvents(sample.formal);
 assert.equal(events[0].marker,'quantifier_exact_open');
 assert.equal(events.at(-1).occurrence_id,'p');
 assert.equal(events.filter(e=>e.occurrence_id==='a').length,1);
 // Scope traversal must terminate even on malformed cyclic input; full validation is separate.
 const cyclic=structuredClone(ir);cyclic.edges.push({edge_id:'cycle',type:'scopes',from:'q',to:'q'});
 assert.equal(registerFor('a',cyclic),expected);
}
console.log('Quantified participants keep actor/target/background/experiencer registers; browser and Ruby agree and scope does not repeat the participant.');
