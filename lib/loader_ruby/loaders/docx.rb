# frozen_string_literal: true

module LoaderRuby
  module Loaders
    class Docx < Base
      EXTENSIONS = %w[.docx].freeze

      def load(path, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        begin
          require "docx"
        rescue LoadError
          raise DependencyMissingError,
            "docx gem is required for DOCX loading. Add `gem 'docx'` to your Gemfile."
        end

        doc = ::Docx::Document.open(path)
        paragraphs = doc.paragraphs.map(&:text)
        content = paragraphs.join("\n")

        Document.new(
          content: content,
          metadata: build_metadata(path,
            format: :docx,
            paragraphs: paragraphs.size
          )
        )
      end
    end
  end
end
