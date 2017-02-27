# frozen_string_literal: true

require 'rack'
require 'rack/response'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Builds Rack::Response with specified status code and body message.
    class HttpErrorResponse
      def call
        Rack::Response.new(message, code).finish
      end

      protected

      def initialize(code, message)
        @code = code.to_i
        @message = Array(message)
        self
      end

      private

      attr_reader :code, :message
    end # class Rack::ServiceApiVersioning::HttpErrorResponse
  end
end
