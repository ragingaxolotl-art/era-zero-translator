// Diagnostic probes, not a coverage score or an acceptance certificate.
import fs from 'node:fs';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
const root=new URL('../',import.meta.url);
const read=p=>JSON.parse(fs.readFileSync(new URL(p,root)));
const authority=read('pages/data/index.json');
const records=read('reviews/foundation_extension_candidates.json').records;
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority});
const cases=[
 ['The lamp is heavy.','mass_standard',{kind:'contextual',dimension:'mass'}],
 ['The heavy robot is carrying the box.','mass_standard',{dimension:'mass',threshold:'10',scale:'kilogram'}],
 ['The heavy robot is carrying the box.','mass_standard',{kind:'contextual',dimension:'mass'}],
 ['The hot robot is carrying the box.','thermal_standard',{kind:'contextual',dimension:'thermodynamic_temperature'}],
 ['The heavy robot is carrying the light box.','mass_standard',{dimension:'mass',threshold:'10',scale:'kilogram'}],
 ['Nora prefers the robot to the box.'],
 ['Nora prefers the heavy robot to the light box.'],
 ['Nora prefers the painful treatment to the more painful treatment.'],
 ['Nora does not prefer the painful treatment to the more painful treatment.'],
 ['Does Nora prefer the painful treatment to the more painful treatment?'],
 ['Nora wants the unnecessary ornament.'],
 ['Nora wants the unpleasant treatment.']
];
const rows=[];
for(const [input,interpretation,standard] of cases){
 try{
  const parsed=parseNamedSentence(input);
  const result=parsed?await composeNamedSentence(input,await load(parsed.predicate),{interpretation,standard}):await composeFoundationSentence(input,authority,records,load,{allowDraft:true});
  rows.push({input,options:standard?{interpretation,standard}:undefined,status:'composed_requires_meaning_and_music_review',reference_restrictions:result.semantic_ir.nodes.filter(n=>n.property_restriction).map(n=>n.property_restriction)});
 }catch(error){if(error.code==='ENOENT')throw error;rows.push({input,options:standard?{interpretation,standard}:undefined,status:'not_composed',diagnostic:error.message});}
}
const report={scope:'Authored diagnostic probes of noun modification; composition alone proves neither intended meaning nor audio recovery.',cases:rows};
fs.writeFileSync(new URL('reports/nominal_modifier_gaps.json',root),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(rows.map(({input,status,diagnostic})=>({input,status,diagnostic})),null,2));
