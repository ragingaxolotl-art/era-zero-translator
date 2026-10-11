const STOPWORDS=new Set('a an the to of in on at for from with am is are was were be being been do does did i you he she it we they this that these those my your his her its our their please now just may might maybe could can would will shall should perhaps possibly probably'.split(' '));
const DIRECT=new Set(['atom','compound']);
const INHERENTLY_POLYSEMOUS=new Set(['know','have','exist','receive','send','share','change','return','run','home']);
const PARTICIPANTS=new Map(Object.entries({i:'speaker',me:'speaker',my:'speaker',myself:'speaker',we:'speaker_group',us:'speaker_group',our:'speaker_group',ourselves:'speaker_group',you:'addressee',your:'addressee',yourself:'addressee',he:'other_person',him:'other_person',his:'other_person',she:'other_person',her:'other_person',hers:'other_person',they:'other_group',them:'other_group',their:'other_group',it:'other_referent',its:'other_referent'}));
const PHRASAL_VERBS=new Set(['pick up','back up','shut down','log in','log out','power on','turn off','turn on','set up','break down']);

const IRREGULAR={
  am:['be'],are:['be'],is:['be'],was:['be'],were:['be'],been:['be'],
  left:['leave','depart'],went:['go'],gone:['go'],
  came:['come'],come:['come'],ran:['run'],
  found:['find'],
  made:['make','create'],built:['build'],
  knew:['know'],known:['know'],thought:['think'],
  sent:['send'],received:['receive'],
  broke:['break'],broken:['break'],fixed:['fix'],repaired:['repair'],
  moved:['move'],stopped:['stop'],continued:['continue'],
  arrived:['arrive'],departed:['depart'],returned:['return'],
  crossed:['cross'],followed:['follow'],waited:['wait'],
  shared:['share'],changed:['change'],created:['create']
};

const SENSE_HINTS=[
  [/\b(?:find|finds|finding|found|discover|discovers|discovered)\b/,'completed_target_discovery_generalized',.34,'context'],
  [/\b(?:wait|waits|waiting|waited)\b/,'deferred_action',.62,'context'],
  [/\b(?:cross|crosses|crossing|crossed)\b.*\b(?:bridge|boundary|border|line|threshold)\b/,'boundary_traversal',.68,'context'],
  [/\b(?:go|goes|going|went|gone)\s+(?:home|there|here|to|toward|towards|into|through|across|away)\b/,'spatial_movement',.58,'context'],
  [/\b(?:go|goes|going|went|gone)\s+(?:red|dark|silent|offline|online|bad|wrong|cold|hot|missing|blank|viral)\b/,'abstract_transition',.62,'context'],
  [/\b(?:send|sends|sending|sent)\b.*\b(?:file|data|packet|record|code|document|information)\b/,'data_transfer',.62,'context'],
  [/\b(?:send|sends|sending|sent|say|tell)\b.*\b(?:message|word|reply|greeting|warning|request)\b/,'communicative_expression',.62,'context'],
  [/\b(?:receive|receives|receiving|received)\b.*\b(?:file|data|packet|record|code|document|information)\b/,'data_transfer_completion',.62,'context'],
  [/\b(?:receive|receives|receiving|received|hear)\b.*\b(?:message|word|reply|greeting|warning|request)\b/,'communicative_reception',.62,'context'],
  [/\b(?:change|changes|changing|changed)\b.*\b(?:mind|opinion|belief|self image)\b/,'mental_revision',.62,'context'],
  [/\b(?:change|changes|changing|changed)\b.*\b(?:file|data|record|code|document|information)\b/,'data_transformation',.62,'context'],
  [/\b(?:change|changes|changing|changed)\b.*\b(?:layout|structure|arrangement|configuration)\b/,'structural_reconfiguration',.62,'context'],
  [/\b(?:run|runs|running|ran)\b.*\b(?:program|script|code|function|application)\b/,'program_execution',.62,'context'],
  [/\b(?:run|runs|running|ran)\b.*\b(?:machine|engine|motor|device)\b/,'machine_operation',.62,'context'],
  [/\b(?:run|runs|running|ran)\b.*\b(?:home|race|mile|road|trail)\b/,'locomotion',.62,'context'],
  [/\b(?:use|uses|using|used)\b.*\b(?:program|app|application|software|script|code)\b/,'program_execution',.62,'context'],
  [/\b(?:is|are|was|were)?\s*(?:being\s+)?deleting\b|\b(?:is|are|was|were)\s+being\s+deleted\b/,'active_information_deletion',.62,'context'],
  [/\b(?:has|have|had|was|were)\s+deleted\b|\bdeleted\b/,'completed_information_deletion',.58,'context'],
  [/\b(?:need|needs|needed|plan|plans|planned|will)\s+(?:to\s+)?migrate\b|\bmigrate\b/,'pending_data_migration_generalized',.58,'context'],
  [/\b(?:is|are|was|were)?\s*(?:being\s+)?migrating\b|\b(?:is|are|was|were)\s+being\s+migrated\b/,'active_data_migration_generalized',.62,'context'],
  [/\b(?:has|have|had)\s+migrated\b|\bmigrated\b/,'completed_data_migration_generalized',.58,'context'],
  [/\b(?:return|returns|returning|returned)\b.*\b(?:value|result|object|null|response)\b/,'function_result',.62,'context'],
  [/\b(?:return|returns|returning|returned)\b.*\b(?:home|back|place|position|origin)\b/,'movement_to_prior_position',.62,'context'],
  [/\b(?:am|is|are|was|were|be|been)?\s*leaving\b/,'active_departure',.52],
  [/\b(?:left|departed|has left|have left|had left)\b/,'completed_departure',.58],
  [/\b(?:approach|approaches|approaching)\b/,'active_target_approach',.50],
  [/\b(?:arrive|arrived|arrives|reached the (?:destination|station|place))\b/,'completed_target_arrival',.55],
  [/\b(?:go|goes|going|went|gone|travel|travels|traveling|travelling)\b/,'spatial_movement',.34],
  [/\b(?:move|moves|moving|moved)\b/,'spatial_displacement',.34],
  [/\b(?:know|knows|knew|known|remember)\b/,'stable_target_representation',.28],
  [/\b(?:create|creates|creating|make|makes|making)\b/,'active_artifact_generation',.38],
  [/\b(?:break|breaks|breaking|broke|broken)\b/,'target_impairment',.38],
  [/\b(?:fix|fixes|fixing)\b/,'target_restoration',.38],
  [/\b(?:repair|repaired)\b/,'completed_target_restoration',.38],
  [/\b(?:send|sends|sending|sent|say|says|saying|tell|tells|telling)\b/,'communicative_expression',.30],
  [/\b(?:receive|receives|receiving|received|hear|hears|hearing)\b/,'communicative_reception',.30]
];

export const normalize=value=>String(value??'').normalize('NFC').toLowerCase().replace(/[?!.,;:()"']/g,' ').replace(/\s+/g,' ').trim();

function variants(token){
  const out=new Set([token]);
  for(const form of IRREGULAR[token]||[])out.add(form);
  if(token.length>4&&token.endsWith('ies'))out.add(`${token.slice(0,-3)}y`);
  if(token.length>4&&token.endsWith('ing')){
    const base=token.slice(0,-3);out.add(base);out.add(`${base}e`);
    if(base.length>2&&base.at(-1)===base.at(-2))out.add(base.slice(0,-1));
  }
  if(token.length>3&&token.endsWith('ed')){
    const base=token.slice(0,-2);out.add(base);out.add(`${base}e`);
    if(base.endsWith('i'))out.add(`${base.slice(0,-1)}y`);
    if(base.length>2&&base.at(-1)===base.at(-2))out.add(base.slice(0,-1));
  }
  if(token.length>3&&token.endsWith('es')){out.add(token.slice(0,-2));out.add(token.slice(0,-1))}
  else if(token.length>3&&token.endsWith('s'))out.add(token.slice(0,-1));
  return out;
}

export function lexicalTokens(value,{keepStopwords=false}={}){
  const words=normalize(value).match(/[\p{L}\p{N}_-]+/gu)||[];
  const out=new Set();
  for(const word of words){
    if(!keepStopwords&&STOPWORDS.has(word))continue;
    for(const form of variants(word))out.add(form);
  }
  return out;
}

const overlap=(a,b)=>[...a].filter(item=>b.has(item));

export function extractExplicitRuntime(value){
  const match=String(value).match(/\s*\[([^\]]+)\]\s*[?.!]?\s*$/);
  if(!match)return[String(value),null];
  if(!['0','1','2'].includes(match[1]))throw{code:'invalid_runtime_state',message:'If you use an explicit state marker, it must be [0], [1], or [2]. You normally do not need one.'};
  return[String(value).slice(0,match.index),Number(match[1])];
}

export function inferEnglishIntent(raw,explicitRuntime=null){
  const text=normalize(raw),words=text.split(' ').filter(Boolean),first=words[0]||'';
  const question=String(raw).trim().endsWith('?')||/^(?:who|what|when|where|why|how|can|could|would|will|do|does|did|is|are|was|were|has|have|had)\b/.test(text);
  const possibility=!question&&/\b(?:may|might|maybe|could|perhaps|possibly|probably)\b/.test(text);
  const definition=!question&&/\b(?:means|is defined as|refers to)\b/.test(text);
  const imperative=!question&&(first==='please'||/^(?:leave|go|move|approach|arrive|send|receive|share|create|make|fix|repair|stop|wait|continue|return|follow|cross|change|remember|think|look|listen)\b/.test(text));
  const speechAct=definition?'definition':possibility?'possibility':question?'question':imperative?'command':'assertion';
  let runtime=explicitRuntime,runtimeSource='explicit';
  if(runtime===null){
    runtime=/\b(?:not|never|no longer|isn t|aren t|wasn t|weren t|don t|doesn t|didn t|cannot|can t)\b/.test(text)?0:1;
    runtimeSource=runtime===0?'inferred from English negation':'ordinary positive-English default';
  }
  return{speechAct,runtime,runtimeSource};
}

function scoreSense(sense,input,inputTokens){
  const forms=[sense.lemma,...(sense.surface_forms||[])].map(normalize),formTokens=forms.map(form=>lexicalTokens(form));
  const exact=forms.includes(input),exactLemma=normalize(sense.lemma)===input,bestTokens=formTokens.sort((a,b)=>overlap(inputTokens,b).length/Math.max(b.size,1)-overlap(inputTokens,a).length/Math.max(a.size,1)||b.size-a.size)[0]||new Set();
  const lexical=overlap(inputTokens,bestTokens).length,ratio=lexical/Math.max(bestTokens.size,1);
  const surfaceMatch=bestTokens.size>0&&ratio===1;
  const hint=SENSE_HINTS.find(([pattern,key])=>key===sense.sense_key&&pattern.test(input));
  if(!exact&&!surfaceMatch&&!lexical&&!hint)return null;
  let score=sense.plain_mapping?(exactLemma?1:exact?.72:surfaceMatch?(bestTokens.size===1?.72:.82):Math.min(.12+.28*ratio,.44)):(exact?1:surfaceMatch?(bestTokens.size===1?.78:.90):Math.min(.18+.34*ratio,.52));
  if(hint)score+=hint[2];
  const cue=overlap(inputTokens,lexicalTokens((sense.selection_cues||[]).join(' '))).length;
  const definition=overlap(inputTokens,lexicalTokens(sense.definition||'')).length;
  score+=Math.min(cue*.025,.08)+Math.min(definition*.012,.07);
  const headForms=forms.map(form=>form.split(' ')[0]).filter(Boolean),headPattern=headForms.length?headForms.map(form=>form.replace(/[.*+?^${}()|[\]\\]/g,'\\$&')).join('|'):null;
  const profileSense=String(sense.sense_id).startsWith('GSE:');
  if(profileSense&&headPattern&&sense.part_of_speech==='verb'&&new RegExp(`^(?:please )?(?:${headPattern})\\b|\\b(?:i|we|you|he|she|they|it) (?:${headPattern})\\b`).test(input))score+=.12;
  if(profileSense&&headPattern&&sense.part_of_speech==='adjective'&&new RegExp(`\\b(?:am|is|are|was|were|feel|feels|felt|seem|seems) (?:${headPattern})\\b`).test(input))score+=.10;
  if(sense.sense_key==='canonical_atom_label'&&!exact)score=Math.min(score,.62);
  const targetAddress=String(sense.target_id||'').match(/^[A-Z]{3}:([012]{3})$/)?.[1],lexicalLayer=sense.lexical_layer||targetAddress?.[0],lexicalPhase=sense.lexical_phase||targetAddress?.[2];
  if(lexicalLayer==='1'){
    const modalQuestion=/^(?:could|can|may|might|will|would)\s+(?:i|we|you|he|she|they|it)\b/.test(input),phase=!modalQuestion&&/\b(?:possible|planned|pending|will|shall|may|might|could|plan|plans|intend|intends|need|needs|needed|want|wants|wanted|later|soon)\b/.test(input)?'2':/\b(?:ongoing|active|current)\b/.test(input)?'1':/\b(?:finished|completed|has|have|had)\b|\b(?:sent|left|went|came|found|made|built|knew|received|broke|fixed|repaired|moved|stopped|continued|arrived|departed|returned|crossed|followed|waited|shared|changed|created|\w+ed)\b/.test(input)?'0':'1';
    if(phase===lexicalPhase)score+=sense.plain_mapping ? .16 : .08;
    else if(['mental_revision','completed_target_discovery_generalized','data_transfer_completion','completed_target_restoration','completed_target_arrival'].includes(sense.sense_key))score-=.02;
    else score=Math.min(score-.18,sense.plain_mapping ? .72 : .84);
  }
  score=Math.round(Math.min(score,1)*10000)/10000;
  return{sense_id:sense.sense_id,lemma:sense.lemma,sense_key:sense.sense_key,route:sense.route,target_id:sense.target_id,definition:sense.definition,selection_cues:sense.selection_cues||[],generalization:sense.generalization||null,fidelity:sense.fidelity||'indexed',plain_mapping:Boolean(sense.plain_mapping),part_of_speech:sense.part_of_speech||null,competition_group:sense.competition_group||null,specificity:bestTokens.size,noun_label_allowed:Boolean(sense.noun_label_allowed),score,confidence:score>=.82?'high':score>=.62?'medium':'low',match_type:exact?'exact_lemma':hint?.[3]==='context'?'contextual_english':hint?'english_sentence':surfaceMatch?'inflected_lemma':'context_overlap',contextual_hint:hint?.[3]==='context',evidence:{lexical_overlap:lexical,selection_cue_overlap:cue,definition_overlap:definition}};
}

function plainMappedSenses(data){
  const atoms=new Map((data.atoms||[]).map(atom=>[atom.canonical_id,atom]));
  const compounds=new Map((data.compounds||[]).map(compound=>[compound.compound_id,compound]));
  return(data.plain_english?.entries||[]).map(entry=>{
    const record=entry.target_type==='atom'?atoms.get(entry.target_id):compounds.get(entry.target_id);
    const address=record?.address||'';
    return{sense_id:`PLN:${entry.target_id}`,lemma:entry.plain_label,surface_forms:entry.match_phrases||[],part_of_speech:address[0]==='1'?'verb_phrase':'noun_phrase',sense_key:'plain_language_mapping',route:entry.target_type,target_id:entry.target_id,definition:record?.core_definition||record?.invariant_definition||entry.plain_explanation,selection_cues:[],generalization:entry.authority_note,fidelity:'plain_language_mapping',plain_mapping:true,lexical_layer:address[0]||null,lexical_phase:address[2]||null,competition_group:address?`PLN:${entry.target_id.split(':')[0]}:${address.slice(0,2)}`:`PLN:${entry.target_id}`};
  });
}

function unknownSemanticKind(words,index){
  const word=words[index],previous=words[index-1]||'',beforePrevious=words[index-2]||'',next=words[index+1]||'';
  if(PHRASAL_VERBS.has(`${word} ${next}`))return'verb';
  if(['a','an','the','this','that','these','those','my','your','his','her','its','our','their'].includes(previous))return null;
  if(/(?:ed|ing)$/.test(word)||['do','does','did','can','could','will','would','should','may','might','must'].includes(previous)||(previous==='to'&&['want','wants','wanted','need','needs','needed','try','tries','tried','plan','plans','planned'].includes(beforePrevious)))return'verb';
  if(['am','is','are','was','were','be','being','been','feel','feels','felt','seem','seems','look','looks'].includes(previous))return'descriptor';
  if(index===0&&next&&['the','a','an','me','us','him','her','them','it'].includes(next))return'verb';
  if(index===1&&PARTICIPANTS.has(previous)&&next)return'verb';
  if(index>0&&next&&/(?:s|es)$/.test(word)&&!STOPWORDS.has(previous))return'verb';
  if(/(?:ous|ful|less|ive|able|ible|ish|ary|ory)$/.test(word))return'descriptor';
  return null;
}

function termCoverage(normalized,data,ranked,allSenses){
  const words=normalize(normalized).match(/[\p{L}\p{N}_-]+/gu)||[],rankBySense=new Map(ranked.map((item,index)=>[item.sense_id,{index,score:item.score,match_type:item.match_type}]));
  return words.map((word,tokenIndex)=>{
    const forms=variants(word),matches=allSenses.filter(sense=>{const surface=[sense.lemma,...(sense.surface_forms||[])];const matched=surface.some(item=>{const comparable=String(sense.sense_id).startsWith('GSE:')?normalize(item).split(' ')[0]:item;return overlap(forms,lexicalTokens(comparable,{keepStopwords:true})).length});if(!matched)return false;if(!STOPWORDS.has(word))return true;return ['grammar','semantic_ir'].includes(sense.route)&&normalize(sense.lemma)===word}).map(sense=>{const ranking=rankBySense.get(sense.sense_id);return{sense_id:sense.sense_id,lemma:sense.lemma,sense_key:sense.sense_key,route:sense.route,target_id:sense.target_id,semantic_class_target_id:sense.semantic_class_target_id,definition:sense.definition,generalization:sense.generalization||null,fidelity:sense.fidelity||'indexed',plain_mapping:Boolean(sense.plain_mapping),part_of_speech:sense.part_of_speech||null,noun_label_allowed:Boolean(sense.noun_label_allowed),score:ranking?.score??0,match_type:ranking?.match_type??'word_match'}}).sort((a,b)=>{const exactA=a.lemma===word?1:0,exactB=b.lemma===word?1:0;return b.score-a.score||exactB-exactA||a.lemma.localeCompare(b.lemma)||a.sense_id.localeCompare(b.sense_id)});
    const authoritative=matches.some(match=>!match.plain_mapping)?matches.filter(match=>!match.plain_mapping):matches;
    const direct=authoritative.filter(match=>DIRECT.has(match.route));
    const gaps=authoritative.filter(match=>match.route==='gap');
    const labels=authoritative.filter(match=>match.route==='label');
    const participant=PARTICIPANTS.get(word),semanticKind=unknownSemanticKind(words,tokenIndex);
    const particle=PHRASAL_VERBS.has(`${words[tokenIndex-1]||''} ${word}`);
    const status=participant?'participant_reference':direct.length?'canonical':gaps.length?'documented_gap':labels.length?'labeled_entity':authoritative.length?'structural':STOPWORDS.has(word)||particle?'function_word':semanticKind?'unresolved_semantic':'phonemic_label';
    const label=labels[0];
    return{token_index:tokenIndex,term:word,status,semantic_kind:semanticKind,participant_role:participant||null,semantic_class_target_id:label?.semantic_class_target_id||null,recommended_sense_id:matches[0]?.sense_id??null,matches};
  });
}

export function analyzeEnglish(raw,data,{limit=Number.POSITIVE_INFINITY}={}){
  let text,explicitRuntime;[text,explicitRuntime]=extractExplicitRuntime(raw);
  const normalized=normalize(text);
  if(!normalized)throw{code:'empty_input',message:'Write an English word, phrase, or sentence to translate.'};
  const intent=inferEnglishIntent(text,explicitRuntime),inputTokens=lexicalTokens(normalized);
  const allSenses=[...data.senses,...(data.game_story_senses||[]),...(data.local_senses||[]),...plainMappedSenses(data)],candidateSenses=allSenses.filter(sense=>sense.route!=='label');
  const ranked=candidateSenses.map(sense=>scoreSense(sense,normalized,inputTokens)).filter(Boolean).sort((a,b)=>b.score-a.score||b.specificity-a.specificity||a.sense_id.localeCompare(b.sense_id)).slice(0,limit);
  const coverage=termCoverage(normalized,data,ranked,allSenses);
  const unresolvedSemantic=coverage.some(item=>item.status==='unresolved_semantic');
  if(!ranked.length)return{status:'ok',input:raw,normalized_input:normalized,speech_act_proposal:intent.speechAct,explicit_runtime_state:intent.runtime,runtime_inference:intent.runtimeSource,candidates:[],candidate_count:0,term_coverage:coverage,decision:{auto_resolution_allowed:false,requires_clarification:true,reasons:[unresolvedSemantic?'unresolved_semantic_content':'phonemic_labels_only'],competing_sense_ids:[]}};
  ranked.forEach(candidate=>{candidate.required_roles=candidate.target_id?data.required_roles[candidate.target_id]||[]:[]});
  const top=ranked[0],sameLemmaAmbiguity=INHERENTLY_POLYSEMOUS.has(normalize(top.lemma))&&!top.contextual_hint;
  const competesForSameHead=candidate=>top.competition_group||candidate.competition_group?Boolean(top.competition_group&&top.competition_group===candidate.competition_group):(!top.part_of_speech||!candidate.part_of_speech||candidate.part_of_speech===top.part_of_speech||normalize(candidate.lemma)===normalize(top.lemma));
  const competing=ranked.slice(1).filter(candidate=>competesForSameHead(candidate)&&(top.contextual_hint?(candidate.contextual_hint&&top.score-candidate.score<.14):(top.score-candidate.score<.14||(sameLemmaAmbiguity&&normalize(candidate.lemma)===normalize(top.lemma)))))
  const material=competing.length>0,direct=DIRECT.has(top.route),missingRoles=top.required_roles.length>0,structural=['semantic_ir','grammar'].includes(top.route),gap=top.route==='gap',hosted=Boolean(top.target_id&&data.resolution_files[top.target_id]);
  const nextSameHead=ranked.slice(1).find(competesForSameHead);
  const confident=top.score>=.76&&(top.contextual_hint||!nextSameHead||top.score-nextSameHead.score>=.14);
  const hasUnfamiliarTerms=coverage.some(item=>item.status==='phonemic_label');
  const crossDomainObject=/(?:\bfiles?\b|\bdocuments?\b|\brecords?\b)/.test(normalized);
  const underspecifiedChange=crossDomainObject&&(/\b(?:move|moves|moving|moved)\b/.test(normalized)||(/\b(?:change|changes|changing|changed)\b/.test(normalized)&&!/\b(?:contents?|represented information)\b/.test(normalized)));
  const auto=Boolean(confident&&!material&&direct&&!missingRoles&&hosted&&!unresolvedSemantic&&!underspecifiedChange);
  const reasons=[];
  if(material)reasons.push('material_sense_ambiguity');
  if(missingRoles)reasons.push('required_roles_missing');
  if(structural)reasons.push('structural_template_required');
  if(gap)reasons.push('documented_vocabulary_gap');
  if(!confident&&!material)reasons.push('low_confidence_english');
  if(direct&&!hosted)reasons.push('local_api_required');
  if(unresolvedSemantic)reasons.push('unresolved_semantic_content');
  if(underspecifiedChange)reasons.push('cross_domain_action_underspecified');
  if(hasUnfamiliarTerms&&!auto)reasons.push('phonemic_labels_present');
  return{status:'ok',input:raw,normalized_input:normalized,speech_act_proposal:intent.speechAct,explicit_runtime_state:intent.runtime,runtime_inference:intent.runtimeSource,candidates:ranked,candidate_count:ranked.length,term_coverage:coverage,decision:{auto_resolution_allowed:auto,requires_clarification:!auto,reasons,competing_sense_ids:competing.map(item=>item.sense_id)}};
}
