class munin::params::master {
  $message = "Unsupported osfamily ${::osfamily}"

  $graph_strategy   = 'cgi'
  $html_strategy    = 'cgi'
  $node_definitions = ''

  case $::osfamily {
    'Debian',
    'RedHat': {
      $config_root = '/etc/munin'
    }
    'Solaris': {
      $config_root = '/opt/local/etc/munin'
    }
    default: {
      fail($message)
    }
  }
}
