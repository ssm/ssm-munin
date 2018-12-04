require 'spec_helper'

t_conf_dir = {}
t_conf_dir.default = '/etc/munin'
t_conf_dir['Solaris'] = '/opt/local/etc/munin'
t_conf_dir['FreeBSD'] = '/usr/local/etc/munin'

t_package = {}
t_package.default = 'munin'
t_package['FreeBSD'] = 'munin-master'

describe 'munin::master' do
  on_supported_os.each do |os, facts|
    # Avoid testing on distributions similar to RedHat and Debian
    next if os =~ %r{^(ubuntu|centos|scientific|oraclelinux)-}

    # No need to test all os versions as long as os version is not
    # used in the params class
    next if os =~ %r{^(debian-[67]|redhat-[56]|freebsd-9)-}

    context "on #{os}" do
      let(:facts) do
        facts
      end

      conf_dir = t_conf_dir[facts[:osfamily]]
      package = t_package[facts[:osfamily]]

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package(package) }

      context 'with default params' do
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
            .with_content(%r{tls = enabled})
            .with_content(%r{tls_certificate = /path/to/certificate\.pem})
            .with_content(%r{tls_private_key = /path/to/key\.pem})
            .with_content(%r{tls_verify_certificate = yes})
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
              'virtual' => {
                'address' => 'unused',
                'virtual' => true,
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_munin__master__node_definition('node-a')
          is_expected.to contain_file("#{conf_dir}/munin-conf.d/node.node_a.conf")
            .without_content(%r{update no})
        end
        it do
          is_expected.to contain_munin__master__node_definition('node-b')
          is_expected.to contain_file("#{conf_dir}/munin-conf.d/node.node_b.conf")
            .without_content(%r{update no})
        end
        it do
          is_expected.to contain_munin__master__node_definition('virtual')
          is_expected.to contain_file("#{conf_dir}/munin-conf.d/node.virtual.conf")
            .with_content(%r{update no})
        end
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

      context 'with extra_config set to a string' do
        token = '1b7febce-bb2d-4c18-b889-84c73538a900'
        let(:params) do
          { extra_config: token }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{is not an Array}) }
      end

      ['test.example.com', 'invalid/hostname.example.com'].each do |param|
        context "with host_name => #{param}" do
          let(:params) do
            { host_name: param }
          end

          if param =~ %r{invalid}
            it { is_expected.to raise_error(Puppet::Error, %r{valid domain name}) }
          else
            it { is_expected.to compile.with_all_deps }
          end
        end
      end

      ['enabled', 'disabled', 'mine', 'unclaimed', 'invalid'].each do |param|
        context "with collect_nodes => #{param}" do
          let(:params) do
            { collect_nodes: param }
          end

          if param == 'invalid'
            it { is_expected.to raise_error(Puppet::Error, %r{validate_re}) }
          else
            it { is_expected.to compile.with_all_deps }
          end
        end
      end
    end
  end
end
