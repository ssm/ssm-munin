require 'spec_helper'

_params = {
  :address => '127.0.0.2',
  :fqn => 'example;foo.example.com',
  :masterconfig => [],
  :mastername => 'munin.example.com'
}
_extra_nodes = {
  'example;svc10.example.com' => {
    'address' => '127.0.0.10',
    'config'  => [],
  },
  'example;svc11.example.com' => {
    'address' => '127.0.0.11',
    'config'  => ['env foo.warn 12'],
  }
}

describe 'munin::node::export' do

  on_supported_os.each do |os, facts|

    context "on #{os}" do
      let(:facts) { facts }
      let(:params) { _params }

      it { should compile.with_all_deps }

      it do
        expect(exported_resources).to have_munin__master__node_definition_resource_count(1)
      end
      it do
        expect(exported_resources).to contain_munin__master__node_definition(_params[:fqn])
                                        .with_address(_params[:address])
                                        .with_mastername(_params[:mastername])
                                        .with_tag(["munin::master::#{_params[:mastername]}"])
      end
    end

    context "on #{os} with extra nodes" do
      let(:facts) { facts }
      let(:params) { _params.merge({ :node_definitions => _extra_nodes }) }

      it { should compile.with_all_deps }

      it do
        expect(exported_resources).to have_munin__master__node_definition_resource_count(3)
      end
      it do
        expect(exported_resources).to contain_munin__master__node_definition(_params[:fqn])
                                        .with_address(_params[:address])
                                        .with_mastername(_params[:mastername])
                                        .with_tag("munin::master::#{_params[:mastername]}")
      end
      _extra_nodes.each_key do |n|
        it do
          expect(exported_resources).to contain_munin__master__node_definition(n)
                                          .with_address(_extra_nodes[n]['address'])
                                          .with_mastername(_params[:mastername])
                                          .with_config(_extra_nodes[n]['config'])
                                          .with_tag("munin::master::#{_params[:mastername]}")
        end
      end
    end
  end
end
