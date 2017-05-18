#!/bin/bash


cut3d=/home/chuang3/work_fsu/codes/abinit-7.10.5/src/98_main/cut3d

echo "go_DEN
   1
   1
   5
   up.dat
0  " | $cut3d


echo "go_DEN
   1
   2
   5
   down.dat
0  " | $cut3d


ls -lh  up.dat
ls -lh  down.dat

cat up.dat   > ../ref_spin_up.dat
cat down.dat > ../ref_spin_down.dat

echo ""
echo ""
echo "done!"
echo ""
echo "The reference densities are ../ref_spin_up.dat and ../ref_spin_down.dat"
echo ""
echo ""
echo ""
