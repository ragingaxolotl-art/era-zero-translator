import {decodeMaterialMeasurementMidi} from '../pages/material_measurement_decoder.mjs';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodePropertyComparisonMidi} from '../pages/property_comparison_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=id=>JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const results=[];
for(const state of [0,1,2])for(const [text,magnitude] of [['0 cd/m²','0'],['00100.500 candelas per square metre','100.5'],['9007199254740993.125 cd/m2','9007199254740993.125'],['at least 50 candelas per square meter','50']]){
 const input=`The lamp has a luminance of ${text} [${state}].`,p=parseNamedSentence(input);assert.equal(p.measurement.magnitude,magnitude);
 const r=await composeNamedSentence(input,load(p.predicate));results.push(r);
 const meaning=decodeMaterialMeasurementMidi(midiFromFormal(r.formal),authority.atoms);assert.equal(meaning.dimension,'luminance');assert.equal(meaning.measurement.magnitude,magnitude);
 const observed=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);assert(observed.tokens.some(t=>t.marker==='measurement_unit_15'));
 assert.equal(observed.tokens.find(t=>t.root_id==='MAT:010').runtime_state,state);
}
for(const state of [0,1,2])for(const [surface,relation] of [['a higher luminance than','greater_than'],['a lower luminance than','less_than'],['the same luminance as','equal'],['at least as high a luminance as','at_least'],['at most as high a luminance as','at_most'],['a different luminance from','not_equal']])for(const [a,b] of [['The lamp','the screen'],['The screen','the lamp']]){
 const r=await composeNamedSentence(`${a} has ${surface} ${b} [${state}].`,load('MAT:010'));results.push(r);
 const d=decodePropertyComparisonMidi(midiFromFormal(r.formal));assert.equal(d.dimension,'luminance');assert.equal(d.relation,relation);assert.equal(d.runtime_state,state);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:15_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
for(const text of ['The lamp has a luminance of -1 cd/m².','The lamp has a luminance of 50 lux.','The lamp has a luminance of 50 candelas.'])assert.equal(parseNamedSentence(text),null);
console.log(`PASS ${results.length} luminance measurements/comparisons: exact magnitudes, roles, direction and runtime match reference output and MIDI observation.`);
