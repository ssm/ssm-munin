require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.fail_fast = true
end

shared_context :unsupported do
  let(:facts) { { osfamily: 'Unsupported' } }
end
