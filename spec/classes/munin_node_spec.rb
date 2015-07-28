require 'spec_helper'

describe 'munin::node' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }

      it { should contain_package('munin-node') }

      case facts[:osfamily]
      when 'Solaris'
        munin_confdir = '/opt/local/etc/munin'
      when 'FreeBSD', 'DragonFly'
        munin_confdir = '/usr/local/etc/munin'
      else
        munin_confdir = '/etc/munin'
      end

      munin_node_conf = "#{munin_confdir}/munin-node.conf"
      munin_plugin_dir = "#{munin_confdir}/plugins"
      munin_plugin_conf_dir = "#{munin_confdir}/plugin-conf.d"

      case facts[:osfamily]
      when 'Solaris'
        munin_node_service = 'smf:/munin-node'
      else
        munin_node_service = 'munin-node'
      end

      case facts[:osfamily]
      when 'Solaris'
        log_dir = '/var/opt/log/munin'
      when 'RedHat'
        log_dir = '/var/log/munin-node'
      else
        log_dir = '/var/log/munin'
      end

      it { should contain_service(munin_node_service) }
      it { should contain_file(munin_node_conf) }

      context 'with no parameters' do
        it { should compile.with_all_deps }
        it do
          should contain_service(munin_node_service)
                  .without_ensure()
        end
        it do
          should contain_file(munin_node_conf)
                  .with_content(/host_name\s+foo.example.com/)
                  .with_content(/log_file\s+#{log_dir}\/munin-node.log/)
        end
      end

      context 'with parameter allow' do
        let(:params) do
          { allow: ['2001:db8:1::',
                    '2001:db8:2::/64',
                    '192.0.2.129',
                    '192.0.2.0/25',
                    '192\.0\.2']
          }
        end
        it { should compile.with_all_deps }
        it do
          should contain_file('/etc/munin/munin-node.conf')
                  .with_content(/^cidr_allow 192.0.2.0\/25$/)
                  .with_content(/^cidr_allow 2001:db8:2::\/64$/)
                  .with_content(/^allow \^192\\.0\\.2\\.129\$$/)
                  .with_content(/^allow 192\\.0\\.2$/)
                  .with_content(/^allow \^2001:db8:1::\$$/)
        end
      end

      context 'with parameter host_name' do
        let(:params) do
          { host_name: 'something.example.com' }
        end
        it { should compile.with_all_deps }
        it do
          should contain_file('/etc/munin/munin-node.conf')
                  .with_content(/host_name\s+something.example.com/)
        end
      end

      context 'with parameter service_ensure' do
        let(:params) do
          { service_ensure: 'running' }
        end
        it { should compile.with_all_deps }
        it do
          should contain_service('munin-node')
            .with_ensure('running')
        end
      end

      context 'logging to syslog' do
        context 'defaults' do
          let(:params) do
            { log_destination: 'syslog' }
          end
          it{ should compile.with_all_deps }
          it do
            should contain_file(munin_node_conf)
                    .with_content(/log_file\s+Sys::Syslog/)
          end
        end

        context 'with syslog options' do
          let(:params) do
            { log_destination: 'syslog',
              syslog_ident: 'munin-granbusk',
              syslog_facility: 'local1',
            }
          end
          it{ should compile.with_all_deps }
          it do
            should contain_file(munin_node_conf)
                    .with_content(/log_file\s+Sys::Syslog/)
                    .with_content(/syslog_ident\s+"munin-granbusk"/)
                    .with_content(/syslog_facility\s+local1/)
          end
        end

        context 'with syslog_facility set to wrong value ' do
          let(:params) do
            { log_destination: 'syslog',
              syslog_facility: 'wrong',
            }
          end
          it { expect { should compile.with_all_deps }.to raise_error(/validate_re/) }
        end
      end
    end
  end

  context 'unsupported' do
    include_context :unsupported
    it {
      expect {
        should contain_class('munin::node')
      }.to raise_error(Puppet::Error, /Unsupported osfamily/)
    }
  end

end
