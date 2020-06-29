---
name: Bug report
about: Create a report to help us improve the Munin module for Puppet
title: ''
labels: bug
assignees: ''

---

<!-- Please use this template while reporting a bug. If you are able
to provide the relevant information, this will make it easier for me
to reproduce the problem and address it properly.

If any of the sections are irrelevant, feel free to delete them, or
file a blank issue.

Thank you for taking the time to report a bug. -->

**Expected behavior**

Please describe the behavior you are expecting.

**Current behavior**

What happens instead of the expected behavior?

**Steps to reproduce**

Please provide steps for reproducing the issue.

Example:

1. Use puppet version X on OS Y
1. Install module with `puppet module install ssm/munin`
1. Run `puppet apply bug.pp` with the following manifest:

```puppet
class { 'munin::master': }
class { 'munin::node': }
```

**Failure logs**

If you can, please include any relevant log snippets or files here.

```
Paste logs into a code block.
```
