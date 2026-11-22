import {renderLexicalOccurrences} from './bound_compounds.mjs?v=partial-word-flow-1';
import {contextualContentReference} from './contextual_content.mjs?v=partial-word-flow-1';
import {grammarMarker} from './scheduler.mjs?v=partial-word-flow-1';
import {informationFrame} from './information_passage_frames.mjs?v=field-repairs-1';

const roleNode=(node,role)=>({nodes:[node,{node_id:'clause',kind:'clause'}],
  edges:[{edge_id:'binding',type:'fills_role',from:node.node_id,to:'clause',role}]});

export function informationMusic(authority,runtime) {
  const anchor=60, marker=name=>grammarMarker({performance:{anchor_midi:anchor}},'passage',name);
  const wrap=(name,events,draft=false)=>{
    // Reuse the existing audible ability enclosure across draft sentence routes.
    if(name==='ability'){name='story_ability';draft=true;}
    const frame=side=>draft?informationFrame(name+'_'+side,anchor):marker(name+'_'+side);
    return [frame('open'),...events,frame('close')];
  };
  const render=node=>renderLexicalOccurrences(node,authority,{anchor});
  const lexical=(target_id,role)=> {
    const node={node_id:'word',kind:'lexical_occurrence',target_type:target_id.startsWith('CMP:')?'compound':'atom',target_id,runtime_state:{code:runtime}};
    return render(role?roleNode(node,role):{nodes:[node],edges:[]});
  };
  const participant=async (value,role)=>{
    const ref=await contextualContentReference(value==='we'?'I':value);
    const events=await render(roleNode(ref,role));
    return wrap('role_'+role,value==='we'?wrap('speaker_group',events,true):events);
  };
  const reference=(node,role)=>render(roleNode(node,role));
  return {anchor,marker,wrap,lexical,participant,reference};
}
