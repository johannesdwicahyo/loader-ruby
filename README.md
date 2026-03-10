# loader-ruby

Document loader library for Ruby RAG pipelines. Load text from PDF, HTML, CSV, DOCX, and web URLs.

## Installation

```ruby
gem "loader-ruby"
```

## Usage

```ruby
require "loader_ruby"

# Auto-detect format from file extension
doc = LoaderRuby.load("report.pdf")
doc = LoaderRuby.load("data.csv")
doc = LoaderRuby.load("page.html")

# Web loader with redirect handling
doc = LoaderRuby.load("https://example.com/article")

# PDF with password
loader = LoaderRuby::Loaders::Pdf.new("encrypted.pdf", password: "secret")
doc = loader.load

# Access content
doc.content   # => extracted text
doc.metadata  # => { source: "report.pdf", ... }
```

## Features

- PDF, HTML, CSV, DOCX, and plain text loaders
- Web loader with configurable max redirects (default: 5)
- Encoding auto-detection (BOM, Content-Type charset)
- Graceful transcoding to UTF-8
- Shared HTML extraction module
- Error hierarchy (FileNotFoundError, TooManyRedirectsError, etc.)
- Input validation for paths and URLs

## License

MIT
