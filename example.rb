#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/vision_mac"

path = ARGV.first || File.expand_path("test/fixtures/sample_jp.png", __dir__)

puts "image: #{path}"
puts
puts "text:"
puts VisionMac.recognize_text(path)
puts
puts "faces:"
faces = VisionMac.detect_faces(path)
puts faces.empty? ? "(none)" : faces
