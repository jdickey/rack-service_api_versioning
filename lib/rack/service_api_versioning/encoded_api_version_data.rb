# frozen_string_literal: true

require 'forwardable'

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
        @data_obj = InputData.new api_version: api_version,
                                  input_data: input_data
        self
      end

      private

      extend Forwardable
      def_delegators :@data_obj, :base_url, :name, :vendor_org

      attr_reader :api_version

      def version_data
        ReturnData.new api_version: api_version, base_url: base_url, name: name,
                       vendor_org: vendor_org
      end

      # Unpacks relevant attributes from passed-in input data
      class InputData < Dry::Struct::Value
        attribute :api_version, Types::Strict::Symbol
        attribute :input_data, Types::Hash

        def base_url
          version_data[:base_url]
        end

        def name
          input_data[:name]
        end

        def vendor_org
          content_type_parts[VENDOR_ORG_INDEX]
        end

        private

        # Index 0 will be `application/vnd`; index 1 the org name (eg, `acme`)
        VENDOR_ORG_INDEX = 1
        private_constant :VENDOR_ORG_INDEX

        def content_type_parts
          version_data[:content_type].split('.')
        end

        def version_data
          input_data[:api_versions][api_version]
        end
      end # class EncodedApiVersionData::InputData
      private_constant :InputData

      # Immutable, structured data type for returned version data.
      class ReturnData < Dry::Struct::Value
        constructor_type :strict_with_defaults

        attribute :api_version, Types::Coercible::String
        attribute :base_url, Types::Strict::String
        attribute :name, Types::Strict::String
        attribute :deprecated, Types::Strict::Bool.default(false)
        attribute :restricted, Types::Strict::Bool.default(false)
        attribute :vendor_org, Types::Strict::String

        def content_type
          content_parts.join('.') + '+json'
        end

        def to_hash
          super.merge(content_type: content_type)
               .reject { |key, _| key == :vendor_org }
        end
        alias to_h to_hash

        private

        def content_parts
          ['application/vnd', vendor_org, name, api_version.to_s]
        end
      end # class EncodedApiVersionData::ReturnData
      private_constant :ReturnData
    end # class EncodedApiVersionData
  end
end
