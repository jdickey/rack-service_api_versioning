# frozen_string_literal: true

# Module with methods that build entries for a Rake `env` environment hash.
# Support methods are prefixed with an underscore. This goes along with the
# `ListMethodsInModule` class; both support the `ApiVersionRedirector` class.
module EnvItems
  def self.http_host(uri)
    { 'HTTP_HOST' => [uri.host, uri.port.to_s].join(':') }
  end

  def self.path_info(uri)
    value = _parts_from(uri)[:tail].join('/')
    { 'PATH_INFO' => value }
  end

  def self.rack_url_schema(uri)
    { 'rack.url_scheme' => uri.scheme }
  end

  def self.request_method(uri)
    { 'REQUEST_METHOD' => uri.scheme }
  end

  def self.script_name(uri)
    script_name = '/' + _parts_from(uri)[:head]
    { 'SCRIPT_NAME' => script_name }
  end

  def self.server_name(uri)
    { 'SERVER_NAME' => uri.host }
  end

  def self.server_port(uri)
    { 'SERVER_PORT' => uri.port }
  end

  def self._all_parts(uri)
    uri.path.split('/')
  end

  def self._non_empty_parts(uri)
    _all_parts(uri).reject(&:empty?)
  end

  def self._parts_from(uri)
    parts = _non_empty_parts(uri)
    head = parts.first || ''
    tail = Array(parts[1..-1])
    { head: head, tail: tail }
  end
end
