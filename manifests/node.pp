# @summary configure a munin node
#
# Configure a munin node, and export configuration a munin master can
# collect.
#
# @see http://guide.munin-monitoring.org/en/latest/
#
# @example Basic usage
#  include munin::node
#
# @param allow [Array] List of IPv4 and IPv6 addresses and networks to
#   allow to connect.
#
# @param config_root [String] Root directory for munin configuration.
#
# @param nodeconfig [Array[String]] List of lines to append to the
#   munin node configuration.
#
# @param host_name [String] The host name munin node identifies
#   as. Defaults to the $::fqdn fact.
#
# @param log_dir [String] The log directory for the munin node
#   process. Defaults change according to osfamily, see
#   munin::params::node for details.
#
# @param log_file [String] File name for the log file, this is
#   appended to "log_dir". Defaults to "munin-node.log".
#
# @param log_destination [Enum['file','syslog']]: "file" or "syslog".
#   Defaults to "file".  If log_destination is "syslog", the
#   "log_file" and "log_dir" parameters are ignored, and the
#   "syslog_*" parameters are used if set.
#
# @param purge_configs [Boolean] Removes all other munin plugins and
#   munin plugin configuration files.  Boolean, defaults to false.
#
# @param syslog_facility [Optional[String]]: Defaults to undef, which
#   makes munin-node use the perl Net::Server module default of
#   "daemon". Possible values are any syslog facility by number, or
#   lowercase name.
#
# @param masterconfig [Array[String]] List of configuration lines to
#   append to the munin master node definitinon
#
# @param mastername [String] The name of the munin master server which
#   will collect the node definition.
#
# @param mastergroup [String] The group used on the master to
#   construct a FQN for this node. Defaults to "", which in turn makes
#   munin master use the domain. Note: changing this for a node also
#   means you need to move rrd files on the master, or graph history
#   will be lost.
#
# @param plugins [Hash] A hash used by create_resources to create
#   munin::plugin instances.
#
# @param address [String] The address used in the munin master node
#   definition.
#
# @param bind_address [String] The IP address the munin-node process
#   listens on. Defaults: *.
#
# @param bind_port [String] The port number the munin-node process
#   listens on.
#
# @param package_name [String] The name of the munin node package to
#   install.
#
# @param service_name [String] The name of the munin node service.
#
# @param service_ensure Used as parameter "ensure" for the munin node
#   service.
#
# @param export_node [Enum['enabled','disabled']]: "enabled" or
#   "disabled". Defaults to "enabled".  Causes the node config to be
#   exported to puppetmaster.
#
# @param file_group [String] The UNIX group name owning the
#   configuration files, log files, etc.
#
# @param timeout [Optional[Integer]] Used to set the global plugin
#   runtime timeout for this node. Defaults to undef, which lets
#   munin-node use its default of 10 seconds.
class munin::node (
  String                          $address,
  Array                           $allow,
  Variant[Enum['*'],Stdlib::Host] $bind_address,
  Stdlib::Port                    $bind_port,
  Stdlib::Absolutepath            $config_root,
  Stdlib::Host                    $host_name,
  Stdlib::Absolutepath            $log_dir,
  String                          $log_file,
  Array                           $masterconfig,
  Optional[String]                $mastergroup,
  Optional[Stdlib::Host]          $mastername,
  Array                           $nodeconfig,
  String                          $package_name,
  Hash                            $plugins,
  Boolean                         $purge_configs,
  Enum['running','stopped']       $service_ensure,
  String                          $service_name,
  Enum['enabled','disabled']      $export_node,
  String                          $file_group,
  Enum['file','syslog']           $log_destination,
  Optional[
    Variant[
      Integer[0,23],
      Enum[
        'kern','user','mail','daemon','auth','syslog','lpr','news','uucp',
        'authpriv','ftp','cron','local0','local1','local2','local3','local4',
        'local5','local6','local7'
      ]]] $syslog_facility,
  Optional[Integer[0]] $timeout         = $munin::params::node::timeout, # Integer?
) {

  case $log_destination {
    'file': {
      $_log_file = "${log_dir}/${log_file}"
      validate_absolute_path($_log_file)
    }
    'syslog': {
      $_log_file = 'Sys::Syslog'
    }
    default: {
      fail('log_destination is not set')
    }
  }

  if $mastergroup {
    $fqn = "${mastergroup};${host_name}"
  }
  else {
    $fqn = $host_name
  }

  if $service_ensure { $_service_ensure = $service_ensure }
  else { $_service_ensure = undef }

  # Defaults
  File {
    ensure => present,
    owner  => 'root',
    group  => $file_group,
    mode   => '0444',
  }

  package { $package_name:
    ensure => installed,
  }

  service { $service_name:
    ensure  => $_service_ensure,
    enable  => true,
    require => Package[$package_name],
  }

  file { "${config_root}/munin-node.conf":
    content => template('munin/munin-node.conf.erb'),
    require => Package[$package_name],
    notify  => Service[$service_name],
  }

  # Export a node definition to be collected by the munin master.
  # (Separated into its own class to prevent warnings about "missing
  # storeconfigs", even if $export_node is not enabled)
  if ($settings::storeconfigs == 'true' and $export_node == 'enabled') {
    class { '::munin::node::export':
      address      => $address,
      fqn          => $fqn,
      mastername   => $mastername,
      masterconfig => $masterconfig,
    }
  }

  # Generate plugin resources from hiera or class parameter.
  create_resources(munin::plugin, $plugins, {})

  # Purge unmanaged plugins and plugin configuration files.
  if $purge_configs {
    file { ["${config_root}/plugins", "${config_root}/plugin-conf.d" ]:
      ensure  => directory,
      recurse => true,
      purge   => true,
      require => Package[$package_name],
      notify  => Service[$service_name],
    }
  }

}
