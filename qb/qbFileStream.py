#!/usr/bin/python

########
#
# qb fileStream by JOD
#
#

import qbMesh
import qbConfig

class fileStream:
    def __init__(self, fileName, mode):
        self._file = open(fileName, mode)
    
    def __del__(self):
        self._file.close()
                
class inflow (fileStream):
    def __init__(self, ensemble): 
        self.__fileName = ensemble.inputFileName()
        fileStream.__init__(self, self.__fileName, 'r')   
        #self._verbosity = 1  # for screen output actually
            
    def readMeshData(self, grid):
        for i in range(0, 10000):   # number of lines read
            line = self._file.readline ()
            lineVariables = line.split()
            if(len(lineVariables) > 0):
                if(lineVariables[0] == "mesh" or lineVariables[0] == "end" ):
                    return lineVariables     # next grid or end of gridFile 
                grid.setVariables(lineVariables)              
        print("  WARNING - Number of lines exceeded when reading input file")	
        
    def readData(self, ensemble):  
        lineVariables = []
        line = self._file.readline() 
        lineVariables = line.split()
    
        while(len(lineVariables) == 0 or lineVariables[0] != "end"):                                          
            line = self._file.readline ()     
            lineVariables = line.split()
            #if(len(lineVariables) > 0):
            #    print (lineVariables[0])
            if(len(lineVariables) > 0 and lineVariables[0] == "verbosity"):
                qbConfig.verbosity = int(lineVariables[1])
                if(qbConfig.verbosity > 0):
                    print("Read file " + str(self.__fileName) )
            if(len(lineVariables) > 0 and lineVariables[0] == "output"):
                mode = int(qbConfig.outputMode[lineVariables[1]])       
                if(qbConfig.verbosity > 0):
                    print("    output " + str(lineVariables[1]) )
                outputStream = outflow (ensemble._outputFileName, mode)
                ensemble.addOutputStream(outputStream)
            while(len(lineVariables) > 0 and lineVariables[0] == "mesh"):
                mesh = qbMesh.mesh(lineVariables[1], lineVariables[2], ensemble.outputStreams()[0]) # 1 output stream    
                lineVariables = self.readMeshData(mesh) 
                ensemble.addMesh(mesh) 

          
class outflow (fileStream):
    def __init__(self, fileName, mode = 0):  
        fileStream.__init__(self, fileName, 'w')
        self.__mode = mode  
    # getter
    def mode(self):
        return self.__mode    
    #                   [nodes,elements]  [header,data,footer]  [-1=full grid data or constituent number]                                   
    def writeOgsFinteElementMesh(self, mesh, portion = "all", number = -1):                  
        for i in range (0, len(mesh.grids())):  
            grid = mesh.grids()[i]
            
            if(grid.constituentType() == 1): #nodes  
                
                if (portion == "header" or portion == "all"):
                    self._file.write("#FEM_MSH \n")
                    self._file.write(" $PCS_TYPE \n")
                    self._file.write("  " + str(mesh.identifier()) + "\n")
                    self._file.write(" $NODES \n")
                    self._file.write("  " + str(mesh.numberOfGridConstituents[i]) + "\n")        
                if (portion == "data" or portion == "all"):
                    if (number == -1):
                        if (qbConfig.verbosity > 0):
                            print("        " + str(mesh.nameOfGridConstituents[i]))
                        grid.writeData(self._file, 'node')
                    else:
                        grid.constituents()[number].writeData(self._file)
            else:  #elements                 
                if (portion == "header" or portion == "all"):
                    self._file.write(" $ELEMENTS \n")  
                    self._file.write("  " + str(mesh.numberOfGridConstituents[i]) + "\n")        
                if (portion == "data" or portion == "all"):
                    if (number == -1):
                        if (qbConfig.verbosity > 0):
                            print("        " + str(mesh.nameOfGridConstituents[i]))
                        grid.writeData(self._file, 'cube')
                    else:
                        grid.constituents()[number].writeData(self._file)  
                if (portion == "footer" or portion == "all"):      
                    self._file.write("#STOP \n")  
             
    def writeMesh(self, mesh, portion = "all", number = -1):  
        if (mesh.meshType() == 0):
            self.writeOgsFinteElementMesh(mesh, portion = "all", number = -1) 
            
                    

    
   
            
            
            
                
               
        
  
            
   
