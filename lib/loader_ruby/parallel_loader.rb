# frozen_string_literal: true

module LoaderRuby
  class ParallelLoader
    def initialize(threads: 4)
      @threads = threads
    end

    def load(sources, **opts)
      return sources.map { |s| LoaderRuby.load(s, **opts) } if @threads <= 1

      results = Array.new(sources.size)
      errors = []
      mutex = Mutex.new

      work_queue = Queue.new
      sources.each_with_index { |s, i| work_queue << [s, i] }
      @threads.times { work_queue << nil }  # Poison pills

      threads = @threads.times.map do
        Thread.new do
          while (item = work_queue.pop)
            source, index = item
            begin
              doc = LoaderRuby.load(source, **opts)
              mutex.synchronize { results[index] = doc }
            rescue => e
              mutex.synchronize { errors << { source: source, error: e } }
            end
          end
        end
      end

      threads.each(&:join)

      raise Error, "#{errors.size} files failed to load" if errors.any? && results.compact.empty?

      results
    end
  end
end
