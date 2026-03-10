# loader-ruby

Document loader library for Ruby RAG pipelines. Extracts text from PDF, DOCX, CSV, HTML, and web pages.

## Installation

```ruby
gem "loader-ruby", "~> 0.1"

# Optional dependencies for specific formats:
gem "pdf-reader"  # PDF support
gem "nokogiri"    # HTML/web support
gem "docx"        # DOCX support
```

## Usage

```ruby
require "loader_ruby"

doc = LoaderRuby.load("document.pdf")
doc.content   # => extracted text
doc.metadata  # => { source: "document.pdf", format: :pdf, pages: 12, ... }

doc = LoaderRuby.load("notes.md")

doc = LoaderRuby.load("data.csv")

docs = LoaderRuby::Loaders::Csv.new.load("data.csv", row_as_document: true)

doc = LoaderRuby.load("https://example.com/page")

docs = LoaderRuby.load_batch(["file1.pdf", "file2.docx"])
```

## License

MIT
