# frozen_string_literal: true

require 'test_helper'
require 'json'

require 'rack/service_api_versioning/api_version_redirector'

describe 'Rack::ServiceApiVersioning::ApiVersionRedirector' do
  let(:described_class) { Rack::ServiceApiVersioning::ApiVersionRedirector }
  let(:app) do
    Class.new do
      def initialize
        @env = :undefined
      end

      # No need for a `#call` method, as the middleware *never calls it;* it
      # ensures that we redirect in all circumstances.
      # def call(env)
      #   @env = env
      #   [400, {}, ['Default Response. Oops.']]
      # end

      attr_reader :env
    end.new
  end
  let(:env) do
    {
      'COMPONENT_API_VERSION_DATA' => JSON.dump(version_data)
    }
  end
  let(:obj) { described_class.new app }
  let(:response) { obj.call env }
  let(:version_data) do
    {
      api_version: 'v2',
      base_url: 'http://v2.example.com/',
      content_type: 'application/vnd.acme.apidemo.v2',
      name: 'apidemo',
      deprecated: false,
      restricted: false
    }
  end

  describe 'has a .call method that' do
    let(:path_info) { 'path/to/endpoint' }
    let(:query_string) { 'foo=1&bar=42' }
    let(:rack_url_scheme) { 'http' }
    let(:request_method) { 'http' }
    let(:script_name) { '/apidemo' }
    let(:server_name) { 'localhost' }
    let(:server_port) { 9876 }
    let(:response_headers) { response[1] }

    before do
      env.merge!(
        'HTTP_HOST' => [server_name, server_port.to_s].join(':'),
        'PATH_INFO' => path_info,
        'QUERY_STRING' => query_string,
        'REQUEST_METHOD' => request_method,
        'REQUEST_PATH' => path_info,
        'REQUEST_URI' => [path_info, query_string].join('?'),
        'SCRIPT_NAME' => script_name, # NOTE: ???
        'SERVER_NAME' => server_name,
        'SERVER_PORT' => server_port,
        'rack.url_scheme' => rack_url_scheme
      )
    end

    describe 'on success, returns an HTTP response with' do
      it 'a status code of 307 (Temporary Redirect)' do
        expect(response[0]).must_equal 307
      end

      it 'a non-empty message body' do
        expect(response[2].body.join).wont_be :empty?
      end

      # Yes, we *do* need all these environment entries to make Rack, or more
      # specifically, `Rack::Request`, do its thing properly. If a body is
      # needed, say, for a Post request, it *must* be in `env[rack.input]` as an
      # `IO` instance, eg, `StringIO`. Several requirements are laid out in the
      # [spec](http://www.rubydoc.info/github/rack/rack/master/file/SPEC)
      # (scroll down to the discussion following the two tables). Lots to keep
      # track of and, if we're doing a thorough enough job, we'd test all of it.
      describe 'headers for' do
        describe '"Location", that' do
          it 'is built from the base URL and Rack environment' do
            url = version_data[:base_url] + path_info
            expected = [url, query_string].join('?')
            expect(response_headers['Location']).must_equal expected
          end
        end # describe '"Location", that'

        describe 'API-Version' do
          it 'using a value from the decoded version data' do
            expected = version_data[:api_version]
            expect(response_headers['API-Version']).must_equal expected
          end
        end # describe 'API-Version'
      end # describe 'headers for'
    end # describe 'on success, returns an HTTP response with'
  end # describe 'has a :call method that'
end
