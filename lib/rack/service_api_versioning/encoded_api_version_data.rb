# frozen_string_literal: true

require 'forwardable'

require 'prolog/dry_types'

require_relative './encoded_api_version_data/input_data'
require_relative './encoded_api_version_data/return_data'
require_relative './encoded_api_version_data/invalid_base_url_error'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Builds an API Version data hash and encodes as JSON, for injection into a
    # Rack environment, normally with the key "COMPONENT_API_VERSION_DATA".
    class EncodedApiVersionData
      def self.call(api_version:, data:)
        new(api_version, data).call
      end

      def call
        JSON.dump(version_data.to_hash)
      end

      protected

      def initialize(api_version, input_data)
        @api_version = api_version.to_sym
        @data_obj = InputData.new api_version: api_version,
                                  input_data: input_data
        self
      end

      private

      extend Forwardable
      def_delegators :@data_obj, :base_url, :name, :vendor_org

      attr_reader :api_version

      def raise_invalid_base_url_error(original_error)
        raise InvalidBaseUrlError.new base_url, original_error
      end

      def return_data_params
        { api_version: api_version, base_url: base_url, name: name,
          vendor_org: vendor_org }
      end

      def version_data
        ReturnData.new return_data_params
      rescue Dry::Struct::Error => original_error
        raise_invalid_base_url_error original_error
      end

      private_constant :InputData
      private_constant :ReturnData
    end # class EncodedApiVersionData
  end
end
