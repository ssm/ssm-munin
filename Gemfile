source 'https://rubygems.org'

group :test do
  gem 'rake'
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem 'rspec-puppet', :git => 'https://github.com/ssm/rspec-puppet.git', :ref => 'feature/rspec3'
  gem 'puppetlabs_spec_helper'
  gem 'metadata-json-lint'
end

group :development do
  gem 'travis'
  gem 'vagrant-wrapper'
  gem 'guard-rake'
end
