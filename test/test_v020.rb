# frozen_string_literal: true

require_relative "test_helper"
require "tmpdir"
require "fileutils"
require "json"

class TestJsonLoader < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("loader_test")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_load_json_object
    path = File.join(@tmpdir, "data.json")
    File.write(path, JSON.generate({ name: "test", value: 42 }))

    doc = LoaderRuby.load(path)
    assert_equal :json, doc.format
    assert doc.content.include?("test")
  end

  def test_load_json_array
    path = File.join(@tmpdir, "items.json")
    File.write(path, JSON.generate([{ text: "hello" }, { text: "world" }]))

    doc = LoaderRuby.load(path)
    assert_equal :json, doc.format
    assert doc.content.include?("hello")
  end

  def test_load_json_with_text_key
    path = File.join(@tmpdir, "docs.json")
    File.write(path, JSON.generate([{ text: "hello" }, { text: "world" }]))

    doc = LoaderRuby::Loaders::Json.new.load(path, text_key: "text")
    assert_equal "hello\nworld", doc.content
  end

  def test_json_not_found
    assert_raises(LoaderRuby::FileNotFoundError) do
      LoaderRuby.load("/nonexistent/file.json")
    end
  end
end

class TestRtfLoader < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("loader_test")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_load_rtf
    path = File.join(@tmpdir, "doc.rtf")
    File.write(path, '{\\rtf1\\ansi Hello World}')

    doc = LoaderRuby.load(path)
    assert_equal :rtf, doc.format
    assert doc.content.include?("Hello World")
  end
end

class TestEmailLoader < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("loader_test")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_load_eml
    path = File.join(@tmpdir, "message.eml")
    File.write(path, "From: sender@example.com\nTo: recipient@example.com\nSubject: Test\n\nHello, this is the body.")

    doc = LoaderRuby.load(path)
    assert_equal :email, doc.format
    assert_equal "Hello, this is the body.", doc.content
    assert_equal "Test", doc.metadata[:subject]
    assert_equal "sender@example.com", doc.metadata[:from]
  end

  def test_load_eml_html_body
    path = File.join(@tmpdir, "html.eml")
    File.write(path, "Subject: HTML\n\n<html><body><p>Hello</p></body></html>")

    doc = LoaderRuby.load(path)
    assert doc.content.include?("Hello")
    refute doc.content.include?("<p>")
  end
end

class TestFormatDetector < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("loader_test")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_detect_json
    path = File.join(@tmpdir, "data")
    File.write(path, '{"key": "value"}')
    assert_equal :json, LoaderRuby::FormatDetector.detect(path)
  end

  def test_detect_xml
    path = File.join(@tmpdir, "data")
    File.write(path, '<?xml version="1.0"?><root/>')
    assert_equal :xml, LoaderRuby::FormatDetector.detect(path)
  end

  def test_detect_email
    path = File.join(@tmpdir, "data")
    File.write(path, "From: test@example.com\nSubject: Hi\n\nBody")
    assert_equal :email, LoaderRuby::FormatDetector.detect(path)
  end

  def test_detect_html
    path = File.join(@tmpdir, "data")
    File.write(path, "<!DOCTYPE html><html><body>Hello</body></html>")
    assert_equal :html, LoaderRuby::FormatDetector.detect(path)
  end

  def test_detect_nonexistent
    assert_nil LoaderRuby::FormatDetector.detect("/nonexistent")
  end

  def test_detect_pdf_magic
    path = File.join(@tmpdir, "data")
    File.binwrite(path, "%PDF-1.4 test")
    assert_equal :pdf, LoaderRuby::FormatDetector.detect(path)
  end

  def test_detect_rtf_magic
    path = File.join(@tmpdir, "data")
    File.binwrite(path, '{\\rtf1\\ansi test}')
    assert_equal :rtf, LoaderRuby::FormatDetector.detect(path)
  end
end

class TestStreamingLoader < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("loader_test")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_streaming_chunks
    path = File.join(@tmpdir, "large.txt")
    File.write(path, "A" * 1000)

    chunks = []
    LoaderRuby::StreamingLoader.new(chunk_size: 100).load(path) { |c| chunks << c }
    assert_equal 10, chunks.size
    assert chunks.all? { |c| c.length == 100 }
  end

  def test_streaming_lines
    path = File.join(@tmpdir, "lines.txt")
    File.write(path, "line1\nline2\nline3\n")

    lines = []
    LoaderRuby::StreamingLoader.new.load_lines(path) { |l| lines << l.chomp }
    assert_equal %w[line1 line2 line3], lines
  end

  def test_streaming_requires_block
    path = File.join(@tmpdir, "test.txt")
    File.write(path, "test")

    assert_raises(ArgumentError) do
      LoaderRuby::StreamingLoader.new.load(path)
    end
  end

  def test_streaming_file_not_found
    assert_raises(LoaderRuby::FileNotFoundError) do
      LoaderRuby::StreamingLoader.new.load("/nonexistent") { |c| }
    end
  end
end

class TestParallelLoader < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("loader_test")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_parallel_load
    3.times { |i| File.write(File.join(@tmpdir, "file#{i}.txt"), "Content #{i}") }
    sources = 3.times.map { |i| File.join(@tmpdir, "file#{i}.txt") }

    loader = LoaderRuby::ParallelLoader.new(threads: 2)
    results = loader.load(sources)
    assert_equal 3, results.compact.size
    assert results.all? { |r| r.is_a?(LoaderRuby::Document) }
  end

  def test_single_thread_fallback
    File.write(File.join(@tmpdir, "a.txt"), "Hello")
    loader = LoaderRuby::ParallelLoader.new(threads: 1)
    results = loader.load([File.join(@tmpdir, "a.txt")])
    assert_equal 1, results.size
  end
end

class TestFormatMap < Minitest::Test
  def test_new_formats_in_map
    assert_equal LoaderRuby::Loaders::Json, LoaderRuby::FORMAT_MAP[".json"]
    assert_equal LoaderRuby::Loaders::Xml, LoaderRuby::FORMAT_MAP[".xml"]
    assert_equal LoaderRuby::Loaders::Epub, LoaderRuby::FORMAT_MAP[".epub"]
    assert_equal LoaderRuby::Loaders::Rtf, LoaderRuby::FORMAT_MAP[".rtf"]
    assert_equal LoaderRuby::Loaders::Email, LoaderRuby::FORMAT_MAP[".eml"]
    assert_equal LoaderRuby::Loaders::Xlsx, LoaderRuby::FORMAT_MAP[".xlsx"]
  end
end
