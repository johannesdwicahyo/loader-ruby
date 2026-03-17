# frozen_string_literal: true

module LoaderRuby
  module FormatDetector
    MAGIC_BYTES = {
      pdf: [0x25, 0x50, 0x44, 0x46],       # %PDF
      zip: [0x50, 0x4B, 0x03, 0x04],       # PK (XLSX, DOCX, EPUB)
      rtf: [0x7B, 0x5C, 0x72, 0x74, 0x66], # {\rtf
    }.freeze

    def self.detect(path)
      return nil unless File.exist?(path)

      bytes = File.binread(path, 8).bytes

      MAGIC_BYTES.each do |format, signature|
        if bytes[0, signature.length] == signature
          return resolve_zip(path) if format == :zip
          return format
        end
      end

      # Fallback: try content inspection
      content = File.read(path, 1024, encoding: "UTF-8") rescue nil
      return nil unless content

      return :json if content.strip.start_with?("{", "[")
      return :email if content.match?(/\AFrom:|Subject:|Content-Type:/i)
      return :html if content.match?(/<html|<!DOCTYPE html/i)
      return :xml if content.strip.start_with?("<?xml", "<")

      nil
    end

    def self.resolve_zip(path)
      # Peek inside ZIP to determine specific format
      content = File.binread(path, 2048)
      return :docx if content.include?("word/document.xml")
      return :xlsx if content.include?("xl/workbook.xml")
      return :epub if content.include?("META-INF/container.xml") || content.include?("mimetype")
      :zip
    end
  end
end
