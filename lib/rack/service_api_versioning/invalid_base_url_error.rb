# frozen_string_literal: true

# Exception wrapper class for invalid return data due to bad SBU. This is not
# nested within the `EncodedApiVersionData` class so as not to unnecessarily
# leak extraneous implementation details.
class InvalidBaseUrlError < RuntimeError
  def initialize(base_url, original_error)
    @original_error = original_error
    super "Invalidly formatted base URL: #{base_url}"
  end

  attr_reader :original_error
end # class InvalidBaseUrlError
