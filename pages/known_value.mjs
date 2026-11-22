// Knowing the identity of a wanted value is an embedded open question. The existing
// polar-knowledge foundation selects a yes/no answer and cannot express this binding.
import {expandNegativeContractions} from './contractions.mjs';
import {scoreRoleReference,readRoleReference} from './dictionary_clause_music.mjs?v=meaning-reliability-1';
import {informationMusic} from './information_music.mjs?v=meaning-reliability-1';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs?v=meaning-reliability-1';
import {describeRuntime} from './meaning_readback.mjs?v=field-repairs-1';

const nominal='(I|we|you|they|she|he|it|(?:the|this|that) [a-z]+|[A-Z][a-z]+|"[^"]+")';
const statement=new RegExp('^(Then,? )?'+nominal+' (know|knows|knew|do not know|does not know|did not know) what (else )?'+nominal+' (want|wants|wanted)[.]?$','i');
function agrees(subject,verb){
  if(verb==='knew'||verb==='did not know'||verb==='wanted')return true;
  const plural=/^(?:i|we|you|they)$/i.test(subject)||/^(?:the|these|those) .+s$/i.test(subject);
  return plural===['want','know','do not know'].includes(verb);
}
export function knownValueReading(input,answers){
  let text=expandNegativeContractions(input.trim().replace(/\s+/g,' '));
  const suffix=/\s*\[([012])\]([.]?)$/.exec(text);
  if(suffix)text=text.slice(0,suffix.index).trim();
  const m=statement.exec(text);
  if(!m||!agrees(m[2],m[3].toLowerCase())||!agrees(m[5],m[6].toLowerCase()))return null;
  const reference=(raw,key)=>{
    const folded=raw.toLowerCase();
    if(['i','you','we'].includes(folded))return folded==='i'?'I':folded;
    if(/^(?:the|this|that) /.test(folded))return folded;
    if(!['he','she','it','they'].includes(folded)&&(/^[A-Z]/.test(raw)||raw[0]==='"'))return raw;
    const given=answers[key]?.replace(/^new:/,'').trim();
    if(given&&/^(?:(?:the|this|that) [a-z]+|[A-Z][a-z]+|"[^"]+")$/.test(given))return given;
    return {question:{key,prompt:'Who or what does “'+raw+'” identify here?',options:[],allowName:true}};
  };
  const knower=reference(m[2],'knower'),wanter=reference(m[5],'wanter');
  if(knower.question)return knower;
  if(wanter.question)return wanter;
  return {valueKnowledge:{knower,wanter,additional:!!m[4],context:!!m[1],
    negated:/not/i.test(m[3]),knowledgePast:/^(did|knew)/i.test(m[3]),desirePast:/^wanted$/i.test(m[6])},runtime:suffix?Number(suffix[1]):1};
}
function meaning(knower,wanter,runtime_state,v){
  return {profile:'EZ-KNOWN-VALUE-1',status:'draft',speech_act:'assertion',runtime_state,
    discourse:v.context?'then':null,knowledge:{kind:'knows_answer',knower,
      scopes:[...(v.knowledgePast?['time_before_speech']:[]),...(v.negated?['negation']:[])],
      question:{kind:'identity',additional:v.additional,restriction:{kind:'wanted_by',wanter,
        scopes:v.desirePast?['time_before_speech']:[],relation_to_value:'unspecified'}}}};
}
export async function scoreKnownValue({valueKnowledge:v,runtime},authority){
  const music=informationMusic(authority,runtime),{wrap,lexical,anchor}=music;
  const who=await scoreRoleReference(v.knower,'experiencer',music);
  const wants=await scoreRoleReference(v.wanter,'source',music);
  let bound=wrap('value_wanted',wrap('role_source',wants.notes),true);
  if(v.desirePast)bound=wrap('time_before_speech',bound);
  if(v.additional)bound=wrap('value_additional',bound,true);
  let body=[...wrap('role_experiencer',who.notes),...await lexical('MIN:011'),...wrap('role_content',bound)];
  if(v.negated)body=wrap('negation',body);
  if(v.knowledgePast)body=wrap('time_before_speech',body);
  if(v.context)body=wrap('value_then',body,true);
  const events=wrap('value_knowledge',body,true);
  const subject={I:'The speaker',we:'The speaker’s group',you:'The listener'}[v.knower]||v.knower;
  const wantsLabel={I:'the speaker',we:'the speaker’s group',you:'the listener'}[v.wanter]||v.wanter;
  const description=(v.context?'At that point in the conversation, ':'')+subject+
    (v.knowledgePast?(v.negated?' did not know':' knew'):(v.negated?' lacks knowledge of':' knows'))+
    ' the identity of '+(v.additional?'an additional':'the')+' thing wanted by '+wantsLabel+(v.desirePast?' in the past':'')+'. '+describeRuntime(runtime);
  return {label:'Knowledge of a wanted value',description,midi:midiFromScheduledEvents(events,anchor,[0,0]),
    meaning:meaning(who.identity,wants.identity,runtime,v)};
}
export function decodeKnownValueMidi(bytes,atoms){
  const invalid=()=>{throw Error('Invalid open-question knowledge score.');};
  const reader=strictSemanticReader(bytes,atoms,'Invalid open-question knowledge score.',{allowDraftInformationPassage:true});
  let nodes=reader.readTree();
  const consume=marker=>{
    if(nodes.length!==1||nodes[0].marker!==marker+'_open')return false;
    nodes=nodes[0].children;return true;
  };
  if(reader.observed.speech_act!=='assertion'||!consume('value_knowledge'))invalid();
  const context=consume('value_then'),knowledgePast=consume('time_before_speech'),negated=consume('negation');
  const [outer,predicate,content]=nodes,runtime=predicate?.runtime_state;
  if(nodes.length!==3||outer.marker!=='role_experiencer_open'||content.marker!=='role_content_open'||![0,1,2].includes(runtime))invalid();
  reader.exactRoot(predicate,'MIN:011','middle',runtime);
  const knower=readRoleReference(outer.children,'experiencer',reader);
  nodes=content.children;
  const additional=consume('value_additional'),desirePast=consume('time_before_speech');
  if(!consume('value_wanted')||!consume('role_source'))invalid();
  return meaning(knower,readRoleReference(nodes,'source',reader),runtime,{context,knowledgePast,negated,additional,desirePast});
}
