// Nonnegative photometric luminance values in cd/m²; no perceptual-brightness conversion.
export function luminanceValue(value,unit='candela_per_square_meter'){
 if(unit!=='candela_per_square_meter'||typeof value!=='string'||value.length>1000||!/^\d+(?:\.\d+)?$/.test(value))return null;
 const [whole,fraction='']=value.split('.'),integer=whole.replace(/^0+(?=\d)/,''),decimal=fraction.replace(/0+$/,'');
 return integer+(decimal?'.'+decimal:'');
}
