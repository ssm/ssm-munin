require 'rubygems'
require 'bundler/setup'

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet/version'
require 'puppet/vendor/semantic/lib/semantic' unless Puppet.version.to_f < 3.6
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'metadata-json-lint/rake_task'

# Puppet 3.x monkey patches safe_yaml so it is incompatible with Rubocop
run_rubocop = Puppet.version.to_f >= 4.0 && RUBY_VERSION.to_f >= 2.1
if run_rubocop
  require 'rubocop/rake_task'

  # These gems aren't always present, for instance
  # on Travis with --without development
  begin
  rescue LoadError # rubocop:disable Lint/HandleExceptions
  end

  RuboCop::RakeTask.new
end

exclude_paths = [
  "bundle/**/*",
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

# Coverage from puppetlabs-spec-helper requires rcov which
# doesn't work in anything since 1.8.7
Rake::Task[:coverage].clear

Rake::Task[:lint].clear

PuppetLint.configuration.relative = true
PuppetLint.configuration.disable_80chars
PuppetLint.configuration.disable_class_inherits_from_params_class
PuppetLint.configuration.disable_class_parameter_defaults
PuppetLint.configuration.fail_on_warnings = false

PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = exclude_paths
end

PuppetSyntax.exclude_paths = exclude_paths

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc "Populate CONTRIBUTORS file"
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

test_tasks = %i[
  metadata_lint
  syntax
  lint
  spec
]
test_tasks += [:rubocop] if run_rubocop

desc "Run syntax, lint, and spec tests."
task :test => test_tasks
