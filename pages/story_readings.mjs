import {validStorySlots} from './story_saved_adjectives.mjs';
import {isPassageHead} from './passage_nouns.mjs';
import {knownValueReading} from './known_value.mjs?v=information-vocabulary-1';
import {faultCategoryReading} from './fault_correction.mjs?v=information-vocabulary-1';
import {routeNounLabel} from './nominals.mjs';
import {expandNegativeContractions} from './contractions.mjs';
import {clauseSyntax, dictionaryClausePlan, dictionaryRoles} from './dictionary_clauses.mjs?v=information-vocabulary-1';
import {properties,feltProperties,isMaterialTarget,isPhysicalContainer,physicalActionLabels} from './story_qualities.mjs?v=information-vocabulary-1';
import {storyWords} from './story_words.mjs?v=information-vocabulary-1';
import {ERASURE,isStoredInformationTarget} from './information_operations.mjs?v=information-operations-1';

const words = new Map(storyWords.map(word => [word.word, word]));
const id = word => words.get(word).id;
const shapes = [
  ['stay','stays','stayed',['bearer'],null,'staying'],
  ['remain','remains','remained',['bearer'],'stay','remaining'],
  ['keep','keeps','kept',['cause','bearer'],null,'keeping'],
  ['push','pushes','pushed',['actor','target'],null,'pushing'],
  ['displace','displaces','displaced',['cause','bearer'],null,'displacing'],
  ['lift','lifts','lifted',['actor','target'],null,'lifting'],
  ['lower','lowers','lowered',['actor','target'],null,'lowering'],
  ['pull','pulls','pulled',['actor','target'],null,'pulling'],
  ['release','releases','released',['actor','target'],null,'releasing'],
  ['fall','falls','fell',['bearer'],null,'falling'],
  ['drop','drops','dropped',['actor','target'],null,'dropping'],
  ['delete','deletes','deleted',['actor','target'],ERASURE,'deleting'],
  ['copy','copies','copied',['actor','target'],null,'copying'],
  ['recall','recalls','recalled',['experiencer','target'],null,'recalling'],
  ['remember','remembers','remembered',['experiencer','target'],'recall','remembering'],
  ['resume','resumes','resumed',['bearer'],null,'resuming'],
  ['vibrate', 'vibrates', 'vibrated', ['bearer']],
  ['sound', 'sounds', 'sounded', ['source']],
  ['ring', 'rings', 'rang', ['source']],
  ['recur', 'recurs', 'recurred', ['bearer']],
  ['repeat', 'repeats', 'repeated', ['actor', 'target']],
  ['cease', 'ceases', 'ceased', ['bearer']],
  ['wait', 'waits', 'waited', ['actor']],
  ['notice', 'notices', 'noticed', ['experiencer','target']],
  ['spot', 'spots', 'spotted', ['experiencer','target']],
  ['reopen', 'reopens', 'reopened', ['bearer']],
  ['return', 'returns', 'returned', ['actor']],
  ['arrive', 'arrives', 'arrived', ['actor']],
  ['find','finds','found',['experiencer','target']],
  ['check','checks','checked',['actor','target']],['inspect','inspects','inspected',['actor','target'],'check'],
  ['recheck','rechecks','rechecked',['actor','target']],
  ['request','requests','requested',['source','content']],
  ['request completion','requests completion','requested completion',['source']],
  ['remain valid','remains valid','remained valid',['bearer']],
  ['stay valid','stays valid','stayed valid',['bearer'],'remain valid'],
  ['follow','follows','followed',['bearer']],
  ['open','opens','opened',['bearer']],['open','opens','opened',['cause','bearer']],
  ['reopen','reopens','reopened',['cause','bearer']],
  ['hear','hears','heard',['experiencer','source']],['see','sees','saw',['experiencer','source']],
  ['have','has','had',['bearer','target']],
  ['approach','approaches','approached',['actor','destination'],'MOV:111','approaching'],
  ['leave','leaves','left',['actor','source'],'MOV:101','leaving'],
  ['move','moves','moved',['actor'],'MOV:121','moving'],
  ['make','makes','made',['source','result'],'CRE:110']
];
const predicateId = (word,target) => target===ERASURE||target?.includes(':')?target:word==='arrive'?'MOV:110':id(target||word);
const commandVerbs=new Set(['repair',...shapes.filter(row=>row[3].length===2).map(row=>row[0]),'ring']);
const pronouns = new Set('they them he him she her it'.split(' '));
const deictics = {i:'I',me:'I',we:'we',us:'we',you:'you'};
const determiners = new Set('a an the this that'.split(' '));
const personNouns = new Set('person people child children teacher worker friend programmer keeper custodian'.split(' '));
const machineActors = new Set('program routine resolver robot machine compiler process agent'.split(' '));
const passageQualities = new Set([id('passable'),id('blocked')]);
const nonNouns = new Set('a few no nobody nothing something home again now can will if then some all none of a an the this that to is are was were it they us and but or before after not need needs might could will must who what do does did'.split(' '));
const folded = s => s.toLowerCase();
const plural = noun => ['people','children','men','women','mice'].includes(noun) || /(?:ies|s)$/.test(noun) && !/(?:ss|us|is)$/.test(noun);
export const storyPropertyIds = new Set([...properties.values(),id('open for use')]);
export const needsState = root => root === id('stay') || root === id('keep');
export function storyRoles(root) {
  const roles = shapes.filter(row=>predicateId(row[0],row[4])===root).map(row=>row[3]);
  if(root===id('hand off work'))roles.push(['source','content']);
  if(root===id('open for use')||root===id('resume'))roles.push(['bearer']);
  if(root===id('resume'))roles.push(['cause','bearer']);
  if(root==='CRE:110')roles.push(['source','result','recipient']);
  if(['MOV:100','MOV:120'].includes(root))roles.push(root==='MOV:100'?['actor','source']:['actor']);
  if (storyPropertyIds.has(root)) roles.push(['bearer']);
  if (root===id('find'))roles.push(['experiencer','target']);
  return [...roles, ...dictionaryRoles(root)];
}

function nounPhrase(tokens, offset, {guessName=false,barePlural=false}={}, qualityAt=propertyAt) {
  const start = offset, token = tokens[offset], word = token?.toLowerCase();
  if (!word) return null;
  const possessive=['her','his','their','my','our','your'].includes(word) && /^[a-z][a-z-]*$/i.test(tokens[offset+1]||'');
  if(possessive){
    const np=nounPhrase(['the',...tokens.slice(offset+1)],0,{},qualityAt);
    if(!np)return null;
    return {...np,text:tokens.slice(start,start+np.length).join(' '),owner:{text:token,pronoun:({her:'she',his:'he',their:'they',my:'i',our:'we',your:'you'})[word]}};
  }
  if (pronouns.has(word) || Object.hasOwn(deictics, word)) return {text:token, length:1, pronoun:word};
  let det = determiners.has(word) ? word : null;
  if (!det) {
    if(word==='home')return {text:token,length:1,reference:'the home',head:'home',category:'thing',plural:false,qualities:[]};
    if(nonNouns.has(word))return null;
    if(/^([A-Z][a-z]+|"[^"\n]+")$/.test(token))
      return {text:token,length:1,reference:token,category:'person',plural:false,qualities:[]};
    if(barePlural&&/^[a-z][a-z-]*$/.test(token)&&plural(word))
      return {text:token,length:1,reference:word,head:word,referenceKind:'indefinite_plural',category:'thing',plural:true,qualities:[]};
    if(guessName&&/^[a-z][a-z-]*$/.test(token)&&!plural(word)){
      const name=token[0].toUpperCase()+token.slice(1);
      return {text:token,length:1,reference:name,category:'person',guessedName:true,plural:false,qualities:[]};
    }
    return null;
  }
  offset++;
  const qualities = [],descriptors=[];
  for(let quality; (quality=qualityAt(tokens,offset));){
    qualities.push(quality.root);descriptors.push(quality.word);offset+=quality.length;
    if(tokens[offset]?.toLowerCase()==='and'&&qualityAt(tokens,offset+1))offset++;
  }
  let head = tokens[offset]?.toLowerCase();
  const route=routeNounLabel(head,tokens[offset+1]?.toLowerCase());
  if(route){head=route;offset++;}
  if (!head || (!route && !/^[a-z]+(?:-[a-z]+)*$/.test(head)) || nonNouns.has(head)) return null;
  if (plural(head) && ['a','an','this','that'].includes(det)) return null;
  return {text:tokens.slice(start,offset+1).join(' '), length:offset-start+1, reference:det+' '+head,
    head, category:personNouns.has(head.replace(/s$/,''))?'person':'thing', plural:plural(head), qualities,descriptors};
}
function countedSubject(tokens,parseNoun){
  const first=folded(tokens[0]||''),second=folded(tokens[1]||'');
  const few=first==='a'&&second==='few';
  if(!few && first!=='nobody' && first!=='nothing' && !(first==='no'&&second==='one'))return null;
  const length=few||first==='no'?2:1;
  if(few){
    const nominal=parseNoun(['the',...tokens.slice(length)],0);
    if(nominal?.plural){
      return {q:'few',subject:{...nominal,reference:nominal.head,referenceKind:'nominal_class',
        text:tokens.slice(0,length+nominal.length-1).join(' '),length:length+nominal.length-1}};
    }
  }
  return {q:few?'few':'none',subject:{text:tokens.slice(0,length).join(' '),length,
    domain:few?'contextual':first==='nothing'?'things':'people',reference:null,
    category:first==='nothing'?'thing':'person',plural:true,singularAgreement:!few,qualities:[]}};
}
const tokensOf = s => s.match(/"[^"\n]+"|[^\s]+/g) || [];
function linkedClauses(body,parseNoun){
  const tokens=tokensOf(body),parts=[],clause=[];
  for(let i=0;i<tokens.length;){
    const word=folded(tokens[i]);
    if(['and','before','after'].includes(word)){
      parts.push(clause.join(' '),word);clause.length=0;i++;continue;
    }
    // Consume a whole noun phrase so the 'and' inside paired adjectives stays with its noun.
    const nominal=parseNoun(tokens,i),length=nominal?.length||1;
    clause.push(...tokens.slice(i,i+length));i+=length;
  }
  return [...parts,clause.join(' ')];
}
function splitObject(tokens,parseNoun) {
  for (let i=1; i<tokens.length; i++) {
    const object = parseNoun(tokens, i,{barePlural:true});
    if(!object)continue;
    const alternatives=[];
    let end=i+object.length;
    while(folded(tokens[end]||'')==='or'){
      const next=parseNoun(tokens,end+1,{barePlural:true});
      if(!next)break;
      alternatives.push(next);end+=1+next.length;
    }
    if(end===tokens.length)return {verb:tokens.slice(0,i).join(' '),object,alternatives};
  }
  return {verb:tokens.join(' '), object:null};
}
// Keep the predicated state separate from a description inside the noun phrase.
function stateComplement(tokens, parseObject, propertyAt) {
  for (let i=1; i<tokens.length; i++) {
    const quality = propertyAt(tokens,i);
    if (!quality || i + quality.length !== tokens.length) continue;
    const parsed = parseObject(tokens.slice(0,i));
    const word = folded(parsed.verb).split(' ').at(-1);
    const keeps = ['keep','keeps','kept','keeping'].includes(word);
    const stays = ['stay','stays','stayed','staying','remain','remains','remained','remaining'].includes(word);
    if ((!keeps && !stays) || keeps !== !!parsed.object || parsed.alternatives?.length) continue;
    // The earlier lexicalized "remain valid" has its own published sound.
    if (stays && quality.word === 'valid' && !word.endsWith('ing')) continue;
    return {...parsed, condition:quality};
  }
  return null;
}
function propertyAt(tokens,offset,adjectives) {
  const first=folded(tokens[offset]||'');
  const choices=adjectives?.byFirst.get(first)||[];
  for(const entry of choices){
    const parts=entry.parts;
    if(parts.every((word,i)=>word===folded(tokens[offset+i]||''))){
      return {word:entry.label,root:properties.get(entry.label)||entry.id,length:parts.length};
    }
  }
  if(first==='available' && folded(tokens[offset+1]||'')==='for' && folded(tokens[offset+2]||'')==='use')
    return {word:'available for use',root:id('available for use'),length:3};
  return properties.has(first)?{word:first,root:properties.get(first),length:1}:null;
}
function describeChoice(row) {
  return row.word === 'return' ? 'went back to an earlier place' : 'happened again';
}
function predicate(verb, subject, object, authority, runtime, preferences) {
  const anchor = subject.pronoun ? (deictics[subject.pronoun] || (['they','them'].includes(subject.pronoun)?'we':'Ada')) :
    subject.plural&&!subject.singularAgreement?'we':'Ada';
  const placeholder = anchor+' '+verb+(object?' the gate':'');
  const syntax = clauseSyntax(placeholder);
  if (!syntax) return [];
  const personal=preferences.length && dictionaryClausePlan(placeholder+' ['+runtime+'].',authority,{preferences});
  if(personal && personal.preferred>=0){
    const r=personal.readings[personal.preferred];
    return [{root:r.root,word:r.sense.lemma,roles:r.participants.map(p=>p.role),scopes:r.scopes,sense:r.sense,specific:false}];
  }
  const tail = object ? folded(syntax.tail).slice(0,-' the gate'.length) : folded(syntax.tail);
  if(syntax.being && !object && properties.has(tail) && !Object.hasOwn(feltProperties,tail) && !['available','curious','resumed'].includes(tail))return [{root:properties.get(tail),word:tail,roles:['bearer'],scopes:syntax.scopes,specific:words.has(tail)||passageQualities.has(properties.get(tail))}];
  const readings = [];
  if(object && syntax.allowPast && tail==='found' && !preferences.some(p=>p.forms?.includes('found'))){
    return [{root:id('find'),word:'find',roles:['experiencer','target'],scopes:[...syntax.scopes,'time_before_speech'],specific:true}];
  }
  for (const [base,third,past,roles,target,progressive] of shapes) {
    const repeatedEvent=base==='repeat'&&!object;
    if ((!repeatedEvent && roles.length !== (object?2:1))||syntax.being&&tail!==progressive)continue;
    const pastMatch = syntax.allowPast && tail === past;
    if(!pastMatch&&!(syntax.being&&tail===progressive)&&tail!==(syntax.form==='third'?third:base))continue;
    const scopes = [...syntax.scopes, ...(pastMatch?['time_before_speech']:[]),...(syntax.being?['aspect_ongoing']:[])];
    let root=predicateId(base,target);
    if(base==='follow' && !subject.domain && !/^(?:event|update|adjustment|arrival|response|request|silence|change)s?$/.test(subject.head||'')){
      readings.push({root,word:base,roles,scopes,specific:true,followChoice:true});break;
    }
    if(base==='move'&&pastMatch)root='MOV:120';
    if(base==='leave'&&pastMatch)root='MOV:100';
    readings.push({root:repeatedEvent?id('recur'):root,word:repeatedEvent?'recur':base,roles:repeatedEvent?['bearer']:roles,scopes,specific:true});
    if (base==='return') readings.push({root:id('recur'),word:'recur',roles:['bearer'],scopes,specific:true});
    break;
  }
  if (readings.length) return readings;
  if(object&&/^(?:carry|carries|carried|carrying)$/.test(tail)&&/^(?:handoffs?|assignments?|workloads?|tasks?|jobs?)$/.test(object.head||'')){
    const scopes=[...syntax.scopes,...(tail==='carried'?['time_before_speech']:[]),...(syntax.being?['aspect_ongoing']:[])];
    return [{root:id('hand off work'),word:'hand off work',roles:['source','content'],scopes,specific:true,carryChoice:true}];
  }
  const plan = dictionaryClausePlan(placeholder+' ['+runtime+'].',authority,{preferences});
  if (!plan) return [];
  const rows = plan.preferred>=0?[plan.readings[plan.preferred]]:plan.readings;
  return rows.map(r=>({root:r.root,word:r.sense.lemma,roles:r.participants.map(p=>p.role),scopes:r.scopes,
    sense:r.sense, specific:false}));
}

function prepare(input, authority, preferences, adjectives) {
  const qualityAt=(tokens,offset)=>propertyAt(tokens,offset,adjectives);
  const parseNoun=(tokens,offset,options)=>nounPhrase(tokens,offset,options,qualityAt);
  const parseObject=tokens=>splitObject(tokens,parseNoun);
  let text=expandNegativeContractions(input.trim().replace(/\s+/g,' ')), runtime=1;
  const state=/\s*\[([012])\]([.!?]?)$/.exec(text);
  if (state) {
    runtime=Number(state[1]);
    text=text.slice(0,state.index).trim().replace(/[.!?]$/,m=>state[2]&&state[2]!==m?'\n':m);
    if(state[2]&&!/[.!?]$/.test(text))text+=state[2];
  }
  if(!text||text.length>1800||/[\[\]\n]/.test(text))return null;
  const sentences=text.match(/[^.!?]+[.!?]?/g);
  if (!sentences || sentences.join('')!==text || sentences.length>8) return null;
  const clauses=[],relations=[];
  let special=false, act='assertion';
  for (const sentence of sentences) {
    let body=sentence.trim().replace(/[.!?]$/,'');
    if(sentence.endsWith('?')){
      if(sentences.length!==1)return null;
      const aux=/^(do|does|did|am|are|is|was|were|might|can|will) (.+)$/i.exec(body);
      if(!aux)return null;
      const tokens=tokensOf(aux[2]),subject=parseNoun(tokens,0,{guessName:true});
      if(!subject)return null;
      body=tokens.slice(0,subject.length).join(' ')+' '+folded(aux[1])+' '+tokens.slice(subject.length).join(' ');
      act='question';
    }
    let link=null;
    const leading=/^(before|after) (.+?),\s*(.+)$/i.exec(body);
    if(leading)body=leading[2]+' '+(folded(leading[1])==='before'?'after':'before')+' '+leading[3];
    const condition=/^if (.+?),\s*(?:then )?(.+)$/i.exec(body),postcondition=/^(.+) if (.+)$/i.exec(body);
    const parts=condition?[condition[1],'condition',condition[2]]:postcondition?[postcondition[1],'provided',postcondition[2]]:linkedClauses(body,parseNoun);
    // Without punctuation or parentheses, three linked clauses have ambiguous attachment.
    if(parts.length>3)return null;
    for(let i=0;i<parts.length;i+=2){
      link=i?folded(parts[i-1]):null;
      let piece=parts[i].trim(), q=null, outsideNegation=false;
      const count=/^(not all|all|none) (?:of )?(the .+)$/i.exec(piece);
      if(count){
        q=folded(count[1])==='none'?'none':'all';outsideNegation=folded(count[1])==='not all';piece=count[2];special=true;
      }
      const tokens=tokensOf(piece);
      const counted=countedSubject(tokens,parseNoun);
      let subject=counted?.subject||parseNoun(tokens,0,{guessName:true}),consumed=subject?.length??0,inherited=false;
      if(counted){q=counted.q;special=true;}
      const shared=link==='and'&&subject?.guessedName?parseObject(tokens):null;
      if(link==='and' && (!subject || subject.category==='person' && shapes.some(row=>row.slice(0,3).includes(folded(tokens[0]))) ||
          shared&&predicate(shared.verb,clauses.at(-1).subject,shared.object,authority,runtime,preferences).length)){
        subject=clauses.at(-1).subject;consumed=0;inherited=true;special=true;
      }
      const polite=folded(tokens[0]||'')==='please'?1:0;
      const commandOffset=polite+(folded(tokens[polite]||'')==='do'&&folded(tokens[polite+1]||'')==='not'?2:0);
      const commandWord=folded(tokens[commandOffset]||'');
      const commandTail=commandVerbs.has(commandWord)?tokens.slice(commandOffset):[];
      const command=commandTail.length?(stateComplement(commandTail,parseObject,qualityAt)||parseObject(commandTail)):null;
      // Use the same complete object parser as statements. An article-only
      // shortcut excluded names and pronouns; matching the entire predicate
      // also avoids turning a person named Copy into an imperative subject.
      if(clauses.length===0 && sentences.length===1 && command?.object && folded(command.verb)===commandWord){
        subject={text:'you',pronoun:'you'};consumed=polite;act='command';
      }
      if(!subject || q&&!subject.plural)return null;
      let tail=tokens.slice(consumed),when=null,again=false,recipient=null;
      if(folded(tail.at(-1)||'')==='now'){when='time_at_speech';tail=tail.slice(0,-1);}
      if(folded(tail.at(-1)||'')==='again'){again=true;tail=tail.slice(0,-1);}
      const ditransitive=tail.findIndex(t=>['make','makes','made'].includes(folded(t)));
      if(ditransitive>=0){
        const indirect=parseNoun(tail,ditransitive+1),result=indirect&&parseNoun(tail,ditransitive+1+indirect.length,{barePlural:true});
        if(indirect&&result&&ditransitive+1+indirect.length+result.length===tail.length){
          recipient=indirect;tail=[...tail.slice(0,ditransitive+1),...tail.slice(ditransitive+1+indirect.length)];
        }
      }
      const state=stateComplement(tail,parseObject,qualityAt);
      let {verb,object,alternatives=[]}=state||parseObject(tail);
      if(!object && /^notic(?:e|es|ed)$/i.test(verb)){
        object={text:'the omitted target',pronoun:'it',prompt:'What did '+subject.text+' notice?'};
      }
      if(!verb)return null;
      let readings=predicate(verb,subject,object,authority,runtime,preferences);
      if(act==='command' && folded(verb)==='find' && object && !preferences.some(p=>p.forms?.includes('find'))){
        readings=[{root:id('find'),word:'find',roles:['experiencer','target'],scopes:[],specific:true}];
      }
      readings=readings.filter(r=>needsState(r.root)===!!state);
      if(again)readings=readings.filter(r=>r.root===id('check')).map(r=>({...r,root:id('recheck'),word:'recheck'}));
      if(when)readings=readings.map(r=>({...r,scopes:[when,...r.scopes]}));
      if(recipient)readings=readings.filter(r=>r.root==='CRE:110');
      if(!readings.length)return null;
      // A modal or negative governing a coordinated verb phrase needs a group scope.
      if(inherited && clauses.at(-1).readings.some(r=>r.scopes.some(s=>s!=='time_before_speech')))return null;
      if (link) {
        const left=clauses.length-1,right=clauses.length;
        const kind=link==='and'?'and':['condition','provided'].includes(link)?'condition':'before';
        relations.push({kind,events:['after','provided'].includes(link)?[right,left]:[left,right]});
      }
      special ||= !!link || readings.some(r=>r.specific) || !!subject.owner || !!object?.owner || !!subject.qualities?.length || !!object?.qualities?.length ||
        pronouns.has(subject.pronoun)||pronouns.has(object?.pronoun);
      clauses.push({subject,object,alternatives,recipient,inherited,readings,q,outsideNegation,condition:state?.condition});
    }
  }
  return special ? {runtime,act,clauses,relations} : null;
}

export function storyReading(input, authority, {answers={}, preferences=[], adjectives}={}) {
  if(typeof input!=='string')return null;
  const embedded=knownValueReading(input,answers)||faultCategoryReading(input,answers);
  if(embedded)return embedded;
  const grammar=prepare(input,authority,preferences,adjectives);
  if(!grammar)return null;
  const entities=[],events=[],notes=[],described=[];
  let question=null, lastSubject;
  function identify(np,key,exclude=null) {
    if(np.guessedName && !entities.some(e=>e.reference===np.reference) && answers[key+'Name']!=='name'){
      if(answers[key+'Name']==='other')return null;
      question={key:key+'Name',prompt:'Is “'+np.text+'” the name '+np.reference+'?',options:[{value:'name',label:'Use the name '+np.reference},{value:'other',label:'I mean something else'}]};
      return null;
    }
    const p=np.pronoun;
    if(pronouns.has(p)){
      const people=!['it'].includes(p);
      const neutral=p==='they'||p==='them';
      const eligible=entities.map((e,i)=>({e,i})).filter(({e,i})=>i!==exclude&&(neutral||!e.plural));
      let candidates=eligible.filter(({e})=>people?(e.category==='person'||(neutral&&(e.plural||machineActors.has(e.head)))):e.category==='thing');
      const direct=candidates.length>0;
      if(!direct && ['it','they','them'].includes(p))candidates=eligible;
      if(p==='it'&&key.startsWith('subject')&&!key.endsWith('Owner')){
        candidates=eligible.filter(({e,i})=>e.category==='thing'||events.some(event=>event.arguments[0].entity===i));
      }
      const answer=answers[key];
      if(answer?.startsWith('new:')){
        const supplied=tokensOf(answer.slice(4).trim()), ref=nounPhrase(supplied,0);
        if(ref && !ref.pronoun && ref.length===supplied.length && !ref.qualities.length && (neutral||!ref.plural)){
          const chosen=identify(ref,key);notes.push('“'+np.text+'” refers to '+ref.text+'.');return chosen;
        }
      }
      const selected=candidates.find(x=>String(x.i)===answer) || (direct && candidates.length===1?candidates[0]:null);
      if(selected){ notes.push('“'+np.text+'” refers to '+selected.e.label+'.');return selected.i; }
      question={key,prompt:np.prompt||(people?'Who or which group':'What')+' does “'+np.text+'” refer to?',
        options:candidates.map(({e,i})=>({value:String(i),label:e.label+' (reference '+(i+1)+')'})),allowName:true};
      return null;
    }
    const reference=p?deictics[p]:np.reference, category=p?'person':np.category;
    const owner=np.owner?identify(np.owner,key+'Owner'):null;
    if(question)return null;
    const indefinite=!!np.domain||!!np.referenceKind||/^an? /.test(reference);
    let previous=entities.map((e,i)=>({e,i})).filter(({e})=>
      !indefinite && e.owner===owner && (e.reference===reference || (np.head && reference.startsWith('the ') && e.head===np.head)));
    if(np.qualities?.length && previous.length){
      const eligible=previous.filter(({i})=>i!==exclude);
      const same=eligible.filter(({i})=>np.qualities.every(q=>described[i].has(q)));
      if(same.length)previous=same;
      else if(eligible.length && eligible.some(({i})=>described[i].size)){
        if(answers[key]==='different')previous=[];
        else{
          const chosen=eligible.find(({i})=>String(i)===answers[key]);
          if(chosen){np.qualities.forEach(q=>described[chosen.i].add(q));return chosen.i;}
          question={key,prompt:'Which participant does “'+np.text+'” describe?',options:[
            ...eligible.map(({e,i})=>({value:String(i),label:e.label+' (reference '+(i+1)+')'})),
            {value:'different',label:'A different '+np.head}]};return null;
        }
      }else previous=eligible;
    }
    if(previous.length===1){(np.qualities||[]).forEach(q=>described[previous[0].i].add(q));return previous[0].i;}
    if(previous.length>1){
      const chosen=previous.find(x=>String(x.i)===answers[key]);
      if(chosen)return chosen.i;
      question={key,prompt:'Which '+np.head+' do you mean?',options:previous.map(({e,i})=>({value:String(i),label:e.label+' (reference '+(i+1)+')'}))};
      return null;
    }
    described.push(new Set(np.qualities||[]));
    entities.push({reference,referenceKind:np.referenceKind,domain:np.domain,label:np.guessedName?np.reference:np.text,head:np.head,plural:!!np.plural||reference==='we',category,owner});return entities.length-1;
  }
  function passageSense(entity,word,key,root){
    if(root===id('empty')||root===id('full')){
      if(isPhysicalContainer(entities[entity].head||'')||answers[key]==='physical')return root;
      if(answers[key]==='other')return null;
      const label=root===id('empty')?'A physical container with none of the relevant contents':'A physical container whose relevant contents reach capacity';
      question={key,prompt:'What does “'+word+'” mean for '+entities[entity].label+'?',options:[{value:'physical',label},{value:'other',label:'Another meaning'}]};
      return null;
    }
    if(root===id('available for use') && word!=='available for use' || root===id('curious') && word==='curious' || root===id('closed')){
      const head=entities[entity].head||'';
      if(root===id('closed') && /^(?:gates?|doors?|hatch(?:es)?|windows?|lids?|boxes|box|valves?)$/.test(head))return root;
      if(answers[key]==='selected')return root;
      if(answers[key]==='other')return null;
      const label=root===id('closed')?'Physically shut':root===id('curious')?'Inclined to learn or find out':'Accessible and ready for the relevant use';
      question={key,prompt:'What does “'+word+'” mean for '+entities[entity].label+'?',options:[{value:'selected',label},{value:'other',label:'Another meaning'}]};
      return null;
    }
    if(![id('reopen'),id('open'),...passageQualities].includes(root))return root;
    const head=(entities[entity].head||'').split(' ').at(-1);
    if(isPassageHead(head))return root;
    const software=root===id('passable')&&['file','document','record','program','application','window'].includes(head);
    const session=root===id('reopen')&&['meeting','session','hearing','debate','trial'].includes(head);
    const answer=answers[key];
    if(answer==='passage')return root;
    if(answer==='software'&&software)return id('open for use');
    if(answer==='session'&&session)return id('resume');
    if(answer==='other')return null;
    const explanation=root===id('reopen')?'a route became passable again':root===id('open')?'a route became passable':root===id('blocked')?'something prevents passage':'something can get through';
    const label=entities[entity].label.replace(/^(?:The|This|That|A|An)\b/,s=>s.toLowerCase());
    const options=[{value:'passage',label:'Yes, '+explanation}];
    if(software)options.push({value:'software',label:'Open for use in software'});
    if(session)options.push({value:'session',label:'The same activity resumed after a pause'});
    options.push({value:'other',label:'I mean another sense of “'+word+'”'});
    question={key,prompt:'Does “'+word+'” describe passage through '+label+'?',options};
    return null;
  }
  function selectProperty(entity,word,key,root){
    const local=adjectives?.byLabel.get(word);
    if(!local)return passageSense(entity,word,key,root);
    if(root!==local.id){
      const choice=answers[key+'Sense'];
      if(choice==='dictionary')return passageSense(entity,word,key,root);
      if(choice!=='saved'){
        question={key:key+'Sense',prompt:'Which meaning of “'+word+'” describes '+entities[entity].label+'?',options:[
          {value:'dictionary',label:'Published dictionary meaning'},
          {value:'saved',label:'Saved meaning · '+(local.definition||word)}]};
        return null;
      }
    }
    if(local.unavailable){question={key,prompt:local.unavailable,options:[]};return null;}
    const bindings=[];
    for(const [i,slot] of local.slots.entries()){
      if(slot.bearer){bindings.push(entity);continue;}
      const slotKey=key+'Slot'+i,answer=answers[slotKey];
      const allowed=index=>local.distinct.every(group=>!group.includes(i)||!group.some(j=>
        j!==i&&(local.slots[j].bearer?entity:bindings[j])===index));
      let target=null;
      if(answer?.startsWith('new:')){
        const tokens=tokensOf(answer.slice(4).trim()),np=nounPhrase(tokens,0);
        if(np&&!np.pronoun&&!np.qualities.length&&np.length===tokens.length)target=identify(np,slotKey+'Referent');
        if(question)return null;
      }else if(answer!==undefined && /^(0|[1-9][0-9]*)$/.test(answer))target=Number(answer);
      if(target===null||!entities[target]||!allowed(target)){
        question={key:slotKey,prompt:'For “'+word+'”, who or what fills '+slot.role+' ('+slot.description+')?',
          options:entities.flatMap((e,index)=>allowed(index)?[{value:String(index),label:e.label}]:[]),allowName:true};
        return null;
      }
      bindings.push(target);
    }
    return validStorySlots(local,bindings,entity,entities.length)?{local_id:local.id,bindings}:null;
  }
  function argument(np,entity,role,key){
    const properties=[];
    for(const [i,root] of (np.qualities||[]).entries()){
      const word=np.descriptors[i],selected=selectProperty(entity,word,key+word,root);
      if(!selected)return null;
      properties.push(selected);
    }
    return {role,entity,properties};
  }
  for(const [index,c] of grammar.clauses.entries()){
    let reading=c.readings[0];
    if(c.readings.length>1){
      reading=c.readings.find(r=>r.root===answers['word'+index]);
      if(!reading)return {question:{key:'word'+index,prompt:'Which meaning do you intend in this action?',options:c.readings.map(r=>({value:r.root,label:r.specific?describeChoice(r):r.sense.definition,sense:r.sense}))}};
    }
    if(reading.followChoice){
      const key='following'+index;
      if(!answers[key])return {question:{key,prompt:'Does “follow” mean something happened later?',options:[
        {value:'time',label:'It occurred after an earlier event'},{value:'other',label:'It followed someone or something in another sense'}]}};
      if(answers[key]!=='time')return null;
    }
    if(reading.carryChoice){
      const key='carrying'+index,choice=answers[key];
      if(!choice)return {question:{key,prompt:'What is being carried here?',options:[
        {value:'work',label:'Work passed between handlers'},{value:'physical',label:'A physical load being carried'}]}};
      if(choice==='physical')return grammar.clauses.length===1?{physicalInput:input}:null;
    }
    const sub=c.inherited?lastSubject:identify(c.subject,'subject'+index);
    if(sub===null)return question?{question}:null;
    const subjectArg=c.inherited?{role:reading.roles[0],entity:sub,properties:[]}:
      argument(c.subject,sub,reading.roles[0],'property'+index+'Subject');
    if(!subjectArg)return question?{question}:null;
    const args=[subjectArg];
    if(c.object){
      const target=identify(c.object,'object'+index,sub);
      if(target===null)return question?{question}:null;
      const objectArg=argument(c.object,target,reading.roles[1],'property'+index+'Object');
      if(!objectArg)return question?{question}:null;
      if(c.alternatives.length){
        objectArg.coordination='any_of';objectArg.alternatives=[];
        for(const [i,np] of c.alternatives.entries()){
          const entity=identify(np,'object'+index+'Alternative'+i,sub);
          if(entity===null)return question?{question}:null;
          const alternative=argument(np,entity,reading.roles[1],'property'+index+'Alternative'+i);
          if(!alternative)return question?{question}:null;
          objectArg.alternatives.push({entity,properties:alternative.properties});
        }
      }
      args.push(objectArg);
    }
    if(Object.hasOwn(physicalActionLabels,reading.word)){
      const affected=args.find(a=>a.role===(reading.word==='fall'?'bearer':reading.word==='displace'?'bearer':'target'));
      for(const [i,option] of [affected,...affected?.alternatives||[]].entries()){
        if(!option)continue;
        const entity=entities[option.entity];
        if(isMaterialTarget(entity.head||''))continue;
        const key='physical'+index+(i?'Alternative'+(i-1):'');
        if(!answers[key])return {question:{key,prompt:'Does “'+reading.word+'” describe a physical action involving '+entity.label+'?',options:[
          {value:'physical',label:physicalActionLabels[reading.word]},{value:'other',label:'Another meaning'}]}};
        if(answers[key]!=='physical')return null;
      }
    }
    const informationVerb=reading.root===ERASURE?'delete':reading.root===id('copy')?'copy':null;
    if(informationVerb){
      const target=args.find(a=>a.role==='target');
      for(const [i,option] of [target,...target.alternatives||[]].entries()){
        const entity=entities[option.entity];
        if(isStoredInformationTarget(entity.head))continue;
        const key='information'+index+(i?'Alternative'+(i-1):'');
        if(!answers[key])return {question:{key,prompt:informationVerb==='delete'
          ?'Does “delete” mean removing '+entity.label+' from a store or collection of information?'
          :'Does “copy” mean creating a distinct stored copy of '+entity.label+' while retaining the source?',options:[
          {value:'stored',label:informationVerb==='delete'?'Remove the stored information item':'Create a stored copy'},{value:'other',label:'Another meaning'}]}};
        if(answers[key]!=='stored')return null;
      }
    }
    if(reading.root===id('recall')){
      const key='retrieval'+index;
      if(!answers[key])return {question:{key,prompt:'Does “'+reading.word+'” mean bringing a previously latent representation back to mind?',options:[
        {value:'retrieval',label:'Bring it back to mind'},{value:'other',label:'Another meaning'}]}};
      if(answers[key]!=='retrieval')return null;
    }
    const bearer=args.find(a=>a.role==='bearer');
    if(bearer){
      const where=bearer===args[0]?'Subject':'Object';
      const root=passageSense(bearer.entity,reading.word,'property'+index+where+reading.word,reading.root);
      if(!root)return question?{question}:null;
      reading={...reading,root};
    }
    let condition;
    if(c.condition){
      condition=selectProperty(bearer.entity,c.condition.word,'condition'+index,c.condition.root);
      if(!condition)return question?{question}:null;
    }
    if(c.recipient){
      const recipient=identify(c.recipient,'recipient'+index);
      if(recipient===null)return question?{question}:null;
      args.push({role:'recipient',entity:recipient,properties:[]});
    }
    if(args.length===2&&args[0].entity===args[1].entity && !['MIN:011','MIN:110'].includes(reading.root))return null;
    lastSubject=sub;
    events.push({predicate:reading.root,arguments:args,scopes:reading.scopes,quantifier:c.q,negated_quantifier:c.outsideNegation,...(condition?{condition}:{})});
    if(c.inherited)notes.push('The next action has the same subject (“'+entities[sub].label+'”).');
    if(c.q)notes.push(c.outsideNegation?'At least one member did not perform this action. Zero performers is possible.':
      c.q==='none'?'Zero members performed this action.':c.q==='few'?'A small, unspecified number of members performed this action.':'Every member performed this action.');
    if(reading.sense?.generalization)notes.push(reading.sense.generalization);
  }
  return {entities,events,relations:grammar.relations,runtime:grammar.runtime,act:grammar.act,notes,...(adjectives?{adjectives}:{})};
}
