#!/bin/bash
echo " "
echo "****$(date)****"
echo "**                                **"
codeSync="lg"
#echo $codeSync

# project : r454_EPT2542NURv2_shipment
cd /home/lemon/r454_EPT2542NURv2_shipment
#echo "==> Svn update project: `pwd`"
#svn up
echo "Update [r454_EPT2542NURv2_shipment]:"
time $codeSync update 

# project : r3056_BRCM68380_development
#cd /home/lemon/branch/r3056_BRCM68380_development
#echo "==> Svn update project: `pwd`"
#svn up
#echo "Update pro_vim :"
#time $codeSync update 

# RTK 9607 project 
cd /home/lemon/branch/RTL9600_portting/dev/
#echo "==> Svn update project: `pwd`"
#./svnupdatescript.sh
echo "Update [RTL9600_portting]:"
time $codeSync update 

cd /home/lemon/branch/rtlbak/dev/
echo "Update [rtlbak]:"
time $codeSync update 

# Total time of this update
echo "==> Total Time: "
echo " "

