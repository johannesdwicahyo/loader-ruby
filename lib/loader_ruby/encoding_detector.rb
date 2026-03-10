# frozen_string_literal: true

module LoaderRuby
  # Detects file encoding from BOM or content-type header and transcodes to UTF-8.
  module EncodingDetector
    BOM_MAP = {
      "\xEF\xBB\xBF".b => "UTF-8",
      "\xFF\xFE".b => "UTF-16LE",
      "\xFE\xFF".b => "UTF-16BE",
      "\xFF\xFE\x00\x00".b => "UTF-32LE",
      "\x00\x00\xFE\xFF".b => "UTF-32BE"
    }.freeze

    private

    # Detect encoding from BOM bytes at the start of raw content.
    def detect_encoding_from_bom(raw_bytes)
      # Check 4-byte BOMs first, then 3-byte, then 2-byte
      if raw_bytes.bytesize >= 4
        bom4 = raw_bytes.byteslice(0, 4)
        return BOM_MAP[bom4] if BOM_MAP.key?(bom4)
      end

      if raw_bytes.bytesize >= 3
        bom3 = raw_bytes.byteslice(0, 3)
        return BOM_MAP[bom3] if BOM_MAP.key?(bom3)
      end

      if raw_bytes.bytesize >= 2
        bom2 = raw_bytes.byteslice(0, 2)
        return BOM_MAP[bom2] if BOM_MAP.key?(bom2)
      end

      nil
    end

    # Detect encoding from a Content-Type header value, e.g. "text/html; charset=iso-8859-1"
    def detect_encoding_from_content_type(content_type)
      return nil unless content_type

      if content_type =~ /charset=([^\s;]+)/i
        $1.strip
      end
    end

    # Transcode content to UTF-8 from the detected or specified encoding.
    # Returns a UTF-8 encoded string with invalid/undefined bytes replaced.
    def transcode_to_utf8(content, source_encoding)
      return content if source_encoding.nil?

      normalized = source_encoding.upcase.strip
      return content if normalized == "UTF-8" && content.encoding == ::Encoding::UTF_8 && content.valid_encoding?

      begin
        content.encode("UTF-8", source_encoding, invalid: :replace, undef: :replace)
      rescue ::EncodingError => e
        raise LoaderRuby::EncodingError, "Failed to transcode from #{source_encoding} to UTF-8: #{e.message}"
      end
    end
  end
end
