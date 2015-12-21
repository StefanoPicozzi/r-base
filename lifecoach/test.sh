#!/bin/sh

PASSWORD=$1
echo $PASSWORD

cd /Users/stefanopicozzi/tnm/tnmbatch
echo "Hello 1" 
git pull
echo "Hello 2" 
git add .
echo "Hello 3" 
git commit -am "dolifecoach crontab batch script tnmbatch"
git push

echo "Hello 4" 
cd /Users/stefanopicozzi/websites/nudge
git pull
echo "Hello 5" 
git add images
git commit -am "dolifecoach crontab batch script website images"
git push

