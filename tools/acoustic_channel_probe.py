#!/usr/bin/env python3
"""Synthetic channel probes; none is a physical speaker/microphone recording."""
import json, sys, wave, subprocess
from pathlib import Path
import numpy as np
from scipy.signal import resample_poly
source=Path(sys.argv[1])
with wave.open(str(source),'rb') as w:
    rate=w.getframerate();x=np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').astype(float)/32768
rng=np.random.default_rng(12034)
echo=np.zeros_like(x);delay=round(.015*rate);echo[delay:]=x[:-delay]
variants={'gain_and_noise':.35*x+rng.normal(0,.001,len(x)), 'speed_plus_two_percent':resample_poly(x,100,102), 'short_weak_echo':x+.08*echo, 'dropout':x.copy()}
# Remove a portion of payload, after audible calibration (about 2.36 s).
variants['dropout'][round(2.5*rate):round(5.5*rate)]=0
results=[]
for name,y in variants.items():
    path=source.with_name(source.stem+'-'+name+'.wav')
    with wave.open(str(path),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes((np.clip(y,-1,1)*32767).astype('<i2').tobytes())
    p=subprocess.run([sys.executable,str(Path(__file__).with_name('acoustic_transport.py')),'decode',str(path)],capture_output=True,text=True)
    results.append({'channel':name,'accepted':p.returncode==0,'result':json.loads(p.stdout) if p.returncode==0 else p.stderr.strip()})
print(json.dumps(results))
