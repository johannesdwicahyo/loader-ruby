# frozen_string_literal: true

module LoaderRuby
  class StreamingLoader
    DEFAULT_CHUNK_SIZE = 64 * 1024  # 64KB

    def initialize(chunk_size: DEFAULT_CHUNK_SIZE)
      @chunk_size = chunk_size
    end

    def load(path, &block)
      raise ArgumentError, "Block required for streaming" unless block_given?
      raise FileNotFoundError, "File not found: #{path}" unless File.exist?(path)

      File.open(path, "rb") do |file|
        while (chunk = file.read(@chunk_size))
          yield chunk
        end
      end
    end

    def load_lines(path, &block)
      raise ArgumentError, "Block required for streaming" unless block_given?
      raise FileNotFoundError, "File not found: #{path}" unless File.exist?(path)

      File.foreach(path) do |line|
        yield line
      end
    end
  end
end
