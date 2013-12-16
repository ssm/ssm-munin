# munin::node - Configure a munin node, and export configuration a
# munin master can collect.
#
# Parameters:
#
# - allow: List of IPv4 and IPv6 addresses and networks to allow to
#   connect.
#
class munin::node (
  $allow=['127.0.0.1'],
  $nodeconfig=[],
  $masterconfig=[],
  $mastergroup='',
  $plugins={},
  $address=$::fqdn,
  $config_root='/etc/munin',
  $service_name='munin-node',
)
{

  validate_array($allow)
  validate_array($nodeconfig)
  validate_array($masterconfig)
  validate_string($mastergroup)
  validate_hash($plugins)
  validate_string($address)
  validate_absolute_path($config_root)

  if $mastergroup {
    $fqn = "${mastergroup};${::fqdn}"
  }
  else {
    $fqn = $::fqdn
  }

  # Defaults
  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
  }

  package { 'munin-node':
    ensure => installed,
  }

  service { $service_name:
    enable  => true,
    require => Package['munin-node'],
  }

  file { "${config_root}/munin-node.conf":
    content => template('munin/munin-node.conf.erb'),
    require => Package['munin-node'],
    notify  => Service['munin-node'],
  }

  # Export a node definition to be collected by the munin master
  @@munin::master::node_definition{ $fqn:
    address => $address,
    config  => $masterconfig,
  }

  # Generate plugin resources from hiera or class parameter.
  create_resources(munin::plugin, $plugins, {})

}
