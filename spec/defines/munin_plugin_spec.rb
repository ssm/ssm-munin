require 'spec_helper'

describe 'munin::plugin', :type => 'define' do

  let(:title) { 'testplugin' }

  context 'with no parameters' do

    it {
      expect {
        should contain_file('/etc/munin/plugins/testplugin')
      }.to raise_error("expected that the catalogue would contain File[/etc/munin/plugins/testplugin]")

      should contain_file('/etc/munin/plugin-conf.d/testplugin.conf').with_ensure('absent')
    }
  end

  context 'with ensure=link parameter' do
    let(:params) { { :ensure => 'link' } }
    it {
      should contain_file('/etc/munin/plugins/testplugin').with_ensure('link').with_target('/usr/share/munin/plugins/testplugin')

      should contain_file('/etc/munin/plugin-conf.d/testplugin.conf').with_ensure('absent')
    }
  end

  context 'with ensure=link and target parameters' do
    let (:title) { 'test_foo' }
    let (:params) {
      { :ensure => 'link',
        :target => 'test_' }
    }

    it {
      should contain_file('/etc/munin/plugins/test_foo').with_ensure('link').with_target('/usr/share/munin/plugins/test_')

      should contain_file('/etc/munin/plugin-conf.d/test_foo.conf').with_ensure('absent')
    }
  end

  context 'with ensure=present and source parameters' do
      let(:params) {
      { :ensure => 'present',
        :source => 'puppet:///modules/munin/plugins/testplugin' }
    }

    it {

      expect {
        should contain_file('/etc/munin/plugins/testplugin').with_ensure('present').with_source('puppet:///modules/munin/plugins/testplugin')
      }
      should contain_file('/etc/munin/plugin-conf.d/testplugin.conf').with_ensure('absent')
    }
  end

  context 'with ensure=present, source and config parameters' do
    let(:params) {
      { :ensure => 'present',
        :source => 'puppet:///modules/munin/plugins/testplugin',
        :config => [ 'something wonderful' ],
      }
    }

    it {
      should contain_file('/etc/munin/plugins/testplugin').with_ensure('present').with_source('puppet:///modules/munin/plugins/testplugin')

      should contain_file('/etc/munin/plugin-conf.d/testplugin.conf').with_ensure('present').with_content(/something wonderful/)
    }
  end

  context 'only configuration' do
    let (:params) {
      { :config => ['env.rootdn cn=admin,dc=example,dc=org'],
        :config_label => 'slapd_*',
      }
    }

    it {

      should contain_file('/etc/munin/plugin-conf.d/testplugin.conf').with_ensure('present').with_content(/env.rootdn/)

      expect {
        should contain_file('/etc/munin/plugins/testplugin')
      }.to raise_error("expected that the catalogue would contain File[/etc/munin/plugins/testplugin]")

    }
  end

end
