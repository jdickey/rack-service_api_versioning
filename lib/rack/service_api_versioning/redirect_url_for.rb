# frozen_string_literal: true

# Builds a "redirect" URL (string) base on a Rack environment and a new
# SBU string, where the redirect URL uses the new SBU's values for host
# name, scheme (protocol), port number, username, and password. The last
# three items, if `nil` or the empty string, will still result in a valid
# URL returned from `.call`.
class RedirectUrlFor
  def self.call(env:, new_base_url:)
    new(env, new_base_url).call
  end

  def call
    copy_fields_from_new_base
    Addressable::URI.new(base_uri).to_s
  end

  protected

  def initialize(env, new_base_url)
    @new_base_uri = Internals.parse_url_str(new_base_url)
    @base_uri = Internals.rack_request_uri_for(env)
    @request_path = env['REQUEST_PATH']
    self
  end

  private

  attr_reader :base_uri, :new_base_uri, :request_path

  def copy_fields_from_new_base
    copy_keyed_fields
    base_uri[:path] = request_path
    self
  end

  def copy_keyed_fields
    [:host, :port, :user, :password, :scheme].each do |key|
      base_uri[key] = new_base_uri[key]
    end
  end

  # Stateless methods
  module Internals
    def self.parse_url_str(url_str)
      Addressable::URI.parse(url_str).to_hash
    end

    def self.rack_request_uri_for(env)
      url = Rack::Request.new(env).url
      parse_url_str(url)
    end
  end
end # class RedirectUrlFor
