# frozen_string_literal: true

require 'test_helper'

module Rack
  describe 'ServiceApiVersioningTest' do
    it 'has a version number' do
      expect(::Rack::ServiceApiVersioning::VERSION).wont_be :nil?
    end
  end # describe 'ServiceApiVersioningTest'
end
