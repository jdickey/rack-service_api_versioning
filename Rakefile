
require "bundler/gem_tasks"
require "rake/testtask"

require 'rake/tasklib'
require 'flay'
require 'flay_task'
require 'tasks/flog_task_patch'
require 'reek/rake/task'
require 'rubocop/rake_task'
# require 'rubycritic/rake_task'

Rake::TestTask.new(:test) do |t|
  # t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
  # NOTE: Silences "loading in progress, circular require considered harmful"
  #       (and any other warnings -- not spec failures -- from MiniTest). Try
  #       removing/uncommenting this after a minitest update from 5.10.1.
  t.warning = false
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = [
    'lib/**/*.rb',
    'test/**/*.rb'
  ]
  task.formatters = ['simple', 'd']
  task.fail_on_error = true
  # task.options << '--rails'
  task.options << '--display-cop-names'
end

Reek::Rake::Task.new do |t|
  t.config_file = 'config.reek'
  t.source_files = 'lib/**/*.rb'
  t.reek_opts = '--sort-by smelliness --no-progress  -s'
end

FlayTask.new do |t|
  t.verbose = true
  t.dirs = %w(lib)
end

FlogTask.new do |t|
  t.verbose = true
  t.threshold = 300 # default is 200
  t.methods_only = true
  t.dirs = %w(lib) # Look, Ma; no tests! Run the tool manually every so often for those.
end

# # NOTE: We still want to keep the `config.reek` file, since RubyCritic uses Reek.
# #       Also note that tests give craptastic scores, hence now skipped. :grimacing:
# RubyCritic::RakeTask.new do |t|
#   t.options = '-f console'
#   t.paths = %w(lib)
# end

task(:default).clear
task default: [:test, :rubocop, :flay, :flog, :reek]
