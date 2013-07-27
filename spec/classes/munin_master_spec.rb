require 'spec_helper'

describe 'munin::master', :type => 'class' do
  it {
    should contain_package('munin')
  }

  it do
    should contain_file('/etc/munin/munin.conf')\
      .with_content(/^graph_strategy cgi$/)
  end

  context 'with graph_strategy => cron' do
    let(:params) { {:graph_strategy => 'cron'} }

    it do
      should contain_file('/etc/munin/munin.conf')\
        .with_content(/^graph_strategy cron$/)
    end
  end
end
