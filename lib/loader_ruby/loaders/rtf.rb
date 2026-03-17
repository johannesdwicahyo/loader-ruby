# frozen_string_literal: true

module LoaderRuby
  module Loaders
    class Rtf < Base
      def load(path, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        raw = File.read(path)
        content = strip_rtf(raw)

        Document.new(
          content: content,
          metadata: build_metadata(path, format: :rtf)
        )
      end

      private

      def strip_rtf(text)
        # Remove RTF control words, keep plain text
        text = text.gsub(/\\[a-z]+\d*[ ]?/i, "")  # Remove control words
        text = text.gsub(/[{}]/, "")              # Remove braces
        text = text.gsub(/\s+/, " ").strip
        text
      end
    end
  end
end
