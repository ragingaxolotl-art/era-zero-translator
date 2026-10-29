import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import fs from 'node:fs';
import {midiFromPerformance,verifyPerformanceMidi} from '../pages/performance_codec.mjs';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),atoms=authority.atoms;
const cases=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-rera_zero_presentation','-rbase64','-e',String.raw`
c=EraZeroControlledEnglish::Compiler.new
puts JSON.generate(EraZeroPresentation::ROLE_ORDER.product([0,1,2]).map do |role,state|
 other=role=='beneficiary' ? 'actor' : 'beneficiary'
 prefix=%(ASSERT "active target restoration" [#{state}] ROLE #{role} "conscious self" [1] ROLE #{other} )
 shared=c.compile!(prefix+"REF #{role}.");separate=c.compile!(prefix+'"conscious self" [1].')
 f=EraZeroRenderer.render(shared);g=EraZeroRenderer.render(separate)
 {role:role,state:state,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),separate_midi:Base64.strict_encode64(EraZeroPresentation.midi(g)),svg:EraZeroPresentation.svg(f)}
end)
`],{cwd:root,encoding:'utf8',maxBuffer:10_000_000}));
for(const {role,state,formal,midi,separate_midi,svg} of cases){
 const scheduled=scheduledLexicalEvents(formal),references=scheduled.filter(e=>e.marker?.startsWith('role_reference_'));
 assert.deepEqual(references.map(e=>e.marker),[`role_reference_${role}`]);
 assert.equal(scheduled.filter(e=>e.target_id==='LIF:001').length,1);
 assert.equal(scheduled.find(e=>e.target_id==='REP:111').runtime_tail.code,state);
 assert.deepEqual(Buffer.from(midiFromFormal(formal)),Buffer.from(midi,'base64'));assert.equal(svgFromFormal(formal),svg);
 assert.notEqual(midi,separate_midi);
 const decoded=decodeStrictMusicMidi(Buffer.from(midi,'base64'),atoms);
 assert.deepEqual(decoded.tokens.filter(t=>t.marker?.startsWith('role_reference_')).map(t=>t.marker),[`role_reference_${role}`]);
}
for(const mode of ['strict','recognition','learning'])assert.match(verifyPerformanceMidi(cases[0].formal,authority.recognition_audio,midiFromPerformance(cases[0].formal,authority.recognition_audio,mode)).status,/^valid_/);
const ambiguous=structuredClone(cases[0].formal);
const edge=ambiguous.semantic_ir.edges.find(e=>e.role==='actor');
ambiguous.semantic_ir.edges.push({...edge,edge_id:'extra'});
assert.throws(()=>scheduledLexicalEvents(ambiguous),/Ambiguous musical role reference/);
console.log('Role-reference music: 66 role/runtime structural cases distinguish a shared argument from identical separate lexical occurrences, preserve Ruby/browser MIDI and SVG, and recover the reference token without source IR. These probes do not approve arbitrary lexical valence.');
