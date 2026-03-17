# frozen_string_literal: true

require_relative "loader_ruby/version"
require_relative "loader_ruby/error"
require_relative "loader_ruby/configuration"
require_relative "loader_ruby/document"
require_relative "loader_ruby/html_extractor"
require_relative "loader_ruby/encoding_detector"
require_relative "loader_ruby/loaders/base"
require_relative "loader_ruby/loaders/text"
require_relative "loader_ruby/loaders/pdf"
require_relative "loader_ruby/loaders/docx"
require_relative "loader_ruby/loaders/csv"
require_relative "loader_ruby/loaders/html"
require_relative "loader_ruby/loaders/web"
require_relative "loader_ruby/loaders/json_loader"
require_relative "loader_ruby/loaders/xml"
require_relative "loader_ruby/loaders/epub"
require_relative "loader_ruby/loaders/rtf"
require_relative "loader_ruby/loaders/email"
require_relative "loader_ruby/loaders/xlsx"
require_relative "loader_ruby/format_detector"
require_relative "loader_ruby/parallel_loader"
require_relative "loader_ruby/streaming_loader"

module LoaderRuby
  FORMAT_MAP = {
    ".txt" => Loaders::Text, ".md" => Loaders::Text, ".markdown" => Loaders::Text,
    ".text" => Loaders::Text, ".log" => Loaders::Text, ".rst" => Loaders::Text,
    ".pdf" => Loaders::Pdf,
    ".docx" => Loaders::Docx,
    ".csv" => Loaders::Csv, ".tsv" => Loaders::Csv,
    ".html" => Loaders::Html, ".htm" => Loaders::Html,
    ".json" => Loaders::Json,
    ".xml" => Loaders::Xml,
    ".epub" => Loaders::Epub,
    ".rtf" => Loaders::Rtf,
    ".eml" => Loaders::Email,
    ".xlsx" => Loaders::Xlsx, ".xls" => Loaders::Xlsx
  }.freeze

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def load(source, **opts)
      raise ArgumentError, "source cannot be nil" if source.nil?
      raise ArgumentError, "source cannot be empty" if source.is_a?(String) && source.strip.empty?

      if source.start_with?("http://", "https://")
        Loaders::Web.new.load(source, **opts)
      else
        ext = File.extname(source).downcase
        loader_class = FORMAT_MAP[ext]
        raise UnsupportedFormatError, "Unsupported format: #{ext}" unless loader_class

        loader_class.new.load(source, **opts)
      end
    end

    def load_batch(sources, **opts)
      sources.map { |source| load(source, **opts) }
    end
  end
end
