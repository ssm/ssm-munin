class munin::params::node {

  $message = "Unsupported osfamily: ${::osfamily}"

  $address        = $::fqdn
  $allow          = []
  $masterconfig   = []
  $mastergroup    = ''
  $nodeconfig     = []
  $plugins        = {}
  $service_ensure = ''

  case $::osfamily {
    RedHat: {
      $config_root  = '/etc/munin'
      $log_dir      = '/var/log/munin-node'
      $service_name = 'munin-node'
      $package_name = 'munin-node'
    }
    Debian: {
      $config_root  = '/etc/munin'
      $log_dir      = '/var/log/munin'
      $service_name = 'munin-node'
      $package_name = 'munin-node'
    }
    Solaris: {
      case $::operatingsystem {
        SmartOS: {
          $config_root  = '/opt/local/etc/munin'
          $log_dir      = '/var/opt/log/munin'
          $service_name = 'smf:/munin-node'
          $package_name = 'munin-node'
        }
        default: {
          fail("Unsupported operatingsystem ${::operatingsystem} for osfamily ${::osfamily}")
        }
      }
    }
    default: {
      fail($message)
    }
  }
}


