#!/usr/bin/env python3
"""Run implementation regressions; a pass is not a full-translator certificate."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--node', default=shutil.which('node'))
parser.add_argument('--include-acoustic', action='store_true', help='Include synthetic WAV-only tests; requires NumPy and SciPy')
args = parser.parse_args()
if not args.node:
    parser.error('Node is required; supply --node /path/to/node')

commands = [['ruby', path] for path in [
    'tests/additive_vocabulary_pins_test.rb', 'tests/packet_evidence_test.rb', 'tests/min_cross_reference_migration_test.rb', 'tests/mov_process_example_migration_test.rb', 'tests/mat_capacity_example_migration_test.rb', 'tests/compound_dependencies_test.rb', 'tests/compound_expansion_test.rb', 'tests/compound_convention_test.rb',
    'tests/dictionary_musical_identity_test.rb', 'tools/audit_dictionary_musical_identity.rb', 'tools/audit_role_musical_contrasts.rb',
    'tests/semantic_reference_validation_test.rb', 'tests/quantity_validation_test.rb', 'tools/validate_semantic_ir_and_grammar.rb',
    'tests/foundation_process_test.rb', 'tests/repetition_performance_test.rb', 'tests/controlled_role_reference_test.rb',
    'tools/validate_gate4b_compound_dictionary.rb', 'tools/validate_gate4c_english_sense_index.rb', 'tools/validate_controlled_english.rb',
    'tools/validate_renderer_decoder.rb', 'tools/validate_glyph_audio.rb',
]] + [[args.node, path] for path in [
    'tests/cognitive_demonstratives_test.mjs', 'tests/learning_pronouns_test.mjs', 'tests/acquisition_preview_ui_test.mjs', 'tests/acquisition_bundle_test.mjs', 'tests/learned_whether_test.mjs', 'tests/knowledge_acquisition_music_test.mjs', 'tests/knowledge_acquisition_test.mjs', 'tests/knowledge_time_test.mjs', 'tests/desired_knowledge_test.mjs', 'tests/knowledge_preview_ui_test.mjs', 'tests/knowledge_sentence_test.mjs', 'tests/cognitive_question_binding_test.mjs', 'tests/neutral_pronoun_contractions_test.mjs', 'tests/neutral_pronoun_sentences_test.mjs', 'tests/cognitive_neutral_pronouns_test.mjs', 'tests/route_learning_preview_ui_test.mjs', 'tests/route_learning_test.mjs', 'tests/route_learning_music_test.mjs', 'tests/understanding_acquisition_test.mjs', 'tests/understanding_pronouns_test.mjs', 'tests/understanding_preview_ui_test.mjs', 'tests/understanding_music_test.mjs', 'tests/understanding_content_test.mjs', 'tests/curiosity_preview_ui_test.mjs', 'tests/cognitive_conjunction_preview_ui_test.mjs', 'tests/cognitive_conjunction_question_test.mjs', 'tests/cognitive_conjunction_possibility_test.mjs', 'tests/cognitive_conjunction_scope_test.mjs', 'tests/cognitive_conjunction_test.mjs', 'tests/curiosity_test.mjs', 'tests/contextual_inquiry_test.mjs', 'tests/contextual_content_test.mjs', 'tests/contextual_content_music_test.mjs', 'tests/question_content_music_test.mjs', 'tests/question_content_test.mjs', 'tests/counted_wording_test.mjs', 'tests/quantified_preview_ui_test.mjs', 'tests/quantified_sentence_test.mjs', 'tests/quantified_property_music_test.mjs', 'tests/quantified_music_test.mjs', 'tests/quantified_binding_test.mjs', 'tests/quantified_predication_model_test.mjs', 'tests/desired_swimming_test.mjs', 'tests/foundation_contractions_test.mjs', 'tests/foundation_pronoun_binding_test.mjs', 'tests/foundation_pronoun_identity_test.mjs', 'tests/foundation_question_runtime_test.mjs', 'tests/contracted_conditional_reference_test.mjs', 'tests/negative_contractions_test.mjs', 'tests/proposition_negation_test.mjs', 'tests/energized_bearer_test.mjs', 'tests/swimming_combinations_test.mjs', 'tests/swimming_viewpoint_test.mjs', 'tests/swimming_across_test.mjs', 'tests/swimming_test.mjs', 'tests/running_test.mjs', 'tests/destination_running_test.mjs', 'tests/completed_running_test.mjs', 'tests/running_viewpoint_test.mjs', 'tests/running_combinations_test.mjs', 'tests/running_command_test.mjs', 'tests/demonstrative_reference_test.mjs', 'tests/brightness_comparison_test.mjs', 'tests/spatial_relations_test.mjs', 'tests/physical_entry_test.mjs', 'tests/entry_modality_test.mjs', 'tests/ongoing_entry_test.mjs', 'tests/entry_viewpoint_test.mjs', 'tests/pronoun_interpretation_choices_test.mjs', 'tests/temporal_proposition_scope_test.mjs', 'tests/texture_sentence_test.mjs', 'tests/surface_texture_profile_test.mjs', 'tests/preference_propositions_test.mjs', 'tests/desired_consciousness_test.mjs', 'tests/desired_atomic_conditions_test.mjs', 'tests/desired_felt_conditions_test.mjs', 'tests/nested_foundation_sentence_test.mjs', 'tests/desire_time_test.mjs', 'tests/desire_negation_scope_test.mjs', 'tests/contextual_standard_test.mjs', 'tests/luminance_foundation_test.mjs', 'tests/luminance_standard_test.mjs', 'tests/desire_subject_control_test.mjs', 'tests/preference_time_test.mjs', 'tests/foundation_preview_ui_test.mjs', 'tests/foundation_english_test.mjs', 'tests/foundation_codec_test.mjs', 'tests/foundation_ir_test.mjs', 'tests/foundation_sentence_music_test.mjs', 'tests/foundation_semantic_inverse_test.mjs',
    'tests/repetition_browser_test.mjs', 'tests/name_participants_test.mjs', 'tests/nominal_reference_test.mjs', 'tests/capability_sentence_test.mjs', 'tests/speech_act_runtime_test.mjs', 'tests/discourse_reference_test.mjs', 'tests/pronoun_resolution_test.mjs',
    'tests/named_sentence_test.mjs', 'tests/dictionary_fidelity_test.mjs', 'tests/long_performance_verification_test.mjs',
    'tools/validate_recognition_audio.mjs', 'tools/validate_performance_audio.mjs', 'tests/sentence_sequence_test.mjs', 'tests/sentence_conjunction_test.mjs', 'tests/sentence_disjunction_test.mjs', 'tools/audit_ordinary_phrase_coverage.mjs',
    'tests/negation_performance_test.mjs', 'tests/modality_performance_test.mjs', 'tests/confidence_performance_test.mjs', 'tests/coordination_performance_test.mjs', 'tests/temporal_performance_test.mjs', 'tests/future_interpretation_test.mjs', 'tests/measurement_performance_test.mjs', 'tests/mass_sentence_test.mjs', 'tests/temperature_sentence_test.mjs', 'tests/thermal_standard_test.mjs', 'tests/mass_standard_test.mjs', 'tests/nominal_mass_property_test.mjs', 'tests/contextual_nominal_mass_test.mjs', 'tests/preference_nominal_mass_test.mjs', 'tests/pain_meaning_test.mjs', 'tests/pain_stimulus_test.mjs', 'tests/pain_comparison_test.mjs', 'tests/pain_preference_test.mjs', 'tests/ownership_preview_ui_test.mjs', 'tests/object_desired_ownership_test.mjs', 'tests/desired_ownership_test.mjs', 'tests/desired_ownership_music_test.mjs', 'tests/ownership_sentences_test.mjs', 'tests/ownership_music_test.mjs', 'tests/ownership_meaning_test.mjs', 'tests/delivery_questions_test.mjs', 'tests/desired_delivery_test.mjs', 'tests/object_desire_test.mjs', 'tests/object_desired_drinking_test.mjs', 'tests/material_reference_test.mjs', 'tests/drinking_meaning_test.mjs', 'tests/desired_drinking_test.mjs', 'tests/desired_drinking_pronouns_test.mjs', 'tests/desired_drinking_music_test.mjs', 'tests/drinking_sentences_test.mjs', 'tests/drinking_pronouns_test.mjs', 'tests/drinking_music_test.mjs', 'tests/drinking_preview_ui_test.mjs', 'tests/pain_preference_music_test.mjs', 'tests/pain_comparison_sentences_test.mjs', 'tests/pain_comparison_music_test.mjs', 'tests/pain_stimulus_sentences_test.mjs', 'tests/pain_stimulus_music_test.mjs', 'tests/pain_music_test.mjs', 'tests/pain_preview_ui_test.mjs', 'tests/pain_stimulus_preview_ui_test.mjs', 'tests/pain_comparison_preview_ui_test.mjs', 'tests/pain_preference_preview_ui_test.mjs', 'tests/aspect_carrying_test.mjs', 'tests/carrying_viewpoint_choice_test.mjs', 'tests/measurement_comparison_test.mjs', 'tests/property_comparison_test.mjs', 'tests/temperature_comparison_test.mjs', 'tests/mass_comparison_inverse_test.mjs', 'tests/strict_music_decoder_test.mjs', 'tests/quantifier_performance_test.mjs', 'tests/quantified_role_test.mjs', 'tests/conditional_performance_test.mjs', 'tests/conditional_sentence_test.mjs', 'tests/conditional_command_test.mjs', 'tests/condition_adjective_test.mjs', 'tests/compound_binding_music_test.mjs', 'tests/compound_binding_constraints_test.mjs', 'tests/role_reference_music_test.mjs', 'tests/qualified_slot_music_test.mjs', 'tests/browser_compound_plans_test.mjs', 'tests/bound_sentence_test.mjs', 'tests/compound_convention_music_test.mjs', 'tests/sensory_registration_test.mjs', 'tests/registration_channels_test.mjs', 'tests/physical_support_test.mjs', 'tests/physical_custody_test.mjs', 'tests/physical_carrying_test.mjs', 'tests/carrying_goal_test.mjs', 'tests/arrival_sentence_test.mjs', 'tests/destination_carrying_test.mjs', 'tests/carrying_inverse_test.mjs', 'tests/custody_inverse_test.mjs', 'tests/availability_sentences_test.mjs', 'tests/custody_opportunity_test.mjs', 'tests/acquisition_viewpoint_test.mjs', 'tests/custody_acquisition_test.mjs', 'tests/custody_transfer_test.mjs', 'tests/custody_delivery_test.mjs', 'tests/controlled_scoped_slot_test.mjs', 'tests/ordinary_reference_expansion_test.mjs', 'tests/felt_conditions_test.mjs', 'tests/carrying_command_test.mjs', 'tests/destination_command_test.mjs', 'tests/clause_interpretation_test.mjs', 'tests/counted_nominal_test.mjs', 'tests/path_sentence_test.mjs', 'tests/unsupported_musical_scope_test.mjs',
    'tools/validate_pages_release.mjs',
    'tools/validate_viseme_performance.mjs',
]]
if args.include_acoustic:
    commands += [[sys.executable, 'tests/acoustic_low_pitch_test.py']]
    commands += [[args.node, path] for path in ['tests/acquisition_viewpoint_acoustic_test.mjs', 'tests/acoustic_transport_test.mjs', 'tests/cognitive_acoustic_test.mjs', 'tests/understanding_acoustic_test.mjs', 'tests/understanding_spoken_content_test.mjs', 'tests/understanding_acquisition_acoustic_test.mjs', 'tests/route_learning_acoustic_test.mjs', 'tests/curiosity_acoustic_test.mjs', 'tests/contextual_nominal_mass_acoustic_test.mjs', 'tests/preference_nominal_mass_acoustic_test.mjs', 'tests/pain_acoustic_test.mjs', 'tests/pain_stimulus_acoustic_test.mjs', 'tests/pain_comparison_acoustic_test.mjs', 'tests/pain_preference_acoustic_test.mjs', 'tests/desired_ownership_acoustic_test.mjs', 'tests/ownership_acoustic_test.mjs', 'tests/delivery_question_acoustic_test.mjs', 'tests/object_desire_acoustic_test.mjs', 'tests/drinking_acoustic_test.mjs', 'tests/desired_drinking_acoustic_test.mjs', 'tests/cognitive_conjunction_acoustic_test.mjs', 'tests/cognitive_conjunction_scope_acoustic_test.mjs', 'tests/cognitive_conjunction_possibility_acoustic_test.mjs', 'tests/cognitive_conjunction_question_acoustic_test.mjs']]
started_at = datetime.now(timezone.utc).isoformat()
tested_revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
initial_worktree_status = subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True).strip()
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
    'tested_revision': tested_revision,
    'run_context': {'started_at': started_at, 'completed_at': datetime.now(timezone.utc).isoformat(), 'initial_worktree_status': initial_worktree_status, 'include_acoustic': args.include_acoustic, 'physical_recordings_tested': 0},
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
