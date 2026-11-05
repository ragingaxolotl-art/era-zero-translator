import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {quantifiedMusicFrames,quantifiedMusicEvent} from '../pages/quantified_music.mjs';
import {decodeStrictMusicMidi,strictGrammarFrameInventory} from '../pages/strict_music_decoder.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const atoms=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))).atoms;
const frames=quantifiedMusicFrames(),paths=frames.map(f=>f.path.join(','));assert.equal(new Set(paths).size,frames.length);
const old=strictGrammarFrameInventory();assert(!old.some(f=>paths.includes(f.path.join(','))));
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_quantified_music','-rjson','-e','puts JSON.generate(EraZeroQuantifiedMusic.frames)'],{cwd:new URL('..',import.meta.url),encoding:'utf8'}));assert.deepEqual(frames,ruby);
// Token/framing probes only, not semantically valid quantified sentences.
for(const q of ['exact','at_least','at_most'])for(const depth of [0,1,2,26,27,80,127])for(const anchor of [48,60,72]){
 const markers=[`counted_${q}_open`,'counted_restriction_open','counted_restriction_close','counted_predicate_open',`counted_reference_${depth}`,'counted_predicate_close',`counted_${q}_close`];
 const formal={semantic_ir:{nodes:[],edges:[]},performance:{anchor_midi:anchor,contour_relative_semitones:[0,0],lexical_events:markers.map(m=>quantifiedMusicEvent(m,anchor))}};
 const bytes=midiFromFormal(formal);assert.throws(()=>decodeStrictMusicMidi(bytes,atoms));
 const d=decodeStrictMusicMidi(bytes,atoms,{allowDraftQuantified:true});assert.deepEqual(d.tokens.map(t=>t.marker),markers);assert.equal(d.tokens[0].closing_token,6);
}
for(const marker of ['counted_reference_128','counted_reference_-1','counted_exact_foo'])assert.throws(()=>quantifiedMusicEvent(marker));
assert.throws(()=>quantifiedMusicEvent('counted_reference_0',20));
console.log('PASS 138 distinct draft frames match Ruby and avoid existing grammar paths; 63 transposed MIDI framing probes decode only with opt-in. Semantic sentence integration remains pending.');
