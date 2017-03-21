# frozen_string_literal: true

require 'prolog/dry_types'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Builds an API Version data hash and encodes as JSON, for injection into a
    # Rack environment, normally with the key "COMPONENT_API_VERSION_DATA".
    class EncodedApiVersionData
      # Immutable, structured data type for returned version data.
      class ReturnData < Dry::Struct::Value
        SBU_FMT = %r{\A\w+?://.+?/\z}
        private_constant :SBU_FMT

        constructor_type :strict_with_defaults

        attribute :api_version, Types::Coercible::String
        attribute :base_url, Types::Strict::String.constrained(format: SBU_FMT)
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
    end # class EncodedApiVersionData
  end
end
