import {isPassageHead} from './passage_nouns.mjs';
import {knownValueReading} from './known_value.mjs?v=field-repairs-1';
import {faultCategoryReading} from './fault_correction.mjs?v=field-repairs-1';
import {routeNounLabel} from './nominals.mjs';
import {expandNegativeContractions} from './contractions.mjs';
import {clauseSyntax, dictionaryClausePlan, dictionaryRoles} from './dictionary_clauses.mjs';
import {storyWords} from './story_words.mjs?v=field-repairs-1';

const words = new Map(storyWords.map(word => [word.word, word]));
const id = word => words.get(word).id;
const shapes = [
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
const predicateId = (word,target) => target?.includes(':')?target:word==='arrive'?'MOV:110':id(target||word);
const properties = new Map(Object.entries({
  cracked:id('cracked'), faulty:id('faulty'), broken:id('broken'), sick:'WRN:001',
  passable:id('passable'), open:id('passable'), blocked:id('blocked'), impassable:id('blocked'),
  valid:id('valid'), wrong:id('wrong'), mistaken:id('wrong'), awake:'LIF:001', asleep:'LIF:002', well:'REP:001', lost:'MOV:212'
}));
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

function nounPhrase(tokens, offset, {guessName=false,barePlural=false}={}) {
  const start = offset, token = tokens[offset], word = token?.toLowerCase();
  if (!word) return null;
  const possessive=['her','his','their','my','our','your'].includes(word) && /^[a-z][a-z-]*$/i.test(tokens[offset+1]||'');
  if(possessive){
    const np=nounPhrase(['the',...tokens.slice(offset+1)],0);
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
  while (properties.has(tokens[offset]?.toLowerCase())){
    const descriptor=tokens[offset++].toLowerCase();
    qualities.push(properties.get(descriptor));descriptors.push(descriptor);
    if(tokens[offset]?.toLowerCase()==='and'&&properties.has(tokens[offset+1]?.toLowerCase()))offset++;
  }
  let head = tokens[offset]?.toLowerCase();
  const route=routeNounLabel(head,tokens[offset+1]?.toLowerCase());
  if(route){head=route;offset++;}
  if (!head || (!route && !/^[a-z]+(?:-[a-z]+)*$/.test(head)) || nonNouns.has(head)) return null;
  if (plural(head) && ['a','an','this','that'].includes(det)) return null;
  return {text:tokens.slice(start,offset+1).join(' '), length:offset-start+1, reference:det+' '+head,
    head, category:personNouns.has(head.replace(/s$/,''))?'person':'thing', plural:plural(head), qualities,descriptors};
}
function countedSubject(tokens){
  const first=folded(tokens[0]||''),second=folded(tokens[1]||'');
  const few=first==='a'&&second==='few';
  if(!few && first!=='nobody' && first!=='nothing' && !(first==='no'&&second==='one'))return null;
  const length=few||first==='no'?2:1;
  if(few){
    const nominal=nounPhrase(['the',...tokens.slice(length)],0);
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
function linkedClauses(body){
  const tokens=tokensOf(body),parts=[],clause=[];
  for(let i=0;i<tokens.length;){
    const word=folded(tokens[i]);
    if(['and','before','after'].includes(word)){
      parts.push(clause.join(' '),word);clause.length=0;i++;continue;
    }
    // Consume a whole noun phrase so the 'and' inside paired adjectives stays with its noun.
    const nominal=nounPhrase(tokens,i),length=nominal?.length||1;
    clause.push(...tokens.slice(i,i+length));i+=length;
  }
  return [...parts,clause.join(' ')];
}
function splitObject(tokens) {
  for (let i=1; i<tokens.length; i++) {
    const object = nounPhrase(tokens, i,{barePlural:true});
    if(!object)continue;
    const alternatives=[];
    let end=i+object.length;
    while(folded(tokens[end]||'')==='or'){
      const next=nounPhrase(tokens,end+1,{barePlural:true});
      if(!next)break;
      alternatives.push(next);end+=1+next.length;
    }
    if(end===tokens.length)return {verb:tokens.slice(0,i).join(' '),object,alternatives};
  }
  return {verb:tokens.join(' '), object:null};
}
function describeChoice(row) {
  return row.word === 'return' ? 'went back to an earlier place' : 'happened again';
}
function predicate(verb, subject, object, authority, runtime, preferences) {
  const anchor = subject.pronoun ? (deictics[subject.pronoun] || (['they','them'].includes(subject.pronoun)?'we':'Ada')) :
    subject.plural&&!subject.singularAgreement?'we':'Ada';
  const capability=/^(cannot|can not|can|will)(?: (not))? (.+)$/i.exec(verb);
  const governed=capability?capability[3]:verb;
  const placeholder = anchor+' '+(capability?'might ':'')+governed+(object?' the gate':'');
  const syntax = clauseSyntax(placeholder);
  if (!syntax) return [];
  if(capability){
    const modal=capability[1].toLowerCase();
    syntax.scopes=modal==='will'?['time_after_speech']:['ability'];
    if(modal==='cannot'||modal==='can not')syntax.scopes.unshift('negation');
    else if(capability[2])syntax.scopes.push('negation');
  }
  const personal=preferences.length && dictionaryClausePlan(placeholder+' ['+runtime+'].',authority,{preferences});
  if(personal && personal.preferred>=0){
    const r=personal.readings[personal.preferred];
    if(r.root!=='erase_stored_object')return [{root:r.root,word:r.sense.lemma,roles:r.participants.map(p=>p.role),scopes:r.scopes,sense:r.sense,specific:false}];
  }
  const tail = object ? folded(syntax.tail).slice(0,-' the gate'.length) : folded(syntax.tail);
  if(syntax.being && !object && properties.has(tail))return [{root:properties.get(tail),word:tail,roles:['bearer'],scopes:syntax.scopes,specific:words.has(tail)||passageQualities.has(properties.get(tail))}];
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
  const rows = (plan.preferred>=0?[plan.readings[plan.preferred]]:plan.readings).filter(r=>r.root!=='erase_stored_object');
  return rows.map(r=>({root:r.root,word:r.sense.lemma,roles:r.participants.map(p=>p.role),scopes:r.scopes,
    sense:r.sense, specific:false}));
}

function prepare(input, authority, preferences) {
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
      const tokens=tokensOf(aux[2]),subject=nounPhrase(tokens,0,{guessName:true});
      if(!subject)return null;
      body=tokens.slice(0,subject.length).join(' ')+' '+folded(aux[1])+' '+tokens.slice(subject.length).join(' ');
      act='question';
    }
    let link=null;
    const leading=/^(before|after) (.+?),\s*(.+)$/i.exec(body);
    if(leading)body=leading[2]+' '+(folded(leading[1])==='before'?'after':'before')+' '+leading[3];
    const condition=/^if (.+?),\s*(?:then )?(.+)$/i.exec(body),postcondition=/^(.+) if (.+)$/i.exec(body);
    const parts=condition?[condition[1],'condition',condition[2]]:postcondition?[postcondition[1],'provided',postcondition[2]]:linkedClauses(body);
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
      const counted=countedSubject(tokens);
      let subject=counted?.subject||nounPhrase(tokens,0,{guessName:true}),consumed=subject?.length??0,inherited=false;
      if(counted){q=counted.q;special=true;}
      const shared=link==='and'&&subject?.guessedName?splitObject(tokens):null;
      if(link==='and' && (!subject || subject.category==='person' && shapes.some(row=>row.slice(0,3).includes(folded(tokens[0]))) ||
          shared&&predicate(shared.verb,clauses.at(-1).subject,shared.object,authority,runtime,preferences).length)){
        subject=clauses.at(-1).subject;consumed=0;inherited=true;special=true;
      }
      if(clauses.length===0 && sentences.length===1 && /^(?:find|notice|spot|repair|repeat|ring) (?:(?:it|them|the|a|an|this|that)\b)/i.test(piece)){
        subject={text:'you',pronoun:'you'};consumed=0;act='command';
      }
      if(!subject || q&&!subject.plural)return null;
      let tail=tokens.slice(consumed),when=null,again=false,recipient=null;
      if(folded(tail.at(-1)||'')==='now'){when='time_at_speech';tail=tail.slice(0,-1);}
      if(folded(tail.at(-1)||'')==='again'){again=true;tail=tail.slice(0,-1);}
      const ditransitive=tail.findIndex(t=>['make','makes','made'].includes(folded(t)));
      if(ditransitive>=0){
        const indirect=nounPhrase(tail,ditransitive+1),result=indirect&&nounPhrase(tail,ditransitive+1+indirect.length,{barePlural:true});
        if(indirect&&result&&ditransitive+1+indirect.length+result.length===tail.length){
          recipient=indirect;tail=[...tail.slice(0,ditransitive+1),...tail.slice(ditransitive+1+indirect.length)];
        }
      }
      let {verb,object,alternatives=[]}=splitObject(tail);
      if(!object && /^notic(?:e|es|ed)$/i.test(verb)){
        object={text:'the omitted target',pronoun:'it',prompt:'What did '+subject.text+' notice?'};
      }
      if(!verb)return null;
      let readings=predicate(verb,subject,object,authority,runtime,preferences);
      if(act==='command' && folded(verb)==='find' && object && !preferences.some(p=>p.forms?.includes('find'))){
        readings=[{root:id('find'),word:'find',roles:['experiencer','target'],scopes:[],specific:true}];
      }
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
      clauses.push({subject,object,alternatives,recipient,inherited,readings,q,outsideNegation});
    }
  }
  return special ? {runtime,act,clauses,relations} : null;
}

export function storyReading(input, authority, {answers={}, preferences=[]}={}) {
  if(typeof input!=='string')return null;
  const embedded=knownValueReading(input,answers)||faultCategoryReading(input,answers);
  if(embedded)return embedded;
  const grammar=prepare(input,authority,preferences);
  if(!grammar)return null;
  const entities=[],events=[],notes=[];
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
    const previous=entities.map((e,i)=>({e,i})).filter(({e})=>
      !indefinite && e.owner===owner && (e.reference===reference || (np.head && reference.startsWith('the ') && e.head===np.head)));
    if(previous.length===1)return previous[0].i;
    if(previous.length>1){
      const chosen=previous.find(x=>String(x.i)===answers[key]);
      if(chosen)return chosen.i;
      question={key,prompt:'Which '+np.head+' do you mean?',options:previous.map(({e,i})=>({value:String(i),label:e.label+' (reference '+(i+1)+')'}))};
      return null;
    }
    entities.push({reference,referenceKind:np.referenceKind,domain:np.domain,label:np.guessedName?np.reference:np.text,head:np.head,plural:!!np.plural||reference==='we',category,owner});return entities.length-1;
  }
  function passageSense(entity,word,key,root){
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
  function argument(np,entity,role,key){
    const properties=[];
    for(const [i,root] of (np.qualities||[]).entries()){
      const word=np.descriptors[i],selected=passageSense(entity,word,key+word,root);
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
    const bearer=args.find(a=>a.role==='bearer');
    if(bearer){
      const where=bearer===args[0]?'Subject':'Object';
      const root=passageSense(bearer.entity,reading.word,'property'+index+where+reading.word,reading.root);
      if(!root)return question?{question}:null;
      reading={...reading,root};
    }
    if(c.recipient){
      const recipient=identify(c.recipient,'recipient'+index);
      if(recipient===null)return question?{question}:null;
      args.push({role:'recipient',entity:recipient,properties:[]});
    }
    if(args.length===2&&args[0].entity===args[1].entity && !['MIN:011','MIN:110'].includes(reading.root))return null;
    lastSubject=sub;
    events.push({predicate:reading.root,arguments:args,scopes:reading.scopes,quantifier:c.q,negated_quantifier:c.outsideNegation});
    if(c.inherited)notes.push('The next action has the same subject (“'+entities[sub].label+'”).');
    if(c.q)notes.push(c.outsideNegation?'At least one member did not perform this action. Zero performers is possible.':
      c.q==='none'?'Zero members performed this action.':c.q==='few'?'A small, unspecified number of members performed this action.':'Every member performed this action.');
    if(reading.sense?.generalization)notes.push(reading.sense.generalization);
  }
  return {entities,events,relations:grammar.relations,runtime:grammar.runtime,act:grammar.act,notes};
}
