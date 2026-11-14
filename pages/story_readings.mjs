import {clauseSyntax, dictionaryClausePlan, dictionaryRoles} from './dictionary_clauses.mjs';
import {storyWords} from './story_words.mjs';

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
  ['return', 'returns', 'returned', ['actor']],
  ['arrive', 'arrives', 'arrived', ['actor']]
];
const predicateId = word => word === 'arrive' ? 'MOV:110' : id(word);
const properties = new Map(Object.entries({
  cracked:id('cracked'), faulty:id('faulty'), broken:id('broken'), sick:'WRN:001',
  awake:'LIF:001', asleep:'LIF:002', well:'REP:001', lost:'MOV:212'
}));
const pronouns = new Set('they them he him she her it'.split(' '));
const deictics = {i:'I',me:'I',we:'we',us:'we',you:'you'};
const determiners = new Set('a an the this that'.split(' '));
const personNouns = new Set('person child teacher worker friend programmer keeper custodian'.split(' '));
const nonNouns = new Set('all none of a an the this that to is are was were it they us and but or before after not need needs might could will must who what do does did'.split(' '));
const folded = s => s.toLowerCase();
const plural = noun => /(?:ies|s)$/.test(noun) && !/(?:ss|us|is)$/.test(noun);
export const storyPropertyIds = new Set(properties.values());
export function storyRoles(root) {
  const roles = shapes.filter(([base]) => predicateId(base) === root).map(row => row[3]);
  if (storyPropertyIds.has(root)) roles.push(['bearer']);
  if (root===id('find'))roles.push(['experiencer','target']);
  return [...roles, ...dictionaryRoles(root)];
}

function nounPhrase(tokens, offset) {
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
    if (!/^([A-Z][a-z]+|"[^"\n]+")$/.test(token) || nonNouns.has(word)) return null;
    return {text:token, length:1, reference:token, category:'person', plural:false, qualities:[]};
  }
  offset++;
  const qualities = [];
  while (properties.has(tokens[offset]?.toLowerCase())) qualities.push(properties.get(tokens[offset++].toLowerCase()));
  const head = tokens[offset]?.toLowerCase();
  if (!head || !/^[a-z]+(?:-[a-z]+)*$/.test(head) || nonNouns.has(head)) return null;
  if (plural(head) && ['a','an','this','that'].includes(det)) return null;
  return {text:tokens.slice(start,offset+1).join(' '), length:offset-start+1, reference:det+' '+head,
    head, category:personNouns.has(head.replace(/s$/,''))?'person':'thing', plural:plural(head), qualities};
}
const tokensOf = s => s.match(/"[^"\n]+"|[^\s]+/g) || [];
function splitObject(tokens) {
  for (let i=1; i<tokens.length; i++) {
    const object = nounPhrase(tokens, i);
    if (object && i+object.length === tokens.length) return {verb:tokens.slice(0,i).join(' '), object};
  }
  return {verb:tokens.join(' '), object:null};
}
function describeChoice(row) {
  return row.word === 'return' ? 'went back to an earlier place' : 'happened again';
}
function predicate(verb, subject, object, authority, runtime, preferences) {
  const anchor = subject.pronoun ? (deictics[subject.pronoun] || (['they','them'].includes(subject.pronoun)?'we':'Ada')) :
    subject.plural?'we':'Ada';
  const placeholder = anchor+' '+verb+(object?' the gate':'');
  const syntax = clauseSyntax(placeholder);
  if (!syntax) return [];
  const tail = object ? folded(syntax.tail).slice(0,-' the gate'.length) : folded(syntax.tail);
  if(syntax.being && !object && properties.has(tail))return [{root:properties.get(tail),word:tail,roles:['bearer'],scopes:syntax.scopes,specific:words.has(tail)}];
  const readings = [];
  if(object && syntax.allowPast && tail==='found' && !preferences.some(p=>p.forms?.includes('found'))){
    return [{root:id('find'),word:'find',roles:['experiencer','target'],scopes:[...syntax.scopes,'time_before_speech'],specific:true}];
  }
  for (const [base,third,past,roles] of shapes) {
    const repeatedEvent=base==='repeat'&&!object;
    if (syntax.being || (!repeatedEvent && roles.length !== (object?2:1))) continue;
    const pastMatch = syntax.allowPast && tail === past;
    if (!pastMatch && tail !== (syntax.form==='third'?third:base)) continue;
    const scopes = [...syntax.scopes, ...(pastMatch?['time_before_speech']:[])];
    readings.push({root:repeatedEvent?id('recur'):predicateId(base),word:repeatedEvent?'recur':base,roles:repeatedEvent?['bearer']:roles,scopes,specific:true});
    if (base==='return') readings.push({root:id('recur'),word:'recur',roles:['bearer'],scopes,specific:true});
    break;
  }
  if (readings.length) return readings;
  const plan = dictionaryClausePlan(placeholder+' ['+runtime+'].',authority,{preferences});
  if (!plan) return [];
  const rows = (plan.preferred>=0?[plan.readings[plan.preferred]]:plan.readings).filter(r=>r.root!=='erase_stored_object');
  return rows.map(r=>({root:r.root,word:r.sense.lemma,roles:r.participants.map(p=>p.role),scopes:r.scopes,
    sense:r.sense, specific:false}));
}

function prepare(input, authority, preferences) {
  let text=input.trim(), runtime=1;
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
    if(sentence.endsWith('?'))return null; // Existing question constructions keep their own interpretation.
    let link=null;
    const leading=/^(before|after) (.+?),\s*(.+)$/i.exec(body);
    if(leading)body=leading[2]+' '+(folded(leading[1])==='before'?'after':'before')+' '+leading[3];
    const parts=body.split(/\s+(and|before|after)\s+/i);
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
      let subject=nounPhrase(tokens,0), consumed=subject?.length??0, inherited=false;
      if(link==='and' && (!subject || subject.category==='person' && shapes.some(row=>row.slice(0,3).includes(folded(tokens[0]))))){
        subject=clauses.at(-1).subject;consumed=0;inherited=true;special=true;
      }
      if(clauses.length===0 && sentences.length===1 && /^(?:find|notice|repair|repeat|ring) (?:(?:it|them|the|a|an|this|that)\b)/i.test(piece)){
        subject={text:'you',pronoun:'you'};consumed=0;act='command';
      }
      if(!subject || q&&!subject.plural)return null;
      let {verb,object}=splitObject(tokens.slice(consumed));
      if(!object && /^notic(?:e|es|ed)$/i.test(verb)){
        object={text:'the omitted target',pronoun:'it',prompt:'What did '+subject.text+' notice?'};
      }
      if(!verb)return null;
      let readings=predicate(verb,subject,object,authority,runtime,preferences);
      if(act==='command' && folded(verb)==='find' && object && !preferences.some(p=>p.forms?.includes('find'))){
        readings=[{root:id('find'),word:'find',roles:['experiencer','target'],scopes:[],specific:true}];
      }
      if(!readings.length)return null;
      // A modal or negative governing a coordinated verb phrase needs a group scope.
      if(inherited && clauses.at(-1).readings.some(r=>r.scopes.some(s=>s!=='time_before_speech')))return null;
      if (link) {
        const left=clauses.length-1,right=clauses.length;
        relations.push({kind:link==='and'?'and':'before',events:link==='after'?[right,left]:[left,right]});
      }
      special ||= !!link || readings.some(r=>r.specific) || !!subject.owner || !!object?.owner || !!subject.qualities?.length || !!object?.qualities?.length ||
        pronouns.has(subject.pronoun)||pronouns.has(object?.pronoun);
      clauses.push({subject,object,inherited,readings,q,outsideNegation});
    }
  }
  return special ? {runtime,act,clauses,relations} : null;
}

export function storyReading(input, authority, {answers={}, preferences=[]}={}) {
  if(typeof input!=='string')return null;
  const grammar=prepare(input,authority,preferences);
  if(!grammar)return null;
  const entities=[],events=[],notes=[];
  let question=null, lastSubject;
  function identify(np,key,exclude=null) {
    const p=np.pronoun;
    if(pronouns.has(p)){
      const people=!['it'].includes(p);
      const eligible=entities.map((e,i)=>({e,i})).filter(({i})=>i!==exclude);
      let candidates=eligible.filter(({e})=>people?(e.category==='person'||(['they','them'].includes(p)&&e.plural)):e.category==='thing');
      const direct=candidates.length>0;
      if(!direct && ['it','they','them'].includes(p))candidates=eligible;
      const answer=answers[key];
      if(answer?.startsWith('new:')){
        const supplied=tokensOf(answer.slice(4).trim()), ref=nounPhrase(supplied,0);
        if(ref && !ref.pronoun && ref.length===supplied.length && !ref.qualities.length){
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
    const indefinite=/^an? /.test(reference);
    const previous=entities.map((e,i)=>({e,i})).filter(({e})=>
      !indefinite && e.owner===owner && (e.reference===reference || (np.head && reference.startsWith('the ') && e.head===np.head)));
    if(previous.length===1)return previous[0].i;
    if(previous.length>1){
      const chosen=previous.find(x=>String(x.i)===answers[key]);
      if(chosen)return chosen.i;
      question={key,prompt:'Which '+np.head+' do you mean?',options:previous.map(({e,i})=>({value:String(i),label:e.label+' (reference '+(i+1)+')'}))};
      return null;
    }
    entities.push({reference,label:np.text,head:np.head,plural:!!np.plural||reference==='we',category,owner});return entities.length-1;
  }
  for(const [index,c] of grammar.clauses.entries()){
    let reading=c.readings[0];
    if(c.readings.length>1){
      reading=c.readings.find(r=>r.root===answers['word'+index]);
      if(!reading)return {question:{key:'word'+index,prompt:'Which meaning do you intend in this action?',options:c.readings.map(r=>({value:r.root,label:r.specific?describeChoice(r):r.sense.definition,sense:r.sense}))}};
    }
    const sub=c.inherited?lastSubject:identify(c.subject,'subject'+index);
    if(question)return {question};
    const args=[{role:reading.roles[0],entity:sub,properties:c.inherited?[]:c.subject.qualities||[]}];
    if(c.object){
      const target=identify(c.object,'object'+index,sub);
      if(question)return {question};
      args.push({role:reading.roles[1],entity:target,properties:c.object.qualities||[]});
    }
    if(args.length===2&&args[0].entity===args[1].entity && !['MIN:011','MIN:110'].includes(reading.root))return null;
    lastSubject=sub;
    events.push({predicate:reading.root,arguments:args,scopes:reading.scopes,quantifier:c.q,negated_quantifier:c.outsideNegation});
    if(c.inherited)notes.push(entities[sub].label+' also performs the next action.');
    if(c.q)notes.push(c.outsideNegation?'At least one member did not perform this action. Zero performers is possible.':
      c.q==='none'?'Zero members performed this action.':'Every member performed this action.');
    if(reading.sense?.generalization)notes.push(reading.sense.generalization);
  }
  return {entities,events,relations:grammar.relations,runtime:grammar.runtime,act:grammar.act,notes};
}
