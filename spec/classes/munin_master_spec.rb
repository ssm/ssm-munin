require 'spec_helper'

describe 'munin::master' do

  [ :CentOS, :Debian, :RedHat, :Ubuntu ].each do |sc|
    context "Check for supported operatingsystem #{sc}" do
      include_context sc
      it { should compile }
      it { should contain_class('munin::master') }
      it {
        should contain_package('munin')
        should contain_file('/etc/munin/munin.conf')
        should contain_file('/etc/munin/munin-conf.d')
          .with_ensure('directory')
      }
    end
  end

  [ :SmartOS ].each do |sc|
    context "Check for supported operatingsystem #{sc}" do
      include_context sc
      it { should compile }
      it { should contain_class('munin::master') }
      it {
        should contain_package('munin')
        should contain_file('/opt/local/etc/munin/munin.conf')
        should contain_file('/opt/local/etc/munin/munin-conf.d')
          .with_ensure('directory')
      }
    end
  end

  context 'with default params' do
    it {
      should contain_file('/etc/munin/munin.conf')
        .with_content(/graph_strategy\s+cgi/)
        .with_content(/html_strategy\s+cgi/)
    }
  end

  context 'with html_strategy => cron' do
    let (:params) { { :html_strategy => 'cron' } }
    it {
      should contain_file('/etc/munin/munin.conf')
        .with_content(/html_strategy\s+cron/)
    }
  end

  context 'with graph_strategy => cron' do
    let (:params) { { :graph_strategy => 'cron' } }
    it {
      should contain_file('/etc/munin/munin.conf')
        .with_content(/graph_strategy\s+cron/)
    }
  end

  context 'with tls => enabled' do
    let(:params) {
      {
        :tls => 'enabled',
        :tls_certificate => '/path/to/certificate.pem',
        :tls_private_key => '/path/to/key.pem',
        :tls_verify_certificate => 'yes',
      }
    }

    it { should compile }
    it {
      should contain_file('/etc/munin/munin.conf')
        .with_content(/tls = enabled/)
        .with_content(/tls_certificate = \/path\/to\/certificate\.pem/)
        .with_content(/tls_private_key = \/path\/to\/key\.pem/)
        .with_content(/tls_verify_certificate = yes/)
    }
  end

end
