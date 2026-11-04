import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence,parseFoundationSentence} from '../pages/foundation_sentences.mjs';
import {composeLearnedWhether,parseLearnedWhether} from '../pages/learned_whether.mjs';
import {midiFromKnowledgeAcquisition} from '../pages/knowledge_acquisition_music.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const root=new URL('..',import.meta.url),read=p=>JSON.parse(fs.readFileSync(new URL(p,root))),authority=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>authority.compound_plans[id]?{authority}:{...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority};
const options={allowDraft:true,allowCognitive:true},inverse={allowDraft:true,allowDraftQuestionContent:true,allowDraftAcquisition:true},results=[];
for(const state of [0,1,2])for(const [text,modes] of [
 ['Nora prefers this tea to that tea.',['proximal_nominal','distal_nominal']],
 ['Nora prefers that tea to this tea.',['distal_nominal','proximal_nominal']],
 ['This robot prefers tea to coffee.',['nominal_class','nominal_class']],
 ['That robot prefers the tea to this tea.',['definite_nominal','proximal_nominal']]
]){
 const r=await composeFoundationSentence(text+` [${state}]`,authority,records,load,options);results.push(r);
 const d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,inverse);
 assert.equal(d.meaning.runtime_state,state);assert.deepEqual([d.meaning.arguments.target.reference.reference_mode,d.meaning.arguments.comparison_standard.reference.reference_mode],modes);
 const refs=r.semantic_ir.nodes.filter(n=>n.kind==='phonemic_reference');
 for(const n of refs){if(n.reference_mode==='proximal_nominal')assert(n.referent_id.startsWith('nominal:proximal:'));if(n.reference_mode==='distal_nominal')assert(n.referent_id.startsWith('nominal:distal:'));}
 if(text.startsWith('This'))assert.equal(d.meaning.arguments.experiencer.reference.reference_mode,'proximal_nominal');
 if(text.startsWith('That'))assert.equal(d.meaning.arguments.experiencer.reference.reference_mode,'distal_nominal');
}
for(const state of [0,1,2]){
 const desire=await composeFoundationSentence(`That robot wants to care for this robot [${state}].`,authority,records,load,options);results.push(desire);
 const d=await decodeFoundationSentenceMidi(midiFromFormal(desire.formal),authority.atoms,records,inverse);
 assert.equal(d.meaning.arguments.experiencer.reference.reference_mode,'distal_nominal');
 const inner=d.meaning.arguments.content.proposition;assert.deepEqual(inner.arguments.actor.reference,{kind:'bound',binding:'parent_desire_experiencer'});assert.equal(inner.arguments.target.reference.reference_mode,'proximal_nominal');
 const knowledge=await composeFoundationSentence(`This robot knows whether that robot is conscious [${state}].`,authority,records,load,options);results.push(knowledge);
 const k=await decodeFoundationSentenceMidi(midiFromFormal(knowledge.formal),authority.atoms,records,inverse);assert.equal(k.meaning.arguments.experiencer.reference.reference_mode,'proximal_nominal');assert.equal(k.meaning.arguments.content.proposition.arguments.bearer.reference.reference_mode,'distal_nominal');
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,**o);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))}})"],{cwd:root,input:JSON.stringify({records,irs:results.map(r=>r.semantic_ir)}),encoding:'utf8',maxBuffer:40_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
const forward=await decodeFoundationSentenceMidi(midiFromFormal(results[0].formal),authority.atoms,records,inverse),reverse=await decodeFoundationSentenceMidi(midiFromFormal(results[1].formal),authority.atoms,records,inverse);
assert.deepEqual(forward.meaning.arguments.target.reference.phonemes,forward.meaning.arguments.comparison_standard.reference.phonemes);
assert.notDeepEqual(midiFromFormal(results[0].formal),midiFromFormal(results[1].formal));assert.equal(reverse.meaning.arguments.target.reference.reference_mode,'distal_nominal');
const learning=[];
for(const eventState of [0,1,2])for(const contentState of [0,1,2])for(const negative of [false,true]){
 const input=`This robot ${negative?'did not learn':'learned'} whether that robot was conscious [${contentState}] [${eventState}].`;
 assert(parseLearnedWhether(input));const r=await composeLearnedWhether(input,authority,records,load,{allowDraft:true});
 const bytes=await midiFromKnowledgeAcquisition(r.acquisition,r.result_formal,authority,{allowDraft:true}),d=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,inverse);
 assert.equal(d.meaning.runtime_state,eventState);assert.equal(d.meaning.result.arguments.experiencer.reference.reference_mode,'proximal_nominal');
 const content=d.meaning.result.arguments.content.proposition;assert.equal(content.runtime_state,contentState);assert.equal(content.arguments.bearer.reference.reference_mode,'distal_nominal');
 learning.push({document:r.acquisition,midi:Buffer.from(bytes).toString('base64')});
}
const learnedRuby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_knowledge_acquisition','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroKnowledgeAcquisition.midi(d,allow_draft:true))})"],{cwd:root,input:JSON.stringify(learning.map(r=>r.document)),encoding:'utf8',maxBuffer:40_000_000}));assert.deepEqual(learnedRuby,learning.map(r=>r.midi));
const bound=await composeFoundationSentence('She prefers this tea to that tea.',authority,records,load,{...options,bindings:{ref0:'this robot'}});assert.equal(bound.resolved_pronouns[0].referent,'this robot');
const learnedBound=await composeLearnedWhether('She learned whether he was conscious.',authority,records,load,{allowDraft:true,bindings:{ref0:'this robot',ref1:'that robot'}});assert.equal(learnedBound.resolved_pronouns[0].referent,'this robot');
await assert.rejects(()=>composeFoundationSentence('Nora prefers this tea to that tea.',authority,records,load),/opt-in|draft|unapproved/i);
for(const input of ['This robots prefers tea to coffee.','Nora prefers this robots to that robot.'])await assert.rejects(()=>composeFoundationSentence(input,authority,records,load,options));
assert.equal(parseFoundationSentence('These robots prefer tea to coffee.'),null);
console.log(`PASS ${results.length} cognitive and ${learning.length} acquisition cases with independent demonstrative-mode recovery, preference direction, subject control, runtime separation and Ruby/MIDI parity; noun phonemes and draft admission remain unchanged.`);
