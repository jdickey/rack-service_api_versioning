# frozen_string_literal: true

require 'rack'
require 'rack/response'

require_relative './service_component_describer/report_service_not_found'

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Middleware that, given a "service name" parameter, will read descriptive
    # data from a supplied repository regarding the named service, format that
    # data as a JSON string, assign it to the `COMPONENT_DESCRIPTION`
    # environment variable, and pass the updated environment along to the next
    # link in the Rack call chain (app or more middleware). If there is no data
    # for the named service in the repository, this middleware will halt
    # execution with a 404 (Not Found).
    #
    # Also bear in mind that both usual parameters (`repository` and
    # `service_name`) are supplied *by the AVIDA,* which should know what those
    # "ought" to be.
    class ServiceComponentDescriber
      DEFAULT_ENV_KEYS = { result: 'COMPONENT_DESCRIPTION' }.freeze

      def initialize(app, repository:, service_name:,
                     env_keys: DEFAULT_ENV_KEYS)
        @app = app
        @env_keys = env_keys
        @repository = repository
        @service_name = service_name
        self
      end

      def call(env)
        env = update_env(env)
        verify_datum_set(env) { |app_env| app.call app_env }
      end

      private

      attr_reader :app, :env_keys, :repository, :service_name

      def first_record
        repository.find(name: service_name).first
      end

      def result_key
        env_keys[:result]
      end

      def update_env(env)
        datum = first_record
        env[result_key] = JSON.dump(datum) if datum
        env
      end

      def verify_datum_set(env)
        verify_found(env) || yield(env)
      end

      def verify_found(env)
        return nil if env[result_key]
        ReportServiceNotFound.call(service_name)
      end
    end
  end
end
