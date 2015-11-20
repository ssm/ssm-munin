class munin::params::node {

  $message = "Unsupported osfamily: ${::osfamily}"

  $address        = $::fqdn
  $host_name      = $::fqdn
  $allow          = []
  $masterconfig   = []
  $mastergroup    = undef
  $mastername     = undef
  $nodeconfig     = []
  $plugins        = {}
  $service_ensure = undef
  $export_node    = 'enabled'
  $log_file       = 'munin-node.log'
  $log_destination = 'file'
  $syslog_facility = undef
  $purge_configs   = false
  $timeout         = undef

  case $::osfamily {
    'RedHat': {
      $config_root  = '/etc/munin'
      $log_dir      = '/var/log/munin-node'
      $service_name = 'munin-node'
      $package_name = 'munin-node'
      $plugin_share_dir = '/usr/share/munin/plugins'
      $file_group   = 'root'
    }
    'Debian',
    'Archlinux': {
      $config_root  = '/etc/munin'
      $log_dir      = '/var/log/munin'
      $service_name = 'munin-node'
      $package_name = 'munin-node'
      $plugin_share_dir = '/usr/share/munin/plugins'
      $file_group   = 'root'
    }
    'Solaris': {
      case $::operatingsystem {
        'SmartOS': {
          $config_root  = '/opt/local/etc/munin'
          $log_dir      = '/var/opt/log/munin'
          $service_name = 'smf:/munin-node'
          $package_name = 'munin-node'
          $plugin_share_dir = '/opt/local/share/munin/plugins'
          $file_group   = 'root'
        }
        default: {
          fail("Unsupported operatingsystem ${::operatingsystem} for osfamily ${::osfamily}")
        }
      }
    }
    'FreeBSD', 'DragonFly': {
      $config_root  = '/usr/local/etc/munin'
      $log_dir      = '/var/log/munin'
      $service_name = 'munin-node'
      $package_name = 'munin-node'
      $plugin_share_dir = '/usr/local/share/munin/plugins'
      $file_group   = 'wheel'
    }
    'OpenBSD': {
      $config_root  = '/etc/munin'
      $log_dir      = '/var/log/munin'
      $service_name = 'munin_node'
      $package_name = 'munin-node'
      $plugin_share_dir = '/usr/local/libexec/munin/plugins'
      $file_group   = 'wheel'
    }
    default: {
      fail($message)
    }
  }
}


