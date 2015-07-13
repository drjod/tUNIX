#!/bin/sh

#########################################################################################
#
# chill by Jens-Olaf Delfs
#
#  to have commands chill and chall
#
#  $1: -a kill all jobs						        	(chall command)
#  else select via shell which job to kill  (chill command)
#
#  add into .bashrc 
#      alias chill='. /path2chill/chill.sh'
#      alias chall='. /path2chill/chill.sh -a'
#
# REQUIREMENTS: ADAPT CONFIGURATION 
#				help.txt file is generated and deleted in chill folder during execution 
#				(mind that no conflict appears)
#
#
#


##### CONFIGURATION

login="sungw389"							# this is my login
path2chill="/home/$login/tools/chill"		# and this is path to the folder I put chill.sh into


###############################################################################

# get job ids and write in help.txt

qstat -u $login | sed '1,5d' | sed 's/.rz.*//'  > $path2chill/help.txt
# 		remove lines 1 to 5, 
#       then remove .rz and the following in each line


if [ "$1" == "-a" ]; then   # CHALL

    while read line; do    # COLLECT JOBS AND KILL
	    
		qdel $line

	done < $path2chill/help.txt


   
else  # CHILL 


	i=0
	while read line; do  # COLLECT JOBS ...

		# echo "line $line" 
		jobs[$i]=$line
		i=$(($i + 1))
	

	done < $path2chill/help.txt


	#####   ... AND ASK BEFORE KILLING

	for ((j=0; j< i; j++))   # i is number of jobs 
	do

		echo "Delete job ${jobs[$j]}? (y)es or no"
		read -n1 slct
		echo ""

		if [ "$slct" == "y" ]; then
	
			qdel ${jobs[$j]}
			echo -e "	Deleted job ${jobs[$j]}\n"

		fi
 
	done

fi


##### CLEAN UP


rm $path2chill/help.txt
