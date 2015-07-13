#!/usr/bin/python

#######################################################################
#
# qb class mesh by JOD
# level 0
#

import qbGrid
import qbOperation
import qbMath
import qbConfig
import sys
            
class mesh:  
    __numberOfGrids = 0
    __numberOfNodes = 1
    __numberOfElements = 1
    __identifier = "NO_PCS"
        
    def __init__(self, cMeshType, cItemType, outputStream):
    
        constituentsType = []   # for config
        numberOfGridConstituents = [] # nodes, elements
        nameOfGridConstituents = [] # nodes, elements
        numberOfConstituentsInDim = []
        shift = []
        self.__constituentsType = constituentsType
        self.numberOfGridConstituents = numberOfGridConstituents
        self.nameOfGridConstituents = nameOfGridConstituents
        self.__numberOfConstituentsInDim = numberOfConstituentsInDim
        self.__shift = shift
        
        length = [0,0,0]
        delta = [0,0,0]
        grids = [] 
        numberOfCubesInDim = [0,0,0]
        assignments = []    
        transformations = []
        
        self.__length = length
        self.__delta = delta
        self.__grids = grids 
        self.__assignments = assignments
        self.__transformations = transformations 
        self.__numberOfCubesInDim = numberOfCubesInDim            
        self.__meshType = int(qbConfig.meshType[cMeshType])
        self.__itemType = int(qbConfig.itemType[cItemType])
        self.__outputStream = outputStream
        self.__dim = int(qbConfig.dim[cItemType])
        self.__numberOfItemsInCube = int(qbConfig.numberOfItemsInCube[cItemType])   
                    
    def __del__(self):       
        del self.__length[:]
        del self.__delta[:]   
        del self.__grids[:]                          
    # getter       
    def meshType(self):                  
        return self.__meshType               
    def itemType(self):   
        return self.__itemType           
    def identifier(self):    
        return self.__identifier                         
    def dim(self):       
        return self.__dim                
    # lists            
    def grids(self):       
        return self.__grids                        
    def delta(self):   
        return self.__delta            
    
    def config(self):
        self.__numberOfElements = self.__numberOfItemsInCube 
        for i in range(0, self.__dim):        
            self.__delta[i] = self.__length[i] / self.__numberOfCubesInDim[i]
            self.__numberOfNodes =  self.__numberOfNodes * ( self.__numberOfCubesInDim[i] + 1)
            self.__numberOfElements =  self.__numberOfElements * self.__numberOfCubesInDim[i]
            
        if(qbConfig.verbosity > 0):
            sys.stdout.write("        resolution")
            for i in range(0, self.__dim):  
                sys.stdout.write(" - " + str(self.__delta[i]))
            sys.stdout.write("\n")
            if(len(self.__transformations) > 0):
                print("        transformations")
                for i in range(0, len(self.__transformations)):
                    self.__transformations[i].writeScreen()
            if(len(self.__assignments) > 0):
                print("        assignments")
                for i in range(0, len(self.__assignments)):
                    self.__assignments[i].writeScreen(self.__dim)       
                
        if(self.__meshType == 0): # ogs finite elements
            self.__numberOfGrids = 2
            self.__constituentsType = ['node', 'cube']
            self.numberOfGridConstituents = [self.__numberOfNodes, self.__numberOfElements]
            self.nameOfGridConstituents = ['nodes', 'elements']
            self.__numberOfConstituentsInDim = [qbMath.add(self.__numberOfCubesInDim, [1,1,1]), self.__numberOfCubesInDim]
            self.__operations = [self.__transformations, self.__assignments]
            self.__shift = [self.__delta, [1,1,1]]
        else:
            print ( "ERROR - mesh type " + str(self.__meshType) + "not supported" )    
    # memory  
    def define(self):   
        for j in range(0, self.__numberOfGrids):                                                                                                                                                                               
            grid_instance = qbGrid.grid(qbConfig.verbosity, self.__dim, self.__numberOfConstituentsInDim[j], self.__constituentsType[j], \
            self.__numberOfItemsInCube, self.__itemType, self.__shift[j], self.__operations[j], self.__outputStream) 
            grid_instance.define() # next level
            self.__grids.append(grid_instance)                         
    # content        
    def fill(self): 
        for i in range (0, len(self.__grids)):
            if(qbConfig.verbosity > 0):
                sys.stdout.write("        grid " + str(i) + " - " + str(self.numberOfGridConstituents[i]) + " " + str(self.nameOfGridConstituents[i]) + " " )
            #if (self.__outputStream.mode() == 1): #direct           
            self.__grids[i].fill() # next level                  
    # file stream
    def setVariables(self, variables):  # from input stream
        	           
        if(qbConfig.identifier.count(variables[0]) > 0):    
            self.__identifier = variables[1] 
                      		
        if(variables[0] == "length"):
            for j in range(0, len(variables) - 1):    # 1 to 3 components
                self.__length[j] = float(variables[j+1])     
            if(qbConfig.verbosity > 1):
                sys.stdout.write("        length:")
                for j in range(0, len(variables) - 1):
                   sys.stdout.write(" " + str(self.__length[j]))
                sys.stdout.write("\n")                           
                      
        if(variables[0] == "numberOfCubes"):
            for j in range(0, len(variables) - 1):
                self.__numberOfCubesInDim[j] = int(variables[j+1])           
            if(qbConfig.verbosity > 1):
                sys.stdout.write("        numberOfCubes:")
                for j in range(0, len(variables) - 1):
                    sys.stdout.write(" " + str(self.__numberOfCubesInDim[j]))
                sys.stdout.write("\n")
                
        if(variables[0] == "property"): 
            if(variables[1] == "increment"):
                operation_inst = qbOperation.increment(variables, self.__numberOfCubesInDim)
            elif(variables[1] == "impose"):
                operation_inst = qbOperation.imposement(variables, self.__numberOfCubesInDim)
            else:
                print("ERROR in property - Operation " + str(variables[1]) + " is not supported")
            self.__assignments.append(operation_inst)
                                    
        if(variables[0] == "position"): 
            if(variables[1] == "shift"):
                operation_inst = qbOperation.shift(variables)
            elif(variables[1] == "rotate"):
                operation_inst = qbOperation.rotation(variables)
            elif(variables[1] == "stretch"):
                operation_inst = qbOperation.stretch(variables)
            else:
                print("ERROR in transformation - Operation " + str(variables[1]) + " is not supported")
            self.__transformations.append(operation_inst)
    # construction of complete tree             
    def construct(self):   
        self.config()   
        self.define()     
        self.fill()
