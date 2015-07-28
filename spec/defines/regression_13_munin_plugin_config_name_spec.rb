require 'spec_helper'

_conf_dir = {}
_conf_dir.default = '/etc/munin'
_conf_dir['Solaris'] = '/opt/local/etc/munin'
_conf_dir['FreeBSD'] = '/usr/local/etc/munin'

describe 'munin::plugin' do
  let(:title) { 'testplugin' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      conf_dir = _conf_dir[facts[:osfamily]]

      context 'with config_label unset, label should be set to title' do
        let(:params) do
          { config: ['env.foo bar'] }
        end

        it do
          should contain_file("#{conf_dir}/plugin-conf.d/testplugin.conf")
                  .with_content(/^\[testplugin\]$/)
        end
      end

      context 'with config_label set, label should be set to config_label' do
        let(:params) do
          { config: ['env.foo bar'],
            config_label: 'foo_' }
        end
        it do
          should contain_file("#{conf_dir}/plugin-conf.d/testplugin.conf")
                  .with_content(/^\[foo_\]$/)
        end
      end

    end # on os
  end

end
