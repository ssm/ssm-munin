# @summary Configure information about a munin node on the munin
#   master
#
# The title of the defined resource should be a munin FQN. See the
# "fqn" parameter
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
# @param fqn
#   (titlevar) The Munin FQN (Fully Qualified Name) of the node.
#   This should be 'hostname', 'group;hostname', 'group;subgroup;hostname').
#
#   If a group is not set, munin will by default use the domain of the
#   node as a group, if the node name is a fully qualified host name.
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
