# frozen_string_literal: true

require_relative "test_helper"

class TestEncodingDetector < Minitest::Test
  include LoaderRuby::EncodingDetector

  def test_detect_utf8_bom
    raw = "\xEF\xBB\xBFhello".b
    assert_equal "UTF-8", detect_encoding_from_bom(raw)
  end

  def test_detect_utf16le_bom
    raw = "\xFF\xFEhello".b
    assert_equal "UTF-16LE", detect_encoding_from_bom(raw)
  end

  def test_detect_utf16be_bom
    raw = "\xFE\xFFhello".b
    assert_equal "UTF-16BE", detect_encoding_from_bom(raw)
  end

  def test_no_bom_returns_nil
    raw = "hello world".b
    assert_nil detect_encoding_from_bom(raw)
  end

  def test_detect_encoding_from_content_type
    assert_equal "ISO-8859-1", detect_encoding_from_content_type("text/html; charset=ISO-8859-1")
    assert_equal "utf-8", detect_encoding_from_content_type("text/html; charset=utf-8")
    assert_nil detect_encoding_from_content_type("text/html")
    assert_nil detect_encoding_from_content_type(nil)
  end

  def test_transcode_to_utf8_from_latin1
    latin1 = "Caf\xe9".b
    result = transcode_to_utf8(latin1, "ISO-8859-1")
    assert_equal Encoding::UTF_8, result.encoding
    assert_includes result, "Caf"
  end

  def test_transcode_with_invalid_bytes_replaces
    bad = "Hello \xFF\xFE World".b
    result = transcode_to_utf8(bad, "UTF-8")
    assert_equal Encoding::UTF_8, result.encoding
    assert_includes result, "Hello"
    assert_includes result, "World"
  end
end
