# frozen_string_literal: true

# All(?) Rack code is namespaced within this module.
module Rack
  # Module includes our middleware components for managing service API versions.
  module ServiceApiVersioning
    # Wrapper around JSON encoding of object in environment with defaulted key.
    class InputEnv
      DEFAULT_INPUT_KEY = 'COMPONENT_DESCRIPTION'

      def initialize(env, input_key = DEFAULT_INPUT_KEY)
        @env = env
        @key = input_key
        self
      end

      def any?
        !input_str.empty?
      end

      def data
        JSON.parse input_str, symbolize_names: true
      end

      private

      attr_reader :env, :key

      def input_str
        input_value.strip
      end

      def input_value
        env[key].to_s
      end
    end # class Rack::ServiceApiVersioning::InputEnv
  end
end
