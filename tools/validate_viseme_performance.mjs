#!/usr/bin/env node
import fs from'node:fs/promises';
import path from'node:path';
import{fileURLToPath}from'node:url';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const pages=path.join(root,'pages');
const{soundPlanFromFormal}=await import(path.join(pages,'engine.mjs'));
const{VISEMES,SYLLABLE_VISEMES,visemesForSyllable,visemePlanFromFormal,visemeFrameAt,visemeFileFromFormal}=await import(path.join(pages,'visemes.mjs'));
const index=JSON.parse(await fs.readFile(path.join(pages,'data/index.json'),'utf8'));
const failures=[];
let assertions=0,variants=0,cues=0;
const check=(condition,message)=>{assertions++;if(!condition)failures.push(message)};
const expectedSyllables=['ba','da','do','ga','gi','ki','li','ma','ni','nu','si','te','wu','ya'];
check(JSON.stringify(Object.keys(SYLLABLE_VISEMES).sort())===JSON.stringify(expectedSyllables),'the explicit syllable map must cover the complete canonical inventory');
check(Object.keys(VISEMES).length===12,'the named rig must expose 12 stable poses');

for(const atom of index.atoms){
  const syllables=atom.formal_carrier.split('-');
  check(syllables.length===4,`${atom.canonical_id} must retain its four-syllable carrier`);
  syllables.forEach(syllable=>check(Boolean(visemesForSyllable(syllable)),`${atom.canonical_id} has unmapped syllable ${syllable}`));
}

for(const[canonicalId,relative]of Object.entries(index.resolution_files)){
  const document=JSON.parse(await fs.readFile(path.join(pages,relative.replace(/^\.\//,'')),'utf8'));
  for(const[key,result]of Object.entries(document.variants)){
    variants++;
    const formal=result.formal,sound=soundPlanFromFormal(formal),plan=visemePlanFromFormal(formal);
    const file=visemeFileFromFormal(formal);
    const expectedNotes=sound.lexical_events.flatMap(event=>[...event.family_opening,...event.address_path,...event.runtime_ending]).concat(sound.sentence_contour);
    cues+=plan.cues.length;
    check(plan.format==='EZVISEME-1'&&plan.version==='1.0.0',`${canonicalId} ${key} format`);
    check(plan.formal_id===formal.formal_id&&plan.semantic_digest===formal.semantic_digest&&plan.semantic_identity_changed===false,`${canonicalId} ${key} identity preservation`);
    check(plan.pitch_drives_viseme===false&&plan.carrier_drives_viseme===true,`${canonicalId} ${key} channel separation`);
    check(file.format==='EZVISEME-1'&&file.formal_id===formal.formal_id&&file.semantic_digest===formal.semantic_digest&&file.semantic_identity_changed===false,`${canonicalId} ${key} standalone file identity`);
    check(file.cues.length===plan.cues.length&&file.cues.every((cue,i)=>cue.viseme_sound===plan.cues[i].syllable&&cue.midi_note===plan.cues[i].note&&cue.poses.length>=1),`${canonicalId} ${key} standalone viseme file cues`);
    check(JSON.stringify(plan.cues.map(cue=>cue.note))===JSON.stringify(expectedNotes),`${canonicalId} ${key} note preservation`);
    check(plan.cues.every((cue,i)=>cue.duration>0&&cue.start>=0&&(i===0||cue.start>plan.cues[i-1].start)),`${canonicalId} ${key} timing order`);
    check(plan.cues.every(cue=>VISEMES[cue.onset_viseme]&&VISEMES[cue.nucleus_viseme]),`${canonicalId} ${key} pose validity`);
    const addressCues=plan.cues.filter(cue=>cue.section==='address_path');
    const carriers=sound.lexical_events.flatMap(event=>event.formal_carrier.split('-'));
    check(JSON.stringify(addressCues.map(cue=>cue.syllable))===JSON.stringify(carriers),`${canonicalId} ${key} address/carrier alignment`);
    const sustained=plan.cues.filter(cue=>cue.section==='runtime_ending'||cue.section==='sentence_contour');
    check(sustained.every(cue=>cue.sustain_only&&cue.onset_viseme===cue.nucleus_viseme),`${canonicalId} ${key} grammatical tone sustain`);
    const runtimeCues=plan.cues.filter(cue=>cue.section==='runtime_ending');
    check(runtimeCues.every(cue=>Math.abs(cue.duration-sound.lexical_events[cue.event_index].runtime.duration_beats*.24)<1e-9),`${canonicalId} ${key} canonical runtime duration`);
    const shifted=structuredClone(formal);shifted.performance.anchor_midi+=7;shifted.performance.lexical_events.forEach(event=>{event.base_midi+=7;event.family_opening_absolute_midi=event.family_opening_absolute_midi.map(note=>note+7);event.address_absolute_midi=event.address_absolute_midi.map(note=>note+7);if(event.runtime_tail)event.runtime_tail.absolute_note+=7});
    const shiftedPlan=visemePlanFromFormal(shifted);
    check(JSON.stringify(shiftedPlan.cues.map(cue=>[cue.syllable,cue.onset_viseme,cue.nucleus_viseme]))===JSON.stringify(plan.cues.map(cue=>[cue.syllable,cue.onset_viseme,cue.nucleus_viseme])),`${canonicalId} ${key} transposition invariance`);
    const first=plan.cues[0],onsetFrame=visemeFrameAt(plan,first.start+.001),nucleusFrame=visemeFrameAt(plan,first.start+first.onset_duration+.001);
    check(onsetFrame.viseme===first.onset_viseme&&nucleusFrame.viseme===first.nucleus_viseme,`${canonicalId} ${key} frame selection`);
  }
}

const status=failures.length?'FAIL':'PASS';
const report=`# Viseme performance validation\n\nStatus: **${status}**\n\n- Canonical atoms covered: **${index.atoms.length}**\n- Hosted formal variants covered: **${variants}**\n- Synchronized tone/viseme cues checked: **${cues}**\n- Assertions: **${assertions}**\n- Failures: **${failures.length}**\n- Semantic identity changed: **no**\n- Transposition invariance: **${failures.some(item=>item.includes('transposition'))?'failed':'verified'}**\n\n${failures.length?'## Failures\n\n'+failures.map(item=>`- ${item}`).join('\n')+'\n':'Every canonical carrier syllable, note event, runtime sustain, contour sustain, cue boundary, and presentation identity passed. Pitch and mouth articulation remain independent channels.\n'}`;
await fs.writeFile(path.join(root,'reports/viseme_performance_validation.md'),report);
console.log(`Viseme performance: ${status} · ${variants} variants · ${cues} cues · ${assertions} assertions`);
if(failures.length){console.error(failures.slice(0,20).join('\n'));process.exit(1)}
