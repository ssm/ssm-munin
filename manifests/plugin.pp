# @summary Install and configure munin plugins
#
# @example Activate a packaged plugin
#   munin::plugin { 'cpu':
#     ensure => link,
#   }
#
# @example Activate a packaged wildcard plugin
#   munin::plugin { 'foo_bar':
#     ensure => link,
#     target => 'foo_',
#   }
#
# @example Install and activate a plugin
#   munin::plugin { 'gazonk':
#     ensure => present,
#     source => 'puppet:///modules/profile/foo/monitoring/gazonk',
#   }
#
# @example A plugin with configuration
#   munin::plugin { 'bletch':
#     ensure => link,
#     config => ['env.database thing', 'user bletch'],
#   }
#
# @example A plugin configuration file, but no plugin
#   munin::plugin { 'slapd':
#     config       => ['env.rootdn cn=admin,dc=example,dc=org'],
#     config_label => 'slapd_*',
#   }
#
# @param ensure
#
#   The ensure parameter is mandatory for installing a plugin.
#
#   With "ensure => link", a symlink is created in the munin plugin
#   directory to where the plugin file is installed.
#
#   With "ensure => present", the plugin is installed in the munin
#   plugin directory, and the "source" or "content" parameter is required to
#   provide a source for the plugin.
#
#   With "ensure => absent", remove the munin plugin.
#
#   When **ensure** is not set, a plugin will not be installed, but
#   extra plugin configuration can be managed with the **config** and
#   **config_label** parameters.
#
# @param source
#
#   When ensure => present, path to a source file
#
# @param content
#
#   When ensure => present, content of the plugin.
#
# @param checksum
#
#   Checksum type for the plugin file.
#
# @param checksum_value
#
#   Checksum value for the plugin file.
#
# @param target
#
#   When "ensure => link", Add a link in the plugin directory to the
#   link target.
#
#   If target is an absolute path (starts with "/") it is used
#   directly.
#
#   If target is a relative path, $munin::node::plugin_share_dir is
#   prepended.
#
#   If target is unset, a link is created to a plugin with the same
#   name in the packaged $munin::node:: plugin_share_dir directory.
#   (In other words, activate a plugin that is already installed)
#
# @param config
#
#   Lines for the munin plugin config.
#
# @param config_label
#
#   Label for munin plugin config
#
define munin::plugin (
  Enum['','present','absent','link'] $ensure = '',
  Optional[String] $source = undef,
  Optional[String[1]] $content = undef,
  Optional[String[1]] $checksum = undef,
  Optional[String[1]] $checksum_value = undef,
  String $target = '',
  Optional[Array[String]] $config = [],
  String $config_label = $title,
) {
  include munin::node

  $plugin_share_dir = $munin::node::plugin_share_dir
  $node_config_root = $munin::node::config_root
  $node_package_name = $munin::node::package_name
  $node_service_name = $munin::node::service_name

  File {
    require => Package[$node_package_name],
    notify  => Service[$node_service_name],
  }

  case $ensure {
    'present', 'absent': {
      $handle_plugin = true
      $plugin_ensure = $ensure
      $plugin_target = undef
    }
    'link': {
      $handle_plugin = true
      $plugin_ensure = 'link'
      case $target {
        '': {
          $plugin_target = "${plugin_share_dir}/${title}"
        }
        /^\//: {
          $plugin_target = $target
        }
        default: {
          $plugin_target = "${plugin_share_dir}/${target}"
        }
      }
      assert_type(Stdlib::Absolutepath, $plugin_target)
    }
    default: {
      $handle_plugin = false
    }
  }

  if ! $config.empty {
    $config_ensure = $ensure ? {
      'absent'=> absent,
      default => present,
    }
  } else {
    $config_ensure = absent
  }

  if $handle_plugin {
    # Install the plugin
    file { "${node_config_root}/plugins/${name}":
      ensure         => $plugin_ensure,
      source         => $source,
      content        => $content,
      target         => $plugin_target,
      mode           => '0755',
      checksum       => $checksum,
      checksum_value => $checksum_value,
    }
  }

  # Config
  file { "${node_config_root}/plugin-conf.d/${name}.conf":
    ensure  => $config_ensure,
    content => epp("${module_name}/plugin_conf.epp",
      {
        'label'  => $config_label,
        'config' => $config,
      },
    ),
  }
}
