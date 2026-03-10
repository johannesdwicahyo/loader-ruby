# frozen_string_literal: true

require "csv"

module LoaderRuby
  module Loaders
    class Csv < Base
      EXTENSIONS = %w[.csv .tsv].freeze

      def load(path, row_as_document: false, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        separator = path.end_with?(".tsv") ? "\t" : ","
        table = ::CSV.read(path, headers: true, col_sep: separator)

        if row_as_document
          load_rows_as_documents(path, table)
        else
          load_as_single_document(path, table)
        end
      end

      private

      def load_as_single_document(path, table)
        content = table.map { |row| row.to_h.map { |k, v| "#{k}: #{v}" }.join(", ") }.join("\n")

        Document.new(
          content: content,
          metadata: build_metadata(path,
            format: :csv,
            rows: table.size,
            headers: table.headers
          )
        )
      end

      def load_rows_as_documents(path, table)
        table.map.with_index do |row, i|
          content = row.to_h.map { |k, v| "#{k}: #{v}" }.join("\n")

          Document.new(
            content: content,
            metadata: build_metadata(path,
              format: :csv,
              row_index: i,
              headers: table.headers
            )
          )
        end
      end
    end
  end
end
