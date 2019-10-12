require 'spec_helper'

t_conf_dir = {}
t_conf_dir.default = '/etc/munin'
t_conf_dir['DragonFly'] = '/usr/local/etc/munin'
t_conf_dir['FreeBSD'] = '/usr/local/etc/munin'
t_conf_dir['Solaris'] = '/opt/local/etc/munin'

describe 'munin::node' do
  on_supported_os.each do |os, facts|
    # Avoid testing on distributions similar to RedHat and Debian
    next if os =~ %r{^(ubuntu|centos|scientific|oraclelinux)-}

    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package('munin-node') }

      munin_confdir = t_conf_dir[facts[:osfamily]]

      munin_node_conf = "#{munin_confdir}/munin-node.conf"
      munin_plugin_dir = "#{munin_confdir}/plugins"
      munin_plugin_conf_dir = "#{munin_confdir}/plugin-conf.d"

      munin_node_service =
        case facts[:osfamily]
        when 'Solaris' then 'smf:/munin-node'
        else 'munin-node'
        end

      log_dir =
        case facts[:osfamily]
        when 'Solaris' then '/var/opt/log/munin'
        when 'RedHat' then '/var/log/munin-node'
        else '/var/log/munin'
        end

      it { is_expected.to contain_service(munin_node_service) }
      it { is_expected.to contain_file(munin_node_conf) }

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service(munin_node_service) }
        it do
          is_expected.to contain_file(munin_node_conf)
            .with_content(%r{host_name\s+\S+$})
            .with_content(%r{log_file\s+#{log_dir}/munin-node.log})
        end
      end

      context 'with parameter allow' do
        let(:params) do
          { allow: ['2001:db8:1::',
                    '2001:db8:2::/64',
                    '192.0.2.129',
                    '192.0.2.0/25',
                    '192\.0\.2'] }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file(munin_node_conf)
            .with_content(%r{^cidr_allow 192\.0\.2\.0/25$})
            .with_content(%r{^cidr_allow 2001:db8:2::/64$})
            .with_content(%r{^allow \^192\\\.0\\\.2\\\.129\$$})
            .with_content(%r{^allow 192\\.0\\.2$})
            .with_content(%r{^allow \^2001:db8:1::\$$})
        end
      end

      context 'with parameter host_name' do
        let(:params) do
          { host_name: 'something.example.com' }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file(munin_node_conf)
            .with_content(%r{host_name\s+something.example.com})
        end
      end

      context 'with parameter service_ensure' do
        let(:params) do
          { service_ensure: 'running' }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_service('munin-node')
            .with_ensure('running')
        end
      end

      context 'logging to syslog' do
        context 'defaults' do
          let(:params) do
            { log_destination: 'syslog' }
          end

          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to contain_file(munin_node_conf)
              .with_content(%r{log_file\s+Sys::Syslog})
          end
        end

        context 'with syslog options' do
          let(:params) do
            { log_destination: 'syslog',
              syslog_facility: 'local1' }
          end

          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to contain_file(munin_node_conf)
              .with_content(%r{log_file\s+Sys::Syslog})
              .with_content(%r{syslog_facility\s+local1})
          end
        end
      end

      context 'purge_configs' do
        context 'set' do
          let(:params) { { purge_configs: true } }

          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to contain_file(munin_plugin_dir)
              .with_ensure('directory')
              .with_recurse(true)
              .with_purge(true)
          end
          it do
            is_expected.to contain_file(munin_plugin_conf_dir)
              .with_ensure('directory')
              .with_recurse(true)
              .with_purge(true)
          end
        end
        context 'unset' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to contain_file(munin_plugin_dir) }
          it { is_expected.not_to contain_file(munin_plugin_conf_dir) }
        end
      end

      context 'timeout' do
        context 'set' do
          let(:params) { { timeout: 123 } }

          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to contain_file(munin_node_conf)
              .with_content(%r{^timeout 123})
          end
        end
        context 'unset' do
          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to contain_file(munin_node_conf)
              .without_content(%r{^timeout})
          end
        end
      end
    end
  end
end
