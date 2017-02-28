# frozen_string_literal: true

require 'test_helper'

require 'rack/service_api_versioning/accept_content_type_selector'

describe 'Rack::ServiceApiVersioning::AcceptContentTypeSelector' do
  let(:described_class) do
    Rack::ServiceApiVersioning::AcceptContentTypeSelector
  end
  let(:app) do
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
  let(:env) { { 'HTTP_ACCEPT' => nil } }
  let(:obj) { described_class.new app }
  let(:response) { obj.call env }

  describe 'when called with a COMPONENT_DESCRIPTION value that' do
    describe 'is missing' do
      describe 'returns a Rack response with' do
        it 'the status (first element) as 400 ("Bad Request")' do
          expect(response[0]).must_equal 400
        end

        # NOTE: `response[2]` is a Rack::BodyProxy instance!
        it 'the body contains the correct message' do
          expected = 'Invalid value for COMPONENT_DESCRIPTION'
          expect(response[2].body.join).must_equal expected
        end
      end # describe 'returns a Rack response with'
    end # describe 'is missing'

    describe 'contains no API Version data' do
      NO_APIS = { name: 'apidemo',
                  description: 'The API Demonstration Component Service',
                  api_versions: {} }.freeze

      before { env['COMPONENT_DESCRIPTION'] = JSON.dump(NO_APIS) }

      describe 'returns a Rack response with' do
        it 'the status (first element) as 404 ("Not Found")' do
          expect(response[0]).must_equal 404
        end

        # NOTE: `response[2]` is a Rack::BodyProxy instance!
        it 'the body contains the correct message' do
          expected = 'Invalid value for COMPONENT_DESCRIPTION'
          expect(response[2].body.join).must_equal expected
        end
      end # describe 'returns a Rack response with'
    end # describe 'contains no API Version data'
  end # describe 'when called with a COMPONENT_DESCRIPTION value that'

  describe 'when the Target Service has a single API Version' do
    SINGLE_API = { name: 'apidemo',
                   description: 'The API Demonstration Component Service',
                   api_versions: {
                     'v2' => {
                       base_url: 'http://v2.example.com:9876/',
                       content_type: 'application/vnd.acme.apidemo.v2+json',
                       restricted: false,
                       deprecated: false
                     }
                   } }.freeze

    let(:api_version_str) { app.env['COMPONENT_API_VERSION_DATA'].to_s }
    let(:api_version_data) do
      JSON.parse(api_version_str, symbolize_names: true)
    end

    before do
      env['COMPONENT_DESCRIPTION'] = JSON.dump(SINGLE_API)
      env['HTTP_ACCEPT'] = accept_header
      _ = response
    end

    describe 'when the request supplies no "Accept" header' do
      let(:accept_header) { nil }

      describe 'the request is aborted with' do
        it 'an HTTP 406 status code' do
          expect(response[0]).must_equal 406
        end

        it 'the message body reporting the only acceptable content type' do
          ctype = SINGLE_API[:api_versions]['v2'][:content_type]
          expected = %({"supported-media-types":"#{ctype}"})
          expect(response[2].body.join).must_equal expected
        end
      end # describe 'the request is aborted with'
    end # describe 'when the request supplies no "Accept" header'

    describe 'when the request supplies an "Accept header" with' do
      describe 'a single content type that' do
        describe 'is an exact match for the available version' do
          let(:accept_header) do
            'application/vnd.acme.apidemo.v2+json'
          end

          it 'matches the correct Service Base URL' do
            expected = SINGLE_API.dig(:api_versions, 'v2', :base_url)
            expect(api_version_data[:base_url]).must_equal expected
          end

          it 'has the correct Content Type' do
            expected = SINGLE_API.dig(:api_versions, 'v2', :content_type)
            expect(api_version_data[:content_type]).must_equal expected
          end
        end # describe 'is an exact match for the available version'

        describe 'does not match the available API Version' do
          let(:accept_header) do
            'application/vnd.acme.apidemo.v472+json'
          end

          describe 'the request is aborted with' do
            it 'an HTTP 406 status code' do
              expect(response[0]).must_equal 406
            end

            it 'the message body reporting the only acceptable content type' do
              ctype = SINGLE_API[:api_versions]['v2'][:content_type]
              expected = %({"supported-media-types":"#{ctype}"})
              expect(response[2].body.join).must_equal expected
            end
          end # describe 'the request is aborted with'
        end # describe 'does not match the available API Version'
      end # describe 'a single content type that'

      describe 'multiple content types that' do
        describe 'includes a match for the available API Version' do
          let(:accept_header) do
            'application/vnd.acme.apidemo.v3+json, ' \
            'application/vnd.acme.apidemo.v2+json'
          end

          it 'matches the content type in both header and list' do
            expected = SINGLE_API.dig(:api_versions, 'v2', :base_url)
            expect(api_version_data[:base_url]).must_equal expected
          end
        end # describe 'includes a match for the available API Version'

        describe 'does not match the available API Version' do
          let(:accept_header) do
            'application/vnd.acme.apidemo.v4+json, ' \
            'application/vnd.acme.apidemo.v3+json'
          end

          describe 'the request is aborted with' do
            it 'an HTTP 406 status code' do
              expect(response[0]).must_equal 406
            end

            it 'the message body reporting the only acceptable content type' do
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
    MULTIPLE_APIS = { name: 'apidemo',
                      description: 'The API Demonstration Component Service',
                      api_versions: {
                        'v2' => {
                          base_url: 'http://v2.example.com:9876/',
                          content_type: 'application/' \
                                        'vnd.acme.apidemo.v2+json',
                          restricted: false,
                          deprecated: false
                        },
                        'v3' => {
                          base_url: 'http://v3.example.org/',
                          content_type: 'application/' \
                                        'vnd.acme.apidemo.v3+json',
                          restricted: false,
                          deprecated: false
                        }
                      } }.freeze

    let(:api_version_str) { app.env['COMPONENT_API_VERSION_DATA'].to_s }
    let(:api_version_data) do
      JSON.parse(api_version_str, symbolize_names: true)
    end

    before do
      env['COMPONENT_DESCRIPTION'] = JSON.dump(MULTIPLE_APIS)
      env['HTTP_ACCEPT'] = accept_header
      _ = response
    end

    describe 'when the request supplies no "Accept" header' do
      let(:accept_header) { nil }

      describe 'the request is aborted with' do
        it 'an HTTP 406 status code' do
          expect(response[0]).must_equal 406
        end

        it 'the message body reporting the only acceptable content type' do
          ctype = [MULTIPLE_APIS[:api_versions]['v2'][:content_type],
                   MULTIPLE_APIS[:api_versions]['v3'][:content_type]].join(', ')
          expected = %({"supported-media-types":"#{ctype}"})
          expect(response[2].body.join).must_equal expected
        end
      end # describe 'the request is aborted with'
    end # describe 'when the request supplies no "Accept" header'

    describe 'when the request supplies an "Accept header" with' do
      describe 'a single content type that' do
        describe 'is an exact match for the available version' do
          let(:accept_header) do
            'application/vnd.acme.apidemo.v2+json'
          end

          it 'matches the correct content type' do
            expected = SINGLE_API.dig(:api_versions, 'v2', :base_url)
            expect(api_version_data[:base_url]).must_equal expected
          end
        end # describe 'is an exact match for the available version'

        describe 'does not match the available API Version' do
          let(:accept_header) do
            'application/vnd.acme.apidemo.v472+json'
          end

          describe 'the request is aborted with' do
            it 'an HTTP 406 status code' do
              expect(response[0]).must_equal 406
            end

            it 'the message body reporting only acceptable content type' do
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
            let(:accept_header) do
              'application/vnd.acme.apidemo.v3+json, ' \
              'application/vnd.acme.apidemo.v2+json'
            end

            it 'has the correct :base_url entry' do
              expected = MULTIPLE_APIS.dig(:api_versions, 'v2', :base_url)
              expect(api_version_data[:base_url]).must_equal expected
            end
          end # describe 'includes a match for the available API Version'

          describe 'does not match the available API Version' do
            let(:accept_header) do
              'application/vnd.acme.apidemo.v5+json, ' \
              'application/vnd.acme.apidemo.v4+json'
            end

            describe 'the request is aborted with' do
              it 'an HTTP 406 status code' do
                expect(response[0]).must_equal 406
              end

              it 'the message body reporting only acceptable content type' do
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
            let(:accept_header) do
              'application/vnd.acme.apidemo.v2+json;q=0.5, ' \
              'application/vnd.acme.apidemo.v1+json;q=0.9'
            end

            it 'matches the entry which occurs in the content-type list' do
              expected = MULTIPLE_APIS.dig(:api_versions, 'v2', :base_url)
              expect(api_version_data[:base_url]).must_equal expected
            end
          end # describe 'a single content type matching available API Versions'

          describe 'multiple content types matching "Accept" header entries' do
            describe 'having different "q" values' do
              let(:accept_header) do
                'application/vnd.acme.apidemo.v2+json;q=0.5, ' \
                'application/vnd.acme.apidemo.v3+json;q=0.9'
              end

              it 'matches the entry with the highest "q" value' do
                expected = MULTIPLE_APIS.dig(:api_versions, 'v3', :base_url)
                expect(api_version_data[:base_url]).must_equal expected
              end
            end # describe 'having different "q" values'

            describe 'where multiple matches have the same "q" value' do
              let(:accept_header) do
                'application/vnd.acme.apidemo.v2+json;q=0.5, ' \
                'application/vnd.acme.apidemo.v3+json;q=0.5'
              end

              it 'matches the entry occurring first in the content-type list' do
                expected = MULTIPLE_APIS.dig(:api_versions, 'v3', :base_url)
                expect(api_version_data[:base_url]).must_equal expected
                # expect(api_version_data[:base_url]).must_equal expected
              end
            end # describe 'where multiple matches have the same "q" value'
          end # describe 'multiple ... types matching "Accept" header entries'
        end # describe 'specify varying "q" values that have'
      end # describe 'multiple content types that'
    end # describe 'when the request supplies an "Accept header" with'
  end # describe 'where the Target Service has multlple API Versions'
end
