#!/bin/sh

#############################################################################################
#      FOR OGS COMPILATION ON RZ CLUSTER   -----  by JOD 2/2015
#############################################################################################
#
# PUT IN OGS FOLDER (SAME LEVEL AS SOURCES AND LIBS)
# BACKUP COMILATION SCRIPT
# NEWER VERSION IN icbc/lemonSqueezy
#
# OGS_FEM_MKL:
#      if error MKL not found, than exchange FindMKL.cmake
#
#
# OGS_FEM_MPI:
#       THE SEEK_SET ERROR MAY SUCK. THUS, FOR COMPILATIONS MPI INVOLVING MPI ADD INTO CMakeLists.txt:  
#           IF(OGS_FEM_MPI OR OGS_FEM_MPI_KRC OR OGS_FEM_PETSC OR OGS_FEM_PETSC_GEMS)   # FOR RZ KIEL
#               SET(CMAKE_CXX_FLAGS -DMPICH_IGNORE_CXX_SEEK)
#           ENDIF(OGS_FEM_MPI OR OGS_FEM_MPI_KRC OR OGS_FEM_PETSC OR OGS_FEM_PETSC_GEMS)
#
#

VERSION_PETSC="3.3" # EITHER 3.5 or NOT

#            0        1               2         3               4
modes=( "OGS_FEM" "OGS_FEM_PETSC" "OGS_FEM_MKL" "OGS_FEM_MPI" "OGS_FEM_MPI_KRC")
nCPUs=6


### LIBS


PETSC="work_j/SoftwareSL/Dpetsc/Dintel14/petsc-3.3-p4"

MKL="cluster/Software/intel14/composer_xe_2013_sp1.0.080/mkl"

MKL_FOLDER="$(pwd)/Libs/MKL"

### COMPILER

INTEL="cluster/Software/intel14/composer_xe_2013_sp1/bin"
INTEL_MPI="cluster/Software/intel14/impi/4.1.1.036/intel64/bin"


ICC="$INTEL/icc"
ICPC="$INTEL/icpc"

MPIICC="$INTEL_MPI/mpiicc"
MPIICPC="$INTEL_MPI/mpiicpc"

COMP_XE="cluster/Software/intel14/composer_xe_2013_sp1.0.080"


#############################################################################################

config_petsc()
{

    if [ "$VERSION_PETSC" == "3.5" ]; then # REPLACE

                # USE ONLY WITH NEW (approx beginning 2015) OGS VERSIONS

        PETSC="cluster/Software/Dpetsc/petsc-3.5.3_intel"
        INTEL_MPI="opt/mpich/bin"
        MPIICC="$INTEL_MPI/mpicc"
        MPIICPC="$INTEL_MPI/mpicxx"

    fi

}

#############################################################################################


selectMode()
{

    echo -e "\nSelect\n"

    for (( i=0; i<${#modes[@]}; i++ ))
    do
        echo -e "\t$i: ${modes[$i]}"
    done
    echo -e "\ta: all"

    read -n1 selectedMode

}


#############################################################################################


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


setPaths()
{

    . /$INTEL/compilervars.sh intel64

    case $modeNDX in

        "0")    # SEQUENTIAL
            ;;

        "1")    # PETSC

            config_petsc  # FOR VERSION 3.5

            export PETSC_DIR=/$PETSC
            export PETSC_ARCH=linux-intel-opt
            export PATH=$PATH:/$PETSC/include

            export PATH=$PATH:/$COMP_XE/compiler/lib/intel64
            ;;


        "2")    # MKL
            export MKLROOT=/$MKL 
            export MKLPATH=/$MKL/lib/intel64 
            export MKLINCLUDE=/$MKL/include 
            export MKL_INCLUDE_DIR=$MKL_INCLUDE_DIR:/$MKL/include 
            export MKL_LIB_PATH=$MKL_LIB_PATH:/$MKL/lib/intel64 
	 
            export MKL_PROCESS_INCLUDES=$MKL_PROCESS_INCLUDES:/$MKL_FOLDER/64  
            export MKL_PROCESS_LIBS=$MKL_PROCESS_LIBS:/$MKL_FOLDER/64 
	 
            export PATH=$PATH:/cluster/intel/mkl/10.2.2.025/lib/64 
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/$MKL/lib/intel64 
            . /$MKL/bin/intel64/mklvars_intel64.sh
            ;;

        "3")    # MPI

            . /$INTEL_MPI/mpivars.sh
            ;;
             "4")    # MPI_KRC

            . /$INTEL_MPI/mpivars.sh
            ;;


        *)     # DEFAULT
             echo -e "ERROR - CASE $mode NOT SUPPORTED - NOTHING DONE"
            ;;

    esac


}


#############################################################################################


createBuildFiles()
{



    case $modeNDX in

        "0")    # SEQUENTIAL

            cmake .. -DOGS_FEM=ON -DCMAKE_C_COMPILER=/$ICC -DCMAKE_CXX_COMPILER=/$ICPC
            ;;

        "1")    # PETSC

            cmake .. -DOGS_FEM_PETSC=ON -DCMAKE_C_COMPILER=/$MPIICC -DCMAKE_CXX_COMPILER=/$MPIICPC
            ;;

        "2")    # MKL

            cmake .. -DOGS_FEM_MKL=ON -DPARALLEL_USE_OPENMP=ON -DCMAKE_C_COMPILER=/$ICC -DCMAKE_CXX_COMPILER=/$ICPC
            ;;

        "3")    # MPI

            cmake .. -DOGS_FEM_MPI=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=/$MPIICC -DCMAKE_CXX_COMPILER=/$MPIICPC
            ;;
        "4")    # MPI_KRC

            cmake .. -DOGS_FEM_MPI_KRC=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=/$MPIICC -DCMAKE_CXX_COMPILER=/$MPIICPC
            ;;

        *)     # DEFAULT
            echo -e "ERROR - CASE $mode NOT SUPPORTED - NOTHING DONE"
            ;;

    esac


}


#############################################################################################
#############################################################################################



selectMode
cd sources

for (( modeNDX=0; modeNDX<${#modes[@]}; modeNDX++ ))
do

    if [ "$modeNDX" == "$selectedMode" ] || [ "$selectedMode" == "a" ]; then

        setPaths
        selectBUILD

        if [ "$BUILD_flag" -eq 1 ]; then

            rm -r Build_${modes[modeNDX]}
            mkdir Build_${modes[modeNDX]}
            cd Build_${modes[modeNDX]}
            createBuildFiles

        else

            cd Build_${modes[modeNDX]}

        fi

        make -j $nCPUs

        cd bin
        mv ogs ogs_${modes[modeNDX]}
            cd ..
            cd ..

    fi

done 
