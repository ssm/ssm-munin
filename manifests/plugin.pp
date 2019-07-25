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
#   plugin directory, and the "source" parameter is required to
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
    Optional[String] $source=undef,
    String $target='',
    Optional[Array[String]] $config = [],
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
      content => epp('munin/plugin_conf.epp', { 'label' => $config_label, 'config' => $config }),
    }
}
