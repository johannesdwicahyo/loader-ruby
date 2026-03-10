# frozen_string_literal: true

require_relative "lib/loader_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "loader-ruby"
  spec.version = LoaderRuby::VERSION
  spec.authors = ["Johannes Dwi Cahyo"]
  spec.email = ["johannes@example.com"]
  spec.summary = "Document loader library for Ruby RAG pipelines"
  spec.description = "Document extraction for RAG pipelines. Loads PDF, DOCX, CSV, HTML, and web pages into a normalized Document format for chunking and embedding."
  spec.homepage = "https://github.com/johannesdwicahyo/loader-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "lib/**/*.rb",
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
    "Rakefile",
    "loader-ruby.gemspec"
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "csv"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
