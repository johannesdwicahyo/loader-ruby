# frozen_string_literal: true

module LoaderRuby
  module Loaders
    class Html < Base
      include HtmlExtractor
      include EncodingDetector

      EXTENSIONS = %w[.html .htm].freeze

      def load(path, **opts)
        check_file_exists!(path)
        check_file_size!(path)
        require_nokogiri!

        raw = File.binread(path)
        detected = detect_encoding_from_bom(raw)
        html = transcode_to_utf8(raw, detected || "UTF-8")

        doc = parse_html(html)
        title = extract_title(doc)
        content = extract_text(doc)

        Document.new(
          content: content,
          metadata: build_metadata(path,
            format: :html,
            title: title
          )
        )
      end
    end
  end
end
