import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeSpatialRelationMidi} from '../pages/spatial_relation_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
for(const state of [0,1,2])for(const [phrase,relation] of [['inside','interior'],['outside','exterior'],['on the boundary of','boundary_intersection']])for(const [input,scopes,act] of [
 [`Nora is ${phrase} the archive`,[],'assertion'],
 [`Nora is not ${phrase} the archive`,[{operator:'negation'}],'assertion'],
 [`It is possible that Nora is ${phrase} the archive`,[{operator:'modality',mode:'possible'}],'assertion'],
 [`Is Nora ${phrase} the archive`,[],'question']
]){
 const r=await composeNamedSentence(`${input} [${state}]${act==='question'?'?':'.'}`,{authority});results.push(r);
 const d=decodeSpatialRelationMidi(midiFromFormal(r.formal),authority.atoms);
 assert.equal(d.relation,relation);assert.equal(d.runtime_state,state);assert.deepEqual(d.scopes,scopes);assert.equal(d.speech_act,act);
 assert.deepEqual(d.bearer.phonemes,['N','AO','R','AE']);assert.equal(d.region.reference_mode,'definite_nominal');
}
for(const input of ['The box is inside this room.','I am outside that room.','The archive is inside the box.']){
 const r=await composeNamedSentence(input,{authority});results.push(r);decodeSpatialRelationMidi(midiFromFormal(r.formal),authority.atoms);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:30_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
for(const input of ['Nora entered the archive.','Nora may enter the archive.','Nora is inside the archive with Eli.'])assert.equal(parseNamedSentence(input),null);
const reversed=await composeNamedSentence('The archive is inside Nora.',{authority});
const forward=decodeSpatialRelationMidi(midiFromFormal(results[0].formal),authority.atoms);
const backward=decodeSpatialRelationMidi(midiFromFormal(reversed.formal),authority.atoms);
assert.deepEqual(forward.bearer.phonemes,backward.region.phonemes);
assert.deepEqual(forward.region.phonemes,backward.bearer.phonemes);
const unrelated=await composeNamedSentence('Nora is physically supporting the archive.',{authority});
assert.throws(()=>decodeSpatialRelationMidi(midiFromFormal(unrelated.formal),authority.atoms));
execFileSync('ruby',['-Itools/lib','-rera_zero_validation','-e',String.raw`
 v=EraZeroValidation;m=v.load_yaml('migrations/spatial_relations_2026_11_04.yaml');d=v.load_yaml('lexicon/compound_dictionary.yaml')['entries'];old=d.select{|e|m['previous_compound_ids'].include?(e['compound_id'])}
 raise 'Prior compounds changed' unless old.length==58 && v.fingerprint(old)==m['before_dictionary_fingerprint']
 raise 'Wrong additions' unless (d.map{|e|e['compound_id']}-m['previous_compound_ids']).sort==m['added_compounds'].values.sort
 baseline=YAML.safe_load(IO.popen(['git','show','0c9645d:lexicon/all_atoms.yaml'], &:read),aliases:true)
 raise 'Roots changed' unless baseline==v.load_yaml('lexicon/all_atoms.yaml')
`],{cwd:root,encoding:'utf8'});
// Independent finite geometry: a contextual one-dimensional extent and region
// (0,2). Boundary contact is a counterexample to outside == not inside.
const classify=(lo,hi)=>({interior:lo>0&&hi<2,exterior:hi<0||lo>2,boundary_intersection:(lo<=0&&hi>=0)||(lo<=2&&hi>=2)});
assert.deepEqual(classify(1,1),{interior:true,exterior:false,boundary_intersection:false});
assert.deepEqual(classify(-1,-1),{interior:false,exterior:true,boundary_intersection:false});
assert.deepEqual(classify(0,0),{interior:false,exterior:false,boundary_intersection:true});
assert.equal(!classify(0,0).interior,true);assert.equal(classify(0,0).exterior,false);
for(let lo=-2;lo<=4;lo++)for(let hi=lo;hi<=4;hi++){const d=classify(lo,hi);assert.equal(Object.values(d).filter(Boolean).length,1);}
// The finite interval model's exhaustiveness is not a universal geometry claim.
console.log(`PASS ${results.length} spatial sentences: independent MIDI roles/relation/runtime/scope recovery, Ruby parity and boundary countermodel.`);
