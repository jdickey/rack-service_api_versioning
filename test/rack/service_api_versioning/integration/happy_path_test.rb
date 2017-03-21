# frozen_string_literal: true

require 'test_helper'

require 'rack/service_api_versioning'

DUMMY_REPO_DATA = IceNine.deep_freeze(
  apidemo: {
    name: 'apidemo',
    description: 'The API Demonstration Component Service',
    api_versions: {
      'v1': {
        base_url: 'http://example.com:2345/',
        content_type: 'application/vnd.example.apidemo.v1+json',
        restricted: false,
        deprecated: false
      }
    }
  }
)

describe 'Rack::ServiceApiVersioning' do
  let(:fixtures) do
    Class.new do
      def acts_api_version_data(app, accept_header)
        obj = Rack::ServiceApiVersioning::AcceptContentTypeSelector.new app
        app.env['HTTP_ACCEPT'] = accept_header
        _response = obj.call app.env
        api_version_str = app.env['COMPONENT_API_VERSION_DATA'].to_s
        JSON.parse api_version_str, symbolize_names: true
      end

      def app_fixture
        Class.new do
          def initialize
            @env = :undefined
          end

          def call(env)
            @env = env
            self
          end

          attr_reader :env
        end.new
      end

      def avr_response(app)
        obj = Rack::ServiceApiVersioning::ApiVersionRedirector.new app
        obj.call app.env
      end

      def env_fixture
        {
          'HTTP_ACCEPT' => 'application/vnd.example.apidemo.v1+json',
          'HTTP_HOST' => 'localhost:4567',
          'PATH_INFO' => path_info,
          'QUERY_STRING' => query_string,
          'rack.url_scheme' => 'http'
        }
      end

      def path_info
        '/path/to/endpoint/'
      end

      def query_string
        'foo=bar&ls=mft'
      end

      def redirect_path
        new_base = DUMMY_REPO_DATA.dig(:apidemo, :api_versions, :v1, :base_url)
        new_base + path_info[1..-1] + '?' + query_string
      end

      def repository_fixture
        Class.new do
          def initialize
            @data = DUMMY_REPO_DATA
            self
          end

          def find(**params)
            match = @data[params[:name].to_sym]
            [match].compact
          end
        end.new
      end

      def scd_call_result(app, env)
        service_name = DUMMY_REPO_DATA.keys.first.to_s
        init_params = { repository: repository_fixture,
                        service_name: service_name }
        scd_class = Rack::ServiceApiVersioning::ServiceComponentDescriber
        scd_class.new(app, init_params).call env
      end
    end.new # anonymous class
  end # :fixtures

  describe 'generates the correct response given valid input, including' do
    before do
      app = fixtures.app_fixture
      env = fixtures.env_fixture
      app = fixtures.scd_call_result(app, env)
      header = 'application/vnd.example.apidemo.v1+json'
      _ = fixtures.acts_api_version_data(app, header)
      @response = fixtures.avr_response(app)
    end

    it 'an HTTP status of 307 (Temporary Redirect)' do
      expect(@response[0]).must_equal 307
    end

    describe 'correct headers, including' do
      before { @headers = @response[1] }

      it 'API-Version' do
        expect(@headers['API-Version']).must_equal 'v1'
      end

      it 'Content-Length' do
        body = @response[2].body.join
        expect(@headers['Content-Length']).must_equal body.length.to_s
      end

      it 'Location' do
        expect(@headers['Location']).must_equal fixtures.redirect_path
      end
    end # describe 'correct headers, including'
  end # describe 'generates the correct response given valid input, including'
end
