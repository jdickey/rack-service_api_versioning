# frozen_string_literal: true

require 'rack'
require 'rack/utils'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Matches content of HTTP Accept header against presently-available API
    # Versions. Returns either a symbolic value (e.g., `:v2`) on success or
    # `nil` on failure.
    class MatchHeaderAgainstApiVersions
      def self.call(accept_header:, api_versions:)
        new(accept_header, api_versions).call
      end

      def call
        best_match
      end

      protected

      def initialize(accept_header, api_versions)
        @accept_header = accept_header
        @api_versions = api_versions
        self
      end

      private

      attr_reader :accept_header, :api_versions

      def all_matches
        api_versions.select { |_, version| best_type?(version) }
      end

      def all_types
        api_versions.values.map { |version| version[:content_type] }
      end

      def best_match
        all_matches.keys.first
      end

      def best_type
        Rack::Utils.best_q_match(accept_header, all_types)
      end

      def best_type?(version)
        version[:content_type] == best_type
      end
    end # class Rack::ServiceApiVersioning::MatchHeaderAgainstApiVersions
  end
end
