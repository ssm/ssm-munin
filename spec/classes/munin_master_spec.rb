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

  context 'with dbdir => /var/lib/munin' do
    let (:params) { { :dbdir => '/var/lib/munin' } }
    it {
      should contain_file('/etc/munin/munin.conf')
        .with_content(/dbdir\s+\/var\/lib\/munin/)
    }
  end

  context 'with htmldir => /var/www/munin' do
    let (:params) { { :htmldir => '/var/www/munin' } }
    it {
      should contain_file('/etc/munin/munin.conf')
        .with_content(/htmldir\s+\/var\/www\/munin/)
    }
  end

  context 'with logdir => /var/log/munin' do
    let (:params) { { :dbdir => '/var/log/munin' } }
    it {
      should contain_file('/etc/munin/munin.conf')
        .with_content(/dbdir\s+\/var\/log\/munin/)
    }
  end

  context 'with rudir => /var/run/munin' do
    let (:params) { { :dbdir => '/var/run/munin' } }
    it {
      should contain_file('/etc/munin/munin.conf')
        .with_content(/dbdir\s+\/var\/run\/munin/)
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
