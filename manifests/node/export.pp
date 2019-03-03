# @summary Helper class to export the munin node.
#
# This class exports a munin::master::node_definition to PuppetDB,
# where one or more munin masters can collect it.
#
# This is separated into its own class to avoid warnings about missing
# storeconfigs.
#
# @api private
#
# @param address [String]
#
# @param fqn [String] A munin Fully Qualified Name
#
# @param masterconfig [Array[String]] List of lines used for
#   configuring the master when connecting to this node
#
# @param mastername [String] The name of the munin master which will
#   collect these exported munin nodes.  This is used for tagging the
#   exported resources.
#
# @param node_definitions [Hash] A hash of extra
#   Munin::Master::Node_definitions to export from this node
class munin::node::export (
  $address,
  $fqn,
  $masterconfig,
  $mastername,
  $node_definitions = {},
)
{
  Munin::Master::Node_definition {
    mastername => $mastername,
    tag        => "munin::master::${mastername}",
  }
  @@munin::master::node_definition{ $fqn:
    address => $address,
    config  => $masterconfig,
  }
  if ! empty($node_definitions) {
    create_resources('@@munin::master::node_definition', $node_definitions)
  }
}
