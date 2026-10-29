import {decodeStrictMusicMidi} from './strict_music_decoder.mjs';
// Recover only the complete EZREFPROPERTY-1 segments from performed MIDI.
// No source IR, English text or encoder event metadata is supplied.
export function decodeNominalMassRestrictions(bytes,atoms){
 const observed=decodeStrictMusicMidi(bytes,atoms),tokens=observed.tokens,restrictions=[];
 const fail=()=>{throw new Error('Malformed nominal mass restriction in performance.');};
 for(let i=0;i<tokens.length;i++){
  if(tokens[i].marker!=='nominal_mass_open')continue;
  const end=tokens[i].closing_token;let at=i+1;
  const expect=marker=>{if(tokens[at++]?.marker!==marker)fail();};
  const relation=tokens[at]?.marker?.match(/^measure_compare_(greater_than|less_than)_open$/)?.[1];if(!relation)fail();at++;
  expect('measurement_open');let magnitude='';
  while(at<end&&(tokens[at].marker==='decimal_point'||/^digit_[0-9]$/.test(tokens[at].marker||''))){const m=tokens[at++].marker;magnitude+=m==='decimal_point'?'.':m.at(-1);}
  if(magnitude.length>1024||!/^(?:0|[1-9][0-9]*)(?:\.[0-9]*[1-9])?$/.test(magnitude))fail();
  expect('measurement_unit_9');expect('measurement_close');expect(`measure_compare_${relation}_close`);expect('nominal_property_head');
  const mode=tokens[at++],name=tokens[at++];
  if(mode?.kind!=='reference_mode'||mode.reference_mode!=='definite_nominal'||name?.kind!=='phonemic'||name.register!==mode.register||at!==end)fail();
  expect('nominal_mass_close');
  restrictions.push({dimension:'mass',magnitude,unit:'kilogram',comparison:relation,reference_mode:'definite_nominal',phonemes:[...name.phonemes],register:name.register,
   enclosing_roles:tokens[i].enclosing_scopes.map(j=>tokens[j].marker).filter(m=>/^role_.+_open$/.test(m)).map(m=>m.slice(5,-5))});
 }
 return {profile:'EZREFPROPERTY-INVERSE-1',restrictions,limitations:['Recovers bounded nominal mass restrictions only, not full sentence meaning.','Repeated sounds do not independently establish discourse identity or original noun spelling.']};
}
