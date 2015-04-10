#!/bin/bash

LOGDIR='/opt/gam/LOGS'
DIR='/opt/gam'
CSVDIR='/opt/gam/CSV/Email'
/bin/rm ${LOGDIR}/event.log ${LOGDIR}/eventswithvaultusers.log

#---Get Users List from Google---

#Create a list of All Users (Active/Suspended) from Google ordered by Email, remove @test.domain.edu from email address and / from org for comparison

/usr/bin/python ${DIR}/gam.py print users fullname ou suspended orderby email query 'orgUnitPath=/Student' > ${CSVDIR}/StudentAll.csv
/usr/bin/python ${DIR}/gam.py print users fullname ou suspended orderby email query 'orgUnitPath=/Employee' > ${CSVDIR}/EmployeeAll.csv
/usr/bin/python ${DIR}/gam.py print users fullname ou suspended orderby email query 'orgUnitPath=/Workstudy' > ${CSVDIR}/WorkstudyAll.csv
/usr/bin/python ${DIR}/gam.py print users fullname ou suspended orderby email query 'orgUnitPath=/Emeritus' > ${CSVDIR}/EmeritusAll.csv

#Append the files together, grep the user lines, sort alphabetical remove @test.domain.edu from email address and / from org, add CSV headers for comparison 
cat ${CSVDIR}/EmeritusAll.csv ${CSVDIR}/EmployeeAll.csv ${CSVDIR}/StudentAll.csv ${CSVDIR}/WorkstudyAll.csv | egrep 'Workstudy|Employee|Emeritus|Student' | sort | sed -e 's/@domain.edu//g' -e 's/\///g' -e '1s/^/Email,Lastname,FullName,Firstname,OU\n/' > ${CSVDIR}/GAMUSERLIST.csv

#append the files together, grep the user lines, sort alphabetical remove @test.domain.edu from email address and / from org, add CSV headers for comparison
cat ${CSVDIR}/EmeritusAll.csv ${CSVDIR}/EmployeeAll.csv ${CSVDIR}/StudentAll.csv ${CSVDIR}/WorkstudyAll.csv | grep ',False,' | sort | sed -e 's/@domain.edu//g' -e 's/\///g' -e '1s/^/Email,Lastname,Fullname,Firstname,OU,Suspended,SuspendedReason\n/' > ${CSVDIR}/GAMACTIVEUSERLIST.csv

#Append the files together, grep the user lines, sort alphabetical remove @test.domain.edu from email address and / from org, add CSV headers for comparison 
cat ${CSVDIR}/EmeritusAll.csv ${CSVDIR}/StudentAll.csv ${CSVDIR}/EmployeeAll.csv ${CSVDIR}/WorkstudyAll.csv | grep ',True,' | sort | sed -e 's/@domain.edu//g' -e 's/\///g' -e '1s/^/Email,Lastname,Fullname,Firstname,OU,Suspended,SuspendedReason\n/' > ${CSVDIR}/GAMSUSPENDEDUSERLIST.csv

#---Create, Suspend, and Enable Users---

#---Suspend Users---

#compare 1st column (username/email) from Banner Allusers and Google Users to create a suspend file, only print the first column (email/username)
awk -F, 'FNR==NR {a[tolower($1)]++; next} !a[tolower($1)] {print $1}' ${CSVDIR}/AllUsers.csv ${CSVDIR}/GAMACTIVEUSERLIST.csv | sed '1s/^/Email\n/' > ${CSVDIR}/SuspendUsers.csv

#Safety Check. If SuspendUsers has more than 100 lines,it will update passwords then cancel the Sync
if [[ $(wc -l < ${CSVDIR}/SuspendUsers.csv) -ge 100 ]]; then
/bin/rm ${LOGDIR}/Fail.log
#update passwords even if the rest of the script is canceled
/usr/bin/python ${DIR}/gam.py csv ${CSVDIR}/passwords.csv gam update user ~Email password ~Password >> ${LOGDIR}/Fail.log 2>&1
echo "Cancelling Sync, Check Suspended User List, Certain Days will require the Safety Check be disabled. To disable the safety check: Edit the BannerToGoogleSync.sh file on Proxy1 located in /opt/gam and comment out the Safety Check section, re run the script, then uncomment the section" >> ${LOGDIR}/Fail.log 
/bin/cat ${LOGDIR}/Fail.log | mailx -s "Sync Failed to many Users to Suspend" blank@domain.edu
exit
fi;
 
/bin/echo "Suspended Users" >> ${LOGDIR}/event.log
/bin/echo "" >> ${LOGDIR}/event.log

#upload/suspend users ~ references the CSV header from file                                                                                                                         
/usr/bin/python ${DIR}/gam.py csv ${CSVDIR}/SuspendUsers.csv gam update user ~Email suspended on >> ${LOGDIR}/event.log 2>&1

#---Re-Enable Users---

#compare 1st column from Banner Allusers to Google Suspended Users to create reenable file, only print first column (email/username) of accounts in both files (no need to added 'Email' header because it is one of the lines in common)
awk -F, 'FNR==NR {a[tolower($1)]++; next} a[tolower($1)] {print $1,$4}' OFS="," ${CSVDIR}/GAMSUSPENDEDUSERLIST.csv ${CSVDIR}/AllUsers.csv > ${CSVDIR}/ReEnableUsers.csv

#Safety Check. If ReEnableUsers has more than 100 lines, it will update passwords then cancel the sync
if [[ $(wc -l < ${CSVDIR}/ReEnableUsers.csv) -ge 100 ]]; then
/usr/bin/python ${DIR}/gam.py csv ${CSVDIR}/passwords.csv gam update user ~Email password ~Password >> ${LOGDIR}/fail.log 2>&1
echo "Cancelling Sync, Check ReEnableUser List" >> ${LOGDIR}/Fail.log 
/bin/cat ${LOGDIR}/Fail.log | mailx -s "Sync Failed to many Users to Re-Enable" blank@domain.edu
exit
fi;

/bin/echo "Re-Enabled Suspended Users" >> ${LOGDIR}/event.log
/bin/echo "" >> ${LOGDIR}/event.log

#upload/renable suspended users ~ reference the CSV Header from the File
/usr/bin/python ${DIR}/gam.py csv ${CSVDIR}/ReEnableUsers.csv gam update user ~Email password ~Password suspended off >> ${LOGDIR}/event.log 2>&1

#---Create New Users---

#compare 1st column (username/email) from Google ALLUserlist and BannerAllusers to create new user file with all columns
awk -F, 'FNR==NR {a[tolower($1)]++; next} !a[tolower($1)]' ${CSVDIR}/GAMUSERLIST.csv ${CSVDIR}/AllUsers.csv | sed '1s/^/Email,Firstname,Lastname,Password,OU\n/' > ${CSVDIR}/NewUsers.csv

/bin/echo "New Users" >> ${LOGDIR}/event.log
/bin/echo "" >> ${LOGDIR}/event.log

#upload/create the new users ~ references the CSV header from the file
/usr/bin/python ${DIR}/gam.py csv ${CSVDIR}/NewUsers.csv gam create user ~Email firstname ~Firstname lastname ~Lastname password ~Password org ~OU >> ${LOGDIR}/event.log 2>&1

#---Change Org---

#compare AllUsers to GAMUERSLIST on column 1 (username/email) and export 1st column (username) and 5th column (ORG) of matching username
awk -F, 'FNR==NR {a[tolower($1)]++; next} a[tolower($1)] {print $1,$5}' OFS="," ${CSVDIR}/GAMUSERLIST.csv ${CSVDIR}/AllUsers.csv > ${CSVDIR}/matchingusersorg.csv

#compare matchingusers file to GAMUSERLIST.csv on username and org, export differences, add CSV headers
awk -F, 'FNR==NR {a[tolower($1 FS $5)]++; next} !a[tolower($1 FS $2)]' ${CSVDIR}/GAMUSERLIST.csv ${CSVDIR}/matchingusersorg.csv | sed '1s/^/Email,OU\n/' > ${CSVDIR}/ChangeOrg.csv

#/bin/echo "" >> ${LOGDIR}/event.log
/bin/echo "Users with Org Change" >> ${LOGDIR}/event.log
/bin/echo "" >> ${LOGDIR}/event.log

#run command to change org, ~ references CSV Header
/usr/bin/python ${DIR}/gam.py csv ${CSVDIR}/ChangeOrg.csv gam update user ~Email org ~OU >> ${LOGDIR}/event.log 2>&1

#---Make Changes to Active Users---

#---Change First/Last Name---

#compare AllUsers to GAMUERSLIST on column 1 (username/email) and export 1st (username), 2nd (first), 3rd (last) column of matching username
awk -F, 'FNR==NR {a[tolower($1)]++; next} a[tolower($1)] {print $1,$2,$3}' OFS="," ${CSVDIR}/GAMUSERLIST.csv ${CSVDIR}/AllUsers.csv > ${CSVDIR}/matchingusersfirstlast.csv

#compare matchingusers file to GAMUSERLIST.csv on username, first, and last. export differences, add CSV headers
awk -F, 'FNR==NR {a[tolower($1 FS $4 FS $2)]++; next} !a[tolower($1 FS $2 FS $3)]' ${CSVDIR}/GAMUSERLIST.csv ${CSVDIR}/matchingusersfirstlast.csv | sed '1s/^/Email,Firstname,Lastname\n/' > ${CSVDIR}/ChangeFirstLast.csv

#/bin/echo "" >> ${LOGDIR}/event.log
/bin/echo "Users with First or Last Name Changes" >> ${LOGDIR}/event.log
/bin/echo "" >> ${LOGDIR}/event.log

#run command to change first/last name, ~ references CSV Header
/usr/bin/python ${DIR}/gam.py csv ${CSVDIR}/ChangeFirstLast.csv gam update user ~Email firstname ~Firstname lastname ~Lastname >> ${LOGDIR}/event.log 2>&1

#---Update User Passwords---

#/bin/echo "" >> ${LOGDIR}/event.log
/bin/echo "Users with Password Update" >> ${LOGDIR}/event.log
/bin/echo "" >> ${LOGDIR}/event.log

#updating passwords that were changed in Banner in the last 3 hours and 5 minutes (3 hours instead of every 2, because the banner email creation script only runs every 3 hours, making the passwords pull overlap will prevent any possible password updates that did not yet have email accounts created, the 5 minutes prevents possible misses on how long it takes to run the scripts)
/usr/bin/python ${DIR}/gam.py csv ${CSVDIR}/passwords.csv gam update user ~Email password ~Password >> ${LOGDIR}/event.log 2>&1

#---Google VAULT---

#Pull down list of Vault Users, get just the username
/usr/bin/python ${DIR}/gam.py print licenses | grep '@domain.edu' | sed -e 's/Google-Vault,//g' -e 's/,Google-Vault//g' -e 's/@domain.edu//g' | tr '[:upper:]' '[:lower:]' | sort > ${CSVDIR}/VaultUsers.csv

#Pull down list of current active employees and generic accounts in Google, remove certain generic type accounts from the list (like room.xxx for calendars, and some training accounts)
/usr/bin/python ${DIR}/gam.py print users orderby email query 'orgUnitPath=/Employee IsSuspended=False' | sed -e 's/@domain.edu//g' | grep "\." | sed -e 's/$/@domain.edu/g' > ${CSVDIR}/EmployeeActive.csv
/usr/bin/python ${DIR}/gam.py print users orderby email query 'orgUnitPath=/Generic IsSuspended=False' | sed -e '/outlook.training/d' -e '/community/d' -e '/room./d' -e '/smartpendas/d' > ${CSVDIR}/GenericActive.csv

#put the files together to make one active list with just username
cat ${CSVDIR}/EmployeeActive.csv ${CSVDIR}/GenericActive.csv | grep '@domain.edu' | sed -e 's/@domain.edu//g' | tr '[:upper:]' '[:lower:]' | sort > ${CSVDIR}/EmployeeGenericActive.csv

#compare EmployeeGenericActive.csv and VaultUsers.csv to see who needs to be added
awk 'FNR==NR {a[$1]++; next} !a[$1]' ${CSVDIR}/VaultUsers.csv ${CSVDIR}/EmployeeGenericActive.csv > ${CSVDIR}/AddUsersToVault.csv

/bin/echo "List of Users supposed to be added to Vault" >> ${LOGDIR}/event.log
/bin/echo "" >> ${LOGDIR}/event.log

#add the new users to Vault. Exporting to the Event Log for Errors only, Successful results do not create an output like Groups does.
/usr/bin/python ${DIR}/gam.py file ${CSVDIR}/AddUsersToVault.csv add license Vault Google-Vault >> ${LOGDIR}/event.log 2>&1

#Vault GAM Code does not output added Users info, Adding the New Vault Users File to show new users instead
/bin/cat ${LOGDIR}/event.log ${CSVDIR}/AddUsersToVault.csv > ${LOGDIR}/eventswithvaultusers.log

#We currently do not remove Users from Vault, this policy may change, if you remove a license we will lose any deleted emails

#Email

#if no accounts are updated do not send email (if an account was updated a @ symbol would be in the log file)
AT_SYMBOL_EXIST=$(cat ${LOGDIR}/eventswithvaultusers.log | grep @)
if [ $? -eq 1 ]
 then
 exit
 fi

#if there is an error in the log send to blank@domain.edu (if an error exist the word 'error' will be in the log file)
ERROR_EXIST=$(cat ${LOGDIR}/eventswithvaultusers.log | grep -i error)
if [ $? -eq 0 ]
 then
/bin/cat ${LOGDIR}/eventswithvaultusers.log | sed -e 's/starting 5 worker threads...//g' -e 's/updating user//g' -e 's/Creating account for //g' -e 's/^[ \t]*//' | mailx -s "Error in Google Sync" blank@domain.edu
 exit
 fi

#if at least one account was update and no Errors were encountered send email to just Andrew
/bin/cat ${LOGDIR}/eventswithvaultusers.log | sed -e 's/starting 5 worker threads...//g' -e 's/updating user//g' -e 's/adding member//g' -e 's/Creating account for //g' -e 's/added.* to group//g' -e 's/^[ \t]*//' | mailx -s "User Update/Creation Results" blank1+google@domain.edu
 
#Remove Files after sync that include password in plain text
rm -rf ${CSVDIR}/ReEnableUsers.csv ${CSVDIR}/NewUsers.csv ${CSVDIR}/passwords.csv ${CSVDIR}/AllUsers.csv

