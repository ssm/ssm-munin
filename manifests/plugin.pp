# Define: munin::plugin
#
# Parameters:
#
# - ensure: link (default), present, absent
# - source: when ensure => present, source file
# - target: when ensure => link, link target
# - config: array of lines for munin plugin config
# - config_label: label for munin plugin config

define munin::plugin (
  $ensure=link,
  $source=undef,
  $target=undef,
  $config=undef,
  $config_label=undef
)
{

  $conf_dir='/etc/munin/plugin-conf.d'
  $plugin_dir='/etc/munin/plugins'
  $plugin_share_dir='/usr/share/munin/plugins'

  $plugin_source = $ensure ? {
    present => $source,
    default => undef,
  }

  $plugin_target = $ensure ? {
    link    => $target ? {
      ''      => "${plugin_share_dir}/${name}",
      default => "${plugin_share_dir}/${target}"
    },
    default => undef,
  }

  $config_ensure = $ensure ? {
        absent  => absent,
        default => present,
  }

  if $source or $target {
    # Install the plugin
    file {"${plugin_dir}/${name}":
      ensure  => $ensure,
      source  => $plugin_source,
      target  => $plugin_target,
      mode    => '0755',
      notify  => Service['munin-node'],
      require => Class['Munin::Plugins'],
    }
  }

  # Config
  if $config {
    file{"${conf_dir}/${name}.conf":
      ensure  => $config_ensure,
      content => template('munin/plugin_conf.erb'),
      notify  => Service['munin-node'],
    }
  }
}
