require 'spec_helper_acceptance'

describe 'munin::master' do
  let(:pp) do
    <<-MANIFEST
    if $facts['os']['family'] == 'RedHat' {
      if $facts['os']['release']['major'] == '8' {
        yumrepo { 'PowerTools':
          enabled => '1',
          before  => Class['munin::master'],
        }
        yumrepo { 'AppStream':
          enabled => '1',
          before  => Class['munin::master'],
        }
      }
      package { 'epel-release':
        ensure => present,
        before => Class['munin::master'],
      }
    }
    include munin::master
    munin::master::node_definition { 'localhost':
      address => 'munin://localhost',
      config  => [ 'load.graph_future 30',
                   'load.load.trend yes',
                   'load.load.predict 86400,12' ],
    }
    MANIFEST
  end

  it 'applies the manifest twice with no stderr' do
    idempotent_apply(pp)
  end

  describe package('munin') do
    it { is_expected.to be_installed }
  end

  describe file '/etc/munin/munin-conf.d/node.localhost.conf' do
    it { is_expected.to exist }
    its(:content) { is_expected.to match %r{munin://localhost} }
  end
end
