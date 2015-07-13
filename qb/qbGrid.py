#!/usr/bin/python

#######################################################################
#
# qb class grid by JOD
# level 1
#

import qbConstituent
import qbConfig
import copy
import sys

class grid: 
    __numberOfConstituentsInDim = [1,1,1]
    __shift = [0,0,0]
    
    def __init__(self, verbosity, dim, numberOfConstituentsInDim, cConstituentType, numberOfItemsInCube, itemType, shift, operations, outputStream):
        constituents = []
        self.__constituents = constituents
        self.__verbosity = verbosity
        self.__dim = dim
        self.__numberOfConstituentsInDim = numberOfConstituentsInDim
        self.__constituentType = int(qbConfig.constituentType[cConstituentType])
        self.__shift = shift
        self.__operations = operations
        self.__outputStream = outputStream
        self.config(numberOfItemsInCube, itemType)
        
    def config(self, numberOfItemsInCube, itemType):    
        if (self.__constituentType == 0 ): #cube
            self.__numberOfItemsInConstituent = numberOfItemsInCube    
            self.__itemType = itemType
        else:   # node
            self.__numberOfItemsInConstituent = numberOfItemsInCube + 1   
            self.__itemType = 0
    # getter    
    def verbosity(self):        
        return self.__verbosity
    def meshIdentifier(self):
        return self.__meshIdentifier   
    def constituentType(self):
        return self.__constituentType          
    def itemType(self):
        return self.__itemType    
    def constituents(self):       
        return self.__constituents     
    def numberOfConstituentsInDim(self):
        return self.__numberOfConstituentsInDim
    def numberOfItemsInConstituent(self):
        return self.__numberOfItemsInConstituent    
                
    # memory    
    def define(self):    
        if (self.__outputStream.mode() == 1): #direct
            self.addConstituent()
        else:                 
            self.defineForDimension(self.__dim - 1)    
                     
    def defineForDimension(self, current_dim):       
        for i in range(0, self.__numberOfConstituentsInDim[current_dim]):      
            if ( current_dim == 0):
                self.addConstituent()
            else:   
                self.defineForDimension(current_dim - 1)
           
    def addConstituent(self):   
        if (self.__constituentType == 0):
            if(self.__dim == 1):
                constituent_inst = qbConstituent.cube_1D(self.__constituentType, self.__itemType, self.__numberOfConstituentsInDim, self.__numberOfItemsInConstituent, self.__operations)
            elif(self.__dim == 2):     
                constituent_inst = qbConstituent.cube_2D(self.__constituentType, self.__itemType, self.__numberOfConstituentsInDim, self.__numberOfItemsInConstituent, self.__operations)
            elif(self.__dim == 3):     
                constituent_inst = qbConstituent.cube_3D(self.__constituentType, self.__itemType, self.__numberOfConstituentsInDim, self.__numberOfItemsInConstituent, self.__operations)
        else:
            constituent_inst = qbConstituent.node(self.__constituentType, self.__itemType, self.__numberOfItemsInConstituent, self.__operations)
        constituent_inst.define()    
        self.__constituents.append((constituent_inst)) # copy.deepcopy(constituent_inst))   
    # content               
    def fillConstituent(self, ndx, gridVariable):   
        if (self.__outputStream.mode() == 1): # direct
            constituent_ndx = 0
        else:
            constituent_ndx = ndx         
        self.__constituents[constituent_ndx].fill(ndx, copy.deepcopy(gridVariable)) # next level
        
    def current_ndx(self, i3):
        return i3[0] + i3[1] * self.__numberOfConstituentsInDim[0] + i3[2] * self.__numberOfConstituentsInDim[0] * self.__numberOfConstituentsInDim[1]  
        
    def fillForDimension(self, i3, current_dim, current_gridVariable):    
        if(qbConfig.verbosity > 1):
            sys.stdout.write(".")
        current_gridVariable[current_dim] = 0    # node: cod; element: ndx in dim 
        for i3[current_dim] in range(0, self.__numberOfConstituentsInDim[current_dim]):              
            if(current_dim == 0):     
                current_ndx = self.current_ndx(i3) 
                self.fillConstituent(current_ndx, current_gridVariable) # next level       
            else:
                self.fillForDimension(i3, current_dim - 1, current_gridVariable) # copy.deepcopy(current_gridVariable)) 
            current_gridVariable[current_dim] = current_gridVariable[current_dim] + self.__shift[current_dim]                                    
              
    def fill(self):    #                i3              origin
        self.fillForDimension([0,0,0], self.__dim - 1, [0.,0.,0.]) 
        print(" ")
    # file stream    
    def writeData(self, file, cConstituentType):
        for i in range (0, len(self.__constituents)):
            if (self.__constituents[i].constituentType() == int(qbConfig.constituentType[cConstituentType]) ):
                self.__constituents[i].writeData(file)  
         
        
        
      
