#!/bin/sh

#############################################################################################  
#      	To generate ogs binaries with intel compiler (mpi, openmp, mkl) on:
#			1. Lockstedt GPI server - Eclipse IDE
#  			2. RZ CLUSTER (hostname rzcl00b) - Eclipse IDE, PETSC
#			3. NEC cluster (hostnames nesh-f1 or nesh-f2) - PETSC	   	
#
#       ogs configurations: OGS_FEM, OGS_FEM_SP, OGS_FEM_MKL (sequential)
#                           OGS_FEM_MPI, OGS_FEM_MPI_KRC, OGS_FEN_PETSC (parallel)
#							(more can be added in 2. below)
#																	by JOD 9/2015  
#	parameter:
#		$1: path to ogs folder or empty (script steps into build folder for cmake and make)
#
#############################################################################################  
#  
# USER GUIDE: 
#   a) Put in OGS folder (same level as sources and libs)  
#	   cd into this folder and type ./compileInKiel.sh  
#      as an option, call script from wherever you want and pass 
#      this ogs folder as parameter $1
# 
#   b) To avoid SEEK_SET ERROR when using mpi compiler, add into CMakeLists.txt:    
#      IF(OGS_FEM_MPI OR OGS_FEM_MPI_KRC OR OGS_FEM_PETSC OR OGS_FEM_PETSC_GEMS)   
#         SET(CMAKE_CXX_FLAGS -DMPICH_IGNORE_CXX_SEEK)  
#      ENDIF(OGS_FEM_MPI OR OGS_FEM_MPI_KRC OR OGS_FEM_PETSC OR OGS_FEM_PETSC_GEMS)  
#  
#   c) For OGS_FEM_MKL, SET COMPILER FLAG -mkl and do not use FindMKL.cmake, 
#      e.g. by adapting CMakeConfiguration/Find.cmake to 
#        IF(OGS_FEM_MKL)  
#	       SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mkl")      
#	       SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mkl")
#	       # Find MKLlib 
#	       # FIND_PACKAGE( MKL REQUIRED ) 
#	       # INCLUDE_DIRECTORIES (${MKL_INCLUDE_DIR}) 
#        ENDIF()  
#


#############################################################################################
# 0. output on console and in compilation.log
#
# parameters:
# 	$1 ["ERROR", "WARNING", "INFO"] message type 
# 	$2 "message"
#

printMessage()
{
	case $1 in
		"ERROR")
			tput setaf 1;  # red
			;;
		"WARNING")
			tput setaf 5;  # cyan
			;;
		"INFO")
			tput setaf 2;  # green
			;;
		*)  
			;;
	esac
	
	echo -e "\n"$1 - $2
	tput sgr0;  # reset color	

	echo -e $(date) $1 - $2 >> $OGS_FOLDER/compilation.log
}

############################################################################################# 
# 1. Initialization
#     first function called in main
#	parameter:
#		$1: path to ogs folder or empty
 
initialize()
{
	nCPUs=6 	 # number of CPUs for compilation (<= number of nodes on cluster login node or server)
	CALLEDFROM=$PWD    	 
	if [ "$1" != "" ]; then		
		OGS_FOLDER=$1          # path passed as parameter into script
	else
		OGS_FOLDER=$CALLEDFROM # call from ogs folder
	fi

	BUILD_CONFIGURATION=""	 # [Debug, Release]   No Debug for NEC
	BUILD_flag=-1            # [0: do not cmake, 1: do cmake]
	IDE="" 		             # [empty,ECLIPSE]

	cConfigurations=(  # extend compiler table (3.) if you add code configurations
		"OGS_FEM"  
		"OGS_FEM_SP"  
		"OGS_FEM_MKL"   
		"OGS_FEM_MPI"  
		"OGS_FEM_MPI_KRC" 
		"OGS_FEM_PETSC" 
	)
	configurationSELECTED=-1  # [0,1,..., number of configurations -1]
	cConfigurationSELECTED="" # [OGS_FEM, OGS_FEM_SP, ...]  
	
	INTEL_VERSION=""
 
	# paths to 
	ROOT_FOLDER=""    # where folder for code configurations will be placed 
						 # for specific BUILD_CONFIGURATION 
						 # ($OGS_FOLDER/"Build_${BUILD_CONFIGURATION}_$INTEL_VERSION")
	BUILD_FOLDER=""   # where folder for specific BUILD_CONFIGURATION will be placed 
	                     #($ROOT_FOLDER/$cConfigurationSELECTED)
	SOFTWARE_FOLDER=""   # where intel folder are
	COMPOSER_ROOT=""
	MPI_ROOT=""
	ICC=""   		# intel c compiler
	ICPC=""			# intel c++ compiler
	MPIICC=""		# mpi c compiler
	MPIICPC=""		# mpi c++ compiler
}
 
############################################################################################# 
#  2. SET PATHS 
#
#  INTEL		: rzcluster (1502, composer_xe_2015.2.164),
#                 NEC cluster(15.0.3, composer_xe_2015.3.187)
#                 Lockstedt (13.1.0, composer_xe_2013.2.146)
#  INTEL mpi    : rzcluster (5.0.3.048), NEC cluster (4.1.1.036), Lockstedt
#  PETSC 3.5.3 	: rzcluster (intel14)
#				  NEC cluster (intel14)
#  Requirements:
#    initialization of INTEL_VERSION (1.)
#  Results:
#    paths to intel tools set (modules loaded)

setPaths()
{

	setPaths__host=$HOSTNAME
	
	case ${setPaths__host:0:2} in 
		rz) 	 # rzcluster 
			SOFTWARE_FOLDER="/cluster/Software"
			INTEL_VERSION="intel1502"
			COMPOSER_ROOT="$SOFTWARE_FOLDER/$INTEL_VERSION/composer_xe_2015.2.164"
			MPI_ROOT="$SOFTWARE_FOLDER/$INTEL_VERSION/impi/5.0.3.048"
    
			ICC="$COMPOSER_ROOT/bin/intel64/icc"
			ICPC="$COMPOSER_ROOT/bin/intel64/icpc"
 	
			MPIICC="$MPI_ROOT/intel64/bin/mpiicc"  
			MPIICPC="$MPI_ROOT/intel64/bin/mpiicpc"
    	
			module load $INTEL_VERSION	
			module load petsc-3.5.3-intel14 
			module load eclipse		
				;;
		ne) # NEC cluster 
			SOFTWARE_FOLDER="/opt"	
			COMPOSER_ROOT="$SOFTWARE_FOLDER/intel/composer_xe_2015.3.187"
			MPI_ROOT="$SOFTWARE_FOLDER/intel/impi/4.1.1.036"
	
			ICC="$COMPOSER_ROOT/bin/intel64/icc"
			ICPC="$COMPOSER_ROOT/bin/intel64/icpc"
 	
			MPIICC="$MPI_ROOT/intel64/bin/mpiicc"  
			MPIICPC="$MPI_ROOT/intel64/bin/mpiicpc"
	
			INTEL_VERSION="intel15.0.3"
			module load $INTEL_VERSION	
			module load petsc-3.5.3-intel
				;;
		Lo)	# GPI server 
			SOFTWARE_FOLDER="/opt"
			COMPOSER_ROOT="$SOFTWARE_FOLDER/intel/composer_xe_2013.2.146"
			MPI_ROOT="$SOFTWARE_FOLDER/openmpi"
		
			ICC="$COMPOSER_ROOT/bin/intel64/icc"
			ICPC="$COMPOSER_ROOT/bin/intel64/icpc"
 	
			MPIICC="$MPI_ROOT/bin/mpicc"  
			MPIICPC="$MPI_ROOT/bin/mpicxx"		
		
			. $COMPOSER_ROOT/bin/compilervars.sh intel64
			. $COMPOSER_ROOT/mkl/bin/intel64/mklvars_intel64.sh
		
			INTEL_VERSION="intel" 
				;;
		*)
			printMessage "ERROR" "Check HOSTNAME - Supported are RZ cluster, NEC cluster, and Lokstedt"
				;; 	 
	esac

	printMessage "INFO" "Paths set for $HOSTNAME" 
}
  
############################################################################################# 
# 3. Compiler table
#    here you can add code configurations  
#    !!!!! MATCH LINES OF cConfigurations (1.) AND compilerTable 
# 	Requirements:
# 		paths set (2.)
#	Result:
#		Compiler are assigned to code configurations (from 1.)
#
 
setCompilerTable()
{ 
	compilerTable=( 
		#	-DPARALLEL_USE_OPENMP= 	-DCMAKE_C_COMPILER= 	-DCMAKE_CXX_COMPILER=		  
			"OFF"					"$ICC"					"$ICPC"					# OGS_FEM   
			"OFF"					"$ICC"					"$ICPC"					# OGS_FEM_SP   
			"ON"					"$ICC"					"$ICPC"					# OGS_FEM_MKL   
			"OFF"					"$MPIICC"				"$MPIICPC"				# OGS_FEM_MPI  
			"OFF"					"$MPIICC"				"$MPIICPC"				# OGS_FEM_MPI_KRC 
			"OFF"					"$MPIICC"			    "$MPIICPC"		        # OGS_FEM_PETSC 					 
	)    
}  
    
#############################################################################################  
# 4. User input
#	supported configurations in 1. above 
#	Debug BUILD_CONFIGURATION for ECLIPSE IDE supported for rzcluster and Lokstedt 
#   Requirements:
#		cConfigurations list
#	Results:
#		variables set
#			configurationSELECTED 	
#			BUILD_CONFIGURATION    	
#			BUILD_flag				
#

selectConfiguration()  # code configuration from list cConfigurations
{      
    echo -e "Select"  
    for (( i=0; i<${#cConfigurations[@]}; i++ ))  
    do  
        echo -e "\t$i: ${cConfigurations[$i]}"  
    done  
    echo -e "\ta: all"  
    read -n1 configurationSELECTED  
	
	# exception handling - restart if input error
	if echo $configurationSELECTED | egrep -q '^[0-9]+$'; then 

		if [ "$configurationSELECTED" -lt 0 ] ||	[ "$configurationSELECTED" -ge ${#cConfigurations[@]} ]; then
			printMessage "ERROR" "Number out of range - Restart"				
			main
		fi
	else
		if [ $configurationSELECTED != "a" ]; then
		  printMessage "ERROR" "Input neither a number nor \"a\" to select all - Restart"				
		  main
		fi
	fi
}  

selectBuild()  
{  
	selectBuild__cInput=""  # used as local variable
	
	# configuration
	if [ HOSTNAME=="rzcl100b" ] || [ HOSTNAME=="Lokstedt" ]; then
	
		echo -e "\n[d]ebug or [r]elease?" 
		read -n1 selectBuild__cInput  
		if [ "$selectBuild__cInput" == "d" ]; then  
			BUILD_CONFIGURATION="Debug"
			IDE="ECLIPSE"
		elif [ "$selectBuild__cInput" == "r" ]; then   
			BUILD_CONFIGURATION="Release"		
		else
			printMessage "ERROR" "Take \"d\" or \"r\" - Restart"				
			main
		fi 
	else
		BUILD_CONFIGURATION="Release"     
	fi	
		
	# flag
    echo -e "\n--------------------------------------------------\n"
    echo -e "\nCreate Build Files ([y]es or [n]o)?"  
    read -n1 selectBuild__cInput  
    if [ "$selectBuild__cInput" == "y" ]; then  
        BUILD_flag=1  
    elif [ "$selectBuild__cInput" == "n" ]; then  
        BUILD_flag=0
	else
		printMessage "ERROR" "Take \"y\" or \"n\" - Restart"		
		main
    fi  
}  

#############################################################################################  
# 5. linking
# 	do cmake
#   parameter:
#   	$1: main__configurationNDX (6.)  
# 	Requirements:
#		compiler paths, compiler table (2.)
#		configurations for code (cConfigurationSELECTED, 1.) and build (BUILD_CONFIGURATION, 4.)    
# 	Result:
#		Build directories exist
#

build()
{
	rm -rf $BUILD_FOLDER  # remove old build
	mkdir $BUILD_FOLDER  
	cd $BUILD_FOLDER   # step into build folder for cmake
	build__COMPILER_C=${compilerTable[(($1 * 3 + 1))]}  # used as local variables
	build__COMPILER_CXX=${compilerTable[(($1 * 3 + 2))]}

	printMessage "INFO" "Building files - Debugger $build__COMPILER_C $build__COMPILER_CXX"
	if [ "$IDE" == "ECLIPSE" ]; then  # only difference is GENERATOR_OPTION -G
		cmake $OGS_FOLDER/sources -G "Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=$BUILD_CONFIGURATION -D$cConfigurationSELECTED=ON -DPARALLEL_USE_OPENMP=${compilerTable[(($1 * 3))]} -DCMAKE_C_COMPILER=$build__COMPILER_C  -DCMAKE_CXX_COMPILER=$build__COMPILER_CXX               		
	else
		cmake $OGS_FOLDER/sources -DCMAKE_BUILD_TYPE=$BUILD_CONFIGURATION -D$cConfigurationSELECTED=ON -DPARALLEL_USE_OPENMP=$COMPILER_C -DCMAKE_C_COMPILER=$build__COMPILER_C  -DCMAKE_CXX_COMPILER=$build__COMPILER_CXX               		
	fi
}

#############################################################################################
# 6. main function
# 	Calls: 
#		select functions (3.) 
#		build (4.) for cmake if BUILD_flag = 1 or if Build folder does not exist
# 	    make for compilation
# 	Requirements:
# 		--- (here script starts)
#	 Result:
# 		binaries (renamed)
#	parameter:
#		$1: path to ogs folder or empty
#

main()
{
	# config - variables and paths
	initialize $1				
	setPaths
	setCompilerTable
	
	# user input
	selectConfiguration    
	selectBuild 

	# config main loop
	ROOT_FOLDER=$OGS_FOLDER/"Build_${BUILD_CONFIGURATION}_$INTEL_VERSION"
	mkdir -p $ROOT_FOLDER

	# loop over all configurations (from list in 2.)
	for (( main__configurationNDX=0; main__configurationNDX<${#cConfigurations[@]}; main__configurationNDX++ ))  
	do  
		# either one or all can be selected
		if [ "$main__configurationNDX" == "$configurationSELECTED" ] || [ "$configurationSELECTED" == "a" ]; then  
			# pre-processing
			cConfigurationSELECTED=${cConfigurations[main__configurationNDX]}   
			printMessage "INFO" "GENERATING $cConfigurationSELECTED $BUILD_CONFIGURATION $IDE" 
			BUILD_FOLDER=$ROOT_FOLDER/$cConfigurationSELECTED
			
			# build
			if [ "$BUILD_flag" -eq 1 ]; then  
				build $main__configurationNDX
			else
				if [ ! -d "$BUILD_FOLDER" ]; then
					printMessage "WARNING" "Build folder does not exist - Building it now"
					build $main__configurationNDX
				fi
				cd $BUILD_FOLDER # step into build folder for make
			fi  
			
			# compile
            printMessage "INFO" "Compiling"
			make -j $nCPUs    
			
			# post-processing
            if [ -e $BUILD_FOLDER/bin/ogs ]; then			
				mv $BUILD_FOLDER/bin/ogs $BUILD_FOLDER/bin/ogs_$cConfigurationSELECTED     # rename
				printMessage "INFO" "Binaries ogs_$cConfigurationSELECTED generated"				
			else
				printMessage "WARNING" "No binaries generated"
			fi
		fi  
	done   

	cd $CALLEDFROM      # back to initial folder
	
	main $1  # restart
} 

main $1 # start