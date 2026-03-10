# frozen_string_literal: true

module LoaderRuby
  # Shared HTML-to-text extraction logic used by both Html and Web loaders.
  module HtmlExtractor
    REMOVE_SELECTORS = "script, style, nav, footer, header"

    private

    def require_nokogiri!
      require "nokogiri"
    rescue LoadError
      raise DependencyMissingError,
        "nokogiri gem is required for HTML loading. Add `gem 'nokogiri'` to your Gemfile."
    end

    def parse_html(html)
      doc = Nokogiri::HTML(html)
      doc.css(REMOVE_SELECTORS).remove
      doc
    end

    def extract_title(doc)
      doc.at_css("title")&.text&.strip
    end

    def extract_text(doc)
      body = doc.at_css("body") || doc
      body.text.gsub(/\s+/, " ").strip
    end
  end
end
