#!/bin/bash


cut3d=/home/chuang3/work_fsu/codes/abinit-7.10.5/src/98_main/cut3d




# interactive way to run cut3d program 

echo "go_DEN
   1
   0
   5
   den.dat
0  " | $cut3d


ls -lh  den.dat

awk '{print $2}' den.dat   > ../ref_spin_up.dat
awk '{print $3}' den.dat   > ../ref_spin_down.dat

rm den.dat

echo ""
echo ""
echo "done!"
echo ""
echo "The reference densities are ../ref_spin_up.dat and ../ref_spin_down.dat"
echo ""
echo ""
echo ""
