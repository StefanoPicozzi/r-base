#!/bin/sh

# www.openshift.com
# login: spicozzi@redhat.com
# app: nudge
# alias: www.satimetry.com

PASSWORD=$1

echo "Check jenkins server application status ..."
restart=`rhc app show --state jenkins -p $PASSWORD | egrep "idle|stopped" | wc -l`
if [ $restart != "0" ]; then
  echo "Jenkins Application is starting"
  rhc app start jenkins -p $PASSWORD
else
  echo "Jenkins Application is already started"
fi

echo "Check jenkins client application status ..."
restart=`rhc app show --state nudgebldr $PASSWORD | egrep "idle|stopped" | wc -l`
if [ $restart != "0" ]; then
  echo "Jenkins Application is starting"
  rhc app start nudgebldr -p $PASSWORD
else
  echo "Jenkins Client is already started"
fi

echo "Check nudge database application status ..."
restart=`rhc app show --state nudgedb -p $PASSWORD | egrep "idle|stopped" | wc -l`
if [ $restart != "0" ]; then
  echo "Nudge Database Application is starting"
  rhc app start nudgedb -p $PASSWORD
else
  echo "Nudge Database Application is already started"
fi

echo "Check nudge client application status ..."
restart=`rhc app show --state nudge -p $PASSWORD | egrep "idle|stopped" | wc -l`
if [ $restart != "0" ]; then
  echo "Nudge Client Application is starting"
  rhc app start nudge -p $PASSWORD
else
  echo "Nudge Client Application is already started"
fi

echo "Check nudge server application status ..."
restart=`rhc app show --state nudgeserver -p $PASSWORD | egrep "idle|stopped" | wc -l`
if [ $restart != "0" ]; then
  echo "Application is starting"
  rhc app start nudgeserver -p $PASSWORD
else
  echo "Nudge Server Application is already started"
fi

cd ~/tnm/tnmbatch/R/lifecoach

echo "Do Solar ..."
./dosolar/dosolar.R
