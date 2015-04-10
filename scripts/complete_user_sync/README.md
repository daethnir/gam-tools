
What this does
==============


This is a Bash based Linux script that takes a list of Users from our Oracle Database (Banner 9)

It then compares the file to a Current List of Google User and enables, disables, name changes, adds Users, change OU, updates passwords and adds user to Google Vault.

It then sends me a log file of all the changes. I also has some built in checks, like if it is going to enable or disable over a 100 users at a time to stop and email me.

Also if there are no updates, to not email me, and if there are any errors in the log file to send it to a larger group of people.
