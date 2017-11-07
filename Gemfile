source "https://rubygems.org"

group :test do
  gem "metadata-json-lint"
  gem "puppet", ENV['PUPPET_GEM_VERSION'] || '~> 3.8.0'
  gem "puppet-lint-absolute_classname-check"
  gem "puppet-lint-classes_and_types_beginning_with_digits-check"
  gem "puppet-lint-leading_zero-check"
  gem "puppet-lint-trailing_comma-check"
  gem "puppet-lint-unquoted_string-check"
  gem "puppet-lint-version_comparison-check"
  gem "puppetlabs_spec_helper"
  gem "rake"
  gem "rspec", '~> 3.0' # works with '~> 3.6.0'
  gem "rspec-puppet"
  gem "rspec-puppet-facts"
  gem 'rubocop' # works with '0.51.0'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
end

group :development do
  gem "guard-rake"
  gem "travis"
  gem "travis-lint"
end

group :system_tests do
  gem "beaker"
  gem "beaker-puppet_install_helper"
  gem "beaker-rspec"
end
