require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts # rubocop:disable Style/MixinUsage

require 'simplecov'
require 'simplecov-console'

SimpleCov.start do
  add_filter '/spec'
  add_filter '/vendor'
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
end

shared_context :unsupported do
  let(:facts) { { osfamily: 'Unsupported' } }
end
