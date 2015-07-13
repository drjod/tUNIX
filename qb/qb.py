#!/usr/bin/python

#######################################################################
#
# qb main function by JOD
#
# REQUIRED: input outout paths
#

import qbEnsemble

def run():
    inputFileName = "C:\\Python34\\grid.geo"
    outputFileName = "C:\\Python34\\grid.msh"
   
	
    ensemble = qbEnsemble.ensemble(inputFileName, outputFileName)
    ensemble.construct()
    
    ensemble.write()
    
    del ensemble # self.__outputStreams[0:]   
	




  
