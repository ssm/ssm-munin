require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

shared_context :unsupported do
  let(:facts) do
    {
      :osfamily => 'Unsupported',
      :fqdn     => 'testnode.example.com',
    }
  end
end

shared_context :Debian do
  let(:facts) do
    {
      :osfamily => 'Debian',
      :fqdn     => 'testnode.example.com',
    }
  end
end

shared_context :RedHat do
  let(:facts) do
    {
      :osfamily => 'RedHat',
      :fqdn     => 'testnode.example.com',
    }
  end
end

shared_context :SmartOS do
  let(:facts) do
    {
      :operatingsystem => 'SmartOS',
      :osfamily        => 'Solaris',
      :fqdn            => 'testnode.example.com',
    }
  end
end

