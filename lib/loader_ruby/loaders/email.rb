# frozen_string_literal: true

module LoaderRuby
  module Loaders
    class Email < Base
      def load(path, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        raw = File.read(path)
        headers, body = parse_email(raw)

        Document.new(
          content: body,
          metadata: build_metadata(path, format: :email,
            subject: headers["subject"],
            from: headers["from"],
            to: headers["to"],
            date: headers["date"])
        )
      end

      private

      def parse_email(raw)
        # Split headers and body at first blank line
        parts = raw.split(/\r?\n\r?\n/, 2)
        header_text = parts[0] || ""
        body = parts[1] || ""

        headers = {}
        header_text.split(/\r?\n/).each do |line|
          if line.match?(/\A\S+:/)
            key, value = line.split(":", 2)
            headers[key.strip.downcase] = value&.strip
          end
        end

        # Strip HTML from body if it looks like HTML
        if body.include?("<html") || body.include?("<body")
          body = body.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
        end

        [headers, body.strip]
      end
    end
  end
end
