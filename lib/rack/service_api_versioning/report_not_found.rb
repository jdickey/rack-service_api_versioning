# frozen_string_literal: true

require_relative './http_error_response'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Builds Rack::Response to halt request execution, responding with a 404.
    class ReportNotFound < HttpErrorResponse
      DEFAULT_MESSAGE = 'Invalid value for COMPONENT_DESCRIPTION'

      def self.call(code: 404, message: DEFAULT_MESSAGE)
        new(code, message).call
      end
    end # class Rack::ServiceApiVersioning::ReportNotFound
  end
end
