# loader-ruby Milestones

## Current State (v0.1.0)

- Loaders: Text/Markdown, PDF, DOCX, CSV/TSV, HTML, Web
- Auto-format detection by file extension
- Unified Document result object with metadata
- Optional dependencies (pdf-reader, nokogiri, docx)
- 11 tests, 25 assertions — all passing (1 skip: nokogiri web test)

---

## v0.1.1 — Bug Fixes & Robustness

### Fix
- [x] **Web loader redirect loop** — `fetch()` follows redirects recursively with no max depth; add `max_redirects: 5` parameter
- [x] **Encoding detection** — Text loader defaults to UTF-8; detect actual encoding via BOM or heuristics, fallback to UTF-8
- [x] **PDF structure loss** — Pages joined with `\n\n` loses paragraph boundaries; preserve paragraph breaks within pages
- [x] **CSV header ambiguity** — `row_as_document: true` requires headers but this isn't validated; error on headerless CSV
- [x] **HTML/Web code duplication** — `extract_text` method duplicated between Html and Web loaders; extract to shared module
- [x] **Input validation** — `LoaderRuby.load(nil)` crashes; validate source parameter

### Add
- [x] **Encoding auto-detection** — Detect file encoding from BOM, content sniffing, or `file` command fallback
- [x] **PDF password support** — `LoaderRuby.load("secret.pdf", password: "...")` for encrypted PDFs
- [x] **Load from IO** — `LoaderRuby.load_io(io, format: :pdf)` for streaming/uploaded files
- [x] **Metadata extraction** — PDF author/title/creation date, DOCX properties, HTML meta tags

### Test
- [x] Redirect loop protection (301 → 302 → 301 cycle)
- [x] Files with different encodings (Latin-1, Shift_JIS, Windows-1252)
- [x] Password-protected PDF
- [x] CSV with special characters (quotes, commas in values, UTF-8)
- [x] Empty files for each format
- [x] Binary file detection (don't load .exe as text)
- [x] Very large files (>100MB) — verify file size check works

---

## v0.2.0 — New Formats & Table Extraction

### Add: Formats
- [ ] **XLSX/Excel** — `Loaders::Xlsx` via `roo` gem (optional dep), sheet selection, row-as-document mode
- [ ] **JSON** — `Loaders::Json` (array → documents, object → single document, JSON Lines support)
- [ ] **XML** — `Loaders::Xml` via nokogiri, XPath-based content extraction
- [ ] **EPUB** — `Loaders::Epub` via `epub-parser` gem (chapters as separate documents)
- [ ] **RTF** — `Loaders::Rtf` basic rich text to plain text conversion
- [ ] **Email (.eml)** — `Loaders::Email` extract subject, body, attachments list

### Add: Features
- [ ] **Table extraction** — Preserve table structure as markdown/CSV in PDF and DOCX
- [ ] **Image extraction** — Extract embedded images from PDF/DOCX, return as metadata references
- [ ] **Heading hierarchy** — Extract heading structure (H1, H2, H3) from HTML/DOCX for chunking hints
- [ ] **Link extraction** — Extract hyperlinks from HTML/DOCX as metadata
- [ ] **Multi-page documents** — `doc.pages` returns array of per-page Documents for PDF
- [ ] **Format auto-detection by content** — Detect format from magic bytes when extension is ambiguous

### Refine
- [ ] **Streaming loader** — Process large files in chunks without loading entirely into memory
- [ ] **Parallel loading** — `load_batch` processes files concurrently with thread pool

### Test
- [ ] Each new format with sample fixtures
- [ ] Table extraction accuracy
- [ ] Heading hierarchy extraction
- [ ] Format detection from content (rename .pdf to .txt, still detect as PDF)

---

## v0.3.0 — Web Crawling & Cloud Sources

### Add: Web
- [ ] **Smart web crawler** — Follow links within same domain, respect robots.txt, configurable depth
- [ ] **Sitemap-based crawling** — Parse sitemap.xml for comprehensive site crawling
- [ ] **JavaScript rendering** — Optional headless browser support for JS-rendered pages (via ferrum/selenium)
- [ ] **Authentication** — HTTP Basic auth, Bearer token, cookie-based auth for protected pages
- [ ] **Proxy support** — Configure HTTP proxy for web loading

### Add: Cloud Sources
- [ ] **Notion API** — `Loaders::Notion.load(page_id:, api_key:)` loads Notion pages/databases
- [ ] **Google Docs** — `Loaders::GoogleDocs.load(doc_id:, credentials:)` loads Google Docs
- [ ] **Google Drive** — `Loaders::GoogleDrive.load(file_id:, credentials:)` downloads and loads files
- [ ] **S3** — `Loaders::S3.load(bucket:, key:, region:)` loads from AWS S3
- [ ] **Azure Blob** — `Loaders::AzureBlob.load(container:, blob:)` loads from Azure storage

### Integrate: chunker-ruby
- [ ] **Pipeline support** — `LoaderRuby.load("doc.pdf").then { |doc| ChunkerRuby.split(doc.content) }`
- [ ] **Heading-aware chunking** — Pass heading hierarchy to chunker for intelligent split points

### Integrate: rag-ruby
- [ ] **Drop-in RAG loader** — `RagRuby.configure { |c| c.loader(:loader_ruby, formats: [:pdf, :docx]) }`
- [ ] **Document metadata for retrieval** — Source, format, page number in vector store metadata

### Test
- [ ] Crawler with robots.txt respect
- [ ] Authenticated web page loading
- [ ] Cloud source integration (with mocked APIs)
- [ ] chunker-ruby pipeline end-to-end

---

## v0.4.0 — OCR & Advanced Extraction

### Add
- [ ] **OCR support** — Extract text from scanned PDFs and images via Tesseract (optional dep)
- [ ] **Table-to-structured-data** — Convert detected tables to Ruby hashes/arrays
- [ ] **Layout analysis** — Detect columns, headers, footers, sidebars in PDF
- [ ] **Compression support** — Load from .gz, .zip, .tar archives (extract and load contained files)
- [ ] **Incremental loading** — Track file modification times, only reload changed files

### Add: Rails
- [ ] `LoaderRuby::Rails::Railtie` — Auto-configure from Rails credentials
- [ ] ActiveStorage integration — `LoaderRuby.load(active_storage_blob)` loads from AS attachments
- [ ] Background job for async document loading

### Refine
- [ ] Memory usage profiling for large documents
- [ ] Extraction accuracy benchmarks per format
- [ ] Plugin architecture for custom loaders: `LoaderRuby.register_loader(:custom, MyLoader)`

---

## v1.0.0 — Production Ready

- [ ] API stability guarantee
- [ ] Comprehensive format support documentation
- [ ] Performance benchmarks (pages/sec for PDF, docs/sec for batch)
- [ ] Extraction quality benchmarks vs Apache Tika
- [ ] Thread-safe concurrent loading
