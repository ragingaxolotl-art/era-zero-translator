#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"
require_relative "lib/era_zero_presentation"

formal_path = ARGV[0] or abort "usage: generate_presentation.rb FORMAL.json OUTPUT_PREFIX"
prefix = ARGV[1] or abort "usage: generate_presentation.rb FORMAL.json OUTPUT_PREFIX"
formal = JSON.parse(File.read(formal_path, encoding: "UTF-8"))
FileUtils.mkdir_p(File.dirname(File.expand_path(prefix)))
File.write("#{prefix}.svg", EraZeroPresentation.svg(formal))
File.binwrite("#{prefix}.mid", EraZeroPresentation.midi(formal))
puts JSON.pretty_generate(EraZeroPresentation.manifest(formal))
