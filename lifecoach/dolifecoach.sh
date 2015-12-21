#!/bin/sh

PASSWORD=$1

echo "*****************************************************************************"
date
echo "*****************************************************************************"

cd ~/GitHub/tnmbatch/R/lifecoach

# echo "Do fitbit steps ..."
./dofitbit/dofitbit.R

echo "Do fitbit weight ..."
./dowithings/dowithings.R

#echo "Do weightwatcher ..."
./doweightwatcher/doweightwatcher.R

echo "Do GAS ..."
./dogas/dogas.R

echo "Do regressions ..."
./doregression/doregression.R

cd ~/GitHub/tnmbatch
git pull
git add .
git commit -am "dolifecoach crontab batch script tnmbatch"
git push

cd ~/GitHub/nudgeclient
git pull
git add images
git commit -am "dolifecoach crontab batch script GitHub images"
git push

cp -r ~/GitHub/nudgeclient/images/lifecoach/user ~/websites/nudge/images/lifecoach
cd ~/websites/nudge
git pull
git add images
git commit -am "dolifecoach crontab batch script website images"
git push
