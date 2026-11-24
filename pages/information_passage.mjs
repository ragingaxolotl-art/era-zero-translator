import {informationMusic} from './information_music.mjs?v=ordinary-comparatives-1';
import {contextualContentReference} from './contextual_content.mjs?v=ordinary-comparatives-1';
import {midiFromScheduledEvents} from './engine.mjs?v=ordinary-comparatives-1';
import {strictSemanticReader} from './strict_semantic_reader.mjs?v=ordinary-comparatives-1';

const programClass = 'CMP:2f350e7d8e5dfba4a802d82d';
const actor = '(I|[Ww]e|[Yy]ou|[A-Z][a-z]+)';
const boundary = '(?:\\s*[,;.](?:\\s+and)?\\s*|\\s+and\\s+|\\s+)';
const construction = new RegExp('^'+actor+' (?:(have|has) )?found the (program|file|message|record)'+boundary+
  actor+' (need|needs) to delete (it|the (?:program|file|message|record))$');

function person(text) {
  if (/^we$/i.test(text)) return 'we';
  if (/^you$/i.test(text)) return 'you';
  if (text === 'I') return text;
  return /^(?:She|He|It|They|The|That|This|Someone|Nobody|Who|What|There|Is|Has|Have|Did|Does|Must|Need)$/i.test(text) ? null : text;
}
export function informationPassagePlan(input) {
  if (typeof input !== 'string') return null;
  let text=input.trim(), runtime=1;
  const suffix=text.match(/\s*\[([012])\]\.?$/);
  if (suffix) { runtime=Number(suffix[1]); text=text.slice(0,suffix.index).trim(); }
  text=text.replace(/[.]$/,'').replace(/\s+/g,' ').replace(/\b(we|you|I)['’]ve\b/gi,'$1 have');
  const m=text.match(construction);
  if (!m) return null;
  const finder=person(m[1]), eraser=person(m[4]);
  if (!finder || !eraser || (m[6]!=='it' && m[6]!== 'the '+m[3])) return null;
  const pluralVerb=p=>['we','I','you'].includes(p);
  if ((m[2] && m[2] !== (pluralVerb(finder)?'have':'has')) || m[5] !== (pluralVerb(eraser)?'need':'needs')) return null;
  return {finder,eraser,object:m[3],presentPerfect:Boolean(m[2]),runtime};
}

export async function composeInformationPassage(input,authority) {
  const p=informationPassagePlan(input);
  if (!p) throw Error('Unsupported discovery and erasure passage.');
  const {anchor,marker,wrap,lexical,participant,reference}=informationMusic(authority,p.runtime);
  const object=await contextualContentReference('the '+p.object);
  const classEvents=p.object==='program'?await lexical(programClass,'target'):[];
  const discovery=wrap('time_before_speech',[
    ...await participant(p.finder,'experiencer'), ...await lexical('MIN:110'),
    ...wrap('role_target',[...classEvents,...await reference(object,'target')])
  ]);
  const required=wrap('modality_necessary',wrap('erase_stored_object',[
    ...await participant(p.eraser,'actor'), ...wrap('role_target',[marker('role_reference_target')]),
    ...await lexical('ORI:110'), ...wrap('role_result',wrap('negation',await lexical('DAT:000')))
  ],true));
  const events=wrap('coord_all_of',[...(p.presentPerfect?wrap('present_perfect',discovery,true):discovery),marker('coord_member'),...required]);
  const midi=midiFromScheduledEvents(events,anchor,[0,0]);
  const meaning={profile:'EZ-INFORMATION-PASSAGE-1',status:'draft',speech_act:'assertion',runtime_state:p.runtime,
    discovery:{actor:p.finder,target:'object',sense:'GSE:001',root:'MIN:110',time:'before_speech',present_perfect:p.presentPerfect},
    object:{id:'object',reference:'definite',head:p.object,...(p.object==='program'?{classification:programClass}:{})},
    requirement:{mode:'necessary',actor:p.eraser,action:'erase_stored_object',target:'object',result:'storage_ceases_to_retain_object',event_asserted:false}};
  return {meaning,midi};
}

// This inverse takes only notes and the dictionary. The second target has to be
// the audible back-reference within the same two-clause construction.
export function decodeInformationPassageMidi(bytes,atoms) {
  const reader=strictSemanticReader(bytes,atoms,'Malformed discovery and erasure passage.',{allowDraftInformationPassage:true});
  const fail=()=>{throw Error('Malformed discovery and erasure passage.');};
  const children=(node,name,count)=>{
    if (node?.marker!==name+'_open' || !node.children || (count!==undefined && node.children.length!==count)) fail();
    return node.children;
  };
  const ref=(node,name,register)=>{
    let body=children(node,'role_'+name);
    const group=body.length===1 && body[0].marker==='speaker_group_open';
    if (group) body=children(body[0],'speaker_group',1);
    const r=reader.reference(body,register);
    if (group && (r.kind!=='deictic'||r.role!=='speaker')) fail();
    return group?{kind:'deictic',role:'speaker_group'}:r;
  };
  const tree=reader.readTree();
  if (tree.length!==1 || reader.observed.speech_act!=='assertion') fail();
  let [fact,join,need]=children(tree[0],'coord_all_of',3);
  if (join.marker!=='coord_member') fail();
  const perfect=fact.marker==='present_perfect_open';
  if (perfect) [fact]=children(fact,'present_perfect',1);
  const [subject,head,target]=children(fact,'time_before_speech',3);
  const runtime=head.runtime_state;
  if (![0,1,2].includes(runtime)) fail();
  reader.exactRoot(head,'MIN:110','middle',runtime);
  const finder=ref(subject,'experiencer','middle');
  const targetBody=[...children(target,'role_target')];
  let classification;
  if (targetBody[0]?.kind==='root') {
    for (const [id,state] of [['DAT:000',null],['LOG:010',null],['CRE:000',runtime]]) reader.exactRoot(targetBody.shift(),id,'high',state);
    classification=programClass;
  }
  const object=reader.reference(targetBody,'high');
  if (object.reference_mode!=='definite_nominal') fail();
  const [erase]=children(need,'modality_necessary',1);
  const [agent,backref,transition,result]=children(erase,'erase_stored_object',4);
  const eraser=ref(agent,'actor','low');
  if (children(backref,'role_target',1)[0].marker!=='role_reference_target') fail();
  reader.exactRoot(transition,'ORI:110','middle',runtime);
  const [negative]=children(result,'role_result',1);
  reader.exactRoot(children(negative,'negation',1)[0],'DAT:000','middle',runtime);
  return {speech_act:'assertion',runtime_state:runtime,discovery:{actor:finder,target:object,time:'before_speech',present_perfect:perfect},
    ...(classification?{classification}:{}),requirement:{actor:eraser,mode:'necessary',target:object,action:'erase_stored_object',event_asserted:false}};
}
