export function massKilograms(value,unit){
  if(typeof value!=='string'||value.length>1000||!/^[0-9]+(?:\.[0-9]+)?$/.test(value)||!['gram','kilogram'].includes(unit))return null;
  let [whole,fraction='']=value.split('.');
  if(unit==='gram'){whole=whole.padStart(4,'0');fraction=whole.slice(-3)+fraction;whole=whole.slice(0,-3);}
  whole=whole.replace(/^0+/,'')||'0';fraction=fraction.replace(/0+$/,'');
  return whole+(fraction?'.'+fraction:'');
}
