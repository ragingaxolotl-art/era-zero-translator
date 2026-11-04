#!/usr/bin/env python3
"""Experimental mono PCM transport for existing semantic note streams.
Decoder takes only a WAV file; framing/calibration/checksum are audible tones.
Not a microphone robustness certificate. No text, IR or note sidecar at decode.
"""
import argparse, json, math, struct, wave, zlib
import numpy as np
from scipy.optimize import minimize_scalar

RATE = 22050
UNIT = .125
GAP = .040
PREAMBLE = [(69,2),(69,4),(81,2),(69,4)]

def checksum(notes):
    return zlib.crc32(json.dumps(notes,separators=(',',':')).encode())

def synth(notes, path):
    # Source is ordinary SMF note timing, normalized to a 480-tick beat.
    payload=[]
    last=0
    for n in notes:
        start,end,pitch=n['start_tick'],n['end_tick'],n['midi']
        if not all(isinstance(v,int) for v in [start,end,pitch]) or not 0<=pitch<=127 or end<=start or (not payload and start!=0) or start < last or (end-start)%120 or (start-last)%120:
            raise ValueError('Transport requires monophonic quarter-beat grid')
        payload.append([pitch,(end-start)//120,(start-last)//120])
        last=end
    if not payload: raise ValueError('Empty payload')
    # CRC is a detection code, not semantic authority or correction.
    digits=[int(c,16) for c in f'{checksum(payload):08x}']
    out=[np.zeros(round(.2*RATE))]
    def tone(pitch,units):
        length=round(units*UNIT*RATE)
        t=np.arange(length)/RATE
        env=np.minimum(1,np.minimum(np.arange(length)+1,length-np.arange(length))/(RATE*.004))
        out.append(.4*env*np.sin(2*np.pi*440*2**((pitch-69)/12)*t))
        out.append(np.zeros(round(GAP*RATE)))
    for p,u in PREAMBLE: tone(p,u)
    out.append(np.zeros(round(.5*RATE)))
    for p,d,g in payload:
        if g: out.append(np.zeros(round(g*UNIT*RATE)))
        tone(p,d)
    out.append(np.zeros(round(.5*RATE)))
    for d in digits: tone(72+d,2)
    out.append(np.zeros(round(.2*RATE)))
    samples=np.concatenate(out)
    with wave.open(path,'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE)
        w.writeframes((np.clip(samples,-1,1)*32767).astype('<i2').tobytes())
    return {'profile':'EZACOUSTIC-EXPERIMENT-1','notes':len(payload),'seconds':len(samples)/RATE}

def decode(path):
    with wave.open(path,'rb') as w:
        if w.getsampwidth()!=2 or w.getnchannels()!=1: raise ValueError('Use mono 16-bit PCM WAV')
        rate=w.getframerate(); x=np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').astype(float)/32768
    if rate<8000 or len(x)>rate*600 or not np.isfinite(x).all(): raise ValueError('Invalid audio bounds')
    # Short energy windows retain repeated-pitch boundaries; no expected score.
    block=max(1,round(rate*.002))
    energy=np.sqrt(np.mean(np.pad(x,(0,(-len(x))%block)).reshape(-1,block)**2,axis=1))
    peak=float(energy.max(initial=0))
    if peak<.005: raise ValueError('Silent or too quiet')
    mask=energy>max(.003,peak*.15)
    # Low-frequency zero crossings can dip below the energy threshold for a
    # few milliseconds. Bridge only short internal dips, never the 40 ms
    # intentional articulation gap. No expected notes inform this operation.
    holes=np.diff(np.r_[True,mask,True].astype(int))
    for a,b in zip(np.where(holes==-1)[0],np.where(holes==1)[0]):
        if a>0 and b<len(mask) and (b-a)*block/rate<=.012: mask[a:b]=True
    changes=np.diff(np.r_[False,mask,False].astype(int))
    regions=[(a*block,min(b*block,len(x))) for a,b in zip(np.where(changes==1)[0],np.where(changes==-1)[0]) if (b-a)*block/rate>.055]
    if len(regions)<13: raise ValueError('Incomplete calibration, payload or checksum')
    def pitch(a,b):
        y=x[a:b]; y=y-y.mean();win=np.hanning(len(y));weighted=y*win
        nfft=1<<(len(y)*8-1).bit_length(); spectrum=np.abs(np.fft.rfft(weighted,nfft))
        frequencies=np.fft.rfftfreq(nfft,1/rate)
        lo=np.searchsorted(frequencies,30);hi=np.searchsorted(frequencies,5000)
        k=lo+np.argmax(spectrum[lo:hi]);estimate=frequencies[k]
        t=np.arange(len(y))/rate
        result=minimize_scalar(lambda f:-abs(np.dot(weighted,np.exp(-2j*np.pi*f*t))),bounds=(estimate-rate/nfft,estimate+rate/nfft),method='bounded')
        return 69+12*math.log2(result.x/440)
    pitches=[pitch(a,b) for a,b in regions]
    durations=np.array([(b-a)/rate for a,b in regions])
    tuning=float(np.median([pitches[i]-PREAMBLE[i][0] for i in range(4)]))
    unit=float(np.median([durations[i]/PREAMBLE[i][1] for i in range(4)]))
    gaps=[(regions[i][0]-regions[i-1][1])/rate for i in range(1,len(regions))]
    gap=float(np.median(gaps[:3]))
    if not .07<unit<.25 or not .015<gap<.1: raise ValueError('Invalid audio clock')
    quantized=[]
    for index,(p,d) in enumerate(zip(pitches,durations)):
        q=round(p-tuning);ticks=round(d/unit)
        if abs(p-tuning-q)>.20 or abs(d/unit-ticks)>.18 or ticks<1 or not 0<=q<=127:
            raise ValueError(f'Uncertain pitch or duration at tone {index}: pitch={p-tuning:.3f}, units={d/unit:.3f}; no correction guessed')
        quantized.append((q,ticks))
    if quantized[:4]!=PREAMBLE: raise ValueError('Invalid audible calibration')
    if abs((gaps[3]-gap)/unit-4)>.25: raise ValueError('Invalid payload boundary')
    # Fixed eight-tone checksum trailer, separated audibly by four extra units.
    split=len(regions)-8
    if abs((gaps[split-1]-gap)/unit-4)>.25: raise ValueError('Invalid checksum boundary')
    digits=quantized[split:]
    if any(not 72<=p<=87 or d!=2 for p,d in digits): raise ValueError('Invalid checksum tones')
    if any(abs((g-gap)/unit)>.25 for g in gaps[split:]): raise ValueError('Invalid checksum spacing')
    payload=[]
    for i in range(4,split):
        rest=0 if i==4 else round((gaps[i-1]-gap)/unit)
        if rest<0 or (i>4 and abs((gaps[i-1]-gap)/unit-rest)>.25): raise ValueError('Uncertain note boundary')
        payload.append([*quantized[i],rest])
    expected=int(''.join(format(p-72,'x') for p,d in digits),16)
    if checksum(payload)!=expected: raise ValueError('Audible checksum mismatch; recording rejected')
    notes=[];tick=0
    for p,d,g in payload:
        tick+=g*120;notes.append({'midi':p,'start_tick':tick,'end_tick':tick+d*120});tick+=d*120
    return {'profile':'EZACOUSTIC-EXPERIMENT-1','notes':notes,'calibration':{'tuning_semitones':tuning,'quarter_beat_seconds':unit,'articulation_gap_seconds':gap},'checksum':'verified','limitations':['Experimental monophonic transport; not general instrument transcription.','Checksum detects damage; it does not prove semantic validity or correct errors.','Speaker-to-microphone robustness remains unverified.']}

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('mode',choices=['synth','decode']);parser.add_argument('path');args=parser.parse_args()
    import sys
    try: print(json.dumps(synth(json.load(sys.stdin),args.path) if args.mode=='synth' else decode(args.path)))
    except (ValueError,wave.Error) as e: print(str(e),file=sys.stderr);sys.exit(1)
