# frozen_string_literal: true

module LoaderRuby
  class Document
    attr_reader :content, :metadata

    def initialize(content:, metadata: {})
      @content = content
      @metadata = metadata
    end

    def source
      @metadata[:source]
    end

    def format
      @metadata[:format]
    end

    def pages
      @metadata[:pages]
    end

    def size
      @content.length
    end

    def empty?
      @content.nil? || @content.strip.empty?
    end

    def to_h
      {
        content: @content,
        metadata: @metadata
      }
    end

    def to_s
      "Document(source: #{source}, format: #{self.format}, size: #{size})"
    end
  end
end
