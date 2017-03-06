# frozen_string_literal: true

require 'addressable'
require 'rack'
require 'rack/response'

require_relative './redirect_url_for'

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

      def headers
        { 'API-Version' => api_version,
          'Location' => location_header }
      end

      def location_header
        RedirectUrlFor.call(env: env, new_base_url: new_base_uri.to_s)
      end

      def new_base_uri
        Addressable::URI.parse(api_version_data[:base_url])
      end

      def response
        Rack::Response.new(response_body, DEFAULT_STATUS, headers).finish
      end

      def response_body
        '<p>Please resend the request to ' \
        "<a href='#{location_header}'>this endpoint</a> without caching it.</p>"
      end
    end # class Rack::ServiceApiVersioning::ApiVersionRedirector
  end
end
