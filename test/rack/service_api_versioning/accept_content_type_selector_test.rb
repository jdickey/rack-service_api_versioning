# frozen_string_literal: true

require 'test_helper'

require 'rack/service_api_versioning/accept_content_type_selector'

describe 'Rack::ServiceApiVersioning::AcceptContentTypeSelector' do
  let(:described_class) do
    Rack::ServiceApiVersioning::AcceptContentTypeSelector
  end
  let(:base_fixture_generator) do
    Class.new do
      def self.app_fixture
        Class.new do
          def initialize
            @env = :undefined
          end

          def call(env)
            @env = env
            [400, {}, ['Default Response. Oops.']]
          end

          attr_reader :env
        end.new
      end

      def self.env_fixture
        { 'HTTP_ACCEPT' => nil }
      end
    end
  end
  let(:fixtures) do
    Class.new do
      def initialize(described_class, base_fixture_generator)
        @described_class = described_class
        @base_fixture_generator = base_fixture_generator
        self
      end

      def multiple_api_version_data(accept_header)
        app = base_fixture_generator.app_fixture
        obj = described_class.new app
        env = base_fixture_generator.env_fixture
        env['COMPONENT_DESCRIPTION'] = JSON.dump(MULTIPLE_APIS)
        env['HTTP_ACCEPT'] = accept_header
        obj.call env
        api_version_str = app.env['COMPONENT_API_VERSION_DATA'].to_s
        JSON.parse api_version_str, symbolize_names: true
      end

      def response_with_multiple_apis(accept_header)
        app = base_fixture_generator.app_fixture
        obj = described_class.new app
        env = base_fixture_generator.env_fixture
        env['COMPONENT_DESCRIPTION'] = JSON.dump(MULTIPLE_APIS)
        env['HTTP_ACCEPT'] = accept_header
        obj.call env
      end

      def response_with_single_api(accept_header)
        app = base_fixture_generator.app_fixture
        obj = described_class.new app
        env = base_fixture_generator.env_fixture
        env['COMPONENT_DESCRIPTION'] = JSON.dump(SINGLE_API)
        env['HTTP_ACCEPT'] = accept_header
        obj.call env
      end

      def single_api_version_data(accept_header)
        app = base_fixture_generator.app_fixture
        obj = described_class.new app
        env = base_fixture_generator.env_fixture
        env['COMPONENT_DESCRIPTION'] = JSON.dump(SINGLE_API)
        env['HTTP_ACCEPT'] = accept_header
        _ = obj.call env
        api_version_str = app.env['COMPONENT_API_VERSION_DATA'].to_s
        JSON.parse api_version_str, symbolize_names: true
      end

      private

      attr_reader :base_fixture_generator, :described_class
    end.new described_class, base_fixture_generator
  end

  API_DESCRIPTION = 'The API Demonstration Component Service'
  V2_BASE_URL = 'http://v2.example.com:9876/'
  V2_CONTENT_TYPE = 'application/vnd.acme.apidemo.v2+json'
  V3_BASE_URL = 'http://v3.example.org/'
  V3_CONTENT_TYPE = 'application/vnd.acme.apidemo.v3+json'
  SINGLE_API = IceNine.deep_freeze(name: 'apidemo',
                                   description: API_DESCRIPTION,
                                   api_versions: {
                                     'v2' => {
                                       base_url: V2_BASE_URL,
                                       content_type: V2_CONTENT_TYPE,
                                       restricted: false,
                                       deprecated: false
                                     }
                                   })

  MULTIPLE_APIS = IceNine.deep_freeze(name: 'apidemo',
                                      description: API_DESCRIPTION,
                                      api_versions: {
                                        'v2' => {
                                          base_url: V2_BASE_URL,
                                          content_type: V2_CONTENT_TYPE,
                                          restricted: false,
                                          deprecated: false
                                        },
                                        'v3' => {
                                          base_url: V3_BASE_URL,
                                          content_type: V3_CONTENT_TYPE,
                                          restricted: false,
                                          deprecated: false
                                        }
                                      })

  NO_APIS = IceNine.deep_freeze(name: 'apidemo',
                                description: API_DESCRIPTION,
                                api_versions: {})

  describe 'when called with a COMPONENT_DESCRIPTION value that' do
    describe 'is missing' do
      describe 'returns a Rack response with' do
        before do
          obj = described_class.new base_fixture_generator.app_fixture
          env = base_fixture_generator.env_fixture
          @response = obj.call env
        end

        it 'the status (first element) as 400 ("Bad Request")' do
          expect(@response[0]).must_equal 400
        end

        # NOTE: `response[2]` is a Rack::BodyProxy instance!
        it 'the body contains the correct message' do
          expected = 'Invalid value for COMPONENT_DESCRIPTION'
          expect(@response[2].body.join).must_equal expected
        end
      end # describe 'returns a Rack response with'
    end # describe 'is missing'

    describe 'contains no API Version data' do
      describe 'returns a Rack response with' do
        before do
          obj = described_class.new base_fixture_generator.app_fixture
          env = base_fixture_generator.env_fixture
          env['COMPONENT_DESCRIPTION'] = JSON.dump(NO_APIS)
          @response = obj.call env
        end

        it 'the status (first element) as 404 ("Not Found")' do
          expect(@response[0]).must_equal 404
        end

        # NOTE: `@response[2]` is a Rack::BodyProxy instance!
        it 'the body contains the correct message' do
          expected = 'Invalid value for COMPONENT_DESCRIPTION'
          expect(@response[2].body.join).must_equal expected
        end
      end # describe 'returns a Rack response with'
    end # describe 'contains no API Version data'

    describe 'contains a Base URL that is invalid because' do
      # rubocop:disable Security/MarshalLoad
      before do
        bad_sbu = 'http://v2.example.com:9876/foo'
        bad_api_version_data = Marshal.load(Marshal.dump(SINGLE_API))
        bad_api_version_data.dig(:api_versions, 'v2')[:base_url] = bad_sbu
        @obj = described_class.new base_fixture_generator.app_fixture
        @env = base_fixture_generator.env_fixture
        @env['COMPONENT_DESCRIPTION'] = JSON.dump(bad_api_version_data)
        @env['HTTP_ACCEPT'] = 'application/vnd.acme.apidemo.v2+json'
        @expected = 'Invalidly formatted base URL: ' + bad_sbu
      end
      # rubocop:enable Security/MarshalLoad

      it 'the finalising slash (/) is omitted' do
        begin
          @obj.call @env
          flunk 'Expected InvalidBaseUrlError was not raised'
        rescue Rack::ServiceApiVersioning::InvalidBaseUrlError => e
          expect(e.message).must_equal @expected
        end
      end # describe 'the finalising slash (/) is'

      it 'the fully-formed URL was not specified' do
        begin
          @obj.call @env
          flunk 'Expected InvalidBaseUrlError was not raised'
        rescue Rack::ServiceApiVersioning::InvalidBaseUrlError => e
          expect(e.message).must_equal @expected
        end
      end
    end # describe 'contains a Base URL that is invalid because'
  end # describe 'when called with a COMPONENT_DESCRIPTION value that'

  describe 'when the Target Service has a single API Version' do
    describe 'when the request supplies no "Accept" header' do
      describe 'the request is aborted with' do
        before do
          obj = described_class.new base_fixture_generator.app_fixture
          env = base_fixture_generator.env_fixture
          env['COMPONENT_DESCRIPTION'] = JSON.dump(SINGLE_API)
          @response = obj.call env
        end

        it 'an HTTP 406 status code' do
          expect(@response[0]).must_equal 406
        end

        it 'the message body reporting the only acceptable content type' do
          ctype = SINGLE_API[:api_versions]['v2'][:content_type]
          expected = %({"supported-media-types":"#{ctype}"})
          expect(@response[2].body.join).must_equal expected
        end
      end # describe 'the request is aborted with'
    end # describe 'when the request supplies no "Accept" header'

    describe 'when the request supplies an "Accept header" with' do
      describe 'a single content type that' do
        describe 'is an exact match for the available version' do
          before do
            header = 'application/vnd.acme.apidemo.v2+json'
            @api_version_data = fixtures.single_api_version_data(header)
          end

          it 'matches the correct Service Base URL' do
            expected = SINGLE_API.dig(:api_versions, 'v2', :base_url)
            expect(@api_version_data[:base_url]).must_equal expected
          end

          it 'has the correct Content Type' do
            expected = SINGLE_API.dig(:api_versions, 'v2', :content_type)
            expect(@api_version_data[:content_type]).must_equal expected
          end
        end # describe 'is an exact match for the available version'

        describe 'does not match the available API Version' do
          describe 'the request is aborted with' do
            before do
              header = 'application/vnd.acme.apidemo.v472+json'
              @response = fixtures.response_with_single_api(header)
            end

            it 'an HTTP 406 status code' do
              expect(@response[0]).must_equal 406
            end

            it 'the message body reporting the only acceptable content type' do
              ctype = SINGLE_API[:api_versions]['v2'][:content_type]
              expected = %({"supported-media-types":"#{ctype}"})
              expect(@response[2].body.join).must_equal expected
            end
          end # describe 'the request is aborted with'
        end # describe 'does not match the available API Version'
      end # describe 'a single content type that'

      describe 'multiple content types that' do
        describe 'includes a match for the available API Version' do
          it 'matches the content type in both header and list' do
            header = 'application/vnd.acme.apidemo.v3+json, ' \
                     'application/vnd.acme.apidemo.v2+json'
            api_version_data = fixtures.single_api_version_data(header)

            expected = SINGLE_API.dig(:api_versions, 'v2', :base_url)
            expect(api_version_data[:base_url]).must_equal expected
          end
        end # describe 'includes a match for the available API Version'

        describe 'does not match the available API Version' do
          describe 'the request is aborted with' do
            it 'an HTTP 406 status code' do
              header = 'application/vnd.acme.apidemo.v4+json, ' \
                       'application/vnd.acme.apidemo.v3+json'
              response = fixtures.response_with_single_api(header)

              expect(response[0]).must_equal 406
            end

            it 'the message body reporting the only acceptable content type' do
              header = 'application/vnd.acme.apidemo.v4+json, ' \
                       'application/vnd.acme.apidemo.v3+json'
              response = fixtures.response_with_single_api(header)

              ctype = SINGLE_API[:api_versions]['v2'][:content_type]
              expected = %({"supported-media-types":"#{ctype}"})
              expect(response[2].body.join).must_equal expected
            end
          end # describe 'the request is aborted with'
        end # describe 'does not match the available API Version'
      end # describe 'multiple content types that'
    end # describe 'when the request supplies an "Accept header" with'
  end # describe 'when the Target Service has a single API Version'

  describe 'where the Target Service has multlple API Versions' do
    describe 'when the request supplies no "Accept" header' do
      describe 'the request is aborted with' do
        before do
          obj = described_class.new base_fixture_generator.app_fixture
          env = base_fixture_generator.env_fixture
          env['COMPONENT_DESCRIPTION'] = JSON.dump(MULTIPLE_APIS)
          @response = obj.call env
        end

        it 'an HTTP 406 status code' do
          expect(@response[0]).must_equal 406
        end

        it 'the message body reporting the only acceptable content type' do
          ctype = [MULTIPLE_APIS[:api_versions]['v2'][:content_type],
                   MULTIPLE_APIS[:api_versions]['v3'][:content_type]].join(', ')
          expected = %({"supported-media-types":"#{ctype}"})
          expect(@response[2].body.join).must_equal expected
        end
      end # describe 'the request is aborted with'
    end # describe 'when the request supplies no "Accept" header'

    describe 'when the request supplies an "Accept header" with' do
      describe 'a single content type that' do
        describe 'is an exact match for the available version' do
          it 'matches the correct content type' do
            header = 'application/vnd.acme.apidemo.v2+json'
            api_version_data = fixtures.multiple_api_version_data(header)

            expected = MULTIPLE_APIS.dig(:api_versions, 'v2', :base_url)
            expect(api_version_data[:base_url]).must_equal expected
          end
        end # describe 'is an exact match for the available version'

        describe 'does not match the available API Version' do
          describe 'the request is aborted with' do
            it 'an HTTP 406 status code' do
              header = 'application/vnd.acme.apidemo.v472+json'
              response = fixtures.response_with_multiple_apis(header)

              expect(response[0]).must_equal 406
            end

            it 'the message body reporting only acceptable content type' do
              header = 'application/vnd.acme.apidemo.v472+json'
              response = fixtures.response_with_multiple_apis(header)

              ctype = [MULTIPLE_APIS[:api_versions]['v2'][:content_type],
                       MULTIPLE_APIS[:api_versions]['v3'][:content_type]]
                      .join(', ')
              expected = %({"supported-media-types":"#{ctype}"})
              expect(response[2].body.join).must_equal expected
            end
          end # describe 'the request is aborted with'
        end # describe 'does not match the available API Version'
      end # describe 'a single content type that'

      describe 'multiple content types that' do
        describe 'do not specify any "q" values that' do
          describe 'includes a match for the available API Version' do
            it 'has the correct :base_url entry' do
              header = 'application/vnd.acme.apidemo.v3+json, ' \
                       'application/vnd.acme.apidemo.v2+json'
              api_version_data = fixtures.multiple_api_version_data(header)
              expected = MULTIPLE_APIS.dig(:api_versions, 'v2', :base_url)
              expect(api_version_data[:base_url]).must_equal expected
            end
          end # describe 'includes a match for the available API Version'

          describe 'does not match the available API Version' do
            describe 'the request is aborted with' do
              it 'an HTTP 406 status code' do
                header = 'application/vnd.acme.apidemo.v5+json, ' \
                         'application/vnd.acme.apidemo.v4+json'
                response = fixtures.response_with_multiple_apis(header)

                expect(response[0]).must_equal 406
              end

              it 'the message body reporting only acceptable content type' do
                header = 'application/vnd.acme.apidemo.v5+json, ' \
                         'application/vnd.acme.apidemo.v4+json'
                response = fixtures.response_with_multiple_apis(header)

                ctype = [MULTIPLE_APIS[:api_versions]['v2'][:content_type],
                         MULTIPLE_APIS[:api_versions]['v3'][:content_type]]
                        .join(', ')
                expected = %({"supported-media-types":"#{ctype}"})
                expect(response[2].body.join).must_equal expected
              end
            end # describe 'the request is aborted with'
          end # describe 'does not match the available API Version'
        end # describe 'do not specify any "q" values that'

        describe 'specify varying "q" values that have' do
          describe 'a single content type matching available API Versions' do
            it 'matches the entry which occurs in the content-type list' do
              header = 'application/vnd.acme.apidemo.v3+json, ' \
                       'application/vnd.acme.apidemo.v2+json'
              api_version_data = fixtures.multiple_api_version_data(header)

              expected = MULTIPLE_APIS.dig(:api_versions, 'v2', :base_url)
              expect(api_version_data[:base_url]).must_equal expected
            end
          end # describe 'a single content type matching available API Versions'

          describe 'multiple content types matching "Accept" header entries' do
            describe 'having different "q" values' do
              it 'matches the entry with the highest "q" value' do
                header = 'application/vnd.acme.apidemo.v2+json;q=0.5, ' \
                         'application/vnd.acme.apidemo.v3+json;q=0.9'
                api_version_data = fixtures.multiple_api_version_data(header)

                expected = MULTIPLE_APIS.dig(:api_versions, 'v3', :base_url)
                expect(api_version_data[:base_url]).must_equal expected
              end
            end # describe 'having different "q" values'

            describe 'where multiple matches have the same "q" value' do
              it 'matches the entry occurring first in the content-type list' do
                header = 'application/vnd.acme.apidemo.v2+json;q=0.5, ' \
                          'application/vnd.acme.apidemo.v3+json;q=0.5'
                api_version_data = fixtures.multiple_api_version_data(header)

                expected = MULTIPLE_APIS.dig(:api_versions, 'v3', :base_url)
                expect(api_version_data[:base_url]).must_equal expected
              end
            end # describe 'where multiple matches have the same "q" value'
          end # describe 'multiple ... types matching "Accept" header entries'
        end # describe 'specify varying "q" values that have'
      end # describe 'multiple content types that'
    end # describe 'when the request supplies an "Accept header" with'
  end # describe 'where the Target Service has multlple API Versions'
end
