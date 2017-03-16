# frozen_string_literal: true

require 'rack'
require 'rack/response'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Build redirect URI from original request URI and API Version SBU.
    class BuildRedirectLocationUri
      def self.call(api_version_base_uri:, request_uri:)
        new(api_version_base_uri, request_uri).call
      end

      def call
        update_path
        update_query
        uri_for_redirect
      end

      protected

      def initialize(api_version_base_uri, request_uri)
        @new_base_uri_parts = api_version_base_uri.to_hash
        @request_uri = request_uri
        self
      end

      private

      attr_reader :new_base_uri_parts, :request_uri

      def combined_path_str
        new_base_uri_parts[:path] + request_uri.path
      end

      def path_str
        combined_path_str.sub('//', '/')
      end

      def update_path
        new_base_uri_parts[:path] = path_str
      end

      def update_query
        new_base_uri_parts[:query] = request_uri.query
      end

      def uri_for_redirect
        Addressable::URI.new(new_base_uri_parts)
      end
    end # class Rack::ServiceApiVersioning::BuildRedirectLocationUri
  end
end
