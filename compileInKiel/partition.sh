#!/bin/sh


##########################################################################
#
# partition by JOD
#
# Task: interface to partmesh (METIS)
#		can be directly called
#		changes name of *.msh to *_mesh.txt if partition by nodes
#
# Requirements: input parameters
#				$1: number of partitions
#				$2: partition by -n nodes or -e elements 
#				$3: -asci or else (meaning binary)
#				$4: path to mesh or empty
#				!!!! take care that only one *.msh file in folder (no warning)
#
###########################################################################


#####	 CONFIGURATION - THIS ALLOWS DIRECT CALL


login="sungw389"
. /home/$login/tools/icbc/configuration/remote.sh   # TO GET path2partmesh


#####	SET PATH AND MESH FILE NAME


path=$(pwd)

if [ "$4" != "" ]; then
	path2msh=$4
	cd $path2msh        	# CD TO SPECIFIED FOLDER	
else
	path2msh=$path		# MESH IS IN CURRENT FOLDER
fi 

meshfile=$(ls | grep *msh)


#####	CALL PARTMESH


cd $path2partmesh
./partmesh --ogs2metis $path2msh/${meshfile%.*}
./partmesh --metis2ogs -np $1 $2 $3 $path2msh/${meshfile%.*}


#####	CLEAN UP


rm $path2msh/${meshfile%.*}\.mes*   

case $2 in
	"-n")  # PARTITION BY NODES
      	rm $path2msh/${meshfile%.*}\_ren*
		mv $path2msh/$meshfile $path2msh/${meshfile%.*}_mesh.txt    # CHANGE NAME of *.msh file

		if [ "$3" == "-asci" ]; then
			mv $path2msh/${meshfile%.*}\_partitioned_$1\.msh $path2msh/${meshfile%.*}\_partitioned.msh
		fi
		;;
		
	"-e") # PARTITION BY ELEMENTS		
		if [ "$3" == "-asci" ]; then   		
			mv $path2msh/${meshfile%.*}\.$1\ddc $path2msh/${meshfile%.*}\.ddc	
		else	
			echo "ERROR - Option $3 not supported"				
		fi
		;;
		
	*) 	
		echo "ERROR - Option $2 not supported"		
		;;
esac



cd $path


###########################################################################

