# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/service_api_versioning/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-service_api_versioning"
  spec.version       = Rack::ServiceApiVersioning::VERSION
  spec.authors       = ["Jeff Dickey"]
  spec.email         = ["jdickey@seven-sigma.com"]

  spec.summary       = %q{Rack middleware for API Version-specific Component Service redirection.}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/jdickey/rack-service_api_versioning"
  spec.required_ruby_version = ">= 2.3.0"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "prolog-dry_types", '0.3.3'
  spec.add_dependency "rack", '2.0.1'

  spec.add_development_dependency "bundler", '1.14.6'
  spec.add_development_dependency "rake", '12.0.0'
  spec.add_development_dependency "minitest", '5.10.1'

  spec.add_development_dependency "minitest-matchers", '1.4.1'
  spec.add_development_dependency "minitest-reporters", '1.1.14'
  spec.add_development_dependency "minitest-tagz", '1.5.2'
  spec.add_development_dependency "flay", '2.8.1'
  spec.add_development_dependency "flog", '4.6.1'
  spec.add_development_dependency "reek", '4.5.6'
  spec.add_development_dependency "rubocop", '0.47.1'
  spec.add_development_dependency "simplecov", '0.14.1'
  spec.add_development_dependency "pry-byebug", '3.4.2'
  spec.add_development_dependency "pry-doc", '0.10.0'
  spec.add_development_dependency "awesome_print", '1.7.0'
  spec.add_development_dependency "colorator", '1.1.0'

  spec.add_development_dependency 'guard', '2.14.1'
  spec.add_development_dependency 'guard-livereload', '2.5.2'
  spec.add_development_dependency 'guard-minitest', '2.4.6'
  spec.add_development_dependency 'guard-rake', '1.0.0'
  spec.add_development_dependency 'guard-reek', '1.0.2'
  spec.add_development_dependency 'guard-rubocop', '1.2.0'
  spec.add_development_dependency 'guard-rubycritic', '2.9.3'
end
