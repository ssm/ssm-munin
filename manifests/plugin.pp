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
# @param ensure [Enum['link','present','absent','']] The ensure
#    parameter is mandatory for installing a plugin.
#
# @param source [String] when ensure => present, path to a source file
#
# @param target [String] when ensure => link, link target.  If target
#   is an absolute path (starts with "/") it is used directly.  If
#   target is a relative path, $munin::node::plugin_share_dir is
#   prepended.
#
# @param config [Array[String]] Lines for the munin plugin config.
#
# @param config_label [String] Label for munin plugin config
define munin::plugin (
    Enum['','present','absent','link'] $ensure = '',
    Optional[String] $source=undef,
    String $target='',
    Optional[Array[String]] $config = undef,
    String $config_label = $title,
)
{

    include munin::node

    $plugin_share_dir = lookup('munin::node::plugin_share_dir', Stdlib::Absolutepath)
    $node_config_root = lookup('munin::node::config_root', Stdlib::Absolutepath)
    $node_package_name = lookup('munin::node::package_name', String)
    $node_service_name = lookup('munin::node::service_name', String)

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
            validate_absolute_path($plugin_target)
        }
        default: {
            $handle_plugin = false
        }
    }

    if $config {
        $config_ensure = $ensure ? {
            'absent'=> absent,
            default => present,
        }
    }
    else {
        $config_ensure = absent
    }


    if $handle_plugin {
        # Install the plugin
        file {"${node_config_root}/plugins/${name}":
            ensure => $plugin_ensure,
            source => $source,
            target => $plugin_target,
            mode   => '0755',
        }
    }

    # Config

    file{ "${node_config_root}/plugin-conf.d/${name}.conf":
      ensure  => $config_ensure,
      content => template('munin/plugin_conf.erb'),
    }
}
