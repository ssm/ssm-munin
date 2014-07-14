require 'spec_helper'

describe 'munin::master', :type => 'class' do
  context 'default' do
    include_context :Debian
    it { should compile }
    it {
      should contain_package('munin')
      should contain_file('/etc/munin/munin.conf')\
        .with_content(/^graph_strategy cgi$/)
    }
  end


  context 'with graph_strategy => cron' do
    include_context :Debian
    let(:params) { {:graph_strategy => 'cron'} }

    it { should compile }
    it {
      should contain_file('/etc/munin/munin.conf')
        .with_content(/^graph_strategy cron$/)
    }
  end

  context 'with tls => enabled' do
    include_context :Debian
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
