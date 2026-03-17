# frozen_string_literal: true

module LoaderRuby
  module Loaders
    class Xlsx < Base
      def load(path, sheet: nil, row_as_document: false, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        begin
          require "roo"
        rescue LoadError
          raise DependencyMissingError, "roo gem is required for XLSX loading"
        end

        workbook = Roo::Spreadsheet.open(path)
        worksheet = sheet ? workbook.sheet(sheet) : workbook.sheet(0)

        if row_as_document
          load_rows(path, worksheet)
        else
          load_all(path, worksheet)
        end
      end

      private

      def load_all(path, worksheet)
        rows = []
        worksheet.each_row_streaming do |row|
          rows << row.map { |cell| cell&.value.to_s }.join("\t")
        end

        Document.new(
          content: rows.join("\n"),
          metadata: build_metadata(path, format: :xlsx, rows: rows.size)
        )
      end

      def load_rows(path, worksheet)
        headers = nil
        documents = []

        worksheet.each_row_streaming.each_with_index do |row, i|
          values = row.map { |cell| cell&.value.to_s }
          if i == 0
            headers = values
            next
          end

          content = headers ? headers.zip(values).map { |k, v| "#{k}: #{v}" }.join("\n") : values.join("\t")
          documents << Document.new(
            content: content,
            metadata: build_metadata(path, format: :xlsx, row_index: i, headers: headers)
          )
        end

        documents
      end
    end
  end
end
