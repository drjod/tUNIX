#!/usr/bin/python

#######
#
# qbEnsemble by JOD
#
#


import qbFileStream
import qbConfig

class ensemble:
    __meshes = []
    __outputStreams = []
    
    def __init__(self, inputFileName, outputFileName):
        meshes = []
        outputStreams = []
        self.__meshes = meshes
        self.__outputStreams = outputStreams
        self.__inputFileName = inputFileName
        self._outputFileName = outputFileName
        
    def __del__(self):  
        for i in range (0, len(self.__outputStreams)):  
            self.__outputStreams[i]._file.close()   
    # getter     
    def inputFileName(self):
        return self.__inputFileName
    def outputStreams(self):
        return self.__outputStreams    
    # setter
    def addOutputStream(self, outputStream_instance):
          self.__outputStreams.append(outputStream_instance)
    def addMesh(self, mesh_instance):
          self.__meshes.append(mesh_instance)          
            
    def construct(self):
        inflow = qbFileStream.inflow(self)
        inflow.readData(self)
        if(qbConfig.verbosity > 0):
            print("    " + str(len(self.__meshes)) + " mesh(es) found" )
            print("Construct") 
        del inflow
                       
        for i in range(0, len(self.__meshes)):
            if(qbConfig.verbosity > 0): 
                    print("    mesh " + str(i) + " - " + self.__meshes[i].identifier())     
            self.__meshes[i].construct()
             
    def write(self):   # restricted to one output stream
        if (self.__outputStreams[0].mode() == 0): #accumulated
            if(qbConfig.verbosity > 0):                   
                print ("Write")
            for i in range(0, len(self.__meshes)):  
                if(qbConfig.verbosity > 0): 
                    print("    mesh " + str(i))
                self.__outputStreams[0].writeMesh(self.__meshes[i], "all")
    

    
    
        
        
       
       

 
            
    

    
                                                                    
