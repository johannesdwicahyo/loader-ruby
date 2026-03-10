# frozen_string_literal: true

require "net/http"
require "uri"
require "set"

module LoaderRuby
  module Loaders
    class Web < Base
      include HtmlExtractor
      include EncodingDetector

      DEFAULT_MAX_REDIRECTS = 5

      def load(url, max_redirects: DEFAULT_MAX_REDIRECTS, **opts)
        validate_url!(url)
        require_nokogiri!

        html, content_type = fetch(url, max_redirects: max_redirects)

        detected = detect_encoding_from_content_type(content_type) ||
                   detect_encoding_from_bom(html.b)
        html = transcode_to_utf8(html, detected) if detected

        doc = parse_html(html)
        title = extract_title(doc)
        content = extract_text(doc)

        Document.new(
          content: content,
          metadata: build_metadata(url,
            format: :web,
            title: title
          )
        )
      end

      def crawl(start_url, max_pages: 10, max_redirects: DEFAULT_MAX_REDIRECTS)
        visited = Set.new
        queue = [start_url]
        documents = []

        while queue.any? && documents.size < max_pages
          url = queue.shift
          next if visited.include?(url)

          visited << url

          begin
            doc = load(url, max_redirects: max_redirects)
            documents << doc
          rescue StandardError
            next
          end
        end

        documents
      end

      private

      def fetch(url, max_redirects:, redirects_followed: 0)
        if redirects_followed > max_redirects
          raise TooManyRedirectsError,
            "Too many redirects (followed #{redirects_followed}, max: #{max_redirects})"
        end

        uri = URI.parse(url)
        config = LoaderRuby.configuration

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.read_timeout = config.http_timeout

        req = Net::HTTP::Get.new(uri.request_uri)
        req["User-Agent"] = config.web_user_agent

        response = http.request(req)

        case response.code.to_i
        when 200..299
          [response.body, response["Content-Type"]]
        when 301, 302, 303, 307, 308
          location = response["Location"]
          # Handle relative redirects
          location = URI.join(url, location).to_s unless location.start_with?("http")
          fetch(location, max_redirects: max_redirects, redirects_followed: redirects_followed + 1)
        else
          raise Error, "HTTP #{response.code} fetching #{url}"
        end
      end
    end
  end
end
