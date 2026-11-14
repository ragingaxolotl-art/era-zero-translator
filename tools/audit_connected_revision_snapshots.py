"""Audit locally captured Drive revision text; never fetch or infer missing text.

Usage: python3 tools/audit_connected_revision_snapshots.py /path/to/captures
Captures require manifest-current.json and its revision-N.txt files. The connector
manifest records raw UTF-16 lengths; local text is CRLF-normalized with a final LF.
"""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
from datetime import datetime, timezone

root = Path(__file__).resolve().parents[1]
capture = Path(sys.argv[1])
manifest = json.loads((capture / 'manifest-current.json').read_text())
normalize = lambda s: re.sub(r'\s+', ' ', s).strip()
typography = lambda s: normalize(s.replace('’', "'"))
snapshots = []
texts = {}
for entry in manifest:
    if not entry['fetched']:
        raise ValueError('Manifest contains an unread revision')
    raw = (capture / entry['local_file']).read_bytes()
    text = raw.decode('utf-8')
    texts[entry['id']] = text
    snapshots.append({**entry, 'normalized_utf8_sha256': hashlib.sha256(raw).hexdigest(),
                      'normalized_utf8_bytes': len(raw), 'line_count': len(text.splitlines())})
latest = texts['68']
atoms = json.loads((root / 'pages/data/index.json').read_text())['atoms']
packet = json.loads(subprocess.check_output(['ruby', '-ryaml', '-rjson', '-e',
    'puts JSON.generate(YAML.load_file(ARGV[0]))', str(root / 'reviews/MOV_200_222_recommended_spec.yaml')]))
migration = json.loads(subprocess.check_output(['ruby', '-ryaml', '-rjson', '-e',
    'puts JSON.generate(YAML.load_file(ARGV[0]))', str(root / 'migrations/2026-07-29_pending_review_packets_approval.yaml')]))
recommendations = {r['fixed_generated_fields']['canonical_id']: r['invariant_definition'] for r in packet['roots']}
promoted = {r['canonical_id']: r['invariant_definition'] for r in migration['promoted_roots']}
matches = {'whitespace_normalized_in_document': [], 'apostrophe_normalized_in_document': [],
           'approved_by_reference_with_exact_repository_definition': [], 'unresolved': []}
approval_phrase = 'MOV:200–222, MAT:000–022, and MAT:100–122 became canonical.'
for atom in atoms:
    identifier, definition = atom['canonical_id'], atom['core_definition']
    if normalize(definition) in normalize(latest):
        category = 'whitespace_normalized_in_document'
    elif typography(definition) in typography(latest):
        category = 'apostrophe_normalized_in_document'
    elif (approval_phrase in latest and identifier.startswith('MOV:2')
          and recommendations.get(identifier) == definition == promoted.get(identifier)
          and migration['metadata']['status'] == 'applied'):
        category = 'approved_by_reference_with_exact_repository_definition'
    else:
        category = 'unresolved'
    matches[category].append(identifier)
markers = ['USER AUTHORITY CORRECTION — GATE 3 WITHDRAWAL',
           'USER APPROVAL — MOV:100–122 SEMANTIC CANONIZATION',
           'SEMANTIC AUTHORITY UPDATE — 81 CANONICAL ROOTS',
           'CRE:200–222 DETAILED REVIEW AND DELEGATED APPROVAL',
           'GATE 4A TYPED COMPOUND ARCHITECTURE',
           'Translator Browser Release 1.4 and Source Completeness Audit']
first_observed = []
for marker in markers:
    for entry in manifest:
        lines = texts[entry['id']].splitlines()
        hits = [i + 1 for i, line in enumerate(lines) if marker in line]
        if hits:
            first_observed.append({'marker': marker, 'first_visible_revision': entry['id'],
                                   'line': hits[0], 'modified_time': entry['modified_time']})
            break
report = {
    'scope': 'All 21 connector-visible revisions of one Google document; not all Drive files or ChatGPT conversations.',
    'observed_at': datetime.now(timezone.utc).isoformat(),
    'repository_revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip(),
    'document_url': 'https://docs.google.com/document/d/1btnSrT37YJt1aD4gXGtJBO8e3ZRG6COYmFLaRkykHA8/edit',
    'visible_revisions_fetched': len(snapshots), 'snapshots': snapshots,
    'first_observed_markers': first_observed,
    'root_definition_correspondence': {k: {'count': len(v), 'ids': v} for k, v in matches.items()},
    'repository_reference_sources': ['reviews/MOV_200_222_recommended_spec.yaml',
                                     'migrations/2026-07-29_pending_review_packets_approval.yaml'],
    'limitations': [
        'Text occurrence establishes wording correspondence, not by itself approval of every occurrence in a historical document.',
        'Nine MOV definitions are verified through a repository packet/migration plus a Google approval-by-reference statement; not verbatim definitions recovered from Google.',
        'First visible revision containing a statement is not proof of its original creation time or direct user authorship.',
        'Compiled documents repeat the 313-node/129-turn claim and historical hash; the original turn ledger and its hash remain independently unverified.',
        'Normalized snapshot hashes are not the historical raw conversation hash.',
        'Snapshots remain local capture artifacts, not new canonical authority or a publication of full source documents.'
    ]}
(root / 'reports/connected_revision_inventory.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'revisions': len(snapshots), 'definition_correspondence': {k: len(v) for k, v in matches.items()},
                  'first_observed_markers': first_observed}, indent=2))
if matches['unresolved']:
    sys.exit(1)
