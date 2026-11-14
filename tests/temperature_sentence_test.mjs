import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,needsSentenceComposition} from '../pages/sentences.mjs';
import {temperaturePointKelvin} from '../pages/temperature.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=id=>JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const cases=[['20 degrees Celsius','293.15'],['293.15 kelvins','293.15'],['-20 degrees Celsius','253.15'],['-273.15 degrees Celsius','0'],['-300 degrees Celsius','-26.85'],['00020.000 degrees Celsius','293.15'],['9007199254740993.1 degrees Celsius','9007199254741266.25'],['0 kelvins','0'],['-0 kelvins','0']];
const results=[];
for(const state of [0,1,2])for(const [reading,magnitude] of cases){
 const input=`The radio has a temperature of ${reading} [${state}].`,parsed=parseNamedSentence(input);assert.equal(parsed?.measurement.magnitude,magnitude,input);
 const r=await composeNamedSentence(input,load(parsed.predicate));results.push(r);
 const measure=r.semantic_ir.nodes.find(n=>n.kind==='measurement');assert.equal(measure.unit,'kelvin');assert.equal(measure.magnitude,magnitude);
 assert(r.semantic_ir.edges.some(e=>e.role==='bearer'&&e.from==='a'));
 assert(r.semantic_ir.edges.some(e=>e.role==='quantity'&&e.from===measure.node_id&&e.to==='p'));
 const decoded=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
 assert(decoded.tokens.some(t=>t.marker==='measurement_unit_14'));
 assert.equal(decoded.tokens.find(t=>t.root_id==='MAT:010').runtime_state,state);
}
for(const relation of ['more than','less than','at least','at most','not exactly']){
 const r=await composeNamedSentence(`The radio has a temperature of ${relation} 20 degrees Celsius.`,load('MAT:010'));results.push(r);
 assert.equal(r.semantic_ir.nodes.find(n=>n.kind==='measurement').magnitude,'293.15');
}
results.push(await composeNamedSentence('I have a thermodynamic temperature of 300 kelvins.',load('MAT:000')));
results.push(await composeNamedSentence('It is possible that the radio has a temperature of 20 degrees Celsius.',load('MAT:010')));
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:12_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
for(let state=0;state<3;state++){
 const offset=state*cases.length;for(const equivalent of [1,5])assert.deepEqual(results[offset].formal,results[offset+equivalent].formal);
 assert.deepEqual(results[offset+3].formal,results[offset+7].formal);assert.deepEqual(results[offset+7].formal,results[offset+8].formal);
}
assert.notDeepEqual(midiFromFormal(results[0].formal),midiFromFormal(results[cases.length].formal));
const mass=await composeNamedSentence('The radio has a mass of 293.15 kilograms.',load('MAT:010'));
assert.notDeepEqual(midiFromFormal(mass.formal),midiFromFormal(results[cases.length].formal));
for(const input of ['The radio has a temperature of 20 degrees Fahrenheit.','The radio has a temperature difference of 20 degrees Celsius.','The radio has a temperature of 20 kilograms.','The radio has a temperature of 2e2 kelvins.','Exactly two radios have a temperature of 20 degrees Celsius.']){assert.equal(parseNamedSentence(input),null,input);assert(needsSentenceComposition(input));}
assert.equal(parseNamedSentence('The radio is hot.').requiredInterpretation,'thermal_standard');
assert.equal(temperaturePointKelvin('1'.repeat(1001),'kelvin'),null);
assert.equal(temperaturePointKelvin('1','fahrenheit'),null);
const controlled=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-e',`r=EraZeroControlledEnglish::Compiler.new.compile('ASSERT "distinct material object" [2] MEASURE 293.15 kelvin.');raise r.inspect unless r['status']=='ok';puts JSON.generate(EraZeroRenderer.render(r['semantic_ir']))`],{cwd:root,encoding:'utf8'}));
assert(decodeStrictMusicMidi(midiFromFormal(controlled),authority.atoms).tokens.some(t=>t.marker==='measurement_unit_14'));
console.log(`Temperature: ${results.length} exact point/state/bound/bearer/modal cases match Ruby formal and MIDI; Celsius/Kelvin equivalents share meaning and sound, temperature differs from mass, controlled kelvin and independent unit/runtime decoding pass.`);
