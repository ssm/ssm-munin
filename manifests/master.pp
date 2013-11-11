# munin::master - Define a munin master
#
# The munin master will install munin, and collect all exported munin
# node definitions as files into /etc/munin/munin-conf.d/.
#
# Parameters:
#
# - node_definitions: A hash of node definitions used by
#   create_resources to make static node definitions.
#
# - graph_strategy: 'cgi' (default) or 'cron'
#   Controls if munin-graph graphs all services ('cron') or if graphing is done
#   by munin-cgi-graph (which must configured seperatly)
#
# - html_strategy: 'cgi' (default) or 'cron'
#   Controls if munin-html will recreate all html pages every run interval
#   ('cron') or if html pages are generated by munin-cgi-graph (which must
#   configured seperatly)
#
# - http_username: undef (default) or string value
#   Controls whether the munin web interface is visible remotely. If undef,
#   the web interface remains viewable on localhost only, with no login.
#   If a username is supplied, the munin web interface will be accessible
#   externally using the supplied username. See http_password.
#
# - http_password: undef (default) or string value
#   The password for the munin web interface. See http_username.
#   
class munin::master (
  $node_definitions={},
  $graph_strategy = 'cgi',
  $html_strategy = 'cgi',
  $http_username = undef,
  $http_password = undef,
  ) {

  # The munin package and configuration
  package { 'munin':
    ensure => latest,
  }

  file { '/etc/munin/munin.conf':
    content => template('munin/munin.conf.erb'),
    require => Package['munin'],
    owner   => 'root',
    group   => 'munin',
    mode    => '0444',
  }

  file { '/etc/munin/munin-conf.d':
    ensure  => directory,
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['munin'],
  }

  # The munin web interface options

  if $http_username and $http_password {
    $http_remote_access = true 
  } else {
    $http_remote_access = false 
  }

  if $http_remote_access == true {

    $http_htpasswd_path = '/etc/munin/munin-htpasswd'

    # Regenerate the file each time so the password always matches the
    # passed Puppet param
    exec { 'remove-htpasswd-file':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      onlyif  => "test -f ${http_htpasswd_path}",
      command => "rm ${http_htpasswd_path}",
      require => Package['munin'],
    }

    exec { "create-htpasswd-file":
      path    => "/bin:/sbin:/usr/bin:/usr/sbin",
      command => "htpasswd -b -c -m ${http_htpasswd_path} \"${http_username}\" \"${http_password}\"",
      require => Exec['remove-htpasswd-file'],
    }

    file { $http_htpasswd_path:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Exec['create-htpasswd-file'],
    }

  }

  file { '/etc/munin/apache.conf':
    content => template('munin/apache.conf.erb'),
    require => Package['munin'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Collect all exported node definitions
  Munin::Master::Node_definition <<| |>>

  # Create static node definitions
  create_resources(munin::master::node_definition, $node_definitions, {})
}
