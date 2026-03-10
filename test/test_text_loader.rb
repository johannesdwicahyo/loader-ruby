# frozen_string_literal: true

require_relative "test_helper"

class TestTextLoader < Minitest::Test
  def setup
    LoaderRuby.reset_configuration!
    @tmpdir = Dir.mktmpdir("loader_test")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_load_text_file
    path = File.join(@tmpdir, "test.txt")
    File.write(path, "Hello, World!")

    doc = LoaderRuby.load(path)

    assert_instance_of LoaderRuby::Document, doc
    assert_equal "Hello, World!", doc.content
    assert_equal :text, doc.format
    assert_equal path, doc.source
  end

  def test_load_markdown_file
    path = File.join(@tmpdir, "test.md")
    File.write(path, "# Title\n\nSome content")

    doc = LoaderRuby.load(path)
    assert_equal "# Title\n\nSome content", doc.content
    assert_equal :text, doc.format
  end

  def test_file_not_found
    assert_raises(LoaderRuby::FileNotFoundError) do
      LoaderRuby.load("/nonexistent/file.txt")
    end
  end

  def test_unsupported_format
    path = File.join(@tmpdir, "test.xyz")
    File.write(path, "data")

    assert_raises(LoaderRuby::UnsupportedFormatError) do
      LoaderRuby.load(path)
    end
  end

  def test_document_to_h
    path = File.join(@tmpdir, "test.txt")
    File.write(path, "Content")

    doc = LoaderRuby.load(path)
    hash = doc.to_h
    assert_equal "Content", hash[:content]
    assert hash[:metadata].key?(:source)
  end

  def test_document_empty
    path = File.join(@tmpdir, "empty.txt")
    File.write(path, "")

    doc = LoaderRuby.load(path)
    assert doc.empty?
  end

  def test_document_size
    path = File.join(@tmpdir, "test.txt")
    File.write(path, "Hello")

    doc = LoaderRuby.load(path)
    assert_equal 5, doc.size
  end

  def test_file_too_large
    LoaderRuby.configure { |c| c.max_file_size = 10 }

    path = File.join(@tmpdir, "big.txt")
    File.write(path, "x" * 100)

    assert_raises(LoaderRuby::FileTooLargeError) do
      LoaderRuby.load(path)
    end
  end

  def test_nil_path_raises_argument_error
    assert_raises(ArgumentError) do
      LoaderRuby.load(nil)
    end
  end

  def test_empty_path_raises_argument_error
    assert_raises(ArgumentError) do
      LoaderRuby.load("")
    end
  end

  def test_blank_path_raises_argument_error
    assert_raises(ArgumentError) do
      LoaderRuby.load("   ")
    end
  end

  def test_encoding_detection_utf8_bom
    path = File.join(@tmpdir, "bom.txt")
    # Write UTF-8 BOM + content
    File.binwrite(path, "\xEF\xBB\xBFHello BOM")

    doc = LoaderRuby.load(path)
    assert_includes doc.content, "Hello BOM"
    assert_equal Encoding::UTF_8, doc.content.encoding
  end

  def test_encoding_detection_utf16le_bom
    path = File.join(@tmpdir, "utf16le.txt")
    # Write UTF-16LE BOM + content
    bom = "\xFF\xFE".b
    content_bytes = "Hi".encode("UTF-16LE").b
    File.binwrite(path, bom + content_bytes)

    doc = LoaderRuby.load(path)
    assert_includes doc.content, "Hi"
    assert_equal Encoding::UTF_8, doc.content.encoding
  end

  def test_encoding_graceful_replacement
    path = File.join(@tmpdir, "bad.txt")
    # Write content with invalid UTF-8 bytes
    File.binwrite(path, "Hello \xFF\xFE World".b)

    doc = LoaderRuby.load(path)
    # Should not raise, should replace invalid bytes
    assert_includes doc.content, "Hello"
    assert_includes doc.content, "World"
  end
end
