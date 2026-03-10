# frozen_string_literal: true

module LoaderRuby
  class Configuration
    attr_accessor :default_encoding, :max_file_size, :http_timeout,
                  :web_user_agent

    def initialize
      @default_encoding = "UTF-8"
      @max_file_size = 100 * 1024 * 1024
      @http_timeout = 30
      @web_user_agent = "LoaderRuby/#{VERSION}"
    end
  end
end
