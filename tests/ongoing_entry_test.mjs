import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConjunction} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodePhysicalEntryMidi} from '../pages/physical_entry_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[],option={interpretation:'physical_entry'};
const time=relation=>({operator:'time',relation}),neg={operator:'negation'},possible={operator:'modality',mode:'possible'};
for(const state of [0,1,2])for(const [input,scopes,act] of [
 ['Nora is entering the archive',[],'assertion'],
 ['Nora is not entering the archive',[neg],'assertion'],
 ['Nora was entering the archive',[time('before_speech')],'assertion'],
 ['Nora was not entering the archive',[time('before_speech'),neg],'assertion'],
 ['Nora was entering the archive yesterday',[time('previous_day')],'assertion'],
 ['Is Nora entering the archive',[],'question'],
 ['Was Nora entering the archive',[time('before_speech')],'question'],
 ['It is possible that Nora is entering the archive',[possible],'assertion'],
 ['It is possible that Nora was entering the archive',[possible,time('before_speech')],'assertion'],
 ['It is not the case that Nora is entering the archive',[neg],'assertion']
]){
 const text=`${input} [${state}]${act==='question'?'?':'.'}`;
 await assert.rejects(()=>composeNamedSentence(text,{authority}),e=>e.code==='physical_entry_required');
 const r=await composeNamedSentence(text,{authority},option);results.push(r);
 const d=decodePhysicalEntryMidi(midiFromFormal(r.formal),authority.atoms);assert.equal(d.predicate,'ongoing_physical_entry');assert.equal(d.runtime_state,state);assert.equal(d.speech_act,act);assert.deepEqual(d.scopes,scopes);
 assert.equal(d.phases.culmination,'not_asserted');assert.equal(d.culmination_criterion,'interior');assert.deepEqual(d.actor.phonemes,['N','AO','R','AE']);assert.equal(d.region.reference_mode,'definite_nominal');
 assert.equal(r.formal.performance.lexical_events.filter(e=>e.runtime_tail).length,1);
}
for(const text of ['I am physically entering this room.','Nora is not physically entering that archive.','Nora wasn’t entering the archive.']){
 const r=await composeNamedSentence(text,{authority},parseNamedSentence(text).requiredInterpretation?option:{});results.push(r);decodePhysicalEntryMidi(midiFromFormal(r.formal),authority.atoms);
}
for(const state of [0,1,2])results.push(await composeSentenceConjunction(`Nora was entering the archive [${state}] and Eli entered the room [${(state+1)%3}].`,async()=>({authority}),[option,option]));
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:50_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
const completed=await composeNamedSentence('Nora physically entered the archive.',{authority});assert.equal(decodePhysicalEntryMidi(midiFromFormal(completed.formal),authority.atoms).phases.culmination,'interior');assert.notDeepEqual(midiFromFormal(completed.formal),midiFromFormal(results[2].formal));
for(const text of ['Nora is entering the archive slowly.'])assert.equal(parseNamedSentence(text),null);
// Valid musical names cannot be spliced into only the pre-phase without failing
// independent identity recovery. No IR is passed to the inverse.
const alternate=await composeNamedSentence('Eli is physically entering the archive.',{authority}),base=await composeNamedSentence('Nora is physically entering the archive.',{authority});
const select=e=>e.kind==='phonemic_label'&&e.binding_path?.includes('q-0-before')&&e.binding_path.at(-1)==='s-bearer';const index=base.formal.performance.lexical_events.findIndex(select);assert(index>=0);base.formal.performance.lexical_events[index]=alternate.formal.performance.lexical_events.find(select);assert.throws(()=>decodePhysicalEntryMidi(midiFromFormal(base.formal),authority.atoms),/entry/);
// A body interval [x,x+1] moves toward region (0,4), straddles its boundary,
// then reverses. Its ongoing entry was real; a completed entry never occurred.
const path=[-2,-1.5,-0.5,-0.8,-2],inside=x=>x>0&&x+1<4,exterior=x=>x+1<0||x>4;
assert(exterior(path[0]));assert(path[2]>path[1]);assert(path[2]<0&&path[2]+1>0);assert(!path.some(inside));assert(exterior(path.at(-1)));
// A successful continuation is a different history sharing that same prefix.
assert([...path.slice(0,3),0.2].some(inside));
execFileSync('ruby',['-Itools/lib','-rera_zero_validation','-e',String.raw`
 v=EraZeroValidation;m=v.load_yaml('migrations/ongoing_entry_2026_11_04.yaml');d=v.load_yaml('lexicon/compound_dictionary.yaml')['entries'];old=d.select{|e|m['previous_compound_ids'].include?(e['compound_id'])}
 raise 'Prior compounds changed' unless old.length==62 && v.fingerprint(old)==m['before_dictionary_fingerprint']
 target=m['target_condition_definition'];entry=d.find{|e|e['compound_id']==target['compound_id']}
 raise 'Target criterion lost' unless entry && entry['definition_version']==target['definition_version'] && entry.dig('conventional_meaning','sense_key')=='physical_region_interior' && target['asserted']==false
 roots=YAML.safe_load(IO.popen(['git','show','850d1de:lexicon/all_atoms.yaml'], &:read),aliases:true)
 raise 'Roots changed' unless roots==v.load_yaml('lexicon/all_atoms.yaml')
`],{cwd:root,encoding:'utf8'});
console.log(`PASS ${results.length} ongoing-entry and mixed-event cases: independent phase/scope/runtime recovery, Ruby/MIDI parity, identity corruption rejection, interruption countermodel and historical vocabulary preservation.`);
