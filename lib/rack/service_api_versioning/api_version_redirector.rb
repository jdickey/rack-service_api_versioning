# frozen_string_literal: true

require 'rack'
require 'rack/response'

require_relative './build_redirect_uri_from_env'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Returns an HTTP 302 response with cleaned-up environment and `Location`
    # header.
    class ApiVersionRedirector
      def initialize(app)
        @app = app
        @env = nil
        self
      end

      def call(env)
        @env = env
        response
      end

      private

      DEFAULT_STATUS = 307
      private_constant :DEFAULT_STATUS

      attr_reader :app, :env

      def api_version
        api_version_data[:api_version]
      end

      def api_version_data
        JSON.parse(env['COMPONENT_API_VERSION_DATA'], symbolize_names: true)
      end

      def body
        'Please resend the request to ' \
          "<a href=\"#{location}\">#{location}</a>" \
          ' without caching it.'
      end

      def headers
        { 'API-Version' => api_version, 'Location' => location }
      end

      def location
        BuildRedirectUriFromEnv.call(env)
      end

      def response
        Rack::Response.new(body, DEFAULT_STATUS, headers).finish
      end
    end # class Rack::ServiceApiVersioning::ApiVersionRedirector
  end
end
