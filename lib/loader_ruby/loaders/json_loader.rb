# frozen_string_literal: true

require "json"

module LoaderRuby
  module Loaders
    class Json < Base
      def load(path, text_key: nil, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        raw = File.read(path)
        data = ::JSON.parse(raw)

        content = if text_key
                    extract_by_key(data, text_key)
                  else
                    ::JSON.pretty_generate(data)
                  end

        Document.new(
          content: content,
          metadata: build_metadata(path, format: :json, keys: data.is_a?(Hash) ? data.keys : nil)
        )
      end

      private

      def extract_by_key(data, key)
        if data.is_a?(Array)
          data.map { |item| item.is_a?(Hash) ? item[key].to_s : item.to_s }.join("\n")
        elsif data.is_a?(Hash)
          data[key].to_s
        else
          data.to_s
        end
      end
    end
  end
end
