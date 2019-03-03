# Class to export the munin node.
#
# This is separated into its own class to avoid warnings about missing
# storeconfigs.
#
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
