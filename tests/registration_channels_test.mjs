import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {decodeConventionFrame} from '../pages/compound_conventions.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const foundation='CMP:ade73037114406a2cd91ce13';
const channels=[['optical','CMP:bcfd189eb305cf364ada975a',1],['acoustic','CMP:42e9bd596b35612ed6cbe3ce',2]];
const dictionary=JSON.parse(execFileSync('ruby',['-ryaml','-rjson','-e','puts JSON.generate(YAML.load_file("lexicon/compound_dictionary.yaml")["entries"])'],{cwd:root,encoding:'utf8'}));
const sounds=[];
for(const [channel,id,code] of channels){
 const entry=dictionary.find(e=>e.compound_id===id);
 assert.deepEqual(entry.nodes,[{node_id:'h',kind:'compound_ref',compound_id:foundation,definition_version:'1.0.0'}]);
 assert.deepEqual(entry.edges,[]);assert.equal(entry.conventional_meaning.sound_code,code);
 const template=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[id],root))).variants['assertion:1'];
 for(const state of [0,1,2])for(const prefix of ['', 'It is possible that ', 'It is not necessary that ']){
  const input=`${prefix}${prefix?'the':'The'} sensor is registering ${channel} input from the bell [${state}].`;
  const result=await composeNamedSentence(input,template),ir=result.semantic_ir;
  assert.equal(ir.edges.find(e=>e.from==='a'&&e.type==='fills_role').role,'target');
  assert.equal(ir.edges.find(e=>e.from==='b'&&e.type==='fills_role').role,'source');
  const reference=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(ir),encoding:'utf8'}));
  assert.deepEqual(result.formal,reference.formal);
  const midi=midiFromFormal(result.formal);assert.deepEqual(Buffer.from(midi),Buffer.from(reference.midi,'base64'));
  const payload=scheduledLexicalEvents(result.formal).filter(e=>e.occurrence_id==='p');
  assert.deepEqual(payload.map(e=>e.marker||e.target_id),[`convention_${code}_open`,'convention_0_open','MAT:211','DAT:111','convention_0_close',`convention_${code}_close`]);
  assert.deepEqual(payload.filter(e=>e.runtime_tail).map(e=>e.runtime_tail.code),[state]);
  const {notes}=notesFromMidi(midi),segments=[];
  for(const note of notes){if(!segments.length||note.start_tick>segments.at(-1).at(-1).end_tick)segments.push([]);segments.at(-1).push(note);}
  const decoded=segments.map(s=>decodeConventionFrame(s.map(n=>n.midi-60))).filter(Boolean);
  assert.deepEqual(decoded.map(f=>[f.side,f.sound_code]),[['open',code],['open',0],['close',0],['close',code]]);
  sounds.push(Buffer.from(midi).toString('base64'));
 }
}
assert.equal(new Set(sounds).size,18);
const generic=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[foundation],root))).variants['assertion:1'];
const plain=await composeNamedSentence('The sensor is registering sensory input from the bell.',generic);
assert.deepEqual(scheduledLexicalEvents(plain.formal).filter(e=>e.grammar_profile==='EZLEX-1').map(e=>e.marker),['convention_0_open','convention_0_close']);
for(const phrase of ['The sensor sees the bell.','The sensor hears the bell.','The sensor is registering optical and acoustic input from the bell.'])assert.equal(parseNamedSentence(phrase),null);
console.log('Registration channels: 18 channel/runtime/scope cases reuse one exact versioned foundation, retain source and receiver roles, preserve nested convention codes in MIDI, and match Ruby/browser formal output. Generic registration and conscious perception remain distinct.');
