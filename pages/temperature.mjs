// Temperature points only. Celsius intervals must not receive this offset.
export function temperaturePointKelvin(value,scale){
  if(typeof value!=='string'||value.length>1000||!/^(-?)[0-9]+(?:\.[0-9]+)?$/.test(value)||!['kelvin','celsius'].includes(scale))return null;
  const negative=value.startsWith('-');
  const [whole,fraction='']=(negative?value.slice(1):value).split('.');
  const places=Math.max(fraction.length,scale==='celsius'?2:0);
  let integer=BigInt(whole+fraction.padEnd(places,'0'))*(negative?-1n:1n);
  if(scale==='celsius')integer+=27315n*10n**BigInt(places-2);
  const sign=integer<0n?'-':'';
  const digits=(integer<0n?-integer:integer).toString().padStart(places+1,'0');
  const result=places?digits.slice(0,-places)+'.'+digits.slice(-places):digits;
  return sign+(result.includes('.')?result.replace(/0+$/,'').replace(/\.$/,''):result);
}
