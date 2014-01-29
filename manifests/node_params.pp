# Class: munin::node::params
#
class munin::node::params {
  case $::osfamily {
    RedHat: {
      $logfile = '/var/log/munin-node/munin-node.log'
    }
    Debian: {
      $logfile = '/var/log/munin/munin-node.log'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The munin:node module only supports osfamily Debian or RedHat (slaves only).")
    }
  }
}
