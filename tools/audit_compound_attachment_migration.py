#!/usr/bin/env python3
"""Evidence for the no-gap renderer migration, relative to its pinned baseline."""
import json
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[1]
BASE='c5a6f94'
def git(*args):
    return subprocess.check_output(['git',*args],cwd=ROOT,text=True)
def prior(path):
    return json.loads(git('show',f'{BASE}:{path}'))
old=prior('reports/dictionary_musical_identity.json')
new=json.loads((ROOT/'reports/dictionary_musical_identity.json').read_text())
a={r['identity']:r['midi_sha256'] for r in old['records']}
b={r['identity']:r['midi_sha256'] for r in new['records']}
assert a.keys()==b.keys(), 'Lexical inventory changed during timing migration'
changed=[key for key in a if a[key]!=b[key]]
assert all(key.startswith('CMP:') for key in changed), 'An atomic MIDI state changed'
paths=git('diff','--name-only',BASE,'--','pages/data/resolutions').splitlines()
assert all(Path(path).name.startswith('cmp_') for path in paths), 'An atomic hosted artifact changed'
variants=0
for path in paths:
    before=prior(path)['variants']
    after=json.loads((ROOT/path).read_text())['variants']
    assert before.keys()==after.keys()
    for key,previous in before.items():
        current=after[key]
        assert previous['semantic_ir']==current['semantic_ir'],(path,key,'semantic IR')
        left=previous['formal']['performance']['lexical_events']
        right=current['formal']['performance']['lexical_events']
        def without_boundary(events):
            return [{k:v for k,v in event.items() if k!='boundary_after_beats'} for event in events]
        assert without_boundary(left)==without_boundary(right),(path,key,'lexical notes, order or runtime')
        assert any(x.get('boundary_after_beats',.5)!=y.get('boundary_after_beats',.5) for x,y in zip(left,right))
        variants+=1
assert not git('diff','--name-only',BASE,'--','lexicon/atoms.yaml','lexicon/compound_dictionary.yaml').strip()
report={'baseline_commit':BASE,'scope':'Exact migration comparison, not general translator completeness.',
 'unchanged_atomic_midi_states':sum(not key.startswith('CMP:') for key in a),
 'changed_compound_midi_states':len(changed),'changed_hosted_compounds':len(paths),
 'compared_hosted_variants':variants,'all_compared_semantic_ir_unchanged':True,
 'all_compared_lexical_notes_order_and_runtime_unchanged':True,
 'atomic_and_compound_lexicons_unchanged':True,'changed_dictionary_performances':changed,
 'completion_proven':False}
(ROOT/'reports/compound_attachment_migration.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='changed_dictionary_performances'}))
