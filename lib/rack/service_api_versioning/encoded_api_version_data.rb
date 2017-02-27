# frozen_string_literal: true

require 'prolog/dry_types'

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
        @base_url = input_data.dig(:api_versions, @api_version, :base_url)
        @name = input_data[:name]
        self
      end

      private

      attr_reader :api_version, :base_url, :name

      def version_data
        ReturnData.new api_version: api_version, base_url: base_url, name: name
      end

      # Immutable, structured data type for returned version data.
      class ReturnData < Dry::Struct::Value
        constructor_type :strict_with_defaults

        attribute :api_version, Types::Coercible::String
        attribute :base_url, Types::Strict::String
        attribute :name, Types::Strict::String
        attribute :deprecated, Types::Strict::Bool.default(false)
        attribute :restricted, Types::Strict::Bool.default(false)

        def content_type
          ['application/vnd.conversagence', name, api_version.to_s].join('.')
        end

        def to_hash
          super.merge(content_type: content_type)
        end
        alias to_h to_hash
      end # class EncodedApiVersionData::ReturnData
      private_constant :ReturnData
    end # class EncodedApiVersionData
  end
end
