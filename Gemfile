source 'https://rubygems.org'

group :test do
  gem 'rake'
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'metadata-json-lint'
end

group :development do
  gem 'travis'
  gem 'vagrant-wrapper'
  gem 'guard-rake'
end
