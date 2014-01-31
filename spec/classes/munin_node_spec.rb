require 'spec_helper'

describe 'munin::node', :type => 'class' do
  context 'default' do
    let(:facts) do
      { :fqdn => 'example.com' }
    end

    it {
      should contain_package('munin-node')
      should contain_service('munin-node')
      should contain_file('/etc/munin/munin-node.conf')
    }
  end
end
