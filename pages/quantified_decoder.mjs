import {strictSemanticReader} from './strict_semantic_reader.mjs';
// Initial semantic inverse: counted unary atomic properties. More predicate
// valences and nested counts must be admitted explicitly, not silently ignored.
export function decodeQuantifiedPropertyMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Draft counted-predicate decoding requires opt-in.');
 const fail=()=>{throw new Error('Unsupported or malformed counted property music.');};
 const reader=strictSemanticReader(bytes,atoms,'Invalid counted property framing.',{allowDraftQuantified:true});
 let tree=reader.readTree(),propositionNegated=false;
 if(tree.length===1&&tree[0].marker==='negation_open'){propositionNegated=true;tree=tree[0].children;}
 if(tree.length!==1)fail();const binder=tree[0],quantifier=binder.marker?.match(/^counted_(exact|at_least|at_most)_open$/)?.[1];if(!quantifier)fail();
 const children=[...binder.children],digits=[];while(/^digit_[0-9]$/.test(children[0]?.marker||''))digits.push(children.shift().marker.at(-1));
 const value=digits.join('');if(!/^(?:0|[1-9][0-9]*)$/.test(value)||value.length>1024||children.length!==2)fail();
 const [restriction,predicate]=children;if(restriction.marker!=='counted_restriction_open'||predicate.marker!=='counted_predicate_open')fail();
 const nominal=reader.reference(restriction.children,'middle');if(nominal.kind!=='phonemic'||nominal.reference_mode!=='nominal_class')fail();
 let body=predicate.children,predicateNegated=false;
 if(body.length===1&&body[0].marker==='negation_open'){predicateNegated=true;body=body[0].children;}
 if(body.length!==2)fail();const [role,head]=body;
 if(role.marker!=='role_bearer_open'||role.children?.length!==1||role.children[0].marker!=='counted_reference_0')fail();
 if(!['MAT:001','WRN:001','REP:001','LIF:011','LIF:012'].includes(head.root_id)||![0,1,2].includes(head.runtime_state))fail();reader.exactRoot(head,head.root_id,'middle',head.runtime_state);
 return {profile:'EZCOUNT-PROPERTY-INVERSE-1',speech_act:reader.observed.speech_act,quantifier,value,restriction:nominal,predicate:{root_id:head.root_id,runtime_state:head.runtime_state,bearer:{kind:'bound',depth:0}},predicate_negated:predicateNegated,proposition_negated:propositionNegated,limitations:['Draft profile; unary atomic properties only.','Noun sounds do not identify the real-world domain.','Runtime state does not evaluate the predicate truth.']};
}
