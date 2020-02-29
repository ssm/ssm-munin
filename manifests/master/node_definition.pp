# @summary Configure information about a munin node on the munin
#   master
#
# This will add configuration for the munin master to connect to a
# munin node, and ask for data from its munin plugins.
#
# The resource title is used as the munin FQN, or "fully qualified
# name". This defines the node name and group. It is common to use the
# host's fully qualified domain name, where the domain name will be
# implicitly used as the node group.
#
# Note: By default, using **munin::node** on a node will create a
# export a **munin::master::node_definition** to PuppetDB. The node
# classified with **munin::master** will collect all these exported
# instances.
#
# @param address
#
#   The address of the munin node. A hostname, an IP address, or a
#   ssh:// uri for munin-async node.
#
# @param mastername
#
#   The name of the munin master server which will collect the node
#   definition. This is used when exporting and collecting
#   **munin::master::node_definition** resources between hosts.
#
# @param config
#
#   An array of configuration lines to be added to the node
#   definition.
#
# @param fqn
#
#   The Munin FQN (Fully Qualified Name) of the node. This should be
#   'hostname', 'group;hostname', 'group;subgroup;hostname').
#
#   If a group is not set, munin will by default use the domain of the
#   node as a group, if the node name is a fully qualified host name.
#
#   The title of the defined resource should be a munin FQN. See the
#   "fqn" parameter
#
# @example Typical usage
#    munin::master::node_definition { 'host.example.com':
#        address => $address,
#        config  => ['additional', 'configuration' 'lines'],
#    }
#
# @example Using a group in the FQN
#    munin::master::node_definition { 'webservers;web01.example.com':
#        address => $address,
#        config  => ['additional', 'configuration' 'lines'],
#    }
#
define munin::master::node_definition (
  String $address,
  Optional[String] $mastername='',
  Array[String] $config=[],
  String $fqn = $title,
)
{

  $config_root = lookup('munin::master::config_root', Stdlib::Absolutepath)

  $filename=sprintf('%s/munin-conf.d/node.%s.conf',
                    $config_root,
                    regsubst($name, '[^[:alnum:]\.]', '_', 'IG'))

  $template_vars = {
    'fqn'     => $fqn,
    'address' => $address,
    'config'  => $config
  }

  file { $filename:
    content => epp('munin/master/node.definition.conf.epp', $template_vars ),
  }
}
