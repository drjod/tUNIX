#!/bin/sh

#################################################################################
#
# qb run by jens-olaf delfs (JOD)
#
# calls qb python genGrid.py
#
# to have the qb command, add into .bashrc
# alias qb='. path2qb/run.sh'
#
# parameter
# $1: path to move generated mesh grid.msh to
# if no path passed grid.msh will be in current path
#
#
#


##### CONFIGURATION


path2qb="/home/sungw389/tools/qb"


#################################################################################


path=$(pwd)

targetPath=$1

if [ "$1" != "" ]; then

	targetPath=$1	

else

	targetPath=$path	

fi 


cd $path2qb/

emacs $path2qb/grid.geo

python $path2qb/genGrid.py $path2qb/grid.geo

mv $path2qb/grid.msh $targetPath

cd $path


#################################################################################
