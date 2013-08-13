# Changelog
	
## 0.0.3 - 2013-08-13

Bugfix for the munin::plugin define.

- Bugfix: No longer requires the class `Munin::Plugins`, which does
  not exist in this module.
  ([#3](https://github.com/ssm/ssm-munin/issues/3))

- The `ensure` attribute no longer defaults to "link". If not set, a
  potentially existing plugin with the same name is not touched.

- Plugin and configuration directories are now configurable.

- Improved rspec tests, which now actually match the documentation.

## 0.0.2 - 2013-06-31

A few pull requests

- Bugfix: Install munin package before creating munin-conf.d directory
  ([#1](https://github.com/ssm/ssm-munin/pull/1))

- Make graph strategy configurable
  ([#2](https://github.com/ssm/ssm-munin/pull/2))

- Improve documentation

## 0.0.1 - 2013-06-02

Initial release
