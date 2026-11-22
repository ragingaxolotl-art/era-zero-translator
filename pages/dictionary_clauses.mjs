// English predicates come from the installed dictionary. A frame specifies which
// participant a predicate can take in this construction, independently of its spelling.
import {matchingChoice} from './dictionary_word_choices.mjs';
import {analyzeEnglish,phrasalVerbAt} from './english.mjs?v=partial-word-flow-2';
import {parseNominal} from './nominals.mjs?v=partial-word-flow-1';
import {expandNegativeContractions} from './contractions.mjs';
import {ERASURE,isStoredInformationTarget,erasureSense} from './information_operations.mjs?v=information-operations-1';

const frames = new Map();
function frame(ids,subject,object,prepositions={}) {
  for (const id of ids.split(' ')) frames.set(id,{subject,object,prepositions});
}
frame('REP:110 REP:111 WRN:110 WRN:111 LIF:110 LIF:111','source','target');
frame('LIF:211 erase_stored_object','actor','target');
frame('MOV:111 MOV:110','actor','destination');
frame('MIN:010 MIN:011 MIN:110 MIN:111 MIN:211','experiencer','target');
frame('CRE:110 CRE:111','source','result');
frame('DAT:101 MAT:101 STR:101 MIN:101','cause','bearer');
frame('CON:100 CON:101 DAT:111 DAT:112','source','content',{to:'recipient'});
frame('CON:110 CON:111 DAT:110','recipient','content',{from:'source'});
frame('DAT:121 CON:121','source','content',{with:'recipient'});
frame('REP:101 LIF:101 MOV:100 MOV:101','actor',null);
frame('WRN:001 REP:001 LIF:001 LIF:002 LIF:011 LIF:012','bearer',null);

const pastForms={hold:'held',find:'found',see:'saw',make:'made',break:'broke',build:'built',send:'sent',leave:'left',go:'went',wake:'woke',sleep:'slept',know:'knew',seek:'sought',take:'took',run:'ran',come:'came',bring:'brought',heal:'healed',hurt:'hurt',do:'did'};
const phases={'REP:110':['REP:111','REP:110'],'REP:111':['REP:111','REP:110'],'WRN:111':['WRN:111','WRN:110'],'CRE:111':['CRE:111','CRE:110'],'CON:101':['CON:101','CON:100'],'CON:111':['CON:111','CON:110'],'LIF:111':['LIF:111','LIF:110']};
const particles=new Set(['up','for','from','to','at','of','with','on','out','down','in','off']);
const forbidden=new Set('a an the this that these those and or but not no never if unless then now today yesterday tomorrow may might will would could should must can to from of in on at with for before after by i me my we us our you your he she they them it her his who what someone nobody everyone something nothing one two three all some each please do does did is are am was were had has have need needs might maybe perhaps when how why which where must would kindly there yes no other any none'.split(' '));
const normalized=text=>text.toLowerCase().replace(/\s+/g,' ').trim();
const knownActor = /^(?:I|we|you)$/i;


function inflections(phrase) {
  const [verb,...rest]=phrase.split(' '),tail=rest.length?' '+rest.join(' '):'';
  let third,past;
  if (/[^aeiou]y$/.test(verb)){third=verb.slice(0,-1)+'ies';past=verb.slice(0,-1)+'ied';}
  else {third=verb+(/(?:s|sh|ch|x|z|o)$/.test(verb)?'es':'s');past=verb+(verb.endsWith('e')?'d':'ed');}
  const stem=verb.replace(/([^e])e$/,'$1');
  return {base:phrase,third:third+tail,past:(pastForms[verb]||past)+tail,progressive:stem+'ing'+tail};
}

// Recognition is separate from having a composer for a particular sentence.
// Exact forms of an existing meaning must not become a new-word alias picker
// just because its argument structure, voice or aspect is unsupported.
const recognizedCache=new WeakMap();
function recognizedPredicateForms(authority){
  const cached=recognizedCache.get(authority);
  if(cached&&cached.local===authority.local_senses)return cached.forms;
  const forms=new Set(),verbSeeds=new Set();
  for(const sense of [...(authority.local_senses||[]),...(authority.game_story_senses||[]),...authority.senses]){
    if(!['verb','adjective'].includes(sense.part_of_speech)||!['atom','compound','semantic_ir','grammar'].includes(sense.route))continue;
    for(const surface of [sense.lemma,...(sense.surface_forms||[])]){
      const form=normalized(surface);forms.add(form);
      if(sense.part_of_speech==='verb'&&/^[a-z-]+(?: [a-z-]+)?$/.test(form)&&
          (!form.includes(' ')||particles.has(form.split(' ')[1])))verbSeeds.add(form);
    }
  }
  const derived=new Set([...verbSeeds].flatMap(seed=>Object.values(inflections(seed)).filter(form=>form!==seed)));
  for(const seed of verbSeeds)if(!derived.has(seed)&&!/(?:ed|ing)$/.test(seed)){
    for(const form of Object.values(inflections(seed)))forms.add(form);
  }
  recognizedCache.set(authority,{local:authority.local_senses,forms});return forms;
}

export function recognizedClausePredicate(input,authority){
  const syntax=clauseSyntax(input);if(!syntax)return null;
  const tokens=syntax.tail.split(' '),length=phrasalVerbAt(tokens.map(normalized),0)?2:1;
  const surface=tokens.slice(0,length).join(' ');
  return recognizedPredicateForms(authority).has(normalized(surface))?surface:null;
}

function subjectAndTail(text) {
  const m=/^("[^"\n]+"|(?:the|this|that|a|an) [a-z]+(?:-[a-z]+)*|[a-z]+)\s+(.+)$/i.exec(text);
  if (!m) return null;
  const subject=reference(m[1],true);
  return subject?{subject,tail:m[2]}:null;
}
function reference(text,subject=false) {
  const value=text.trim(),v=normalized(value);
  if (v==='you') return 'you';
  if (subject ? v==='i' : v==='me') return 'I';
  if (subject ? v==='we' : v==='us') return 'we';
  if (/^"[^"\n]+"$/.test(value)) return value;
  if (/^[A-Z][a-z]+$/.test(value) && !forbidden.has(v)) return value;
  const indefinite=/^(a|an) ([a-z]+(?:-[a-z]+)*)$/.exec(v);
  if(indefinite && !forbidden.has(indefinite[2]) && parseNominal('the '+indefinite[2]))return v;
  const nominal=parseNominal(v);
  if (nominal && !nominal.quantifier && !forbidden.has(nominal.head)) return v;
  return null;
}

function agrees(aux,subject) {
  const p=knownActor.test(subject);
  if (['do','does','need','needs'].includes(aux)) return ['do','need'].includes(aux)===p;
  if (['am','is','are'].includes(aux)) return aux===(subject==='I'?'am':p?'are':'is');
  if (['was','were'].includes(aux)) return aux===(p&&subject!=='I'?'were':'was');
  return true;
}

export function clauseSyntax(input) {
  if (typeof input!=='string') return null;
  let text=input.trim().replace(/\s+/g,' '),runtime=1;
  const tag=/\s*\[([012])\]([.!?]?)$/.exec(text);
  if (tag){runtime=Number(tag[1]);text=text.slice(0,tag.index).trim();const mark=text.match(/[.!?]$/)?.[0];if(mark&&tag[2]&&mark!==tag[2])return null;if(!mark)text+=tag[2];}
  text=expandNegativeContractions(text,'(I|we|you|[A-Z][a-z]+)');
  const question=text.endsWith('?');
  text=text.replace(/[.!?]$/,'');
  let first='', lead;
  if (question){
    lead=/^(do|does|did|might|can|cannot|will|is|are|am|was|were)\s+(.+)$/i.exec(text);
    if(!lead)return null;
    first=normalized(lead[1]);text=lead[2];
  }
  // An opening phrasal verb addresses the listener, even when capitalized.
  const commandText=text.replace(/^please\s+/i,''),words=normalized(commandText).split(' ');
  const phrase=question?null:phrasalVerbAt(words,0);
  if(phrase && phrase!==words.slice(0,2).join(' '))return null;
  const parts=phrase?{subject:'you',tail:commandText}:subjectAndTail(text);if(!parts)return null;
  let {subject,tail}=parts;
  if (first) tail=first+' '+tail;
  else if(/^need not /i.test(tail))tail=(knownActor.test(subject)?'do':'does')+' not need to '+tail.slice(9);
  const scopes=[],when=/\s+(today|yesterday|tomorrow)$/i.exec(tail);
  if(when){scopes.push('time_'+({today:'current_day',yesterday:'previous_day',tomorrow:'next_day'}[normalized(when[1])]));tail=tail.slice(0,when.index);}
  let form=knownActor.test(subject)?'base':'third',being=false;
  const aux=/^(do|does|did|might|can|cannot|will|is|are|am|was|were)\s+(not\s+)?(.+)$/i.exec(tail);
  if(aux){
    const a=normalized(aux[1]);
    if(!agrees(a,subject))return null;
    if(a==='did'||a==='was'||a==='were')scopes.push('time_before_speech');
    if(a==='might')scopes.push('modality_possible');
    if(a==='will')scopes.push('time_after_speech');
    // Cannot / can not deny ability; will not places negation inside future time.
    if(a==='can'||a==='cannot'){
      if(a==='cannot'&&aux[2])return null;
      if(a==='cannot'||aux[2])scopes.push('negation');
      scopes.push('ability');
    }else if(aux[2])scopes.push('negation');
    being=['am','is','are','was','were'].includes(a);
    form=being?'progressive':'base';tail=aux[3];
  }
  const need=/^(need|needs) to\s+(not\s+)?(.+)$/i.exec(tail);
  if(need){
    if(being|| (aux?normalized(need[1])!=='need':!agrees(normalized(need[1]),subject)))return null;
    scopes.push('modality_necessary');if(need[2])scopes.push('negation');
    form='base';tail=need[3];
  }
  if(!being && (need||aux) && /^be /i.test(tail)){being=true;form='progressive';tail=tail.slice(3);}
  return {subject,tail,scopes,form,being,allowPast:!aux&&!need&&!phrase,speechAct:question?'question':phrase?'command':'assertion',runtime};
}

// Index only exact English word forms in the dictionary. Broad search matches
// are valuable for browsing, but cannot establish a predicate in a sentence.
const indices=new WeakMap();
function lexicon(authority) {
  const previous=indices.get(authority);
  if(previous && previous.local===authority.local_senses)return previous.entries;
  const entries=[];
  for (const original of [...(authority.local_senses||[]),...(authority.game_story_senses||[]),...authority.senses]) {
    const sense=original.sense_id==='GSE:043'?{...original,target_id:'erase_stored_object'}:original;
    const shape=frames.get(sense.target_id),pos=sense.part_of_speech;
    if(!shape||(sense.route!=='atom'&&sense.target_id!=='erase_stored_object')||!['verb','adjective'].includes(pos))continue;
    if(pos==='adjective'&&shape.subject!=='bearer')continue;
    const extra={active_search_attention_generalized:['search for'],active_living_care_generalized:['care for'],target_impairment:['damage'],target_restoration:['restore']};
    const hints=[...(extra[sense.sense_key]||[]),sense.lemma,...(sense.surface_forms||[]),...(sense.lemma==='care'?['care for']:[])];
    const forms=[...new Set(hints.map(normalized))];
    if(pos==='adjective'){
      for(const form of forms)if(/^[a-z-]+$/.test(form))entries.push({sense,shape,form,mode:'quality'});
      continue;
    }
    const seeds=forms.filter(f=>/^[a-z-]+(?: [a-z-]+)?$/.test(f)&&(!f.includes(' ')||particles.has(f.split(' ')[1])));
    const derived=new Set(seeds.flatMap(f=>{const v=inflections(f);return [v.third,v.past,v.progressive].filter(s=>s!==f);}));
    for(const seed of seeds.filter(f=>!derived.has(f)&&!/(?:ed|ing)$/.test(f))){
      for(const [mode,form] of Object.entries(inflections(seed)))entries.push({sense,shape,form,mode});
    }
  }
  indices.set(authority,{local:authority.local_senses,entries});
  return entries;
}

function argumentsFor(shape,subject,remainder) {
  const participants=[{role:shape.subject,text:subject}];
  if(!shape.object) return remainder?null:participants;
  const direct=reference(remainder);
  if(direct) return [...participants,{role:shape.object,text:direct}];
  // Separators inside a quoted name are part of the name.
  for(const prep of Object.keys(shape.prepositions)){
    const pieces=remainder.match(/"[^"]*"|[^\s]+/g)||[];
    const i=pieces.findIndex(w=>normalized(w)===prep);
    if(i<1)continue;
    const obj=reference(pieces.slice(0,i).join(' ')),extra=reference(pieces.slice(i+1).join(' '));
    if(obj&&extra)return [...participants,{role:shape.object,text:obj},{role:shape.prepositions[prep],text:extra}];
  }
  return null;
}

export function dictionaryClausePlan(input,authority,{offerDefinition=false,preferences=[]}={}) {
  const syntax=clauseSyntax(input);if(!syntax)return null;
  const tail=normalized(syntax.tail),readings=[];
  for(const {sense,shape,mode,form} of lexicon(authority)){
    if(syntax.being ? !['quality','progressive'].includes(mode) : mode!==syntax.form&&!(syntax.allowPast&&mode==='past'))continue;
    if(tail!==form&&!tail.startsWith(form+' '))continue;
    const participants=argumentsFor(shape,syntax.subject,syntax.tail.slice(form.length).trim());
    if(!participants || new Set(participants.map(p=>normalized(p.text))).size!==participants.length)continue;
    if(sense.target_id===ERASURE&&!isStoredInformationTarget(participants[1]?.text?.replace(/^(?:the|this|that|a|an) /,'')))continue;
    const scopes=[...syntax.scopes];
    if(mode==='past' && scopes.includes('time_next_day'))continue;
    if(mode==='past')scopes.push('time_before_speech');
    if(mode==='progressive')scopes.push('aspect_ongoing');
    const pair=!sense.local_review&&phases[sense.target_id],root=pair?pair[mode==='past'||scopes.includes('modality_necessary')&&mode==='base'?1:0]:sense.target_id;
    const key=JSON.stringify([root,participants,scopes]);
    if(readings.some(r=>r.key===key))continue;
    const selectedSense=root===ERASURE?erasureSense(authority,{mode,scopes,speechAct:syntax.speechAct}):sense;
    readings.push({key,sense:selectedSense,root,participants,scopes,word:syntax.tail.slice(0,form.length),quality:mode==='quality'});
  }
  if(readings.length>1){
    const rank=new Map(analyzeEnglish(input,authority).candidates.map((c,i)=>[c.sense_id,i]));
    readings.sort((a,b)=>Number(!!b.sense.local_review)-Number(!!a.sense.local_review)||(rank.get(a.sense.sense_id)??Infinity)-(rank.get(b.sense.sense_id)??Infinity));
  }
  let needsDefinition=false;
  if(!readings.length && (offerDefinition||preferences.length)){
    const tokens=syntax.tail.split(' '), word=normalized(tokens[0]);
    if(!/^[a-z][a-z-]*$/.test(word)||forbidden.has(word))return null;
    const length=phrasalVerbAt(tokens.map(normalized),0)?2:1;
    const surface=tokens.slice(0,length).join(' '), remainder=tokens.slice(length).join(' ');
    const quality=syntax.being&&!word.endsWith('ing');
    const scopes=[...syntax.scopes];
    if(syntax.being&&!quality)scopes.push('aspect_ongoing');
    else if(syntax.allowPast&&word.endsWith('ed'))scopes.push('time_before_speech');
    for(const {sense,mode,shape} of lexicon(authority)){
      if(mode!==(quality?'quality':'base')||sense.target_id==='erase_stored_object')continue;
      const participants=argumentsFor(shape,syntax.subject,remainder);
      if(!participants||new Set(participants.map(p=>normalized(p.text))).size!==participants.length)continue;
      // A word being defined takes the exact dictionary sense the user picks.
      // Its participants, possibility, necessity and tense are scored separately.
      const root=sense.target_id;
      const existing=readings.find(r=>r.root===root);
      if(existing){if(!existing.terms.includes(sense.lemma))existing.terms.push(sense.lemma);continue;}
      readings.push({sense,root,participants,scopes,word:surface,quality,terms:[sense.lemma]});
    }
    needsDefinition=true;
  }
  if(!readings.length)return null;
  const preferred=readings.findIndex(r=>matchingChoice(preferences,r)?.target===r.sense.target_id);
  // A prior explicit personal definition can deliberately use the same spelling.
  // Without one, do not offer unrelated meanings for an already defined word.
  if(needsDefinition&&preferred<0&&recognizedClausePredicate(input,authority))return null;
  if(preferred>=0){
    const reading=readings[preferred],choice=matchingChoice(preferences,reading);
    const root=choice.root??choice.target;
    if([reading.sense.target_id,...(phases[reading.sense.target_id]||[])].includes(root))reading.root=root;
  }
  if(needsDefinition && preferred<0 && !offerDefinition)return null;
  const first=readings[0],surface=normalized(first.word);
  const preferenceForms=!first.quality&&syntax.form==='base'&&!syntax.being&&!first.scopes.includes('time_before_speech')?Object.values(inflections(surface)):[surface];
  return {input,runtime:syntax.runtime,speechAct:syntax.speechAct,needsDefinition,readings,preferred,preferenceForms};
}

export function dictionaryRoles(root) {
  const shape=frames.get(root);
  if(!shape)return [];
  const base=[shape.subject,...(shape.object?[shape.object]:[])];
  return [base,...Object.values(shape.prepositions).map(role=>[...base,role])];
}

// Saved definitions retain their declared roles and verb forms. This extends
// their existing parser for necessities and the inclusive speaker-group anchor.
export function savedScopedReadings(input,entries,part) {
  const syntax=clauseSyntax(input);if(!syntax)return [];
  // Bound personal compounds do not yet have the story ability enclosure.
  // Do not reinterpret ability as an empty or possible modality.
  if(syntax.scopes.includes('ability'))return [];
  if(syntax.subject!=='we'&&!syntax.scopes.includes('modality_necessary'))return [];
  const scopes=syntax.scopes.map(scope=>scope==='negation'?{operator:'negation'}:scope.startsWith('time_')?{operator:'time',relation:scope.slice(5)}:{operator:'modality',mode:scope.slice(9)});
  const tail=normalized(syntax.tail),matches=[];
  for(const entry of entries){
    const d=entry.definition;if(d.part_of_speech!==part)continue;
    let label;
    if(part==='adjective'){if(!syntax.being||!d.roles.some(r=>r.role==='bearer'))continue;label=d.label;}
    else {if(syntax.being)continue;label=syntax.form==='base'?d.label:d.english_forms?.third_person;}
    if(!label)continue;label=normalized(label);
    if(tail!==label&&!tail.startsWith(label+' '))continue;
    const rest=syntax.tail.slice(label.length).trim(),object=rest&&reference(rest);
    if(rest&&(!object||part==='adjective')||/^an? /i.test(object||'')||/^an? /i.test(syntax.subject))continue;
    matches.push({compound_id:entry.compound_id,subject:syntax.subject,...(part==='verb'?{object:object||null,available_roles:d.roles}:{}),
      runtime_state:syntax.runtime,speech_act:syntax.speechAct,scopes});
  }
  return matches;
}
