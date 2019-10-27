---
name: Bug report
about: Create a report to help us improve the Munin module for Puppet
title: ''
labels: bug
assignees: ''

---

<!-- Please use this template while reporting a bug. If you are able
to provide the relevant information, this will make it easier for me
to reproduce the problem and address it properly. Thank you :) -->

**Expected Behavior**

Please describe the behavior you are expecting.

**Current Behavior**

What is the current behavior?

**Failure Information (for bugs)**

Please help provide information about the failure if this is a bug.

* Use verbose outputs to capture any debug information.

```
Paste output into a code block.
```

**Steps to Reproduce**

Please provide detailed steps for reproducing the issue.

Example:

1. Use puppet version X on OS Y
1. Install module with `puppet module install ssm/munin`
1. Run `puppet apply bug.pp` with the following manifest:

```puppet
class { 'munin::master': }
class { 'munin::node': }
```

1. Watch X happen

**Context**

Please provide any relevant information about your setup. This is
important in case the issue is not reproducible except for under
certain conditions.

* Version of project.
* Version of dependencies.
* Version of operating system.

**Failure Logs**

Please include any relevant log snippets or files here.

* Use verbose outputs to capture any debug information.

```
Paste logs into a code block.
```
