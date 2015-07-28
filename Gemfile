source 'https://rubygems.org'

group :test do
  gem 'rake'
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 4.0'
  gem 'rspec-puppet'
  gem 'rspec-puppet-facts', :require => false
  gem 'puppetlabs_spec_helper', '~> 0.10.2'
  gem 'metadata-json-lint'
end

group :development do
  gem 'travis'
  gem 'vagrant-wrapper'
  gem 'guard-rake'
end
