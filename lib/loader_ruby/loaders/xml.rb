# frozen_string_literal: true

module LoaderRuby
  module Loaders
    class Xml < Base
      def load(path, **opts)
        check_file_exists!(path)
        check_file_size!(path)

        begin
          require "nokogiri"
        rescue LoadError
          raise DependencyMissingError, "nokogiri gem is required for XML loading"
        end

        raw = File.read(path)
        doc = Nokogiri::XML(raw)

        content = doc.text.gsub(/\s+/, " ").strip

        Document.new(
          content: content,
          metadata: build_metadata(path, format: :xml, root: doc.root&.name)
        )
      end
    end
  end
end
