# frozen_string_literal: true

require "test_helper"

class VisionMacTest < Test::Unit::TestCase
  FIXTURE = File.expand_path("../fixtures/sample_jp.png", __dir__)
  FACE_FIXTURE = ENV["VISION_MAC_TEST_FACE"]

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

  test "detect_faces returns an empty string for a face-less image" do
    assert_equal("", VisionMac.detect_faces(FIXTURE))
  end

  test "detect_faces returns one line of four normalized values for a single face" do
    omit("set VISION_MAC_TEST_FACE to a local image holding exactly one face") unless FACE_FIXTURE

    lines = VisionMac.detect_faces(FACE_FIXTURE).split("\n")
    assert_equal(1, lines.length)

    parts = lines.first.split("\t")
    assert_equal(4, parts.length, "Expected 4 tab-separated values, got: #{lines.first.inspect}")
    parts.each do |p|
      f = Float(p)
      assert(f >= 0.0 && f <= 1.0, "Expected normalized 0..1 value, got: #{p.inspect}")
    end
  end

  test "detect_faces raises Errno::ENOENT for nonexistent path" do
    assert_raise(Errno::ENOENT) do
      VisionMac.detect_faces("/nonexistent/path/missing.png")
    end
  end
end
