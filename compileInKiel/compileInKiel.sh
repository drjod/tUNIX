#!/bin/sh 


############################################################################################# 
#      FOR OGS COMPILATION ON NEC AND RZ CLUSTER Kiel  -----  by JOD 8/2015 
############################################################################################# 
# 
# REQUIREMENTS:
#   1. PUT IN OGS FOLDER (SAME LEVEL AS SOURCES AND LIBS) 
#   
#   2. CALL SCRIPT FROM THIS FOLDER !!!
#
#   3. THE SEEK_SET ERROR MAY SUCK. THUS, FOR COMPILATIONS INVOLVING MPI ADD INTO CMakeLists.txt:   
#      IF(OGS_FEM_MPI OR OGS_FEM_MPI_KRC OR OGS_FEM_PETSC OR OGS_FEM_PETSC_GEMS)   # FOR RZ KIEL 
#         SET(CMAKE_CXX_FLAGS -DMPICH_IGNORE_CXX_SEEK) 
#      ENDIF(OGS_FEM_MPI OR OGS_FEM_MPI_KRC OR OGS_FEM_PETSC OR OGS_FEM_PETSC_GEMS) 
# 
#   4. FOR OGS_FEM_MKL, SET COMPILER FLAG -mkl and do not use FindMKL.cmake,
#      e.g. by adapting CMakeConfiguration/Find.cmake to
#        IF(OGS_FEM_MKL)
#	       # Find MKLlib
#	       SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mkl")     
#	       SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mkl")
#	       # FIND_PACKAGE( MKL REQUIRED )
#	       # INCLUDE_DIRECTORIES (${MKL_INCLUDE_DIR})
#        ENDIF() 
#
#   ##########
# 
#   OGS-CONFIGURATIONS CAN BE FOUND AND ADDED IN POINT 2. BELOW
#
#   SELECT NEC OR RZ

CLUSTER=NEC
# CLUSTER=RZ

nCPUs=6

#############################################################################################
#  1. SET PATHS

echo -e "\nUp for compilation on $CLUSTER CLUSTER KIEL"

if [ "$CLUSTER" == "NEC" ]; then 
    MKL="/opt/intel/composer_xe_2013_sp1/mkl"
    INTEL="/opt/intel/composer_xe_2013_sp1/bin"
    INTEL_MPI="/opt/intel/impi/4.1.1.036/intel64/bin"
    COMP_XE="/opt/intel/composer_xe_2013_sp1.0.080"	
	
elif [ "$CLUSTER" == "RZ" ]; then 
    PETSC="/work_j/SoftwareSL/Dpetsc/Dintel14/petsc-3.3-p4" 
    MKL="/cluster/Software/intel14/composer_xe_2013_sp1.0.080/mkl" 
    ## MKL_FOLDER="$(pwd)/Libs/MKL"
	INTEL="/cluster/Software/intel14/composer_xe_2013_sp1/bin" 
    INTEL_MPI="/cluster/Software/intel1502/impi/5.0.3.048/intel64/bin"   # change to INTEL MPI VERSION 15 - 2015-7-24
	COMP_XE="/cluster/Software/intel14/composer_xe_2013_sp1.0.080" 

else
    echo -e "ERROR - CLUSTER MUST BE NEC OR RZ - PATHS NOT SET" 
fi 

###
	
ICC="$INTEL/icc" 
ICPC="$INTEL/icpc" 

MPIICC="$INTEL_MPI/mpiicc" 
MPIICPC="$INTEL_MPI/mpiicpc" 

### 

. $INTEL/compilervars.sh intel64 
. $INTEL_MPI/mpivars.sh
. $MKL/bin/intel64/mklvars_intel64.sh

module load petsc-3.3-p4-intel	
export PATH=$PATH:$COMP_XE/compiler/lib/intel64 

#############################################################################################
# 2. SET COMPILER

cConfigurations=( 
"OGS_FEM" 
"OGS_FEM_SP" 
"OGS_FEM_MKL"  
"OGS_FEM_MPI" 
"OGS_FEM_MPI_KRC"
"OGS_FEM_PETSC"
) 
 
compilerTable=( #	-DPARALLEL_USE_OPENMP= 	-DCMAKE_C_COMPILER= 	-DCMAKE_CXX_COMPILER=		 
 					"OFF"					"$ICC"					"$ICPC"					# OGS_FEM  
 					"OFF"					"$ICC"					"$ICPC"					# OGS_FEM_SP  
 					"ON"					"$ICC"					"$ICPC"					# OGS_FEM_MKL  
 					"OFF"					"$MPIICC"				"$MPIICPC"				# OGS_FEM_MPI 
 					"OFF"					"$MPIICC"				"$MPIICPC"				# OGS_FEM_MPI_KRC
 					"OFF"					"$MPIICC"			    "$MPIICPC"		        # OGS_FEM_PETSC 					
 )    # MATCH LINES OF cConfigurations AND compilerTable
   
############################################################################################# 

selectConfiguration() 
{ 
    echo -e "Select" 
    for (( i=0; i<${#cConfigurations[@]}; i++ )) 
    do 
        echo -e "\t$i: ${cConfigurations[$i]}" 
    done 
    echo -e "\ta: all" 
    read -n1 configurationSELECTED 
} 

selectBUILD() 
{ 
    echo -e "\nCreate Build Files ([y]es or no)?" 
    read -n1 input 
    if [ "$input" == "y" ]; then 
        BUILD_flag=1 
    else 
        BUILD_flag=0 
    fi 
} 

#############################################################################################
# main

selectConfiguration
selectBUILD 
cd sources 

for (( configurationNDX=0; configurationNDX<${#cConfigurations[@]}; configurationNDX++ )) 
do 
    if [ "$configurationNDX" == "$configurationSELECTED" ] || [ "$configurationSELECTED" == "a" ]; then 
	    echo -e "\nDealing with ${cConfigurations[configurationNDX]}"
        if [ "$BUILD_flag" -eq 1 ]; then 

            rm -r Build_${cConfigurations[configurationNDX]} 
            mkdir Build_${cConfigurations[configurationNDX]} 
            cd Build_${cConfigurations[configurationNDX]} 
			cmake .. -D${cConfigurations[configurationNDX]}=ON -DCMAKE_BUILD_TYPE=Release -DPARALLEL_USE_OPENMP=${compilerTable[(($configurationNDX * 3))]} -DCMAKE_C_COMPILER=${compilerTable[(($configurationNDX * 3 + 1))]}  -DCMAKE_CXX_COMPILER=${compilerTable[(($configurationNDX * 3 + 2))]}  
            
        else 
            cd Build_${cConfigurations[configurationNDX]} 
        fi 

        make -j $nCPUs 

        cd bin 
        mv ogs ogs_${cConfigurations[configurationNDX]} 
            cd .. 
            cd .. 
    fi 
done  




