// Dependency evidence, not an English-coverage or new-root proof.
import fs from 'node:fs';
const root=new URL('../',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),ids=['MOV:201','MOV:202','MAT:201','MAT:202','MIN:201','MIN:202','CON:100','CON:120','CON:201','CON:202','STR:201','STR:202'];
if(index.atoms.length!==324)throw new Error('Unexpected root inventory; review before extending.');
const candidates=ids.map(id=>{const a=index.atoms.find(a=>a.canonical_id===id);if(!a)throw new Error(`Missing ${id}`);return {canonical_id:id,title:a.title,definition:a.core_definition};});
const report={status:'dependency_review',completion_proven:false,root_count:index.atoms.length,candidates,
 senses:[
 {id:'resource_opportunity',example:'The tea is available to Nora.',required:['resource identity','prospective user','access or acquisition activity','contextual conditions'],not_entailed:['ownership','current custody','permission under every framework','actual acquisition or use']},
 {id:'schedule',example:'Nora is available tomorrow.',required:['participant','time interval','activity or commitment context'],not_entailed:['willingness','physical proximity','free time for every activity']},
 {id:'offer_or_stock',example:'The tea is available for sale.',required:['resource or kind','offer activity','context or provider','relevant conditions'],not_entailed:['purchase','delivery','ownership change','free access']},
 {id:'functional_readiness',example:'The tool is available for use.',required:['resource','intended activity','contextual readiness/access conditions'],not_entailed:['unrestricted permission','actual use','ownership']}
 ],
 conclusions:['Existing capacity roots remain domain-specific; their shared available wording is not a general resource-availability invariant.','Runtime 1 cannot by itself encode available-to-whom, for-what or under-which-conditions.','No new family is justified by this inventory; evaluate scoped opportunity/access composition before a new convention.','Bare availability remains unresolved rather than silently selecting a sense.'],
 next_dependencies:['explicit activity content and its participant binding','context and conditions of access/opportunity','temporal interval for scheduling sense','scope-aware possibility distinct from normative permission'],
 limitations:['Authored distinctions, not independent semantic review.','Does not prove that no existing compound composition can express a specific selected reading.','No dictionary, parser, music code or source approval changes.']};
fs.writeFileSync(new URL('reports/availability_dependency_audit.json',root),JSON.stringify(report,null,2)+'\n');
console.log(`Reviewed ${candidates.length} domain-specific availability roots among ${index.atoms.length}; four distinct unresolved readings recorded, no new family admitted.`);
