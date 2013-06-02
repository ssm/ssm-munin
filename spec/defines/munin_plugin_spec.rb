require 'spec_helper'

describe 'munin::plugin', :type => 'define' do
  let(:title) { 'one' }
  let(:params) {
    { :source => '/usr/share/munin/plugins/one' }
  }

  it {
    should contain_file('/etc/munin/plugins/one')
  }
end

describe 'munin::plugin', :type => 'define' do
  let(:title) { 'two' }
  let(:params) {
    { :source => '/usr/share/munin/plugins/two',
      :config => [ 'something wonderful' ],
    }
  }
  it {
    should contain_file('/etc/munin/plugin-conf.d/two.conf').with_content(/something wonderful/)
    should contain_file('/etc/munin/plugins/two')
  }
end
