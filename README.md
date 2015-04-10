
gam-tools
============

Tools that use the Google Apps Manager (GAM).

What is it?
===========

[GAM] is a free open source command line tool for Google Apps administrators
to manage domain and user settings quickly and easily.

GAM has some modes in which it can act in batch, by reading or exporting
CSV data. However sometimes you need something more custom.

This repository stores tools that use the gam code beyond the builtin
functionality. Typically these are scripts (bash, powershell) that call
gam based on other data sources.


How secure is the code in here?
===============================

Just because something is in here does not mean it has been
tested or guaranteed to work. It's your responsibility to read
the code and understand what it is doing.


Adding scripts to the repository
================================

Want to add here? Great! Here are the ground rules.

How do I get my changes into the repository?
--------------------------------------------

This is a standard github repo, so the normal processes are what
you need.

   * fork
   * make changes
   * issue a pull request

The main repo owner will integrate pull requests as soon as possible
and will only reject if they're clearly egregious, e.g. they have
huge binaries, or are an obvious security nightmare.

    
How should I organize contributions?
------------------------------------

Please create a directory with a README.md in the scripts directory
that explains what it does and any restrictions (e.g. only works in
GAM version X.Y and greater) for documentation.


What should I commit?
---------------------

Anything gam-utilizing code that you've written that could
be useful for others, presumably bash / powershell / etc scripts.

Binaries are not welcome at this time - source only.


Can I commit someone else's code?
---------------------------------

You can commit code that you get from others, for example that which
is found on the [GAM Mailing List], if you've gotten their permission
and they agree to the MIT license.


[GAM]: https://github.com/jay0lee/GAM/
[GAM Mailing List]: http://groups.google.com/group/google-apps-manager

