require 'spec_helper'

describe 'munin::master', :type => 'class' do
  it {
    should contain_package('munin')
  }
end
