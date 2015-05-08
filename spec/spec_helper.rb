require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

shared_context :unsupported do
  let(:facts) { { :osfamily => 'Unsupported', } }
end
