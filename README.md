# Puppet module ssm-munin

[![Puppet Forge](https://img.shields.io/puppetforge/v/ssm/munin.svg)](https://forge.puppetlabs.com/ssm/munin)
[![Build Status](https://travis-ci.org/ssm/ssm-munin.png?branch=master)](https://travis-ci.org/ssm/ssm-munin)

- [Puppet module ssm-munin](#puppet-module-ssm-munin)
  - [Overview](#overview)
  - [Module Description](#module-description)
  - [Setup](#setup)
    - [Setup requirements](#setup-requirements)
  - [Usage](#usage)

## Overview

Configure munin master, node and plugins.

## Module Description

This module installs the munin master using the `munin::master` class, munin
node using the `munin::node` class, and can install, configure and manage munin
plugins using the `munin::plugin` defined type.

Munin nodes are automatically exported by the munin nodes, and collected on the
munin master. (Requires puppetdb)

## Setup

Add the Classify all nodes with `munin::node`, and classify at least one node
with `munin::master`. Use the `munin::plugin` defined type to control plugin
installation and configuration.

### Setup requirements

Munin should be available in most distributions. For RedHat OS Family, you need
to install the EPEL source.

The `munin::master` class does not manage any web server configuration. The
munin package installed might add some.

If your munin master is not on the same host as the munin node, you need to use
the `allow` parameter on the `munin::node` class.

## Usage

On each node, include the `munin::node` class. This will install munin-node,
and export a node definition to the Puppet DB that puppet will collect on the
munin server.

Use the `allow` parameter to permit the munin server to connect. In this
example, `192.0.2.1` and `2001:db8::1` are the IP addresses of the munin
server.

```puppet
class {'munin::node':
  allow => ['192.0.2.1', '2001:db8::1'],
}
```

On the munin server, include the `munin::master` class. This will collect the
node definitions from Puppet DB and configure munin to connect to nodes to
collect metrics.

To define additional nodes to collect metrics from, use the
`munin::master::node_definition` defined resource type.

You can define a set of node definitions for the `node_definitions` parameter
to the `munin::master` class. Defined in Hiera with YAML it may look something
like this:

```yaml
---
munin::master::node_definitions:
  foo.example.com:
    address: 192.0.2.12
  bar.example.com:
    address: 192.0.2.13
    config:
      - load.graph_future 30
      - load.load.trend yes
      - load.load.predict 86400,12
```

For advanced usage and additional examples, see the [ssm-munin
reference](REFERENCE.md).
