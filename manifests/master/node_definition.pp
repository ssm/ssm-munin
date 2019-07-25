# @summary Configure information about a munin node on the munin
#   master
#
# The title of the defined resource should be a munin FQN,
# ('hostname', 'group;hostname', 'group;subgroup;hostname'). If a
# group is not set, munin will by default use the domain of the node
# as a group.
#
# @param address [String] The address of the munin node. A hostname,
#   an IP address, or a ssh:// uri for munin-async node.
#
# @param mastername [String] The name of the munin master server which
#   will collect the node definition.
#
# @param config [Array[String]] An array of configuration lines to be
#   added to the node definition.
#
define munin::master::node_definition (
  String $address,
  Optional[String] $mastername = '',
  Array[String] $config = [],
)
{

  include ::munin::params::master

  $config_root = $munin::params::master::config_root

  $filename = sprintf('%s/munin-conf.d/node.%s.conf',
                    $config_root,
                    regsubst($name, '[^[:alnum:]\.]', '_', 'IG'))

  file { $filename:
    content => template('munin/master/node.definition.conf.erb'),
  }
}
