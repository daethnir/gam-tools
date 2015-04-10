#!/bin/bash
DIR='/opt/gam/gam-test'

#Create All Employee Group list 
/usr/bin/python ${DIR}/gam.py info group employees.all | grep '(user)' | sed -e 's/member://g' -e 's/manager://g' -e 's/owner://g' -e 's/(user)//g' -e 's/@test.aims.edu//g' -e 's/^[ \t]*//' -e 's/ *$//' | tr '[:upper:]' '[:lower:]' | /bin/sort > ${DIR}/EmployeesAllGroup.csv

#Compare Active Google Employee List to Current Employee Group list from Banner to see who needs to be removed                                             
awk 'FNR==NR {a[$1]++; next} !a[$1]' ${DIR}/allemployeegroupclean.csv ${DIR}/EmployeesAllGroup.csv > ${DIR}/RemoveUsersFromAllEmployeeGroup.csv

#Compare Employee Group from Banner to Google Active Employee List to see who needs to be added                                                                                  
awk 'FNR==NR {a[$1]++; next} !a[$1]' ${DIR}/EmployeesAllGroup.csv ${DIR}/allemployeegroupclean.csv > ${DIR}/AddUsersToAllEmployeeGroup.csv


#Add Users                                                                                                                                                          
/usr/bin/python ${DIR}/gam.py update group employees.all add file ${DIR}/AddUsersToAllEmployeeGroup.csv >> ${DIR}/event.log 2>&1

#Remove Users                                                                                                                                                      
/usr/bin/python ${DIR}/gam.py update group employees.all remove file ${DIR}/RemoveUsersFromAllEmployeeGroup.csv >> ${DIR}/event.log 2>&1
