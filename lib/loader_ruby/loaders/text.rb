# frozen_string_literal: true

module LoaderRuby
  module Loaders
    class Text < Base
      include EncodingDetector

      EXTENSIONS = %w[.txt .md .markdown .text .log .rst].freeze

      def load(path, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        explicit_encoding = opts[:encoding]

        raw = File.binread(path)
        detected = explicit_encoding || detect_encoding_from_bom(raw) || LoaderRuby.configuration.default_encoding
        content = transcode_to_utf8(raw, detected)

        Document.new(
          content: content,
          metadata: build_metadata(path, format: :text, encoding: detected)
        )
      end
    end
  end
end
