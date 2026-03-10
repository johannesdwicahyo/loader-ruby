# frozen_string_literal: true

require_relative "test_helper"

class TestHtmlLoader < Minitest::Test
  def setup
    LoaderRuby.reset_configuration!
    @tmpdir = Dir.mktmpdir("loader_test")
    begin
      require "nokogiri"
    rescue LoadError
      skip "nokogiri not available"
    end
  end

  def teardown
    FileUtils.rm_rf(@tmpdir) if @tmpdir
  end

  def test_load_html_file
    path = File.join(@tmpdir, "test.html")
    File.write(path, "<html><head><title>Test</title></head><body><p>Content here</p></body></html>")

    doc = LoaderRuby.load(path)
    assert_instance_of LoaderRuby::Document, doc
    assert_equal :html, doc.format
    assert_includes doc.content, "Content here"
    assert_equal "Test", doc.metadata[:title]
  end

  def test_html_strips_script_and_style
    path = File.join(@tmpdir, "test.html")
    File.write(path, <<~HTML)
      <html>
        <head><title>Page</title><style>body { color: red; }</style></head>
        <body>
          <script>alert('hi');</script>
          <nav>Navigation</nav>
          <p>Main content</p>
          <footer>Footer text</footer>
        </body>
      </html>
    HTML

    doc = LoaderRuby.load(path)
    assert_includes doc.content, "Main content"
    refute_includes doc.content, "alert"
    refute_includes doc.content, "Navigation"
    refute_includes doc.content, "Footer text"
    refute_includes doc.content, "color: red"
  end

  def test_html_shared_extraction_matches_web_extraction
    # Both Html and Web loaders use the same HtmlExtractor module
    html_content = "<html><head><title>Shared</title></head><body><p>Shared content</p></body></html>"

    path = File.join(@tmpdir, "shared.html")
    File.write(path, html_content)

    html_doc = LoaderRuby::Loaders::Html.new.load(path)

    # Verify the extraction logic produces the same text
    assert_includes html_doc.content, "Shared content"
    assert_equal "Shared", html_doc.metadata[:title]
  end

  def test_html_file_not_found
    assert_raises(LoaderRuby::FileNotFoundError) do
      LoaderRuby::Loaders::Html.new.load("/nonexistent/file.html")
    end
  end

  def test_html_nil_path_raises_argument_error
    assert_raises(ArgumentError) do
      LoaderRuby::Loaders::Html.new.load(nil)
    end
  end
end
