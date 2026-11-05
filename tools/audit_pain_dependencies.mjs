// Audit the project's own meanings; not a medical ontology or lexical approval.
import fs from 'node:fs';
const root=new URL('../',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const keys=['felt_self_condition','unpleasant_felt_condition','felt_bodily_need','sad_felt_mood'];
const dependencies=keys.map(key=>{
 const matches=authority.compounds.filter(c=>c.conventional_meaning?.sense_key===key);
 if(matches.length!==1)throw new Error(`Expected one authoritative ${key}`);
 const c=matches[0];return {compound_id:c.compound_id,definition_version:c.definition_version,meaning:c.conventional_meaning};
});
const explicitPainExclusions=authority.atoms.filter(a=>a.distinctions_and_exclusions?.some(t=>/\bpain\b/i.test(t))).map(a=>({canonical_id:a.canonical_id,core_definition:a.core_definition,exclusions:a.distinctions_and_exclusions.filter(t=>/\bpain\b/i.test(t))}));
const positivePainDefinitions=[...authority.atoms.map(a=>({id:a.canonical_id,definition:a.core_definition})),...authority.compounds.map(c=>({id:c.compound_id,definition:c.conventional_meaning?.added_definition||''}))].filter(a=>/\bpain\b/i.test(a.definition));
const report={scope:'Literal inspection of current authoritative definitions and exclusions. Mentioning pain does not establish a pain meaning; absence of a literal mention does not prove semantic absence.',root_count:authority.atoms.length,dependencies,explicitPainExclusions,definitionsMentioningPain:positivePainDefinitions,decision:'Reuse felt experience and unpleasant valence as dependencies; do not alias pain to them or to WRN. Review a pain-specific convention, then a pain-producing relation and degree comparison before painful-treatment preferences. No new root family established by this audit.'};
fs.writeFileSync(new URL('reports/pain_dependency_audit.json',root),JSON.stringify(report,null,2)+'\n');
console.log(`Audited ${authority.atoms.length} roots; pinned ${dependencies.length} reusable compounds; found ${explicitPainExclusions.length} explicit root exclusions. No vocabulary admitted.`);
