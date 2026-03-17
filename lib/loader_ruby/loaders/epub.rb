# frozen_string_literal: true

require "zip" if defined?(Zip) || begin; require "zip"; rescue LoadError; false; end

module LoaderRuby
  module Loaders
    class Epub < Base
      def load(path, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        begin
          require "zip"
        rescue LoadError
          raise DependencyMissingError, "rubyzip gem is required for EPUB loading"
        end

        content = extract_text(path)

        Document.new(
          content: content,
          metadata: build_metadata(path, format: :epub)
        )
      end

      private

      def extract_text(path)
        texts = []
        Zip::File.open(path) do |zip|
          zip.each do |entry|
            next unless entry.name.end_with?(".xhtml", ".html", ".htm")
            html = entry.get_input_stream.read
            texts << strip_html(html)
          end
        end
        texts.join("\n\n")
      end

      def strip_html(html)
        html.gsub(/<script[^>]*>.*?<\/script>/m, "")
            .gsub(/<style[^>]*>.*?<\/style>/m, "")
            .gsub(/<[^>]+>/, " ")
            .gsub(/\s+/, " ")
            .strip
      end
    end
  end
end
