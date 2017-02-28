# frozen_string_literal: true

require 'rack'
require 'rack/response'

require_relative './env_items'
require_relative './list_methods_in_module'
require_relative './rack_env_for_uri'

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

      def api_version_base_uri
        URI.parse(api_version_data[:base_url])
      end

      def api_version
        api_version_data[:api_version]
      end

      def api_version_data
        JSON.parse(env['COMPONENT_API_VERSION_DATA'], symbolize_names: true)
      end

      def headers
        { 'API-Version' => api_version,
          'Location' => location_header }
      end

      def location_header
        uri = api_version_base_uri
        url_from_tweaked_env(uri)
      end

      def response
        Rack::Response.new(response_body, DEFAULT_STATUS, headers).finish
      end

      def response_body
        '<p>Please resend the request to ' \
        "<a href='#{location_header}'>this endpoint</a> without caching it.</p>"
      end

      def tweak_env_for(uri)
        @env.merge! RackEnvForUri.call(uri)
      end

      def url_from_tweaked_env(uri)
        actual_env = tweak_env_for(uri)
        req = Rack::Request.new(actual_env)
        req.url
      end
    end # class Rack::ServiceApiVersioning::ApiVersionRedirector
  end
end
