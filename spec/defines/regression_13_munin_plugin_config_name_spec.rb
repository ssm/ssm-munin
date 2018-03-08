require 'spec_helper'

_conf_dir = {}
_conf_dir.default = '/etc/munin'
_conf_dir['Solaris'] = '/opt/local/etc/munin'
_conf_dir['FreeBSD'] = '/usr/local/etc/munin'

describe 'munin::plugin' do
  let(:title) { 'testplugin' }

  on_supported_os.each do |os, facts|
    # Avoid testing on distributions similar to RedHat and Debian
    next if os =~ %r{^(ubuntu|centos|scientific|oraclelinux)-}

    # No need to test all os versions as long as os version is not
    # used in the params class
    next if os =~ %r{^(debian-[67]|redhat-[56]|freebsd-9)-}

    context "on #{os}" do
      let(:facts) { facts }

      conf_dir = _conf_dir[facts[:osfamily]]

      context 'with config_label unset, label should be set to title' do
        let(:params) do
          { config: ['env.foo bar'] }
        end

        it do
          is_expected.to contain_file("#{conf_dir}/plugin-conf.d/testplugin.conf")
            .with_content(%r{^\[testplugin\]$})
        end
      end

      context 'with config_label set, label should be set to config_label' do
        let(:params) do
          { config: ['env.foo bar'], config_label: 'foo_' }
        end

        it do
          is_expected.to contain_file("#{conf_dir}/plugin-conf.d/testplugin.conf")
            .with_content(%r{^\[foo_\]$})
        end
      end
    end
  end
end
