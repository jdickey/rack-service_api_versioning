# frozen_string_literal: true

require 'rack'
require 'rack/response'

require_relative './build_redirect_location_uri'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Build redirect URI from data in `env`
    class BuildRedirectUriFromEnv
      def self.call(env)
        new(env).call
      end

      def call
        location_uri_from(request_uri).to_s
      end

      protected

      def initialize(env)
        @env = env
        self
      end

      private

      attr_reader :env

      def api_version_base_uri
        Addressable::URI.parse(api_version_data[:base_url])
      end

      def api_version_data
        JSON.parse(env['COMPONENT_API_VERSION_DATA'], symbolize_names: true)
      end

      def location_uri_from(request_uri)
        params = { api_version_base_uri: api_version_base_uri,
                   request_uri: request_uri }
        BuildRedirectLocationUri.call params
      end

      def request_uri
        request_str = Rack::Request.new(env).url
        Addressable::URI.parse(request_str)
      end
    end # class BuildRedirectUriFromEnv
  end
end
