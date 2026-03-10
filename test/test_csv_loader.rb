# frozen_string_literal: true

require_relative "test_helper"

class TestCsvLoader < Minitest::Test
  def setup
    LoaderRuby.reset_configuration!
    @tmpdir = Dir.mktmpdir("loader_test")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_load_csv_single_document
    path = File.join(@tmpdir, "data.csv")
    File.write(path, "name,age\nAlice,30\nBob,25\n")

    doc = LoaderRuby.load(path)
    assert_instance_of LoaderRuby::Document, doc
    assert_equal :csv, doc.format
    assert_includes doc.content, "name: Alice"
    assert_includes doc.content, "name: Bob"
  end

  def test_load_csv_rows_as_documents
    path = File.join(@tmpdir, "data.csv")
    File.write(path, "name,age\nAlice,30\nBob,25\n")

    docs = LoaderRuby::Loaders::Csv.new.load(path, row_as_document: true)
    assert_instance_of Array, docs
    assert_equal 2, docs.size
    assert_includes docs[0].content, "Alice"
    assert_includes docs[1].content, "Bob"
  end
end
