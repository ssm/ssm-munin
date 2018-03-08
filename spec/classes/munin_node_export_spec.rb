require 'spec_helper'

t_params = {
  address: '127.0.0.2',
  fqn: 'example;foo.example.com',
  masterconfig: [],
  mastername: 'munin.example.com',
}
t_extra_nodes = {
  'example;svc10.example.com' => {
    'address' => '127.0.0.10',
    'config'  => [],
  },
  'example;svc11.example.com' => {
    'address' => '127.0.0.11',
    'config'  => ['env foo.warn 12'],
  },
}

describe 'munin::node::export' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) { t_params }

      it { is_expected.to compile.with_all_deps }

      it do
        expect(exported_resources).to have_munin__master__node_definition_resource_count(1)
      end
      it do
        expect(exported_resources).to contain_munin__master__node_definition(t_params[:fqn])
          .with_address(t_params[:address])
          .with_mastername(t_params[:mastername])
          .with_tag(["munin::master::#{t_params[:mastername]}"])
      end
    end

    context "on #{os} with extra nodes" do
      let(:facts) { facts }
      let(:params) { t_params.merge(node_definitions: t_extra_nodes) }

      it { is_expected.to compile.with_all_deps }

      it do
        expect(exported_resources).to have_munin__master__node_definition_resource_count(3)
      end
      it do
        expect(exported_resources).to contain_munin__master__node_definition(t_params[:fqn])
          .with_address(t_params[:address])
          .with_mastername(t_params[:mastername])
          .with_tag("munin::master::#{t_params[:mastername]}")
      end
      t_extra_nodes.each_key do |n|
        it do
          expect(exported_resources).to contain_munin__master__node_definition(n)
            .with_address(t_extra_nodes[n]['address'])
            .with_mastername(t_params[:mastername])
            .with_config(t_extra_nodes[n]['config'])
            .with_tag("munin::master::#{t_params[:mastername]}")
        end
      end
    end
  end
end
