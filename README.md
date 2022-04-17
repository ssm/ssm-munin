# Puppet module ssm-munin

[![Puppet Forge](https://img.shields.io/puppetforge/v/ssm/munin.svg)](https://forge.puppetlabs.com/ssm/munin)
[![Build Status](https://travis-ci.org/ssm/ssm-munin.png?branch=master)](https://travis-ci.org/ssm/ssm-munin)

- [Puppet module ssm-munin](#puppet-module-ssm-munin)
  - [Overview](#overview)
  - [Module Description](#module-description)
  - [Setup](#setup)
    - [Setup requirements](#setup-requirements)
  - [Usage](#usage)
    - [munin::node](#muninnode)
      - [Export extra nodes](#export-extra-nodes)
    - [munin::master](#muninmaster)
    - [munin::master::node_definition](#muninmasternode_definition)
  - [Examples](#examples)
    - [munin::master::node_definition](#muninmasternode_definition-1)
      - [Static node definitions](#static-node-definitions)
      - [node definitions as class parameter](#node-definitions-as-class-parameter)
      - [node definitions with hiera](#node-definitions-with-hiera)
    - [munin::node](#muninnode-1)
      - [Allow remote masters to connect](#allow-remote-masters-to-connect)
    - [munin::plugin](#muninplugin)
      - [Activate a plugin](#activate-a-plugin)
      - [Install and activate a plugin](#install-and-activate-a-plugin)
      - [Activate wildcard plugin](#activate-wildcard-plugin)
      - [Plugin with configuration](#plugin-with-configuration)
      - [A plugin configuration file](#a-plugin-configuration-file)

## Overview

Configure munin master, node and plugins.

## Module Description

This module installs the munin master using the `munin::master` class, munin
node using the `munin::node` class, and can install, configure and manage munin
plugins using the `munin::plugin` defined type.

Munin nodes are automatically exported by the munin nodes, and collected on the
munin master. (Requires puppetdb)

## Setup

Classify all nodes with `munin::node`, and classify at least one node with
`munin::master`. Use the `munin::plugin` defined type to control plugin
installation and configuration.

### Setup requirements

Munin should be available in most distributions. For RedHat OS Family, you need
to install the EPEL source.

The `munin::master` class does not manage any web server configuration. The
munin package installed might add some.

## Usage

For detailed usage, see the [reference](REFERENCE.md).

### munin::node

Typical usage

```puppet
include munin::node
```

Installs a munin node.

By default, `munin::node` exports a munin node definition so a node classified
with the `munin::master` class can collect it.

#### Export extra nodes

If `munin::node::export_node` is enabled, you may export additional nodes with
the `munin::node::export::node_definitions` hash. These are exported as
`munin::master::node_definition` resources. They will be associated with the
same mastername as the node itself.

### munin::master

Typical usage:

```puppet
include munin::master
```

Installs a munin master.

By default, `munin::master` collects all munin node definitions exported by
nodes classified with `munin::node`.

### munin::master::node_definition

This will add configuration for the munin master to connect to a munin node,
and ask for data from its munin plugins.

Note: By default, the node classified with `munin::master` will collect all all
exported instances of this type from hosts classified with `munin::node`.

The resource title is used as the munin FQN, or "fully qualified name". This
defines the node name and group. It is common to use the host's fully qualified
domain name, where the domain name will be implicitly used as the node group.

For more information about configuring a munin node definition, see
<https://munin.readthedocs.io/en/latest/reference/munin.conf.html#node-definitions>

If you have multiple munin master servers in your infrastructure and want to
assign different nodes to different masters, you can specify the master's fully
qualified domain name on the node's definition:

```puppet
munin::master::node_definition { 'fqn':
  address    => $address,
  mastername => 'munin.example.com',
}
```

## Examples

### munin::master::node_definition

#### Static node definitions

The munin master class will collect all `munin::master::node_definition`
exported by `munin::node`.

For extra nodes, you can define them in hiera data for the master server, and
munin::master will create them. Example:

```puppet
munin::master::node_definition { 'foo.example.com':
  address => '192.0.2.1',
}
munin::master::node_definition { 'bar.example.com':
  address => '192.0.2.1',
  config  => [ 'load.graph_future 30',
               'load.load.trend yes',
               'load.load.predict 86400,12' ],
}
```

See also `munin::node::export::node_definitions` for extra nodes declared on
the clients.

#### node definitions as class parameter

If you define your nodes as a data structure in a puppet manifest, or from the
puppet External Node Classifier, you can use a class parameter:

```puppet
$nodes = { ... }

class { 'puppet::master':
  node_definitions => $nodes,
}
```

#### node definitions with hiera

A JSON definition.

```json
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
```

A YAML definition

```yaml
---
munin::master::node_definitions:
  foo.example.com:
    address: 192.0.2.1
  bar.example.com:
    address: 192.0.2.2
    config:
    - load.graph_future 30
    - load.load.trend yes
    - load.load.predict 86400,12
```

### munin::node

#### Allow remote masters to connect

The `allow` parameter enables the munin master to connect. By default, the
munin node only permits connections from localhost.

```puppet
class { 'munin::node':
  allow => [ '192.0.2.0/24', '2001:db8::/64' ]
}
```

or in hiera:

```yaml
---
munin::node::allow:
  - 192.0.2.0/24
  - 2001:db8::/64
```

Installs munin-node, and exports a `munin::master::node_definition` which
`munin::master` will collect, and allows munin masters on specified networks to
connect.

### munin::plugin

#### Activate a plugin

Here, we activate an already installed plugin.

The use of `ensure => link` creates an implicit
`target => "/usr/share/munin/plugins/${title}"`.

The `target` parameter can be set to an absolute path (starting with a "/"), or
a relative path (anything else). If relative,
`$munin::params::node::plugin_share_dir` is prepended to the path.

```puppet
munin::plugin {
  'apt':
    ensure => link;
  'something':
    ensure => link,
    target => '/usr/local/share/munin/plugins/something';
  'ip_eth0':
    ensure => link,
    target => 'ip_'; # becomes $munin::params::node::plugin_share_dir/ip_
}
```

#### Install and activate a plugin

The use of "ensure => present" creates a file in /etc/munin/plugins

```puppet
munin::plugin { 'somedaemon':
  ensure => present,
  source => 'puppet:///modules/munin/plugins/somedaemon',
}
```

#### Activate wildcard plugin

A pair of plugins we provide, with a _name symlink (This is also known as
"wildcard" plugins)

```puppet
munin::plugin {
  'foo_bar':
    ensure => present,
    target => 'foo_',
    source => 'puppet:///modules/munin/plugins/foo_';
  'foo_baz':
    ensure => present,
    target => 'foo_',
    source => 'puppet:///modules/munin/plugins/foo_';
}
```

#### Plugin with configuration

This creates an additional `/etc/munin/plugin-conf.d/${title}.conf`

```puppet
munin::plugin {
  'bletch':
    ensure => link,
    config => 'env.database flumpelump';
  'thud':
    ensure => present,
    source => 'puppet:///modules/munin/plugins/thud',
    config => ['env.database zotto', 'user root'];
}
```

#### A plugin configuration file

This adds a plugin configuration file, but does not manage the plugin.

```puppet
munin::plugin { 'slapd':
  config       => ['env.rootdn cn=admin,dc=example,dc=org'],
  config_label => 'slapd_*',
}
```
