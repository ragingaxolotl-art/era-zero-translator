import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {canonicalDigest,midiFromFormal} from '../pages/engine.mjs';
import {decodeContextualStandardMidi} from '../pages/contextual_standard_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const template=JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files['MAT:010'],root))).variants['assertion:1'];
const sounds=new Set();
for(const norm of ['rough','smooth'])for(const state of [0,1,2])for(const negative of [false,true]){
 // Construct the new typed profile using existing bearer and scope plumbing.
 // This is not an assertion that English rough/smooth parsing is implemented.
 const base=await composeNamedSentence(`The stone is ${negative?'not ':''}hot [${state}].`,template,{interpretation:'thermal_standard',standard:{kind:'contextual',dimension:'thermodynamic_temperature'}});
 const ir=structuredClone(base.semantic_ir),comparison=ir.nodes.find(n=>n.standard==='contextual');
 Object.assign(comparison,{norm,dimension:'surface_texture',relation:norm==='rough'?'greater_than':'less_than'});
 delete ir.utterance_id;delete ir.serialization;
 const digest=await canonicalDigest(ir);ir.utterance_id='UTT:'+digest.slice(0,24);ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"ir=JSON.parse(STDIN.read);f=EraZeroRenderer.render(ir);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})"],{cwd:root,input:JSON.stringify(ir),encoding:'utf8'}));
 const bytes=midiFromFormal(ruby.formal);assert.equal(Buffer.from(bytes).toString('base64'),ruby.midi);sounds.add(ruby.midi);
 const decoded=decodeContextualStandardMidi(bytes,authority.atoms);
 assert.equal(decoded.dimension,'surface_texture');assert.equal(decoded.standard.norm,norm);assert.equal(decoded.runtime_state,state);
 assert.equal(decoded.relation,norm==='rough'?'greater_than':'less_than');assert.deepEqual(decoded.scopes,negative?[{operator:'negation'}]:[]);
 const malformed=structuredClone(ruby.formal);malformed.semantic_ir.nodes.find(n=>n.standard==='contextual').dimension='mass';
 assert.throws(()=>midiFromFormal(malformed),/contextual/);
}
assert.equal(sounds.size,12);
console.log('PASS surface-texture profile: 12 distinct norm/state/negation performances, Ruby/browser MIDI parity, inverse meaning and wrong-dimension rejection. English/UI admission remains pending.');
