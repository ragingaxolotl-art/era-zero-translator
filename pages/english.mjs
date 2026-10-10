const STOPWORDS=new Set('a an the to of in on at for from with is are was were be being been do does did i you he she it we they this that these those my your his her its our their please now just may might maybe could can would will shall should perhaps possibly probably'.split(' '));
const DIRECT=new Set(['atom','compound']);
const INHERENTLY_POLYSEMOUS=new Set(['know','have','exist','receive','send','share','change','return','run','home']);

const IRREGULAR={
  am:['be'],are:['be'],is:['be'],was:['be'],were:['be'],been:['be'],
  left:['leave','depart'],went:['go'],gone:['go'],
  came:['come'],come:['come'],ran:['run'],
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
  const lemma=normalize(sense.lemma),lemmaTokens=lexicalTokens(lemma),exact=input===lemma;
  const lexical=overlap(inputTokens,lemmaTokens).length,ratio=lexical/Math.max(lemmaTokens.size,1);
  const surfaceMatch=lemmaTokens.size>0&&ratio===1;
  const hint=SENSE_HINTS.find(([pattern,key])=>key===sense.sense_key&&pattern.test(input));
  if(!exact&&!surfaceMatch&&!lexical&&!hint)return null;
  let score=exact?1:surfaceMatch?(lemmaTokens.size===1?.78:.90):Math.min(.18+.34*ratio,.52);
  if(hint)score+=hint[2];
  const cue=overlap(inputTokens,lexicalTokens((sense.selection_cues||[]).join(' '))).length;
  const definition=overlap(inputTokens,lexicalTokens(sense.definition||'')).length;
  score+=Math.min(cue*.025,.08)+Math.min(definition*.012,.07);
  if(sense.sense_key==='canonical_atom_label'&&!exact)score=Math.min(score,.62);
  score=Math.round(Math.min(score,1)*10000)/10000;
  return{sense_id:sense.sense_id,lemma:sense.lemma,sense_key:sense.sense_key,route:sense.route,target_id:sense.target_id,definition:sense.definition,selection_cues:sense.selection_cues||[],score,confidence:score>=.82?'high':score>=.62?'medium':'low',match_type:exact?'exact_lemma':hint?.[3]==='context'?'contextual_english':hint?'english_sentence':surfaceMatch?'inflected_lemma':'context_overlap',contextual_hint:hint?.[3]==='context',evidence:{lexical_overlap:lexical,selection_cue_overlap:cue,definition_overlap:definition}};
}

function termCoverage(normalized,data,ranked){
  const words=normalize(normalized).match(/[\p{L}\p{N}_-]+/gu)||[],rankBySense=new Map(ranked.map((item,index)=>[item.sense_id,{index,score:item.score,match_type:item.match_type}]));
  return words.map((word,tokenIndex)=>{
    const forms=variants(word),matches=data.senses.filter(sense=>{const lemmaTokens=lexicalTokens(sense.lemma,{keepStopwords:true}),matched=overlap(forms,lemmaTokens).length;if(!matched)return false;if(!STOPWORDS.has(word))return true;return ['grammar','semantic_ir'].includes(sense.route)&&lemmaTokens.size===1}).map(sense=>{const ranking=rankBySense.get(sense.sense_id);return{sense_id:sense.sense_id,lemma:sense.lemma,sense_key:sense.sense_key,route:sense.route,target_id:sense.target_id,definition:sense.definition,score:ranking?.score??0,match_type:ranking?.match_type??'word_match'}}).sort((a,b)=>{const exactA=normalize(a.lemma)===word?1:0,exactB=normalize(b.lemma)===word?1:0;return b.score-a.score||exactB-exactA||a.lemma.localeCompare(b.lemma)||a.sense_id.localeCompare(b.sense_id)});
    const direct=matches.filter(match=>DIRECT.has(match.route));
    const gaps=matches.filter(match=>match.route==='gap');
    const status=direct.length?'canonical':gaps.length?'documented_gap':matches.length?'structural':STOPWORDS.has(word)?'function_word':'phonemic_label';
    return{token_index:tokenIndex,term:word,status,recommended_sense_id:matches[0]?.sense_id??null,matches};
  });
}

export function analyzeEnglish(raw,data,{limit=Number.POSITIVE_INFINITY}={}){
  let text,explicitRuntime;[text,explicitRuntime]=extractExplicitRuntime(raw);
  const normalized=normalize(text);
  if(!normalized)throw{code:'empty_input',message:'Write an English word, phrase, or sentence to translate.'};
  const intent=inferEnglishIntent(text,explicitRuntime),inputTokens=lexicalTokens(normalized);
  const ranked=data.senses.map(sense=>scoreSense(sense,normalized,inputTokens)).filter(Boolean).sort((a,b)=>b.score-a.score||a.sense_id.localeCompare(b.sense_id)).slice(0,limit);
  const coverage=termCoverage(normalized,data,ranked);
  if(!ranked.length)return{status:'ok',input:raw,normalized_input:normalized,speech_act_proposal:intent.speechAct,explicit_runtime_state:intent.runtime,runtime_inference:intent.runtimeSource,candidates:[],candidate_count:0,term_coverage:coverage,decision:{auto_resolution_allowed:false,requires_clarification:true,reasons:['phonemic_labels_only'],competing_sense_ids:[]}};
  ranked.forEach(candidate=>{candidate.required_roles=candidate.target_id?data.required_roles[candidate.target_id]||[]:[]});
  const top=ranked[0],sameLemmaAmbiguity=INHERENTLY_POLYSEMOUS.has(normalize(top.lemma))&&!top.contextual_hint,competing=ranked.slice(1).filter(candidate=>top.contextual_hint?(candidate.contextual_hint&&top.score-candidate.score<.14):(top.score-candidate.score<.14||(sameLemmaAmbiguity&&normalize(candidate.lemma)===normalize(top.lemma)))),material=competing.length>0,direct=DIRECT.has(top.route),missingRoles=top.required_roles.length>0,structural=['semantic_ir','grammar'].includes(top.route),gap=top.route==='gap',hosted=Boolean(top.target_id&&data.resolution_files[top.target_id]);
  const confident=top.score>=.76&&(top.contextual_hint||!ranked[1]||top.score-ranked[1].score>=.14);
  const hasUnfamiliarTerms=coverage.some(item=>item.status==='phonemic_label');
  const auto=Boolean(confident&&!material&&direct&&!missingRoles&&hosted);
  const reasons=[];
  if(material)reasons.push('material_sense_ambiguity');
  if(missingRoles)reasons.push('required_roles_missing');
  if(structural)reasons.push('structural_template_required');
  if(gap)reasons.push('documented_vocabulary_gap');
  if(!confident&&!material)reasons.push('low_confidence_english');
  if(direct&&!hosted)reasons.push('local_api_required');
  if(hasUnfamiliarTerms&&!auto)reasons.push('phonemic_labels_present');
  return{status:'ok',input:raw,normalized_input:normalized,speech_act_proposal:intent.speechAct,explicit_runtime_state:intent.runtime,runtime_inference:intent.runtimeSource,candidates:ranked,candidate_count:ranked.length,term_coverage:coverage,decision:{auto_resolution_allowed:auto,requires_clarification:!auto,reasons,competing_sense_ids:competing.map(item=>item.sense_id)}};
}
