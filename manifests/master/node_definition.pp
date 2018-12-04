# munin::master::node_definition - A node definition for the munin
# master.
#
# - title: The title of the defined resource should be a munin FQN,
#   ('hostname', 'group;hostname', 'group;subgroup;hostname'). If a
#   group is not set, munin will by default use the domain of the node
#   as a group.
#
# Parameters
#
# - address: The address of the munin node. A hostname, an IP address,
#   or a ssh:// uri for munin-async node. Required.
#
# - mastername: The name of the munin master server which will collect
#   the node definition.
#
# - virtual: If true, this is a [virtual node](https://munin.readthedocs.io/en/latest/reference/munin.conf.html#virtual-node).
#
# - config: An array of configuration lines to be added to the node
#   definition. Default is an empty array.
#
define munin::master::node_definition (
  $address,
  $mastername='',
  $virtual=false,
  $config=[],
)
{

  include ::munin::params::master

  $config_root = $munin::params::master::config_root

  validate_string($address)
  validate_array($config)
  validate_string($config_root)

  $filename=sprintf('%s/munin-conf.d/node.%s.conf',
                    $config_root,
                    regsubst($name, '[^[:alnum:]\.]', '_', 'IG'))

  $template = $virtual ? {
    true  => 'munin/master/node-virtual.definition.conf.erb',
    false => 'munin/master/node.definition.conf.erb',
  }

  file { $filename:
    content => template($template)
  }
}
