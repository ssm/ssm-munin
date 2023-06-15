require 'spec_helper'

t_conf_dir = {}
t_conf_dir.default = '/etc/munin'
t_conf_dir['Solaris'] = '/opt/local/etc/munin'
t_conf_dir['FreeBSD'] = '/usr/local/etc/munin'

t_package = {}
t_package.default = 'munin'
t_package['FreeBSD'] = 'munin-master'
t_package['OpenBSD'] = 'munin-server'

describe 'munin::master' do
  on_supported_os.each do |os, facts|
    # Avoid testing on distributions similar to RedHat and Debian
    next if %r{^(ubuntu|centos|scientific|oraclelinux)-}.match?(os)

    context "on #{os}" do
      let(:facts) do
        facts
      end

      conf_dir = t_conf_dir[facts[:osfamily]]
      package = t_package[facts[:osfamily]]

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package(package) }

      context 'with default params' do
        it { is_expected.to contain_class('munin::master::collect') }
        it do
          is_expected.to contain_file("#{conf_dir}/munin.conf")
            .with_content(%r{graph_strategy\s+cgi})
            .with_content(%r{html_strategy\s+cgi})
        end

        it do
          is_expected.to contain_file("#{conf_dir}/munin-conf.d")
            .with_ensure('directory')
        end
      end

      context 'with collect_nodes => disabled' do
        let(:params) { { collect_nodes: 'disabled' } }

        it { is_expected.not_to contain_class('munin::master::collect') }
      end

      context 'with html_strategy => cron' do
        let(:params) { { html_strategy: 'cron' } }

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file("#{conf_dir}/munin.conf")
            .with_content(%r{html_strategy\s+cron})
        end
      end

      context 'with graph_strategy => cron' do
        let(:params) { { graph_strategy: 'cron' } }

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file("#{conf_dir}/munin.conf")
            .with_content(%r{graph_strategy\s+cron})
        end
      end

      context 'with dbdir => /var/lib/munin' do
        let(:params) { { dbdir: '/var/lib/munin' } }

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file("#{conf_dir}/munin.conf")
            .with_content(%r{dbdir\s+/var/lib/munin})
        end
      end

      context 'with htmldir => /var/www/munin' do
        let(:params) { { htmldir: '/var/www/munin' } }

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file("#{conf_dir}/munin.conf")
            .with_content(%r{htmldir\s+/var/www/munin})
        end
      end

      context 'with logdir => /var/log/munin' do
        let(:params) { { dbdir: '/var/log/munin' } }

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file("#{conf_dir}/munin.conf")
            .with_content(%r{dbdir\s+/var/log/munin})
        end
      end

      context 'with rundir => /var/run/munin' do
        let(:params) { { dbdir: '/var/run/munin' } }

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file("#{conf_dir}/munin.conf")
            .with_content(%r{dbdir\s+/var/run/munin})
        end
      end

      context 'with tls => enabled' do
        let(:params) do
          {
            tls: 'enabled',
            tls_certificate: '/path/to/certificate.pem',
            tls_private_key: '/path/to/key.pem',
            tls_verify_certificate: 'yes',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file("#{conf_dir}/munin.conf")
            .with_content(%r{tls enabled})
            .with_content(%r{tls_certificate /path/to/certificate\.pem})
            .with_content(%r{tls_private_key /path/to/key\.pem})
            .with_content(%r{tls_verify_certificate yes})
        end
      end

      context 'with node_definitions' do
        let(:params) do
          {
            node_definitions: {
              'node-a' => {
                'address' => 'munin://node-a.example.com',
              },
              'node-b' => {
                'address' => 'munin://node-b.example.com',
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_munin__master__node_definition('node-a') }
        it { is_expected.to contain_munin__master__node_definition('node-b') }
      end

      context 'with extra_config' do
        token = '1b7febce-bb2d-4c18-b889-84c73538a900'
        let(:params) do
          { extra_config: [token] }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file("#{conf_dir}/munin.conf")
            .with_content(%r{#{token}})
        end
      end
    end
  end
end
