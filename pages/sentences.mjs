import {renderLexicalOccurrences,lexicalGloss} from './bound_compounds.mjs';
import {NOMINAL_PATTERN,parseNominal} from './nominals.mjs';
import {registerFor} from './roles.mjs';
import {canonicalDigest} from './engine.mjs';
import {encodeName, notesForName} from './names.mjs';
import {deicticReference,deicticEvent,nominalMarker} from './references.mjs';

// Reviewed constructions use exact process senses, never a generic synonym pool.
const ACTIONS = [
  {pattern:'is physically supporting',predicate:'CMP:eef9fff8ac6618ce60927f18',key:'active_physical_load_support',wording:'is physically supporting',role:'source',targetRole:'target',compoundSlots:{source:['s-source'],target:['s-target']},semanticNote:'Physical load-bearing support: this source bears at least part of the distinct material load. This does not assert carrying, movement, intention, or emotional support.'},
  {pattern:'has a directed data link to',negativePattern:'does not have a directed data link to',predicate:'CMP:742b44d9ead66b451346708a',key:'directed_data_link',wording:'has a directed data link to',role:'source',targetRole:'target',compoundSlots:{source:['a-source-01'],target:['a-target-01']},semanticNote:'An established directed communication relation with bounded data content; it does not assert an ongoing transfer.'},
  {pattern:'is registering optical input from',predicate:'CMP:bcfd189eb305cf364ada975a',key:'ongoing_optical_registration',wording:'is registering optical input from',role:'target',targetRole:'source',semanticNote:'Optical sensory registration uses a light-carried input. It does not by itself assert conscious seeing, attention, recognition, color, or understanding.'},
  {pattern:'is registering acoustic input from',predicate:'CMP:42e9bd596b35612ed6cbe3ce',key:'ongoing_acoustic_registration',wording:'is registering acoustic input from',role:'target',targetRole:'source',semanticNote:'Acoustic sensory registration uses a propagating mechanical pressure or elastic vibration signal. It does not by itself assert conscious hearing, attention, recognition, speech comprehension, or understanding.'},
  {pattern:'is registering sensory input from',predicate:'CMP:ade73037114406a2cd91ce13',key:'ongoing_sensory_registration',wording:'is registering sensory input from',role:'target',targetRole:'source',semanticNote:'Sensory registration is physical sensory transduction of information from this source into this receiver. It does not by itself assert consciousness, attention, recognition, understanding, or a particular sensory channel.'},
  {pattern:'(?:can repair|is able to repair)',negativePattern:'(?:cannot repair|can not repair|is not able to repair|is unable to repair)',predicate:'REP:211',key:'available_target_repair',wording:'can repair',semanticNote:'Can means currently enabled to restore this target under applicable conditions; it does not assert permission, ongoing repair, or guaranteed success.'},
  {pattern:'(?:can restore|is able to restore)',negativePattern:'(?:cannot restore|can not restore|is not able to restore|is unable to restore)',predicate:'REP:211',key:'available_target_restoration',wording:'can restore',semanticNote:'Can means currently enabled to restore this target under applicable conditions; it does not assert permission, ongoing restoration, or guaranteed success.'},
  {pattern:'(?:loves|is loving)', negativePattern:'(?:does not love|is not loving)', predicate:'CMP:44718c92b66443c0c0f03ad7', key:'approved_poetic_love', wording:'loves', semanticNote:'DBA poetic love: an established life-bond characterized by self-awakening and the preserved, not-yet-expressed self.'},
  {pattern:'is paying attention to', predicate:'MIN:211', key:'active_target_attention', wording:'is paying attention to', role:'experiencer'},
  {pattern:'is revising a mental representation of', predicate:'MIN:111', key:'active_target_model_revision', wording:'is revising a mental representation of', role:'experiencer'},
  {pattern:'is moving toward', predicate:'MOV:111', key:'active_target_approach', wording:'is moving toward', targetRole:'destination'},
  {pattern:'is moving away from', predicate:'MOV:101', key:'active_source_departure', wording:'is moving away from', targetRole:'source'},
  {pattern:'is moving relative to', predicate:'MOV:121', key:'active_shared_frame_movement', wording:'is moving relative to', targetRole:'environment'},
  {pattern:'(?:cares for|is caring for)', predicate:'LIF:211', key:'active_care', gloss:'active care', wording:'actively cares for'},
  {pattern:'is awakening', predicate:'LIF:111', key:'active_other_awakening', gloss:'actively awaken another', wording:'is awakening'},
  {pattern:'is restoring', predicate:'REP:111', key:'active_target_restoration', gloss:'active target restoration', wording:'is restoring'},
  {pattern:'is damaging', predicate:'WRN:111', key:'active_target_impairment', gloss:'active target impairment', wording:'is damaging'},
  {pattern:'is repairing', predicate:'REP:111', key:'ongoing_target_repair', wording:'is repairing'},
  {pattern:'is physically repairing', predicate:'CMP:2816a7eeb356c2148b26beca', key:'ongoing_physical_repair', wording:'is physically repairing'}
];
const DESCRIPTIONS = [
  {pattern:'(?:damaged|impaired)', predicate:'WRN:001', key:'present_internal_impairment', wording:'is impaired', semanticNote:'Damaged or impaired describes a present intrinsic adverse condition relative to the bearer’s accepted state. It does not identify a damaging agent, mechanism, or ongoing damaging event.'},
  {pattern:'restored', predicate:'REP:001', key:'present_internal_restored_state', wording:'is restored', semanticNote:'Restored describes the bearer’s applicable internal restoration condition as presently realized. It does not identify a restorer or assert that restoration is still in progress.'},
  {pattern:'able to pay attention', predicate:'MIN:201', key:'available_attentional_capacity', wording:'is able to pay attention'},
  {pattern:'conscious', predicate:'LIF:011', key:'conscious_other', wording:'is conscious'},
  {pattern:'dormant', predicate:'LIF:012', key:'dormant_other', wording:'is dormant'}
];
// Shift a decimal percentage by two places without binary floating point.
export function confidenceFromPercent(value) {
  if(typeof value!=='string'||value.length>1000||!/^\d+(?:\.\d+)?$/.test(value))return null;
  let [whole,fraction='']=value.split('.');whole=whole.replace(/^0+/,'')||'0';
  if(whole.length>3||Number(whole)>100||(whole==='100'&&/[1-9]/.test(fraction)))return null;
  const padded=whole.padStart(3,'0'),integer=padded.slice(0,-2),decimal=(padded.slice(-2)+fraction).replace(/0+$/,'');
  return integer+(decimal?'.'+decimal:'');
}
function participantIdentity(text){
  const nominal=parseNominal(text);
  if(nominal)return `nominal:${nominal.mode}:${nominal.head}:${nominal.quantifier||''}:${nominal.value||''}`;
  if(['I','me','Me'].includes(text))return 'discourse:speaker';
  if(['You','you'].includes(text))return 'discourse:addressee';
  return 'name:'+text.replaceAll('"','').toLowerCase();
}
export function parseNamedSentence(input, depth=0, speechActs=depth===0) {
  if(depth>16)return null;
  const explicitState=String(input).trim().match(/^(.*?)\s+\[([012])\]([.!?]?)$/);
  if(explicitState){
    const content=explicitState[1].trim(),punctuation=explicitState[3],existing=content.match(/[.!?]$/)?.[0];
    if(existing&&punctuation&&existing!==punctuation)return null;
    const inner=parseNamedSentence(content+(existing?'':punctuation),depth+1,speechActs);
    if(!inner||inner.runtimeState!==undefined)return null;
    return {...inner,runtimeState:Number(explicitState[2])};
  }
  const participant='(I|me|you|'+NOMINAL_PATTERN+'|(?!(?:She|He|It|They|We|Her|Him|Them|Us)\\b)[A-Z][a-z]+|"[A-Za-z]+(?:[ -][A-Za-z]+)*")';
  if(speechActs){
    const commands=[['care for','cares for'],['restore','is restoring'],['repair','is repairing'],['awaken','is awakening'],['damage','is damaging'],['physically repair','is physically repairing'],['move toward','is moving toward'],['move away from','is moving away from'],['move relative to','is moving relative to'],['pay attention to','is paying attention to'],['revise a mental representation of','is revising a mental representation of']];
    for(const [verb,wording] of commands){
      const command=String(input).trim().match(new RegExp(`^(?:[Dd]o not )?${verb} ${participant}[.!]?$`,'i'));
      if(command){
        const negative=/^[Dd]o not /.test(String(input).trim());
        const predicate=negative?(verb==='care for'?'does not care for':wording.replace('is ','is not ')):wording;
        const inner=parseNamedSentence(`you ${predicate} ${command[1]}.`,depth+1);
        if(!inner)return null;
        return {...inner,speechAct:'command',construction:`command_${inner.construction}`,explicitInterpretation:String(input).trim()};
      }
    }
    const question=String(input).trim().match(new RegExp(`^(?:[Ii]s|[Aa]re|[Aa]m) ${participant} (.+)\\?$`));
    const careQuestion=String(input).trim().match(new RegExp(`^[Dd]o(?:es)? ${participant} (not )?care for ${participant}\\?$`));
    const pastQuestion=String(input).trim().match(new RegExp(`^(?:[Ww]as|[Ww]ere) ${participant} (.+)\\?$`));
    const didQuestion=String(input).trim().match(new RegExp(`^[Dd]id ${participant} (not )?(care for|restore|repair|awaken|damage|physically repair) ${participant}( (?:yesterday|today))?\\?$`));
    const pastVerbs={'care for':'cared for',restore:'restored',repair:'repaired',awaken:'awakened',damage:'damaged','physically repair':'physically repaired'};
    const statement=question?`${question[1]} is ${question[2]}.`:careQuestion?`${careQuestion[1]} ${careQuestion[2]?'does not care for':'cares for'} ${careQuestion[3]}.`:pastQuestion?`${pastQuestion[1]} was ${pastQuestion[2]}.`:didQuestion?`${didQuestion[1]} ${didQuestion[2]?'did not '+didQuestion[3]:pastVerbs[didQuestion[3]]} ${didQuestion[4]}${didQuestion[5]||''}.`:null;
    if(statement){
      const inner=parseNamedSentence(statement,depth+1);
      if(!inner)return null;
      return {...inner,speechAct:'question',construction:`question_${inner.construction}`,explicitInterpretation:String(input).trim()};
    }
  }
  const confidence=String(input).trim().match(/^[Ww]ith ([0-9]+(?:\.[0-9]+)?)% confidence, (.+)$/);
  if(confidence){
    const strength=confidenceFromPercent(confidence[1]),inner=parseNamedSentence(confidence[2],depth+1);
    if(strength===null||!inner?.scopes?.length)return null;
    const outer=inner.scopes.at(-1);
    // Attaching confidence to an outer negation would require a distinct scope.
    if(outer.operator!=='modality'||!['possible','necessary','predicted'].includes(outer.mode)||outer.strength!==undefined)return null;
    return {...inner,scopes:[...inner.scopes.slice(0,-1),{...outer,strength}],construction:`confidence_${inner.construction}`,explicitInterpretation:String(input).trim().replace(/\.$/,'')+'.'};
  }
  const modal=String(input).trim().match(/^[Ii]t is (not )?(possible|necessary) that (.+)$/);
  if(modal){
    const inner=parseNamedSentence(modal[3],depth+1);
    if(!inner||inner.calendarDay!==undefined||inner.speechTime!==undefined)return null;
    const scopes=[...(inner.scopes||[]),{operator:'modality',mode:modal[2]}];
    if(modal[1])scopes.push({operator:'negation'});
    return {...inner,scopes,construction:`scoped_${inner.construction}`,explicitInterpretation:String(input).trim().replace(/\.$/,'')+'.'};
  }
  // Calendar-day statements retain their interval; tense is not runtime state.
  const calendar=String(input).trim().match(/^(.*?) (yesterday|today|tomorrow)[.]?$/);
  if(calendar){
    let clause=calendar[1];
    const day=calendar[2];
    const rewrite=(forms)=>{
      for(const [surface,replacement] of forms){
        const match=clause.match(new RegExp(`^${participant} ${surface} (.+)$`));
        if(match)return `${match[1]} ${replacement} ${match[2]}`;
      }
      return null;
    };
    if(day==='tomorrow')clause=rewrite([['will not be','is not'],['will be','is'],['will not care for','does not care for'],['will care for','cares for']]);
    if(clause===null)return null;
    const inner=parseNamedSentence(clause,depth+1);
    if(!inner||inner.calendarDay!==undefined||inner.scopes?.length||inner.speechAct||(day==='yesterday'&&inner.speechTime!=='before')||(day==='tomorrow'&&inner.speechTime!==undefined))return null;
    return {...inner,...(day==='yesterday'?{speechTime:undefined}:{}),...(day==='tomorrow'?{semanticNote:[inner.semanticNote,'Interprets will as a future assertion; promise, intention, and willingness are not inferred.'].filter(Boolean).join(' ')}:{}),calendarDay:{yesterday:'-1',today:'0',tomorrow:'1'}[day],construction:`calendar_${inner.construction}`,explicitInterpretation:String(input).trim().replace(/\.$/,'')+'.'};
  }
  const pastForms=[
    ['was','is'],['were','is'],['cared for','cares for'],['did not care for','does not care for'],
    ['repaired','is repairing','REP:110'],['did not repair','is not repairing','REP:110'],
    ['restored','is restoring','REP:110'],['did not restore','is not restoring','REP:110'],
    ['awakened','is awakening','LIF:110'],['did not awaken','is not awakening','LIF:110'],
    ['damaged','is damaging','WRN:110'],['did not damage','is not damaging','WRN:110'],
    ['physically repaired','is physically repairing','CMP:22f8ddc4d9b2d1a818d38e9f'],
    ['did not physically repair','is not physically repairing','CMP:22f8ddc4d9b2d1a818d38e9f']
  ];
  for(const [surface,replacement,completedPredicate] of pastForms){
    const match=String(input).trim().match(new RegExp(`^${participant} ${surface} (.+)$`));
    if(!match)continue;
    const inner=parseNamedSentence(`${match[1]} ${replacement} ${match[2]}`,depth+1);
    if(!inner||inner.calendarDay!==undefined||inner.speechTime!==undefined||inner.scopes?.length||inner.speechAct)return null;
    return {...inner,...(completedPredicate?{predicate:completedPredicate}:{}),speechTime:'before',construction:`past_${inner.construction}`,explicitInterpretation:String(input).trim().replace(/\.$/,'')+'.'};
  }
  const path=String(input).trim().match(new RegExp(`^${participant} (?:is|am|are) (not )?moving from ${participant} (?:to|toward) ${participant}[.]?$`));
  if(path){
    const texts=[path[1],path[3],path[4]],counted=texts.filter(text=>parseNominal(text)?.quantifier);
    if(new Set(texts.map(participantIdentity)).size!==3||(counted.length&&(path[2]||counted.length>1)))return null;
    return {...(counted.length?{quantifiedParticipants:true}:{}),predicate:'MOV:111',key:'active_path_approach',construction:`named_active_path_approach${path[2]?'_negated':''}`,negated:!!path[2],
      participants:texts.map((text,index)=>({text,label:text.replaceAll('"',''),role:['actor','source','destination'][index]})),
      explicitInterpretation:String(input).trim().replace(/\.$/,'')+'.'};
  }
  const transfer=String(input).trim().match(new RegExp(`^[Dd]ata ${participant} is (not )?being transferred from ${participant} to ${participant}[.]?$`));
  if(transfer){
    const counted=[transfer[1],transfer[3],transfer[4]].filter(text=>parseNominal(text)?.quantifier);
    if(counted.length&&(transfer[2]||counted.length>1))return null;
    if(participantIdentity(transfer[3])===participantIdentity(transfer[4]))return null;
    const label=value=>value.replaceAll('"','');
    return {...(counted.length?{quantifiedParticipants:true}:{}),predicate:'DAT:111',key:'active_data_transfer',construction:`named_active_data_transfer${transfer[2]?'_negated':''}`,negated:!!transfer[2],
      participants:[{label:label(transfer[3]),text:transfer[3],role:'source'},{label:label(transfer[1]),text:transfer[1],role:'content'},{label:label(transfer[4]),text:transfer[4],role:'target'}],
      explicitInterpretation:String(input).trim().replace(/\.$/,'')+'.'};
  }
  const massPair=String(input).trim().match(new RegExp(`^${participant} (?:has|have) (more mass than|greater mass than|less mass than|the same mass as|at least as much mass as|at most as much mass as|a different mass from) ${participant}[.]?$`));
  if(massPair){
    if([massPair[1],massPair[3]].some(text=>parseNominal(text)?.quantifier))return null;
    const relation=({'more mass than':'greater_than','greater mass than':'greater_than','less mass than':'less_than','the same mass as':'equal','at least as much mass as':'at_least','at most as much mass as':'at_most','a different mass from':'not_equal'})[massPair[2]];
    return {actor:massPair[1].replaceAll('"',''),actorText:massPair[1],target:massPair[3].replaceAll('"',''),targetText:massPair[3],role:'bearer',targetRole:'comparison_standard',predicate:massPair[1]==='I'?'MAT:000':'MAT:010',
      key:'mass_pair_comparison',construction:'mass_pair_comparison',scopes:[{operator:'comparison',dimension:'mass',relation}],
      semanticNote:'Compares the first bearer’s physical mass with the second bearer’s mass. No numeric value, weight force, perceived burden, or contextual heavy/light threshold is asserted.'};
  }
  const mass=String(input).trim().match(new RegExp(`^${participant} (has|have) a mass (?:of )?(?:(more than|greater than|less than|at least|at most|not exactly|exactly) )?([0-9]+(?:\\.[0-9]+)?) (grams?|kilograms?)[.]?$`));
  if(mass){
    const nominal=parseNominal(mass[1]);
    if(nominal?.quantifier||mass[4].length>1000)return null;
    if(['I','you','You'].includes(mass[1])?(mass[2]!=='have'):(mass[2]!=='has'))return null;
    let [whole,fraction='']=mass[4].split('.');
    if(mass[5].startsWith('gram')){whole=whole.padStart(4,'0');fraction=whole.slice(-3)+fraction;whole=whole.slice(0,-3);}
    whole=whole.replace(/^0+/,'')||'0';fraction=fraction.replace(/0+$/,'');
    const magnitude=whole+(fraction?'.'+fraction:'');
    return {actor:mass[1].replaceAll('"',''),actorText:mass[1],role:'bearer',predicate:mass[1]==='I'?'MAT:000':'MAT:010',key:'mass_measurement',construction:'mass_measurement',
      measurement:{magnitude,unit:'kilogram',...((mass[3]&&mass[3]!=='exactly')?{comparison:({'more than':'greater_than','greater than':'greater_than','less than':'less_than','at least':'at_least','at most':'at_most','not exactly':'not_equal'})[mass[3]]}:{})},semanticNote:'This states physical mass, normalized exactly to kilograms. It does not state weight as force, size, heaviness relative to a standard, or the result of a weighing event.'};
  }
  const grammaticalText=String(input).trim().replace(new RegExp(`^(${NOMINAL_PATTERN}) are `),'$1 is ').replace(/^I am /,'I is ').replace(/^(You|you) are /,'$1 is ').replace(/^(I|You|you) care for /,'$1 cares for ').replace(/^(I|You|you) do not (care for|love|have a directed data link to) /,'$1 does not $2 ').replace(/^(I|You|you) have a directed data link to /,'$1 has a directed data link to ').replace(/^(I|You|you) love /,'$1 loves ');
  for(const action of ACTIONS){
    for(const negated of [false,true]){
      const pattern=negated?(action.negativePattern||(action.key==='active_care'?'(?:does not care for|is not caring for)':action.pattern.replace('is ','is not '))):action.pattern;
      const match=grammaticalText.match(new RegExp(`^${participant} ${pattern} ${participant}[.]?$`));
      if(match&&action.key==='approved_poetic_love'&&(match[1].startsWith('"')||match[2].startsWith('"')||parseNominal(match[1])||parseNominal(match[2])))return null;
      const quantified=match&&[match[1],match[2]].some(text=>parseNominal(text)?.quantifier);
      if(quantified&&(action.compoundSlots||negated||[match[1],match[2]].filter(text=>parseNominal(text)?.quantifier).length>1))return null;
      if(match&&participantIdentity(match[1])===participantIdentity(match[2]))return null;
      if(match)return {...(quantified?{quantifiedParticipants:true}:{}),actor:match[1].replaceAll('"',''),target:match[2].replaceAll('"',''),actorText:match[1],targetText:match[2],...action,negated,construction:`named_${action.key}${negated?'_negated':''}`};
    }
  }
  for(const description of DESCRIPTIONS){
    const match=grammaticalText.match(new RegExp(`^${participant} is (not )?${description.pattern}[.]?$`));
    const quantified=match&&!!parseNominal(match[1])?.quantifier;
    if(quantified&&match[2])return null;
    if(match)return {...(quantified?{quantifiedParticipants:true}:{}),actor:match[1].replaceAll('"',''),actorText:match[1],...description,predicate:match[1]==='I'?({'LIF:011':'LIF:001','LIF:012':'LIF:002'}[description.predicate]||description.predicate):description.predicate,role:'bearer',negated:!!match[2],construction:`named_${description.key}${match[2]?'_negated':''}`};
  }
  return null;
}

// Recognize the construction family even when additional meaning makes its
// current complete parser decline. The legacy keyword path may still offer
// dictionary readings, but must not present one as the complete sentence.
export function needsSentenceComposition(input) {
  return (/^[Ii]f\b/.test(String(input)) || /\b(?:it\s+is\s+(?:not\s+)?(?:possible|necessary)\s+that|with\s+[0-9.]+%\s+confidence|(?:care|cares|caring)\s+for|awakening|restoring|damaging|repairing|moving|transferred|attention|revising|conscious|dormant|damaged|impaired|restored|registering)\b/i.test(String(input))) && !parseNamedSentence(input);
}

// A complete antecedent and a comma establish conditional scope. Without
// explicit "then", currently accept only an imperative consequent.
export function parseSentenceConditional(input) {
  const text=String(input).trim().replace(/\.$/,'');
  if(!/^[Ii]f /.test(text))return null;
  let quoted=false;const commas=[],explicitBoundaries=[];
  for(let i=3;i<text.length;i++){
    if(text[i]==='"')quoted=!quoted;
    if(!quoted&&text[i]===','){commas.push(i);if(/^,\s+then\s+/.test(text.slice(i)))explicitBoundaries.push(i);}
  }
  const boundaries=explicitBoundaries.length?explicitBoundaries:commas;
  if(quoted||boundaries.length!==1)return null;
  const i=boundaries[0],antecedent=text.slice(3,i).trim();
  let consequent=text.slice(i+1).trim();
  const explicitThen=/^then\s+/.test(consequent);
  if(explicitThen)consequent=consequent.replace(/^then\s+/,'');
  const condition=parseNamedSentence(antecedent);
  if(!condition||condition.speechAct)return null;
  // Local "it" requires a single definite nominal bearer. Multiple participants,
  // quantified classes and discourse-dependent pronouns need clarification.
  if(/\bit(?=\s*(?:\[[012]\])?[.!]?$)/i.test(consequent)){
    const reference=parseNominal(condition.actorText||'');
    if(condition.role!=='bearer'||condition.target||reference?.mode!=='definite_nominal')return null;
    consequent=consequent.replace(/\bit(?=\s*(?:\[[012]\])?[.!]?$)/i,condition.actorText);
  }
  const result=parseNamedSentence(consequent);
  if(!result||result.speechAct==='question'||(!explicitThen&&result.speechAct!=='command'))return null;
  return [antecedent,consequent];
}
export async function composeSentenceConditional(input,loadTemplate) {
  return composeClauseGroup(input,parseSentenceConditional(input),'conditional',loadTemplate);
}

export function parseSentenceSequence(input) { return parseClauseGroup(input,/^(?:,\s*|\s+)then\s+/); }
export function parseSentenceConjunction(input) { return parseClauseGroup(input,/^(?:,\s*|\s+)and\s+/); }
function parseClauseGroup(input,delimiter) {
  const text=String(input).trim().replace(/\.$/,'');
  let quoted=false,start=0;const clauses=[];
  for(let i=0;i<text.length;i++){
    if(text[i]==='"')quoted=!quoted;
    if(!quoted){
      const match=text.slice(i).match(delimiter);
      if(match){clauses.push(text.slice(start,i).trim());i+=match[0].length-1;start=i+1;}
    }
  }
  if(quoted||!clauses.length)return null;
  // Without explicit grouping a leading modal can scope one clause or the
  // entire sequence. Do not guess that attachment.
  if(/^(?:[Ii]t is (?:not )?(?:possible|necessary) that |[Ww]ith [0-9.]+% confidence, )/.test(text))return null;
  clauses.push(text.slice(start).trim());
  if(clauses.slice(0,-1).some(clause=>/^(?:[Ii]t is (?:not )?(?:possible|necessary) that |[Ww]ith [0-9.]+% confidence, )/.test(clause)))return null;
  if(clauses.length>32||clauses.some(clause=>{const parsed=parseNamedSentence(clause);return !parsed||!!parsed.speechAct}))return null;
  return clauses;
}

export async function composeSentenceSequence(input,loadTemplate) {
  const clauses=parseSentenceSequence(input);
  return composeClauseGroup(input,clauses,'sequence',loadTemplate);
}

export async function composeSentenceConjunction(input,loadTemplate) {
  return composeClauseGroup(input,parseSentenceConjunction(input),'all_of',loadTemplate);
}

async function composeClauseGroup(input,clauses,operator,loadTemplate) {
  if(!clauses)throw new Error('Every clause must have a complete, unambiguous interpretation.');
  const conditional=operator==='conditional';
  const groupId=conditional?'conditional':operator==='sequence'?'sequence':'conjunction';
  const parts=await Promise.all(clauses.map(async clause=>composeNamedSentence(clause,await loadTemplate(parseNamedSentence(clause).predicate))));
  const ir={ir_version:'1.0',root_clause:'c',speech_act:conditional?parts[1].semantic_ir.speech_act:'assertion',nodes:[{node_id:'c',kind:'clause',clause_type:conditional?'conditional':'predication'},...(conditional?[]:[{node_id:groupId,kind:'coordination',operator}])],
    edges:[{edge_id:'e0',type:'centers',from:conditional?'s001_c':groupId,to:'c'}],discourse_constraints:{}};
  const events=[],gloss=[];
  parts.forEach((part,index)=>{
    const prefix=`s${String(index).padStart(3,'0')}_`;
    ir.nodes.push(...part.semantic_ir.nodes.map(node=>({...structuredClone(node),node_id:prefix+node.node_id,...(node.compound_bindings?{compound_bindings:node.compound_bindings.map(binding=>({...binding,argument_id:prefix+binding.argument_id}))}:{})})));
    ir.edges.push(...part.semantic_ir.edges.map(edge=>({...edge,edge_id:prefix+edge.edge_id,from:prefix+edge.from,to:prefix+edge.to})));
    if(!conditional)ir.edges.push({edge_id:`member${index}`,type:'member_of',from:prefix+'c',to:groupId,...(operator==='sequence'?{order:index+1}:{})});
    events.push(...part.formal.performance.lexical_events.map(event=>({...structuredClone(event),occurrence_id:prefix+event.occurrence_id,...(event.argument_node_id?{argument_node_id:prefix+event.argument_node_id}:{}),...(event.binding_chain?{binding_chain:event.binding_chain.map(binding=>({...binding,compound_occurrence_id:prefix+binding.compound_occurrence_id,argument_id:prefix+binding.argument_id}))}:{})})));
    gloss.push(part.formal.literal_gloss.split(' | ').map(value=>prefix+value).join(' | '));
  });
  if(conditional)ir.edges.push({edge_id:'condition',type:'condition_of',from:'s000_c',to:'s001_c',condition_status:'open'});
  const digest=await canonicalDigest(ir);
  ir.utterance_id=`UTT:${digest.slice(0,24)}`;ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
  const structural=ir.edges.slice().sort((a,b)=>a.edge_id<b.edge_id?-1:a.edge_id>b.edge_id?1:0).map(edge=>({edge_id:edge.edge_id,edge_type:edge.type,from:edge.from,to:edge.to,...(edge.role?{role:edge.role}:{}),...(edge.relation?{relation:edge.relation}:{}),boundary:edge.type==='fills_role'?'short_gap':'medium_gap',boundary_beats:edge.type==='fills_role'?.5:1}));
  const performance={...structuredClone(parts[conditional?1:0].formal.performance),lexical_events:events,structural_events:structural,...(conditional?{secondary_contours:['unresolved_ending']}:{})};
  const relative=events.map(event=>{
    const {base_midi,family_opening_absolute_midi,address_absolute_midi,...copy}=event;
    copy.runtime_tail=event.runtime_tail?Object.fromEntries(Object.entries(event.runtime_tail).filter(([key])=>key!=='absolute_note')):null;
    return copy;
  });
  const relativePlan={primary_contour:performance.primary_contour,contour_relative_semitones:performance.contour_relative_semitones,secondary_contours:performance.secondary_contours,lexical_events:relative,structural_events:structural,statement_boundary:performance.statement_boundary,statement_boundary_beats:performance.statement_boundary_beats};
  const formalDigest=await canonicalDigest({semantic_digest:digest,relative_plan:relativePlan});
  const formal={format:'EZF-1',renderer_version:'1.0.0',formal_id:`EZF:${formalDigest.slice(0,24)}`,formal_digest:formalDigest,semantic_digest:digest,semantic_ir:ir,performance,literal_gloss:gloss.join(' | ')};
  return {source_input:input,target_id:operator,semantic_note:[...new Set(parts.map(part=>part.semantic_note).filter(Boolean))].join(' ')||null,sense_id:`construction:explicit_${groupId}`,surface_fidelity:'complete_construction',controlled_input:'',semantic_ir:ir,formal,construction:`explicit_${groupId}`,interpretation:(conditional?'If ':'')+parts.map(part=>part.interpretation.replace(/\.$/,'')).join(conditional||operator==='sequence'?', then ':' and ')+'.'};
}

export async function composeNamedSentence(input,template) {
  const parsed=parseNamedSentence(input);
  if(!parsed)throw new Error('The complete sentence does not match this construction.');
  const bound=!!parsed.compoundSlots;
  if(bound&&!template.authority)throw new Error('Bound construction requires the compiled dictionary authority.');
  const source=bound?{semantic_ir:{speech_act:'assertion',nodes:[{node_id:'c',kind:'clause'},{node_id:'p',kind:'lexical_occurrence',target_type:'compound',target_id:parsed.predicate,runtime_state:{code:1}}],edges:[{type:'centers'}]},performance:{profile:'reference-midi-v1',anchor_midi:60,transposition_semantically_significant:false,primary_contour:'level',contour_relative_semitones:[0,0],secondary_contours:[],statement_boundary:'long_gap',statement_boundary_beats:2}}:template.formal;
  const predicates=source.semantic_ir.nodes.filter(node=>node.kind==='lexical_occurrence');
  if(source.semantic_ir.speech_act!=='assertion' || source.semantic_ir.nodes.length!==2 || source.semantic_ir.edges.length!==1 || source.semantic_ir.edges[0].type!=='centers' || source.performance.anchor_midi!==60 || predicates.length!==1 || predicates[0].target_id!==parsed.predicate || predicates[0].runtime_state?.code!==1)
    throw new Error('Expected the matching canonical action assertion template at anchor 60.');
  const participants=parsed.participants||[{label:parsed.actor,text:parsed.actorText,role:parsed.role||'actor'},...(parsed.target?[{label:parsed.target,text:parsed.targetText,role:parsed.targetRole||'target'}]:[])];
  const participantIds=participants.map((_,index)=>index<2?['a','b'][index]:`d${index}`);
  const deicticRoles=participants.map(({text})=>['I','me','Me'].includes(text)?'speaker':['you','You'].includes(text)?'addressee':null);
  const nominal=participants.map(({text})=>parseNominal(text));
  const names=await Promise.all(participants.map(({label},index)=>deicticRoles[index]?null:encodeName(nominal[index]?nominal[index].head:label)));
  const references=names.map((name,index)=>deicticRoles[index]?deicticReference(deicticRoles[index],participantIds[index]):({node_id:participantIds[index],kind:'phonemic_reference',referent_id:nominal[index]?`nominal:${nominal[index].mode==='definite_nominal'?'definite':'class'}:${name.name_id}`:name.name_id,value_type:'entity',name,...(nominal[index]?{reference_mode:nominal[index].mode}:{})}));
  const ir={ir_version:'1.0',root_clause:'c',speech_act:parsed.speechAct||'assertion',nodes:[{node_id:'c',kind:'clause',clause_type:'predication'},
    {node_id:'p',kind:'lexical_occurrence',target_type:predicates[0].target_type,target_id:parsed.predicate,runtime_state:{code:parsed.runtimeState??1}},...references],
    edges:[{edge_id:'e0',type:'centers',from:'p',to:'c'},...participants.map((participant,index)=>({edge_id:`e${index+1}`,type:'fills_role',from:participantIds[index],to:'p',role:participant.role}))],discourse_constraints:{}};
  if(bound){
    if(nominal.some(description=>description?.quantifier))throw new Error('Quantified compound participants are not supported by this construction.');
    ir.nodes[1].compound_bindings=participants.map((participant,index)=>({slot_path:parsed.compoundSlots[participant.role],argument_id:participantIds[index]}));
    ir.edges=ir.edges.filter(edge=>edge.type!=='fills_role');
  }
  nominal.forEach((description,index)=>{
    if(!description?.quantifier)return;
    const id=`quantity${index}`;
    ir.nodes.push({node_id:id,kind:'scope_operator',operator:'quantifier',quantifier:description.quantifier,value:description.value});
    ir.edges[index+1].from=id;
    ir.edges.push({edge_id:`quantity${index}`,type:'scopes',from:participantIds[index],to:id});
  });
  if(parsed.measurement){
    ir.nodes.push({node_id:'measure',kind:'measurement',...parsed.measurement});
    ir.edges.push({edge_id:'measurement',type:'fills_role',from:'measure',to:'p',role:'quantity'});
  }
  if(parsed.negated){
    ir.nodes.push({node_id:'neg',kind:'scope_operator',operator:'negation'});
    ir.edges[0].from='neg';
    ir.edges.push({edge_id:`e${Math.max(3,participants.length+1)}`,type:'scopes',from:'p',to:'neg'});
  }
  for(const [index,scope] of (parsed.scopes||[]).entries()){
    const id=`scope${String(index).padStart(2,'0')}`;
    ir.nodes.push({node_id:id,kind:'scope_operator',...scope});
    ir.edges.push({edge_id:`zscope${String(index).padStart(2,'0')}`,type:'scopes',from:ir.edges[0].from,to:id});
    ir.edges[0].from=id;
  }
  if(parsed.calendarDay!==undefined){
    ir.nodes.push({node_id:'time',kind:'time_anchor',anchor_type:'interval',calendar_unit:'day',relative_to:'speech_date',day_offset:parsed.calendarDay});
    ir.edges.push({edge_id:'time0',type:'time_relation',from:'time',to:'c',relation:'during'});
  }
  if(parsed.speechTime!==undefined){
    ir.nodes.push({node_id:'speech_time',kind:'time_anchor',anchor_type:'speech_time'});
    ir.edges.push({edge_id:'time1',type:'time_relation',from:'speech_time',to:'c',relation:parsed.speechTime});
  }
  const digest=await canonicalDigest(ir);
  ir.utterance_id=`UTT:${digest.slice(0,24)}`;
  ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
  const events=bound?await renderLexicalOccurrences(ir,template.authority):names.flatMap((name,index)=>{
    const register=registerFor(participantIds[index],ir);
    if(deicticRoles[index])return [deicticEvent(references[index],register)];
    const offset={low:-12,middle:0,high:12,sustained_background:-5}[register],notes=notesForName(name);
    const labelEvent={kind:'phonemic_label',occurrence_id:participantIds[index],target_id:name.name_id,referent_id:references[index].referent_id,label:name.normalized_label,semantic_claim:false,
      register,base_midi:60+offset,family_qualified_transliteration:name.normalized_label,formal_carrier:'',
      family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:notes.map(note=>note-60),address_absolute_midi:notes.map(note=>note+offset),note_duration_beats:1};
    return nominal[index]?[nominalMarker(references[index],register),labelEvent]:[labelEvent];
  });
  if(!bound)events.push(...source.performance.lexical_events.map(event=>{
    const copy={...structuredClone(event),occurrence_id:'p'};
    if(copy.runtime_tail&&parsed.runtimeState!==undefined){
      const code=parsed.runtimeState,last=copy.address_absolute_midi.at(-1),base=copy.base_midi;
      copy.runtime_tail=code===0?{code,name:'inactive',relative_motion_semitones:-1,absolute_note:last-1,articulation:'sharp_stop',duration_beats:.25}:code===2?{code,name:'num',relative_motion_semitones:7,absolute_note:last+7,articulation:'sustain',duration_beats:2}:{code,name:'active',relative_motion_semitones:(-copy.address_relative_semitones.at(-1)||0),absolute_note:base,articulation:'firm_return',duration_beats:.5};
    }
    return copy;
  }));
  const structural=ir.edges.slice().sort((a,b)=>a.edge_id<b.edge_id?-1:a.edge_id>b.edge_id?1:0).map(edge=>({edge_id:edge.edge_id,edge_type:edge.type,from:edge.from,to:edge.to,...(edge.role?{role:edge.role}:{}),...(edge.relation?{relation:edge.relation}:{}),boundary:edge.type==='fills_role'?'short_gap':'medium_gap',boundary_beats:edge.type==='fills_role'?.5:1}));
  const performance={...structuredClone(source.performance),lexical_events:events,structural_events:structural};
  if(parsed.speechAct==='command'){performance.primary_contour='sharply_falling';performance.contour_relative_semitones=[0,-4]}
  if(parsed.speechAct==='question'){performance.primary_contour='rising';performance.contour_relative_semitones=[0,2]}
  const relative=events.map(event=>{
    const {base_midi,family_opening_absolute_midi,address_absolute_midi,...copy}=event;
    copy.runtime_tail=event.runtime_tail?Object.fromEntries(Object.entries(event.runtime_tail).filter(([key])=>key!=='absolute_note')):null;
    return copy;
  });
  const relativePlan={primary_contour:performance.primary_contour,contour_relative_semitones:performance.contour_relative_semitones,secondary_contours:performance.secondary_contours,
    lexical_events:relative,structural_events:structural,statement_boundary:performance.statement_boundary,statement_boundary_beats:performance.statement_boundary_beats};
  const formalDigest=await canonicalDigest({semantic_digest:digest,relative_plan:relativePlan});
  const formal={format:'EZF-1',renderer_version:'1.0.0',formal_id:`EZF:${formalDigest.slice(0,24)}`,formal_digest:formalDigest,semantic_digest:digest,semantic_ir:ir,performance,
    literal_gloss:bound?lexicalGloss(events,template.authority):`${names.map((name,index)=>deicticRoles[index]?`${participantIds[index]}:reference(${deicticRoles[index]})`:`${nominal[index]?`${participantIds[index]}:reference(${nominal[index].mode}) | `:''}${participantIds[index]}:name(${name.normalized_label})`).join(' | ')} | ${source.literal_gloss.replaceAll(`${predicates[0].node_id}:`,'p:').replaceAll(`${predicates[0].node_id}.`,'p.').replace(/\[1\](?= \| |$)/g,`[${parsed.runtimeState??1}]`)}`};
  return {source_input:input,target_id:parsed.predicate,sense_id:`construction:${parsed.construction}`,surface_fidelity:'complete_construction',controlled_input:'',semantic_ir:ir,formal,
    semantic_note:parsed.semanticNote?(parsed.semanticNote+(parsed.runtimeState===2&&parsed.key==='approved_poetic_love'?' The num ending carries the approved never-finished-becoming reading.':'')):null,construction:parsed.construction,interpretation:parsed.explicitInterpretation||((deicticRoles.some(Boolean)||parsed.semanticNote)?String(input).trim():null)||`${parsed.actorText} ${parsed.negated?(parsed.key==='active_care'?'does not actively care for':parsed.wording.replace('is ','is not ')):parsed.wording}${parsed.targetText?' '+parsed.targetText:''}.`};
}
