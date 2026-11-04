import {strictSemanticReader} from './strict_semantic_reader.mjs';

// Independent bounded semantic projection; only performed MIDI and root sounds.
export function decodeCustodyDeliveryMidi(bytes,atoms){
 const message='Unsupported or malformed custody-delivery music.';
 const fail=()=>{throw new Error(message);},same=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
 const {observed,marker,exactRoot,role,unwrapScopes}=strictSemanticReader(bytes,atoms,message);
 const children=(node,code,length)=>{if(!marker(node,`convention_${code}_open`)||node.children?.length!==length)fail();return node.children;};
 const {current,scopes}=unwrapScopes(node=>marker(node,'convention_10_open'));
 if(current.length!==1)fail();const [arrival,transfer]=children(current[0],10,2);
 const [arriving,destination,path,arrivalHead]=children(arrival,6,4);exactRoot(arrivalHead,'MOV:110','middle',null);
 const [moving,goal,carrying,pathHead]=children(path,5,4);exactRoot(pathHead,'MOV:111','middle',null);
 const [conveyed,support,carryingHead]=children(carrying,4,3);exactRoot(carryingHead,'MOV:121','middle',null);
 const [carrier,load,supportHead]=children(support,3,3);exactRoot(supportHead,'MAT:211','middle',null);
 const source=role(carrier,'source','low'),object=role(load,'target','high',true),recipient=role(destination,'destination','high');
 for(const mover of [arriving,moving,conveyed])if(!same(role(mover,'actor','low'),object))fail();
 if(!same(role(goal,'destination','high'),recipient))fail();
 const custody=node=>{const [holder,target,head]=children(node,7,3);exactRoot(head,'MAT:210','middle',null);return {holder:role(holder,'source','low'),object:role(target,'target','high',true)};};
 const [prior,acquisition]=children(transfer,9,2),before=custody(prior);
 const [gained,head]=children(acquisition,8,2),after=custody(gained),runtime=head?.runtime_state;
 if(![0,1,2].includes(runtime))fail();exactRoot(head,'ORI:110','middle',runtime);
 if(!same(before.holder,source)||!same(before.object,object)||!same(after.object,object)||!same(after.holder,recipient))fail();
 return {profile:'EZCUSTODY-DELIVERY-INVERSE-1',speech_act:observed.speech_act,scopes,
  predicate:'completed_carrying_custody_delivery',runtime_state:runtime,participants:{carrier:source,object,recipient},
  convention_codes:[10,6,5,4,3,9,7,8,7],
  meaning:{same_object:true,carrier_is_transfer_source:true,destination_referent_is_recipient:true,
   arrival_culminates_in_transfer:true,same_delivery_event:true,source_custody_before_transfer:true,
   source_custody_at_culmination:false,recipient_custody_before_transfer:false,recipient_custody_at_culmination:true,
   ownership_asserted:false,willingness_asserted:false,persistence_after_culmination_asserted:false},
  limitations:[
   'These are event-type commitments inside recovered scope and speech act. Ongoing, habitual, negated, modal, questioned or commanded delivery does not assert a current completed arrival or transfer.',
   'The source pre-state is immediately before transfer; this does not assert exclusive custody throughout the whole journey.',
   'The destination is the recipient-associated position; carrying arrival and handover belong to one culmination, not unrelated episodes.',
   'Repeated audible references are checked; original spelling, external identity, general discourse and recorded audio are outside this bounded MIDI inverse.',
   'This profile excludes delivery by unsupported flight, an unattended drop-off without custody acquisition, retained source custody or transfer by a different agent.'
  ]};
}
