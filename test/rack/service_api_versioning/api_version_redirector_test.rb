# frozen_string_literal: true

require 'test_helper'
require 'addressable'
require 'json'

require 'rack/service_api_versioning/api_version_redirector'

describe 'Rack::ServiceApiVersioning::ApiVersionRedirector' do
  let(:described_class) { Rack::ServiceApiVersioning::ApiVersionRedirector }
  let(:app) { :dummy_app }
  let(:env) do
    {
      'COMPONENT_API_VERSION_DATA' => JSON.dump(version_data)
    }
  end
  let(:http_host) do
    tail = server_port == 80 ? '' : ":#{server_port}"
    server_name + tail
  end
  let(:new_request_url) do
    temp_uri = Addressable::URI.parse(version_data[:base_url])
    ret = temp_uri.host
    ret += [':', temp_uri.port.to_s] if temp_uri.port
    ret += temp_uri.path + path_info
    ret.sub!('//', '/')
    ret += ['?', query_string].join unless query_string.to_s.empty?
    [temp_uri.scheme, '://', ret].join
  end
  let(:obj) { described_class.new app }
  let(:path_info) { '/path/to/endpoint' }
  let(:query_string) { 'foo=1&bar=42' }
  let(:rack_url_scheme) { 'http' }
  let(:response) { obj.call env }
  let(:response_headers) { response[1] }
  let(:server_name) { 'localhost' }
  let(:server_port) { 9876 }
  let(:version_data) do
    {
      api_version: 'v2',
      base_url: 'http://v2.example.com/apidemo/',
      content_type: 'application/vnd.conversagence.apidemo.v2',
      name: 'apidemo',
      deprecated: false,
      restricted: false
    }
  end

  before do
    env.merge!(
      'HTTP_HOST' => http_host,
      'PATH_INFO' => path_info,
      'QUERY_STRING' => query_string,
      'rack.url_scheme' => rack_url_scheme
    )
  end

  describe 'has a .call method that' do
    describe 'on success, returns an HTTP response with' do
      it 'a status code of 307 (Temporary Redirect)' do
        expect(response[0]).must_equal 307
      end

      it 'a body with a readable "please redirect w/o caching" text' do
        the_body = response[2].body.join
        fragment = version_data[:base_url] + path_info[1..-1] + '?' +
                   query_string
        parts = the_body.split(fragment)
        expect(parts.count).must_equal 3
      end

      # Yes, we *do* need all these environment entries to make Rack, or more
      # specifically, `Rack::Request`, do its thing properly. If a body is
      # needed, say, for a Post request, it *must* be in `env[rack.input]` as an
      # `IO` instance, eg, `StringIO`. Several requirements are laid out in the
      # [spec](http://www.rubydoc.info/github/rack/rack/master/file/SPEC)
      # (scroll down to the discussion following the two tables). Lots to keep
      # track of and, if we're doing a thorough enough job, we'd test all of it.
      describe 'headers for' do
        describe 'API-Version' do
          it 'using a value from the decoded version data' do
            expected = version_data[:api_version]
            expect(response_headers['API-Version']).must_equal expected
          end
        end # describe 'API-Version'

        describe '"Location", that' do
          it 'is built from the base URL and Rack environment' do
            expect(response_headers['Location']).must_equal new_request_url
          end
        end # describe '"Location", that'
      end # describe 'headers for'
    end # describe 'on success, returns an HTTP response with'
  end # describe 'has a :call method that'
end
