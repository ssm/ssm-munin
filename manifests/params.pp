# Class: munin::params
#
class munin::params {
  case $::osfamily {
    RedHat: {
      $log_file = '/var/log/munin-node/munin-node.log'
    }
    Debian: {
      $log_file = '/var/log/munin/munin-node.log'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The munin:params module only supports osfamily Debian or RedHat (slaves only).")
    }
  }
}
