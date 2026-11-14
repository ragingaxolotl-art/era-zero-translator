import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true});
const decode=r=>decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
const music=new Set();
for(const holder of ['I','Nora'])for(const condition of ['conscious','dormant'])for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negative of [false,true]){
 const r=await compose(`${holder} ${holder==='I'?'want':'wants'} to be ${negative?'not ':''}${condition} [${inner}] [${outer}].`);
 const d=await decode(r),content=d.meaning.arguments.content,p=content.proposition;
 assert.equal(content.content_status,'intensional');assert.equal(d.meaning.runtime_state,outer);assert.equal(p.runtime_state,inner);
 assert.equal(p.predicate.root_id,`LIF:0${holder==='I'?'0':'1'}${condition==='conscious'?'1':'2'}`);
 assert.deepEqual(p.scopes,negative?[{operator:'negation'}]:[]);
 assert.deepEqual(p.arguments.bearer.reference,{kind:'bound',binding:'parent_desire_experiencer'});
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};f=EraZeroRenderer.render(x['ir'],**o);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))})"],{cwd:root,input:JSON.stringify({ir:r.semantic_ir,records}),encoding:'utf8'}));
 assert.deepEqual(r.formal,ruby.formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby.midi);music.add(ruby.midi);
}
assert.equal(music.size,72);
for(const [text,id,kind] of [
 ['You want to be conscious.','LIF:011','bound'],
 ['I want Nora to be dormant.','LIF:012','phonemic'],
 ['Nora wants me to be conscious.','LIF:001','deictic'],
 ['Nora wants Nora to be conscious.','LIF:011','phonemic'],
 ['Did I want to be dormant?','LIF:002','bound'],
 ['Nora does not want to be dormant.','LIF:012','bound']
]){
 const d=await decode(await compose(text)),p=d.meaning.arguments.content.proposition;
 assert.equal(p.predicate.root_id,id);assert.equal(p.arguments.bearer.reference.kind,kind);
 if(text.startsWith('Did')){assert.equal(d.speech_act,'question');assert(d.meaning.scopes.some(s=>s.relation==='before_speech'));}
 if(text.includes('does not'))assert.deepEqual(d.meaning.scopes,[{operator:'negation'}]);
}
for(const [text,id] of [['Nora wants that I want to be conscious.','LIF:001'],['I want that Nora wants to be conscious.','LIF:011']]){
 const d=await decode(await compose(text));
 assert.equal(d.meaning.arguments.content.proposition.arguments.content.proposition.predicate.root_id,id);
}
console.log('PASS 72 consciousness/dormancy performances preserve lexical self/other, separate inner/outer runtime states, negation and controlled identity; Ruby parity and MIDI-only inverse verified.');
