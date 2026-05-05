# frozen_string_literal: true

require "test_helper"

class VisionMacTest < Test::Unit::TestCase
  FIXTURE = File.expand_path("../fixtures/sample_jp.png", __dir__)

  test "recognize_text returns non-empty OCR text from a sample image" do
    text = VisionMac.recognize_text(FIXTURE)
    assert_kind_of(String, text)
    assert_false(text.strip.empty?, "Expected non-empty OCR output, got: #{text.inspect}")
    assert(text.include?("rb-vision-mac"), "Expected 'rb-vision-mac' in OCR output, got: #{text.inspect}")
  end

  test "recognize_text raises Errno::ENOENT for nonexistent path" do
    assert_raise(Errno::ENOENT) do
      VisionMac.recognize_text("/nonexistent/path/missing.png")
    end
  end

  test "detect_faces returns a String for a face-less image" do
    output = VisionMac.detect_faces(FIXTURE)
    assert_kind_of(String, output)
  end

  test "detect_faces output lines contain four tab-separated normalized values when faces exist" do
    output = VisionMac.detect_faces(FIXTURE)
    return if output.empty?

    output.split("\n").each do |line|
      parts = line.split("\t")
      assert_equal(4, parts.length, "Expected 4 tab-separated values per face, got: #{line.inspect}")
      parts.each do |p|
        f = Float(p)
        assert(f >= 0.0 && f <= 1.0, "Expected normalized 0..1 value, got: #{p.inspect}")
      end
    end
  end

  test "detect_faces raises Errno::ENOENT for nonexistent path" do
    assert_raise(Errno::ENOENT) do
      VisionMac.detect_faces("/nonexistent/path/missing.png")
    end
  end
end
