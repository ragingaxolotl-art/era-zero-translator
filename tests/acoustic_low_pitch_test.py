"""Regression for zero-crossing holes in short, low grammar-frame notes."""
import importlib.util
from pathlib import Path
import tempfile
spec=importlib.util.spec_from_file_location('transport',Path(__file__).parents[1]/'tools/acoustic_transport.py')
t=importlib.util.module_from_spec(spec);spec.loader.exec_module(t)
notes=[];tick=0
for pitch in range(26,49):
    for duration in (120,240,480,960):
        notes.append({'midi':pitch,'start_tick':tick,'end_tick':tick+duration})
        tick+=duration+240
with tempfile.TemporaryDirectory(prefix='era-low-pitch-') as directory:
    path=str(Path(directory)/'probe.wav');t.synth(notes,path)
    decoded=t.decode(path)
    assert decoded['notes']==notes
print('PASS 92 low-pitch/duration combinations from blind PCM with explicit boundaries.')
