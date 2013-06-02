require 'spec_helper'

describe 'munin::node', :type => 'class' do
  it {
    should contain_package('munin-node')
  }
end
