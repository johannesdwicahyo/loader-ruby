# frozen_string_literal: true

require_relative "test_helper"

class TestErrors < Minitest::Test
  def test_error_hierarchy
    assert LoaderRuby::Error < StandardError
    assert LoaderRuby::FileNotFoundError < LoaderRuby::Error
    assert LoaderRuby::UnsupportedFormatError < LoaderRuby::Error
    assert LoaderRuby::FileTooLargeError < LoaderRuby::Error
    assert LoaderRuby::DependencyMissingError < LoaderRuby::Error
    assert LoaderRuby::TooManyRedirectsError < LoaderRuby::Error
    assert LoaderRuby::EncodingError < LoaderRuby::Error
  end

  def test_errors_are_catchable_as_base_error
    assert_raises(LoaderRuby::Error) do
      raise LoaderRuby::FileNotFoundError, "test"
    end

    assert_raises(LoaderRuby::Error) do
      raise LoaderRuby::TooManyRedirectsError, "test"
    end

    assert_raises(LoaderRuby::Error) do
      raise LoaderRuby::EncodingError, "test"
    end
  end
end
