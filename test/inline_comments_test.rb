# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'json'
require_relative '../ios/ReactNativeConfig/ReadDotEnv'

class InlineCommentsTest < Minitest::Test
  FIXTURES = JSON.parse(File.read(File.join(__dir__, 'fixtures/inline_comments.json')))

  def setup
    @previous_envfile = ENV['ENVFILE']
    ENV.delete('ENVFILE')
  end

  def teardown
    ENV['ENVFILE'] = @previous_envfile
  end

  FIXTURES.each do |fixture|
    define_method("test_#{fixture['key'].downcase}") do
      Dir.mktmpdir('rnc-comment') do |root|
        File.write(File.join(root, '.env'), fixture['line'] + "\n")
        result = nil
        capture_io { result = read_dot_env(root) }
        assert_equal({ fixture['key'] => fixture['value'] }, result.first)
      end
    end
  end

  def test_escaped_quote_does_not_end_a_quoted_value
    value = 'VALUE="say \" # literal"'
    assert_equal value, strip_inline_comment(value + ' # discarded')
  end

  def test_even_backslashes_allow_the_closing_quote
    value = 'VALUE="path' + ('\\' * 2) + '"'
    assert_equal value, strip_inline_comment(value + ' # discarded')
  end

  def test_unclosed_quoted_values_are_left_for_the_existing_parser
    value = 'VALUE="unfinished # literal'
    assert_equal value, strip_inline_comment(value)
  end
end
