# frozen_string_literal: true

require 'prolog/dry_types'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Builds an API Version data hash and encodes as JSON, for injection into a
    # Rack environment, normally with the key "COMPONENT_API_VERSION_DATA".
    class EncodedApiVersionData
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
    end # class EncodedApiVersionData
  end
end
