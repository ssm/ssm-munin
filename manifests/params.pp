# Class: munin::params
#
class munin::params {
  $message = "Unsupported osfamily: ${::osfamily}"

  case $::osfamily {
    RedHat: {
      $log_dir = '/var/log/munin-node'
    }
    Debian: {
      $log_dir = '/var/log/munin'
    }
    Solaris: {
      case $::operatingsystem {
        SmartOS: {
          $log_dir = '/var/opt/log/munin'
        }
        default: {
          fail($message)
        }
      }
    }
    default: {
      fail($message)
    }
  }
}
