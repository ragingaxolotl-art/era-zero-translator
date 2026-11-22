import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,composeSentenceSequence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeContextualStandardMidi} from '../pages/contextual_standard_decoder.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {analyzeEnglish} from '../pages/english.mjs';
import {dictionaryClausePlan,recognizedClausePredicate} from '../pages/dictionary_clauses.mjs';
import {CONTEXTUAL_NORMS} from '../pages/contextual_standards.mjs';
import {encodeName} from '../pages/names.mjs';
import {readSongLine} from '../pages/song_readback.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=async id=>JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const options={interpretation:'width_standard',standard:{kind:'contextual',dimension:'physical_width'}};
const results=[],sounds=new Set();
async function check(text,{norm,scopes=[],state=1,act='assertion',bearer='board',deictic}={}){
  const parsed=parseNamedSentence(text);assert.equal(parsed?.requiredInterpretation,'width_standard',text);
  const r=await composeNamedSentence(text,await load(parsed.predicate),options),bytes=midiFromFormal(r.formal);
  const d=decodeContextualStandardMidi(bytes,authority.atoms);
  assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),d);
  assert.deepEqual(decodeContextualStandardMidi(expandChordMidi(compactChordMidi(bytes,authority.atoms),authority.atoms),authority.atoms),d);
  assert.equal(d.dimension,'physical_width');assert.equal(d.standard.norm,norm);assert.equal(d.standard.scope,'local_context');
  assert.equal(d.relation,norm==='wide'?'greater_than':'less_than');assert.equal(d.runtime_state,state);assert.equal(d.speech_act,act);
  assert.deepEqual(d.scopes,scopes,text);assert(!r.semantic_ir.nodes.some(n=>n.kind==='measurement'));
  if(deictic)assert.deepEqual(d.bearer,{kind:'deictic',role:deictic});
  else assert.deepEqual(d.bearer.phonemes,(await encodeName(bearer)).phonemes);
  results.push(r);sounds.add(Buffer.from(bytes).toString('base64'));return {r,bytes,d};
}
for(const norm of ['wide','narrow'])for(const state of [0,1,2])for(const neg of [false,true])for(const past of [false,true]){
  await check(`The board ${past?'was':'is'} ${neg?'not ':''}${norm}. [${state}]`,{norm,state,
    scopes:[...(past?[{operator:'time',relation:'before_speech'}]:[]),...(neg?[{operator:'negation'}]:[])]});
}
assert.equal(sounds.size,24);
await check('Is the gate wide?',{norm:'wide',act:'question',bearer:'gate'});
await check('It is possible that the board is not narrow.',{norm:'narrow',scopes:[{operator:'modality',mode:'possible'},{operator:'negation'}]});
await check('The board is wide today.',{norm:'wide',scopes:[{operator:'time',relation:'current_day'}]});
await check('I am narrow.',{norm:'narrow',deictic:'speaker'});
await check('You are wide.',{norm:'wide',deictic:'addressee'});
const readback=await readSongLine(compactChordMidi(midiFromFormal(results[25].formal),authority.atoms),authority.atoms,[],true);
assert.match(readback.summary,/narrow \(physical width\)/);assert.match(readback.summary,/possible/);assert.match(readback.summary,/does not hold/);
assert.match(readback.summary,/Bearer =/);assert.match(readback.summary,/no numerical cutoff/);
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',
  'puts JSON.generate(JSON.parse(STDIN.read).map{|ir| f=EraZeroRenderer.render(ir); {formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],
  {cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:15_000_000}));
for(const [i,r] of results.entries()){
  assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);
}
const legacy=JSON.parse(fs.readFileSync(new URL('tests/contextual_adjective_legacy_2026_11_22.json',root)));
for(const row of legacy.cases){
  const r=await composeNamedSentence(row.text,await load('MAT:010'),{interpretation:row.interpretation,standard:{kind:'contextual',dimension:row.dimension}});
  assert.equal(crypto.createHash('sha256').update(midiFromFormal(r.formal)).digest('hex'),row.sha256,row.text);
}
for(const [i,norm] of ['hot','cold','heavy','light','bright','dim','rough','smooth','wide','narrow'].entries())assert.equal(CONTEXTUAL_NORMS[norm].code,i);
const first=results[0],malformed=structuredClone(first.formal);
malformed.semantic_ir.nodes.find(n=>n.standard==='contextual').dimension='mass';assert.throws(()=>midiFromFormal(malformed),/contextual/i);
const bytes=midiFromFormal(first.formal),observed=decodeStrictMusicMidi(bytes,authority.atoms);
const token=observed.tokens.find(t=>t.marker==='contextual_wide_open'),timeline=notesFromMidi(bytes);
const attack=timeline.notes.findIndex(n=>n.start_tick===token.start_tick);timeline.notes[attack+2].midi+=2;
assert.throws(()=>decodeContextualStandardMidi(midiFromNoteTimeline(timeline.notes,timeline.division,timeline.tempos[0].value),authority.atoms));
await assert.rejects(composeNamedSentence('The board is wide.',await load('MAT:010')),e=>e.code==='width_standard_required');
for(const standard of [{kind:'contextual',dimension:'mass'},{dimension:'physical_width',threshold:'2',scale:'meter'},
  {kind:'contextual',dimension:'physical_width',threshold:'2'}])await assert.rejects(composeNamedSentence('The board is wide.',await load('MAT:010'),{interpretation:'width_standard',standard}));
for(const text of ['The board is wider than the gate.','The board is very wide.','The board is two meters wide.','The board looks narrow.',
  'The narrow gate opened.','The board is wide for a gate.'])assert.equal(parseNamedSentence(text),null,text);
for(const norm of Object.keys(CONTEXTUAL_NORMS)){
  const text=`The board is ${norm}.`;
  assert.equal(recognizedClausePredicate(text,authority),norm,text);
  assert(analyzeEnglish(text,authority).term_coverage.some(item=>item.term===norm&&item.matches.some(m=>m.route==='semantic_ir')),norm);
  assert.equal(dictionaryClausePlan(text,authority,{offerDefinition:true}),null,norm+' must not become an unrelated alias');
}
// Complete contextual-adjective groups now reuse the established group sounds.
const sequence=await composeSentenceSequence('The gate is wide, then the board is narrow.',load,[options,options]);
const group=await decodeSupportedMeaningWithDrafts(midiFromFormal(sequence.formal),authority.atoms,[],{allowDraft:true});
assert.equal(group.operator,'sequence');assert.deepEqual(group.members.map(m=>m.standard.norm),['wide','narrow']);
console.log('PASS '+results.length+' width meanings, Ruby/browser parity, 48 unchanged legacy sounds, ten dictionary routes and malformed/unsupported rejection. Ordered contextual-adjective groups independently decode.');
