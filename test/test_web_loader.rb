# frozen_string_literal: true

require_relative "test_helper"
require "webmock/minitest"

class TestWebLoader < Minitest::Test
  def setup
    LoaderRuby.reset_configuration!
  end

  def test_load_web_page
    begin
      require "nokogiri"
    rescue LoadError
      skip "nokogiri not available"
    end

    stub_request(:get, "https://example.com/page")
      .to_return(
        status: 200,
        body: "<html><head><title>Test Page</title></head><body><p>Hello World</p></body></html>",
        headers: { "Content-Type" => "text/html" }
      )

    doc = LoaderRuby.load("https://example.com/page")
    assert_instance_of LoaderRuby::Document, doc
    assert_equal :web, doc.format
    assert_includes doc.content, "Hello World"
    assert_equal "Test Page", doc.metadata[:title]
  end

  def test_redirect_within_limit_succeeds
    begin
      require "nokogiri"
    rescue LoadError
      skip "nokogiri not available"
    end

    stub_request(:get, "https://example.com/a")
      .to_return(status: 302, headers: { "Location" => "https://example.com/b" })

    stub_request(:get, "https://example.com/b")
      .to_return(status: 302, headers: { "Location" => "https://example.com/c" })

    stub_request(:get, "https://example.com/c")
      .to_return(
        status: 200,
        body: "<html><body><p>Final</p></body></html>",
        headers: { "Content-Type" => "text/html" }
      )

    doc = LoaderRuby.load("https://example.com/a", max_redirects: 5)
    assert_includes doc.content, "Final"
  end

  def test_max_redirects_exceeded_raises_error
    begin
      require "nokogiri"
    rescue LoadError
      skip "nokogiri not available"
    end

    stub_request(:get, "https://example.com/loop1")
      .to_return(status: 302, headers: { "Location" => "https://example.com/loop2" })

    stub_request(:get, "https://example.com/loop2")
      .to_return(status: 302, headers: { "Location" => "https://example.com/loop1" })

    assert_raises(LoaderRuby::TooManyRedirectsError) do
      LoaderRuby.load("https://example.com/loop1", max_redirects: 2)
    end
  end

  def test_encoding_from_content_type_header
    begin
      require "nokogiri"
    rescue LoadError
      skip "nokogiri not available"
    end

    body = "<html><body><p>Caf\xe9</p></body></html>".b
    stub_request(:get, "https://example.com/latin")
      .to_return(
        status: 200,
        body: body,
        headers: { "Content-Type" => "text/html; charset=ISO-8859-1" }
      )

    doc = LoaderRuby.load("https://example.com/latin")
    assert_includes doc.content, "Caf"
    assert doc.content.encoding == Encoding::UTF_8
  end

  def test_invalid_url_raises_argument_error
    begin
      require "nokogiri"
    rescue LoadError
      skip "nokogiri not available"
    end

    assert_raises(ArgumentError) do
      LoaderRuby::Loaders::Web.new.load("not-a-url")
    end
  end

  def test_nil_url_raises_argument_error
    begin
      require "nokogiri"
    rescue LoadError
      skip "nokogiri not available"
    end

    assert_raises(ArgumentError) do
      LoaderRuby::Loaders::Web.new.load(nil)
    end
  end

  def test_empty_url_raises_argument_error
    begin
      require "nokogiri"
    rescue LoadError
      skip "nokogiri not available"
    end

    assert_raises(ArgumentError) do
      LoaderRuby::Loaders::Web.new.load("  ")
    end
  end
end
