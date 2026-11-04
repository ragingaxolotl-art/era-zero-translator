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
end
