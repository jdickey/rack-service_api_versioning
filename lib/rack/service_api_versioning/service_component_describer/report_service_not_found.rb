# frozen_string_literal: true

require 'rack'
require 'rack/response'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Middlware to query and encode data on a named service, making it available
    # to later entries in the middleware chain via an environment variable.
    class ServiceComponentDescriber
      # Builds Rack::Result to halt request execution, responding with a 404.
      class ReportServiceNotFound
        def self.call(service_name)
          new(service_name).call
        end

        def call
          new_response.finish
        end

        protected

        def initialize(service_name)
          @service_name = service_name
          self
        end

        private

        attr_reader :service_name

        def body
          %(Service not found: "#{service_name}")
        end

        def new_response
          Rack::Response.new(Array(body), 404)
        end
      end # class ServiceComponentDescriber::ReportServiceNotFound
    end # class ServiceComponentDescriber
  end
end
