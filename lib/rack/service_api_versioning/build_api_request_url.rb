# frozen_string_literal: true

require 'uri'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Given an AVIDA SBU, an actual fully-formed request URL, and the SBU for
    # the correct API Version implementation, hands back the as-decorated URL to
    # make the request against the indicated API Version.
    class BuildApiRequestUrl
      def self.call(api_version_sbu:, avida_sbu:, request_url:)
        new(api_version_sbu, avida_sbu, request_url).call
      end

      def call
        default_for_bad_fragment || version_specific_url
      end

      protected

      def initialize(api_version_sbu, avida_sbu, request_url)
        @api_version_sbu = URI.parse(api_version_sbu)
        @avida_sbu = URI.parse(avida_sbu)
        @request_url = URI.parse(request_url)
        self
      end

      private

      attr_reader :api_version_sbu, :avida_sbu, :request_url

      def default_for_bad_fragment
        return request_url.to_s if Internals.bad_fragment?(fragment)
      end

      def fragment
        request_url.route_from(avida_sbu)
      end

      def version_specific_url
        api_version_sbu.merge(fragment).to_s
      end

      # Stateless methods
      module Internals
        def self.bad_fragment?(fragment)
          fragment.host || fragment.path[0..1] == '..'
        end
      end
    end # class Rack::ServiceApiVersioning::BuildApiRequestUrl
  end
end
