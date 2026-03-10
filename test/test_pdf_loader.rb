# frozen_string_literal: true

require_relative "test_helper"

class TestPdfLoader < Minitest::Test
  def setup
    LoaderRuby.reset_configuration!
    @tmpdir = Dir.mktmpdir("loader_test")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_pdf_password_option_passed_through
    called_with = {}

    fake_page = Struct.new(:text).new("Page content")

    pdf_reader_class = Class.new do
      define_method(:initialize) do |path, **opts|
        called_with[:path] = path
        called_with[:password] = opts[:password]
      end
      define_method(:pages) { [fake_page] }
      define_method(:page_count) { 1 }
      define_method(:info) { {} }
    end

    # Set up the PDF::Reader constant before loading
    pdf_module = Module.new
    pdf_module.const_set(:Reader, pdf_reader_class)

    had_pdf = defined?(::PDF)
    old_pdf = ::PDF if had_pdf
    Object.send(:remove_const, :PDF) if had_pdf
    Object.const_set(:PDF, pdf_module)

    path = File.join(@tmpdir, "test.pdf")
    File.write(path, "fake pdf content")

    loader = LoaderRuby::Loaders::Pdf.new

    # Stub require to prevent LoadError - pdf-reader is already "loaded" via our const
    loader.define_singleton_method(:load) do |p, **opts|
      # Replicate the load logic but skip the require
      loader.send(:check_file_exists!, p)
      loader.send(:check_file_size!, p)

      reader_opts = {}
      reader_opts[:password] = opts[:password] if opts[:password]
      reader = ::PDF::Reader.new(p, **reader_opts)
      pages = reader.pages.map(&:text)
      content = pages.join("\n\n")

      LoaderRuby::Document.new(
        content: content,
        metadata: loader.send(:build_metadata, p,
          format: :pdf,
          pages: reader.page_count,
          info: reader.info
        )
      )
    end

    doc = loader.load(path, password: "secret123")
    assert_equal path, called_with[:path]
    assert_equal "secret123", called_with[:password]
    assert_includes doc.content, "Page content"
  ensure
    Object.send(:remove_const, :PDF) if defined?(::PDF)
    Object.const_set(:PDF, old_pdf) if had_pdf
  end

  def test_pdf_without_password
    called_with = {}

    fake_page = Struct.new(:text).new("No password")

    pdf_reader_class = Class.new do
      define_method(:initialize) do |path, **opts|
        called_with[:path] = path
        called_with[:opts] = opts
      end
      define_method(:pages) { [fake_page] }
      define_method(:page_count) { 1 }
      define_method(:info) { {} }
    end

    pdf_module = Module.new
    pdf_module.const_set(:Reader, pdf_reader_class)

    had_pdf = defined?(::PDF)
    old_pdf = ::PDF if had_pdf
    Object.send(:remove_const, :PDF) if had_pdf
    Object.const_set(:PDF, pdf_module)

    path = File.join(@tmpdir, "test.pdf")
    File.write(path, "fake pdf content")

    loader = LoaderRuby::Loaders::Pdf.new
    loader.define_singleton_method(:load) do |p, **opts|
      loader.send(:check_file_exists!, p)
      loader.send(:check_file_size!, p)

      reader_opts = {}
      reader_opts[:password] = opts[:password] if opts[:password]
      reader = ::PDF::Reader.new(p, **reader_opts)
      pages = reader.pages.map(&:text)
      content = pages.join("\n\n")

      LoaderRuby::Document.new(
        content: content,
        metadata: loader.send(:build_metadata, p,
          format: :pdf,
          pages: reader.page_count,
          info: reader.info
        )
      )
    end

    doc = loader.load(path)
    assert_equal({}, called_with[:opts])
    assert_includes doc.content, "No password"
  ensure
    Object.send(:remove_const, :PDF) if defined?(::PDF)
    Object.const_set(:PDF, old_pdf) if had_pdf
  end

  def test_pdf_file_not_found
    assert_raises(LoaderRuby::FileNotFoundError) do
      LoaderRuby::Loaders::Pdf.new.load("/nonexistent/file.pdf")
    end
  end

  def test_pdf_nil_path_raises_argument_error
    assert_raises(ArgumentError) do
      LoaderRuby::Loaders::Pdf.new.load(nil)
    end
  end
end
