# frozen_string_literal: true

module LoaderRuby
  class Error < StandardError; end
  class FileNotFoundError < Error; end
  class UnsupportedFormatError < Error; end
  class FileTooLargeError < Error; end
  class DependencyMissingError < Error; end
  class TooManyRedirectsError < Error; end
  class EncodingError < Error; end
end
