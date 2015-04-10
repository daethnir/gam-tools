

setsig
============

This tool has two components.

WARNING
=======


These scripts are sanitized versions of our real ones.
As such, you will be expected to fix as needed,
They have had minimal testing.


setsig.py
=========

This script takes command line options and generates a 'dynamic'
signature (based on username/first/last) and sets the signature
for the user.

You should change the actual signature content block to what you
like (perhaps adding your personal flair/branding), as well as
the globals at the top that define domains and such.

Should run anywhere python works.

setsig.sh
=========

Reads a list of usernames and, if the user does not have
a signature already defined, calls setsig.py to set it.

Pulls the first/last name info (inelegantly) from the gecos
field.

Should run on POSIX (e.g. Linux) systems where user info is 
available via getent.
