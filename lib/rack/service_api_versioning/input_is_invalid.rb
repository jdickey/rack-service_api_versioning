# frozen_string_literal: true

require_relative './report_invalid_description'
require_relative './report_not_found'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Validates input for AcceptContentTypeSelector. If input passes checks,
    # returns `nil`. Returns a Rack::Response instance if any validation step
    # failed.
    class InputIsInvalid
      def self.call(input)
        Internals.verify_input(input) || Internals.verify_api_versions(input)
      end

      # Stateless methods
      module Internals
        def self._api_versions?(input)
          input.data[:api_versions].any?
        end

        def self.verify_api_versions(input)
          return ReportNotFound.call unless _api_versions?(input)
          nil
        end

        def self.verify_input(input)
          return ReportInvalidDescription.call unless input.any?
          nil
        end
      end
    end # class Rack::ServiceApiVersioning::InputIsInvalid
  end
end
