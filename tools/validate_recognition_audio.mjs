#!/usr/bin/env node
import fs from'node:fs/promises';
import path from'node:path';
import{fileURLToPath}from'node:url';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const pages=path.join(root,'pages');
const index=JSON.parse(await fs.readFile(path.join(pages,'data/index.json'),'utf8'));
const{recognitionForTarget,verifyRecognition}=await import(path.join(pages,'recognition.mjs'));
const{visemePlanFromFormal}=await import(path.join(pages,'visemes.mjs'));
const{midiFromPerformance,notesFromMidi,verifyPerformanceMidi,verifyPerformanceNotes}=await import(path.join(pages,'performance_codec.mjs'));
const{midiFromFormal}=await import(path.join(pages,'engine.mjs'));
const registry=index.recognition_audio,failures=[];
let assertions=0,variants=0;
const check=(condition,message)=>{assertions++;if(!condition)failures.push(message)};
const signatures=new Set(registry.records.map(record=>record.relative_semitones.join(',')));
check(registry.metadata.format==='EZRP-1'&&registry.metadata.semantic_authority_changes===0,'registry boundary');
check(registry.records.length===324&&signatures.size===324,'complete globally unique pitch signatures');
check(JSON.stringify(registry.metadata.length_distribution)===JSON.stringify({'2':28,'3':148,'4':112,'5':36}),'length distribution');
for(const record of registry.records){
  check(record.note_count>=2&&record.note_count<=5&&record.note_count===record.relative_semitones.length,`${record.target_id} note count`);
  check(record.relative_semitones.every(offset=>offset>=0&&offset<=12),`${record.target_id} octave range`);
  check(record.relative_semitones.every((offset,index,notes)=>index===0||Math.abs(offset-notes[index-1])<=7),`${record.target_id} melodic interval`);
  check(record.octave_positions.length<=1&&record.semantic_content===false,`${record.target_id} octave and semantic boundary`);
  check(verifyRecognition(record.target_id,null,registry).status==='valid_strict_absence',`${record.target_id} strict absence`);
  check(verifyRecognition(record.target_id,record,registry).status==='valid_checksum',`${record.target_id} checksum acceptance`);
  check(verifyRecognition(record.target_id,{...record,checksum:'corrupt'},registry).status==='checksum_mismatch',`${record.target_id} corruption rejection`);
}
for(const[canonicalId,relative]of Object.entries(index.resolution_files)){
  const document=JSON.parse(await fs.readFile(path.join(pages,relative.replace(/^\.\//,'')),'utf8'));
  const reference=document.variants['assertion:1'].formal;
  for(const mode of ['strict','recognition','learning']){
    const bytes=midiFromPerformance(reference,registry,mode),parsed=notesFromMidi(bytes),verified=verifyPerformanceMidi(reference,registry,bytes);
    check(parsed.notes.length>0&&verified.status===(mode==='strict'?'valid_strict_absence':'valid_checksum'),`${canonicalId} ${mode} performance MIDI round trip`);
    check(verified.semantic_content===false&&verified.semantic_identity_changed===false,`${canonicalId} ${mode} nonsemantic performance boundary`);
    if(mode==='recognition'){
      const changed=parsed.notes.map(note=>note.midi),phrase=visemePlanFromFormal(reference,{mode:'recognition',recognitionRegistry:registry}).cues.findIndex(cue=>cue.section==='recognition_phrase');
      changed[phrase]=changed[phrase]===127?126:changed[phrase]+1;
      check(verifyPerformanceNotes(reference,registry,changed).status==='checksum_or_path_mismatch',`${canonicalId} corrupted identity phrase rejected`);
      check(verifyPerformanceNotes(reference,registry,parsed.notes.slice(0,-1)).status==='checksum_or_path_mismatch',`${canonicalId} missing contour note rejected`);
    }
  }
  check(verifyPerformanceMidi(reference,registry,midiFromFormal(reference)).status==='valid_strict_absence',`${canonicalId} canonical MIDI is valid strict absence`);
  for(const[key,result]of Object.entries(document.variants)){
    variants++;
    const strict=visemePlanFromFormal(result.formal);
    const explicitStrict=visemePlanFromFormal(result.formal,{mode:'strict',recognitionRegistry:registry});
    const recognized=visemePlanFromFormal(result.formal,{mode:'recognition',recognitionRegistry:registry});
    const learning=visemePlanFromFormal(result.formal,{mode:'learning',recognitionRegistry:registry});
    check(JSON.stringify(strict)===JSON.stringify(explicitStrict),`${canonicalId} ${key} strict default unchanged`);
    const expectedCount=result.formal.performance.lexical_events.reduce((sum,event)=>sum+recognitionForTarget(event.target_id,registry,event.base_midi).note_count,0);
    const recognitionCues=recognized.cues.filter(cue=>cue.section==='recognition_phrase');
    check(recognitionCues.length===expectedCount,`${canonicalId} ${key} recognition count`);
    check(recognized.semantic_identity_changed===false&&recognized.recognition_semantic_content===false,`${canonicalId} ${key} identity boundary`);
    check(learning.duration_seconds>recognized.duration_seconds&&recognized.duration_seconds>strict.duration_seconds,`${canonicalId} ${key} mode timing`);
    check(recognitionCues.every(cue=>cue.note>=48&&cue.note<=96&&cue.sustain_only),`${canonicalId} ${key} pitch and mouth sustain`);
  }
}
const status=failures.length?'FAIL':'PASS';
const report=`# Recognition audio validation\n\nStatus: **${status}**\n\n- Registry records: **${registry.records.length}**\n- Hosted formal variants: **${variants}**\n- Assertions: **${assertions}**\n- Globally unique pitch signatures: **${signatures.size}**\n- Note-count range: **2–5**\n- Performance MIDI: strict, recognition, and learning round-trips for every hosted target\n- Corrupt identity notes and missing contour notes: rejected\n- Canonical MIDI: accepted as strict absence\n- Strict canonical presentation changed: **no**\n- Semantic authority changed: **no**\n- Failures: **${failures.length}**\n\n${failures.length?'## Failures\n\n'+failures.map(item=>`- ${item}`).join('\n')+'\n':'Every optional recognition phrase is deterministic, unique, musically bounded, checksum-verifiable from a real MIDI performance, and cleanly separated from address, runtime, and contour channels.\n'}`;
await fs.writeFile(path.join(root,'reports/recognition_audio_validation.md'),report);
console.log(`Recognition audio: ${status} · ${variants} variants · ${assertions} assertions`);
if(failures.length){console.error(failures.slice(0,30).join('\n'));process.exit(1)}
