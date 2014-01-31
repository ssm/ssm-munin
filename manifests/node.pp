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
  $package_name='munin-node',
  $service_name='munin-node',
  $service_ensure='',
)
{
  include munin::params

  $log_dir = $munin::params::log_dir

  validate_array($allow)
  validate_array($nodeconfig)
  validate_array($masterconfig)
  validate_string($mastergroup)
  validate_hash($plugins)
  validate_string($address)
  validate_absolute_path($config_root)
  validate_string($package_name)
  validate_string($service_name)
  validate_re($service_ensure, '^(|running|stopped)$')
  validate_absolute_path($log_dir)

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

  package { $package_name:
    ensure => installed,
  }

  service { $service_name:
    enable  => true,
    require => Package[$package_name],
    ensure  => $service_ensure ? {
      ''      => undef,
      default => $service_ensure,
    }
  }

  file { "${config_root}/munin-node.conf":
    content => template('munin/munin-node.conf.erb'),
    require => Package[$package_name],
    notify  => Service[$service_name],
  }

  # Export a node definition to be collected by the munin master
  @@munin::master::node_definition{ $fqn:
    address => $address,
    config  => $masterconfig,
  }

  # Generate plugin resources from hiera or class parameter.
  create_resources(munin::plugin, $plugins, {})

}
