# @summary Helper class to collect the exported munin nodes.
#
# This is separated into its own class to avoid warnings about missing
# storeconfigs.
#
# @api private
#
# @param collect_nodes[Enum['enabled','mine', 'unclaimed','disabled']]
#
# @param host_name [String] Host named used for selecting exported
#   resources to collect.
class munin::master::collect (
  Enum['enabled','disabled','mine','unclaimed'] $collect_nodes,
  String $host_name,
)
{
  case $collect_nodes {
    'enabled': {
      Munin::Master::Node_definition <<| |>>
    }
    'mine': {
      # Collect nodes explicitly tagged with this master
      Munin::Master::Node_definition <<| tag == "munin::master::${host_name}" |>>
    }
    'unclaimed': {
      # Collect all exported node definitions, except the ones tagged
      # for a specific master
      Munin::Master::Node_definition <<| tag == 'munin::master::' |>>
    }
    'disabled',
    default: {
      # do nothing
    }
  }
}
