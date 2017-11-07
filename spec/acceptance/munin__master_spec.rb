require 'spec_helper_acceptance'

describe 'munin::master class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-PUPPET_CODE
      class { 'munin::master': }
      PUPPET_CODE

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('munin') do
      it { is_expected.to be_installed }
    end
  end
end
