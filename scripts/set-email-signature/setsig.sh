#!/bin/bash

# This script sets the email signature for anyone
# who does not already have one by calling a
# script that invokes gam with commandline
# parameters for username, first, and last name.

EMAIL_ADDRS=/path/to/email/addrs.txt

set -e
set -u


for email in $(cat $EMAIL_ADDRS)
do
    # remove domain 
    user=$(echo $email | sed -e s/@.*//)

    # get first/last from LDAP
    first=$(getent passwd $user | awk -F: '{print $5}' | sed -e 's/,.*//' | awk  '{print $1}' )
    last=$(getent passwd $user | awk -F: '{print $5}' | sed -e 's/,.*//' | awk  '{print $2}' )

    none=$(gam user $user show signature 2>/dev/null | sed -e 's/ //')
    if [ "None" = "$none" ] ; then
         ./setsig.py --username $user --first $first --last $last
    fi
done

