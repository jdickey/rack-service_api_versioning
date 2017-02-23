# frozen_string_literal: true

require 'rake/tasklib'
require 'flog'
require 'flog_task'

# Redefinition of standard task's Rake invocation. Because we don't like
# inconsistency in option settings.
class FlogTask < Rake::TaskLib
  # Reek bitches that this is a :reek:Attribute (writable). That's the *point*.
  attr_accessor :methods_only
end
