// Presentation for an already unsupported sentence. This does not compose a
// new meaning or choose a root. Genuine unknown predicates remain visible.
const quantities=new Set('both zero one two three four five six seven eight nine ten eleven twelve'.split(' '));
const irregularPlurals=new Set('children people men women mice geese feet teeth sheep fish'.split(' '));
const auxiliaries=new Set('do does did can could will would might must has have had is are was were'.split(' '));
const copulas=new Set('am is are was were be being been'.split(' '));
const hasPredicateMeaning=row=>row.matches.some(m=>['verb','adjective'].includes(m.part_of_speech));
export function sentenceGapGuidance(result){
 if(!(result.complete_sentence_unavailable||!result.candidates.length)||result.term_coverage.length<2||/["“”]/.test(result.input))return result;
 const rows=result.term_coverage.map(row=>({...row})),words=rows.map(row=>row.term),reasons=[];
 const clear=(index,status,kind=null)=>{
  rows[index]={...rows[index],status,semantic_kind:kind,matches:[],recommended_sense_id:null,semantic_class_target_id:null};
 };
 const scope=index=>{clear(index,'function_word');rows[index].unscored_scope=true;};
 const quantity=words[0],head=words[1]==='the'?2:1;
 if((quantities.has(quantity)||/^(?:0|[1-9][0-9]*)$/.test(quantity))&&rows[head+1]&&
    !hasPredicateMeaning(rows[head])&&!/(?:ed|ing)$/.test(words[head])&&
    (/s$/.test(words[head])||irregularPlurals.has(words[head])||quantity==='one')){
  scope(0);clear(head,'phonemic_label');
  const verb=head+1;
  if(rows[verb].status==='phonemic_label'&&!auxiliaries.has(words[verb]))clear(verb,'unresolved_semantic','verb');
  reasons.push('“'+words.slice(0,head+1).join(' ')+'” needs '+(quantity==='both'?'pair':'quantity')+' grammar. The noun does not need a new verb definition. This quantity has not been added to a whole-sentence score.');
 }
 for(let i=2;i<words.length-1;i++){
  if(!['very','still'].includes(words[i])||!copulas.has(words[i-1]))continue;
  scope(i);
  if(rows[i+1].status==='phonemic_label')clear(i+1,'unresolved_semantic','descriptor');
  reasons.push(words[i]==='very'?'“Very” adds degree to the description. That degree needs sentence grammar and has not been discarded.':'“Still” says the condition continues. That continuation needs sentence grammar and has not been discarded.');
 }
 if(!reasons.length)return result;
 return {...result,term_coverage:rows,complete_sentence_unavailable:true,
  decision:{...result.decision,auto_resolution_allowed:false,requires_clarification:true},
  sentence_gap:{explanation:reasons.join(' ')}};
}
