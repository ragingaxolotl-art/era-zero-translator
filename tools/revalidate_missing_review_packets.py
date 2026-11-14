#!/usr/bin/env python3
"""Current packet evidence, explicitly not restoration of historical approvals."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
def run(*args):
    return subprocess.run(args, cwd=ROOT, capture_output=True, text=True, check=False)

audit = json.loads((ROOT / 'reports/root_review_provenance_audit.json').read_text())
output = ROOT / 'reports/packet_revalidation_2026_11_04'
output.mkdir(exist_ok=True)
results = []
for source in audit['sources']:
    if source['status'] != 'missing_at_cited_path':
        continue
    path = source['path']
    history = run('git', 'log', '--all', '--format=%H', '-1', '--', path)
    if history.returncode:
        raise RuntimeError(history.stderr)
    entry = {'missing_citation': path, 'historical_commit_found': history.stdout.strip() or None}
    match = re.fullmatch(r'reviews/([A-Z]{3})_(\d{3})_(\d{3})_validation\.md', path)
    if match:
        family, start, end = match.groups()
        stem = f'{family}_{start}_{end}'
        report = output / (stem + '.md')
        command = ['ruby', 'tools/validate_semantic_packet.rb', f'{family}:{start}-{end}', '--mode', 'canonical', '--report', str(report.relative_to(ROOT))]
        result = run(*command)
        entry.update(command=command, exit_code=result.returncode, output=result.stdout + result.stderr,
                     current_report=str(report.relative_to(ROOT)))
        if report.exists():
            text = report.read_text()
            report.write_text('> Fresh revalidation, 2026-11-04. This is not the missing historical report or independent evidence of user approval.\n\n' + text)
            entry['report_sha256'] = hashlib.sha256(report.read_bytes()).hexdigest()
        print(f'{stem}: {"PASS" if result.returncode == 0 else "FAIL"}', flush=True)
    else:
        entry['current_revalidation'] = 'Not run: historical soundness audit requires a separate scope-specific review.'
    results.append(entry)

report = {
    'scope': 'Missing root-review citations in available local Git history, plus fresh reusable packet checks. Not full source reconciliation.',
    'observed_date': '2026-11-04',
    'implementation_revision': run('git', 'rev-parse', 'HEAD').stdout.strip(),
    'shallow_repository': run('git', 'rev-parse', '--is-shallow-repository').stdout.strip(),
    'root_inventory_sha256': hashlib.sha256((ROOT / 'lexicon/atoms.yaml').read_bytes()).hexdigest(),
    'missing_paths': len(results),
    'historical_paths_found': sum(bool(x['historical_commit_found']) for x in results),
    'current_packet_passes': sum(x.get('exit_code') == 0 for x in results),
    'current_packet_failures': sum('exit_code' in x and x['exit_code'] != 0 for x in results),
    'authority_limit': 'Current consistency checks cannot prove historical approval or recover missing evidence. No cited historical path is created or changed.',
    'results': results,
    'completion_proven': False,
}
(ROOT / 'reports/missing_review_revalidation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({k:v for k,v in report.items() if k.endswith(('passes','failures','found','paths'))}))
