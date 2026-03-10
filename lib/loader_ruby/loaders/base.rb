# frozen_string_literal: true

require "uri"

module LoaderRuby
  module Loaders
    class Base
      def load(source, **opts)
        raise NotImplementedError, "#{self.class}#load not implemented"
      end

      private

      def validate_path!(path)
        raise ArgumentError, "path cannot be nil" if path.nil?
        raise ArgumentError, "path cannot be empty" if path.is_a?(String) && path.strip.empty?
      end

      def validate_url!(url)
        raise ArgumentError, "URL cannot be nil" if url.nil?
        raise ArgumentError, "URL cannot be empty" if url.is_a?(String) && url.strip.empty?

        uri = URI.parse(url)
        unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
          raise ArgumentError, "Invalid URL: #{url}"
        end
      end

      def check_file_exists!(path)
        validate_path!(path)
        raise FileNotFoundError, "File not found: #{path}" unless File.exist?(path)
      end

      def check_file_size!(path)
        max = LoaderRuby.configuration.max_file_size
        size = File.size(path)
        if size > max
          raise FileTooLargeError, "File too large: #{size} bytes (max: #{max})"
        end
      end

      def build_metadata(source, format:, **extra)
        {
          source: source,
          format: format,
          loaded_at: Time.now.iso8601
        }.merge(extra)
      end
    end
  end
end
