= Munin master

Typical usage:

  include munin::master

== JSON node definitions in hiera:

The munin master class will collect all
"munin::master::node_definition" exported by "munin::node".

For extra nodes, you can define them in hiera, and munin::master will
create them.

   {
     "munin::master::node_definitions" : {
       "foo.example.com" : {
         "address" : "192.0.2.1"
       },
       "bar.example.com" : {
         "address" : "192.0.2.2",
         "config" : [
           "load.graph_future 30",
           "load.load.trend yes",
           "load.load.predict 86400,12"
         ]
       }
     }
   }


= Munin node

Typical usage:

  include munin::node

Installs munin-node, and exports a munin::master::node_definition
which munin::master will collect.

= Munin plugins

The defined type munin::plugin is used to control the munin plugins used on a
munin node.

Typical usage:

 munin::plugin {

    # A plugin already installed. The use of "ensure => link" creates an
    # implicit "target => /usr/share/munin/plugins/$name".
    "apt":
        ensure => link;
    "ip_eth0":
        ensure => link,
        target => "ip_"; # look in /usr/share/munin/plugins or similar

    # A plugin we provide.  The use of "ensure => present" creates a file in
    # /etc/munin/plugins
    "somedaemon":
        ensure => present,
        source => "puppet:///munin/plugins/somedaemon";

    # A pair of plugins we provide, with a _name symlink
    "foo_bar":
        ensure => present,
        target => "foo_",
        source => "puppet:///munin/plugins/foo_";
    "foo_baz":
        ensure => present,
        target => "foo_",
        source => "puppet:///munin/plugins/foo_";

    # A plugin with configuration (creates an additional
    # /etc/munin/plugin-conf.d/$name.conf
    "bletch":
        ensure => link,
        config => "env.database flumpelump";
    "thud":
        ensure => present,
        source => "puppet:///munin/plugins/thud",
        config => ["env.database zotto", "user root"];

    # A plugin configuration file only
    "slapd":
	config => ["env.rootdn cn=admin,dc=example,dc=org"],
	config_label => "slapd_*";
  }
