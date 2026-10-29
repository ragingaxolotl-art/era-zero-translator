#!/usr/bin/env python3
"""Run implementation regressions; a pass is not a full-translator certificate."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--node', default=shutil.which('node'))
args = parser.parse_args()
if not args.node:
    parser.error('Node is required; supply --node /path/to/node')

commands = [['ruby', path] for path in [
    'tests/min_cross_reference_migration_test.rb', 'tests/mov_process_example_migration_test.rb', 'tests/compound_dependencies_test.rb', 'tests/compound_expansion_test.rb', 'tests/compound_convention_test.rb',
    'tests/dictionary_musical_identity_test.rb', 'tools/audit_dictionary_musical_identity.rb', 'tools/audit_role_musical_contrasts.rb',
    'tests/semantic_reference_validation_test.rb', 'tests/quantity_validation_test.rb', 'tools/validate_semantic_ir_and_grammar.rb',
    'tests/foundation_process_test.rb', 'tests/repetition_performance_test.rb', 'tests/controlled_role_reference_test.rb',
    'tools/validate_gate4b_compound_dictionary.rb', 'tools/validate_gate4c_english_sense_index.rb',
    'tools/validate_renderer_decoder.rb', 'tools/validate_glyph_audio.rb',
]] + [[args.node, path] for path in [
    'tests/repetition_browser_test.mjs', 'tests/name_participants_test.mjs', 'tests/nominal_reference_test.mjs', 'tests/capability_sentence_test.mjs', 'tests/speech_act_runtime_test.mjs', 'tests/discourse_reference_test.mjs',
    'tests/named_sentence_test.mjs', 'tests/dictionary_fidelity_test.mjs', 'tests/long_performance_verification_test.mjs',
    'tools/validate_recognition_audio.mjs', 'tools/validate_performance_audio.mjs', 'tests/sentence_sequence_test.mjs', 'tests/sentence_conjunction_test.mjs', 'tools/audit_ordinary_phrase_coverage.mjs',
    'tests/negation_performance_test.mjs', 'tests/modality_performance_test.mjs', 'tests/confidence_performance_test.mjs', 'tests/coordination_performance_test.mjs', 'tests/temporal_performance_test.mjs', 'tests/future_interpretation_test.mjs', 'tests/measurement_performance_test.mjs', 'tests/mass_sentence_test.mjs', 'tests/temperature_sentence_test.mjs', 'tests/thermal_standard_test.mjs', 'tests/mass_standard_test.mjs', 'tests/nominal_mass_property_test.mjs', 'tests/aspect_carrying_test.mjs', 'tests/measurement_comparison_test.mjs', 'tests/property_comparison_test.mjs', 'tests/temperature_comparison_test.mjs', 'tests/mass_comparison_inverse_test.mjs', 'tests/strict_music_decoder_test.mjs', 'tests/quantifier_performance_test.mjs', 'tests/quantified_role_test.mjs', 'tests/conditional_performance_test.mjs', 'tests/conditional_sentence_test.mjs', 'tests/conditional_command_test.mjs', 'tests/condition_adjective_test.mjs', 'tests/compound_binding_music_test.mjs', 'tests/compound_binding_constraints_test.mjs', 'tests/role_reference_music_test.mjs', 'tests/qualified_slot_music_test.mjs', 'tests/browser_compound_plans_test.mjs', 'tests/bound_sentence_test.mjs', 'tests/compound_convention_music_test.mjs', 'tests/sensory_registration_test.mjs', 'tests/registration_channels_test.mjs', 'tests/physical_support_test.mjs', 'tests/physical_carrying_test.mjs', 'tests/carrying_goal_test.mjs', 'tests/carrying_command_test.mjs', 'tests/counted_nominal_test.mjs', 'tests/path_sentence_test.mjs', 'tests/unsupported_musical_scope_test.mjs',
    'tools/validate_pages_release.mjs',
    'tools/validate_viseme_performance.mjs',
]]
results = []
for command in commands:
    try:
        run = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, timeout=120)
        result = {'test': command[1], 'passed': run.returncode == 0,
                  'exit_code': run.returncode, 'output': run.stdout + run.stderr}
    except subprocess.TimeoutExpired:
        result = {'test': command[1], 'passed': False, 'output': 'Timed out after 120 seconds'}
    results.append(result)
    print(('PASS ' if result['passed'] else 'FAIL ') + result['test'], flush=True)

report = {
    'scope': 'Implementation regression only. Full ordinary-English coverage and musical semantic completeness are not established.',
    'passed': all(result['passed'] for result in results),
    'results': results,
    'remaining_requirements': [
        'Broad ordinary sentence parsing and unquoted noun phrases',
        'Pronouns, discourse reference and ambiguity handling',
        'Adjectives, quantities and sensory/affective foundations',
        'Tense, modality, quantifier and parallel-scope sound conventions',
        'General semantic validation of new occurrence bindings and phonemic references',
        'Recursive compound generation and complete scoped timing in the browser',
        'Independent held-out meaning and sound decoding',
        'Source reconciliation, release migration and publication validation',
    ],
}
(ROOT / 'reports/translator_completion_regression.json').write_text(json.dumps(report, indent=2) + '\n')
sys.exit(0 if report['passed'] else 1)
