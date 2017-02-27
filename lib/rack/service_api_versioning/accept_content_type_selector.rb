# frozen_string_literal: true

require_relative './encoded_api_version_data'
require_relative './input_env'
require_relative './input_is_invalid'
require_relative './match_header_against_api_versions'
require_relative './report_no_matching_version'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Select API Version of Component Service based on HTTP `Accept` header.
    class AcceptContentTypeSelector
      def initialize(app)
        @app = app
        @env = nil
        @input = nil
        self
      end

      def call(env)
        @env = env
        @input = InputEnv.new env
        match_request_from_header
      end

      private

      attr_reader :app, :env, :input

      def add_component_api_version_data(version)
        env['COMPONENT_API_VERSION_DATA'] = encoded_data_for(version)
        self
      end

      def api_versions
        input.data[:api_versions]
      end

      def encoded_data_for(api_version)
        EncodedApiVersionData.call(api_version: api_version, data: input.data)
      end

      def if_component_apis_defined(&_)
        InputIsInvalid.call(input) || yield
      end

      def if_requested_api_version_found
        best_version = specified_api_version
        return report_no_matching_api_versions unless best_version
        yield best_version
      end

      def match_request_from_header
        if_component_apis_defined do
          if_requested_api_version_found do |matching_version|
            use_api_version(matching_version)
          end
        end
      end

      def report_no_matching_api_versions
        ReportNoMatchingVersion.call api_versions: api_versions
      end

      def specified_api_version
        MatchHeaderAgainstApiVersions.call(accept_header: env['HTTP_ACCEPT'],
                                           api_versions: api_versions)
      end

      def use_api_version(matching_version)
        add_component_api_version_data(matching_version)
        app.call env
      end
    end # class AcceptContentTypeSelector
  end
end
