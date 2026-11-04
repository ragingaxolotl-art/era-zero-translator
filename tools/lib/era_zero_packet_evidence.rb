# frozen_string_literal: true

# Read explicitly named evidence fields across historical packet schemas.
# Missing, blank, or contradictory aliases are not evidence.
module EraZeroPacketEvidence
  module_function
  def field(record, keys)
    values = keys.select { |key| record.key?(key) }.map { |key| record[key] }.uniq
    return nil unless values.length == 1
    value = values.first
    value.is_a?(String) && !value.strip.empty? ? value : nil
  end

  def fixed_fields?(record, required, optional)
    return false unless record.is_a?(Hash)
    allowed = required.merge(optional)
    (record.keys - allowed.keys).empty? &&
      required.all? { |key, value| record.key?(key) && record[key] == value } &&
      record.all? { |key, value| allowed[key] == value }
  end
end
