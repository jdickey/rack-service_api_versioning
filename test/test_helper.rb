# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pry-byebug'
require 'simplecov'
require 'minitest/spec'
require 'minitest/autorun'
require 'awesome_print'

uses_cova = ENV['COVERALLS_REPO_TOKEN']
uses_cc = ENV['CODECLIMATE_REPO_TOKEN']

if uses_cc
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

SimpleCov.start do
  add_filter '/gemsets/'
  add_filter '/test/matchers/asserters/'

  sc_formatters = [
    SimpleCov::Formatter::HTMLFormatter
  ]

  if uses_cova
    require 'coveralls'
    sc_formatters.unshift(Coveralls::SimpleCov::Formatter)
  end

  sc_formatters.unshift(CodeClimate::TestReporter::Formatter) if uses_cc
  self.formatters = sc_formatters
  # formatter SimpleCov::Formatter::MultiFormatter[*sc_formatters]
  Coveralls.wear! if uses_cova
end

# if uses_cc
#   CodeClimate.TestReporter.start
# end

require 'minitest/autorun' # harmless if already required
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(
  color: true, detailed_skip: true, fast_fail: true
)]

# Set up MiniTest::Tagz, with stick-it-anywhere `:focus` support.
require 'minitest/tagz'
tags = ENV['TAGS'].split(',') if ENV['TAGS']
tags ||= []
tags << 'focus'
Minitest::Tagz.choose_tags(*tags, run_all_if_no_match: true)
