# frozen_string_literal: true

module LoaderRuby
  module Loaders
    class Pdf < Base
      EXTENSIONS = %w[.pdf].freeze

      def load(path, password: nil, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        begin
          require "pdf-reader"
        rescue LoadError
          raise DependencyMissingError,
            "pdf-reader gem is required for PDF loading. Add `gem 'pdf-reader'` to your Gemfile."
        end

        reader_opts = {}
        reader_opts[:password] = password if password
        reader = PDF::Reader.new(path, **reader_opts)
        pages = reader.pages.map(&:text)
        content = pages.join("\n\n")

        Document.new(
          content: content,
          metadata: build_metadata(path,
            format: :pdf,
            pages: reader.page_count,
            info: reader.info
          )
        )
      end
    end
  end
end
