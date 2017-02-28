# frozen_string_literal: true

require 'test_helper'

require 'rack/service_api_versioning'

describe 'ServiceApiVersioning middleware has' do
  it 'an AcceptContentTypeSelector class' do
    actual = Rack::ServiceApiVersioning::AcceptContentTypeSelector
    expect(actual).must_be_instance_of Class
  end

  it 'an ApiVersionRedirector class' do
    actual = Rack::ServiceApiVersioning::ApiVersionRedirector
    expect(actual).must_be_instance_of Class
  end

  it 'a ServiceComponentDescriber class' do
    actual = Rack::ServiceApiVersioning::ServiceComponentDescriber
    expect(actual).must_be_instance_of Class
  end
end # describe 'ServiceApiVersioning middleware has'
