# frozen_string_literal: true

# Builds a Rack environment hash by adding entries to a Hash based on module
# methods called with a passed-in URI parameter.
class RackEnvForUri
  def self.call(uri)
    new(uri).call
  end

  def call
    items.reduce({}) { |result, item| result.merge! item }
  end

  protected

  def initialize(uri)
    @uri = uri
  end

  private

  attr_reader :uri

  def items
    Internals.item_methods.map { |meth| meth.call(uri) }
  end

  # Support methods for this class that do not depend on instance state.
  module Internals
    def self.item_methods
      ListMethodsInModule.call(EnvItems)
    end
  end
  private_constant :Internals
end # class RackEnvForUri
