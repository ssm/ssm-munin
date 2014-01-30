# Class: munin::params
#
class munin::params {
  case $::osfamily {
    RedHat: {
      $log_dir = '/var/log/munin-node'
    }
    Debian: {
      $log_dir = '/var/log/munin'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The munin::params module only supports osfamily Debian or RedHat (slaves only).")
    }
  }
}
