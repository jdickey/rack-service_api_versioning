# frozen_string_literal: true

require 'test_helper'

require 'rack/service_api_versioning'

ISRE_DUMMY_REPO_DATA = IceNine.deep_freeze(
  apidemo: {
    name: 'apidemo',
    description: 'The Broken API Demonstration Component Service',
    api_versions: {
      'v1': {
        base_url: 'http://example.com:3456/whoops',
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

      def repository_fixture
        Class.new do
          def initialize
            @data = ISRE_DUMMY_REPO_DATA
            self
          end

          def find(**params)
            match = @data[params[:name].to_sym]
            [match].compact
          end
        end.new
      end

      def scd_call_result(app, env)
        service_name = ISRE_DUMMY_REPO_DATA.keys.first.to_s
        init_params = { repository: repository_fixture,
                        service_name: service_name }
        scd_class = Rack::ServiceApiVersioning::ServiceComponentDescriber
        scd_class.new(app, init_params).call env
      end
    end.new # anonymous class
  end # :fixtures

  describe 'generates correct response given a bad SBU in input, including' do
    before do
      app = fixtures.app_fixture
      env = fixtures.env_fixture
      @app = fixtures.scd_call_result(app, env)
      accept_header = 'application/vnd.example.apidemo.v1+json'
      @obj = Rack::ServiceApiVersioning::AcceptContentTypeSelector.new @app
      @app.env['HTTP_ACCEPT'] = accept_header
    end

    it 'raises a Rack::ServiceApiVersioning::InvalidBaseUrlError' do
      begin
        @obj.call @app.env
      rescue Rack::ServiceApiVersioning::InvalidBaseUrlError => e
        sbu = ISRE_DUMMY_REPO_DATA.dig(:apidemo, :api_versions, :v1, :base_url)
        expected = 'Invalidly formatted base URL: ' + sbu
        expect(e.message).must_equal expected
      end
    end
  end # describe 'generates correct response given a bad SBU in input, ...'
end
