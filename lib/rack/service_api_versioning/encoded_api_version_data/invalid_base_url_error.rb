# frozen_string_literal: true

require 'prolog/dry_types'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Exception wrapper class for invalid return data from
    # `EncodedApiVersionData#version_data` due to a bad SBU being specified.
    # Not nested within that class to avoid leaking unnecessary implementation
    # detail, *even though* this class is (presently) only used by that class.
    class InvalidBaseUrlError < RuntimeError
      def initialize(base_url, original_error)
        @original_error = original_error
        super "Invalidly formatted base URL: #{base_url}"
      end

      attr_reader :original_error
    end # class InvalidBaseUrlError
  end
end
