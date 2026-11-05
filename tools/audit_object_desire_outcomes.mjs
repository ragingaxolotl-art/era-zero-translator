// Authored coverage probes: success requires complete musical inverse, not parsing.
import fs from 'node:fs';
import {composeObjectDesire} from '../pages/object_desire.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json'),records=read('reviews/foundation_extension_candidates.json').records;
const load=id=>!authority.resolution_files[id]?{authority}:({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority});
const probes=[
 ['custody','Eli has physical custody of the tea.'],
 ['acquiring_custody','Eli acquired physical custody of the tea.'],
 ['carrying','Eli is carrying the tea.'],
 ['drinking','Nora drinks the tea.'],
 ['ownership','Nora owns the tea.'],
 ['availability','The tea is available.'],
 ['delivery','Eli delivers the tea to Nora.'],
 ['making','Eli makes the tea.']
],results=[];
for(const [id,desiredProposition] of probes){
 let phase='composition';
 try{
  const d=await composeObjectDesire('Nora wants tea.',authority,records,load,{allowDraft:true,desiredProposition});phase='musical_inverse';
  const recovered=await decodeSupportedMeaningWithDrafts(midiFromFormal(d.formal),authority.atoms,records,{allowDraft:true});
  results.push({id,desiredProposition,status:'inverse_available_needs_case_specific_semantic_review',recovered});
 }catch(error){results.push({id,desiredProposition,status:'unsupported',phase:error.cause?'musical_inverse':phase,diagnostic:error.message});}
}
const report={scope:'Authored outcome coverage probes, not semantic acceptance or held-out evaluation. The outcome is explicitly selected, never inferred from wants tea.',completion_proven:false,results};
fs.writeFileSync(new URL('../reports/object_desire_outcome_coverage.json',import.meta.url),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(results.map(({id,status,phase})=>({id,status,phase}))));
