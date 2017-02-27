# frozen_string_literal: true

require_relative './http_error_response'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Builds Rack::Response to halt request execution with an HTTP status code
    # of 406 ("Not Acceptable") when no presently available API Version has been
    # specified in an HTTP `Accept` header.
    class ReportNoMatchingVersion < HttpErrorResponse
      def self.call(api_versions:, code: 406)
        new(code, Internals.message_data(api_versions)).call
      end

      # Stateless methods.
      module Internals
        def self.all_types_as_string(api_versions, separator = ', ')
          all_types = api_versions.values.map do |version|
            version[:content_type]
          end
          all_types.join(separator)
        end

        def self.message_data(api_versions)
          types = all_types_as_string(api_versions)
          JSON.dump('supported-media-types': types)
        end
      end
      private_constant :Internals
    end # class Rack::ServiceApiVersioning::ReportNoMatchingVersion
  end
end
