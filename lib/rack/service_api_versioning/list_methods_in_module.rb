# frozen_string_literal: true

# Class which builds a list of methods in a class, not including methods whose
# names are prefixed with `_` as is the convention for "private" non-instance
# methods.
class ListMethodsInModule
  def self.call(container)
    new(container).call
  end

  def call
    list.map { |sym| container.method(sym) }
  end

  protected

  def initialize(container)
    @container = container
    self
  end

  private

  attr_reader :container

  def list
    container.methods(false).reject { |item| Internals.private_item?(item) }
  end

  # Support methods for this class that do not depend on instance state.
  module Internals
    def self.private_item?(item)
      item.to_s[0] == '_'
    end
  end
end # class ListMethodsInModule
