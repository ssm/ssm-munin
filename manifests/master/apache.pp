# munin::master::apache - Manage the bundled apache.conf file settings
#
# Parameters
#
# - username: undef (default) or string value
#   Controls whether the munin web interface is visible remotely. If undef,
#   the web interface remains viewable on localhost only, with no login.
#   If a username is supplied, the munin web interface will be accessible
#   externally using the supplied username. See password.
#
# - password: undef (default) or string value
#   The password for the munin web interface. See username.
#
class munin::master::apache (
  $username = undef,
  $password = undef,
)
{

  if $username and $password {
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
      command => "htpasswd -b -c -m ${http_htpasswd_path} \"${username}\" \"${password}\"",
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
    content => template('munin/master/apache.conf.erb'),
    require => Package['munin'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

}
