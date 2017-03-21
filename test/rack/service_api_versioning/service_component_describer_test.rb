# frozen_string_literal: true

require 'test_helper'
require 'uri'

require 'rack/service_api_versioning/service_component_describer'

SCD_DUMMY_REPO_DATA = {
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
}.freeze

describe 'Rack::ServiceApiVersioning::ServiceComponentDescriber' do
  let(:described_class) do
    Rack::ServiceApiVersioning::ServiceComponentDescriber
  end
  let(:app) do
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
  let(:env) { { 'OTHER_HEADER': 'OTHER_VALUE' } }
  let(:obj) { described_class.new app, init_params }

  describe 'when called with an explicit :repository parameter' do
    let(:actual) { app.env['COMPONENT_DESCRIPTION'] }
    let(:actual_obj) { JSON.parse(actual, symbolize_names: true) }
    let(:init_params) do
      { repository: repository, service_name: service_name }
    end
    let(:repository) do
      Class.new do
        def initialize
          @data = SCD_DUMMY_REPO_DATA
          self
        end

        def find(**params)
          match = @data[params[:name].to_sym]
          [match].compact
        end
      end.new
    end

    describe 'when called with a "service_name" parameter that' do
      let(:response) { obj.call env }

      before { _ = response }

      describe 'has an entry in the supplied repository that' do
        let(:service_name) { 'apidemo' }

        it 'sets env["COMPONENT_DESCRIPTION"] for the middleware stack' do
          expect(actual).wont_be :nil?
        end

        describe 'sets env["COMPONENT_DESCRIPTION"] so that its' do
          let(:api_versions) { actual_obj[:api_versions] }

          it ':name attribute has the service name' do
            expect(actual_obj[:name]).must_equal service_name
          end

          it ':api_versions attribute has at least one item' do
            expect(api_versions.count).must_be :>, 0
          end

          describe ':api_versions attribute has entries such that each' do
            it 'has a unique key value' do
              expected = api_versions.keys.uniq.count
              expect(api_versions.keys.count).must_equal expected
            end

            describe 'has a :base_url attribute with' do
              it 'a valid URL' do
                urls = api_versions.values.map { |v| URI.parse(v[:base_url]) }
                expect(urls).wont_be :empty?
              end

              # Yes, too many intermediate temporary variables. This uncovers a
              # code smell; we have a Demeter violation since getting to the
              # `expected_url` value (let alone `expected_port`) overflows the
              # line-length limit enforced by RuboCop.
              it 'the correct port number if non-default port specified' do
                actual_url = api_versions.values.first[:base_url]
                actual_port = URI.parse(actual_url).port
                expected_api_versions = SCD_DUMMY_REPO_DATA.dig(:apidemo,
                                                                :api_versions)
                expected_url = expected_api_versions.values.last[:base_url]
                expected_port = %r{:(\d+?)/$}.match(expected_url)[1].to_i
                expect(actual_port).must_equal expected_port
              end
            end # describe 'has a :base_url attribute with'

            it 'has a :deprecated attribute with a value of false' do
              any_deprecated = api_versions.values.inject(false) do |acc, entry|
                acc || entry[:deprecated]
              end
              expect(any_deprecated).must_equal false
            end

            it 'has a :restricted attribute with a value of false' do
              any_restricted = api_versions.values.inject(false) do |acc, entry|
                acc || entry[:restricted]
              end
              expect(any_restricted).must_equal false
            end
          end # describe ':api_versions attribute has entries such that each'
        end # describe 'sets env["COMPONENT_DESCRIPTION"] so that its'
      end # describe 'has an entry in the supplied repository that'

      describe 'has NO entry in the supplied repository that' do
        let(:service_name) { 'nonexistent' }

        describe 'returns a Rack response with' do
          it 'the status (first element) as 404 ("Not Found")' do
            expect(response[0]).must_equal 404
          end

          # NOTE: `response[2]` is a Rack::BodyProxy instance!
          it 'the body contains the correct message' do
            expected = %(Service not found: "#{service_name}")
            expect(response[2].body.join).must_equal expected
          end
        end # describe 'returns a Rack response with'
      end # describe 'has NO entry in the supplied repository that' do
    end # describe 'when called with a "service_name" parameter that'
  end # describe 'when called with an explicit :repository parameter'
end
