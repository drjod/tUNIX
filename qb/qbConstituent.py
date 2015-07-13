#!/usr/bin/python

#######################################################################
#
# qb class constituent by JOD
# level 2
#

import qbItem
import qbConfig
import copy

class constituent: # level2
    _ndx = 0
    
    def __init__(self, constituentType, itemType, numberOfItems, operations):       
        items = []
        gridVariable = [0,0,0]
        self._items = items 
        self._gridVariable = gridVariable 
        self._numberOfItems = numberOfItems
        self._operations = operations
        self._constituentType = constituentType
        self._itemType = itemType
    # getter     
    def constituentType(self):
        return self._constituentType 
    def items(self):
        return self._items          
    def ndx(self):
        return self._ndx
    # memory
    def define(self):    
        for i in range (0, self._numberOfItems):
            self.addItem(i)
    # content        
    def fill(self, ndx, gridVariable): 
        self._ndx = ndx   
        self._gridVariable = gridVariable
        self.modify()
        self.fillItems() # next level  
                
class node(constituent):
    def __init__(self, constituentType, itemType, numberOfItems, operations):            
        constituent.__init__(self, constituentType, itemType, numberOfItems, operations)
    # memory
    def addItem(self, local_ndx):
        pass
    # content                 
    def fillItems(self):
        pass # no next level
    def modify(self):    
        for i in range (0, len(self._operations)):
            self._gridVariable = self._operations[i].execute(self._gridVariable)  
    # file stream                                     
    def writeData(self, file):
        file.write(str(self._ndx) + " " + str(self._gridVariable[0]) + " " + str(self._gridVariable[1]) + " " + str(self._gridVariable[2]) + "\n" ) 
         
class cube(constituent):
    def __init__(self, constituentType, itemType, numberOfCubesInDim, numberOfItems, operations):          
        self._numberOfCubesInDim = numberOfCubesInDim  
        self._property = 0 # material
        constituent.__init__(self, constituentType, itemType, numberOfItems, operations) 
    # content    
    def fillItems(self):
        self.setNodesNumber()
        for i in range(0, self._numberOfItems):
            self._items[i].fill(self._nodesNumber) # next level           
    # file stream                                 
    def writeData(self, file):
        for i in range (0, len(self._items)):
            file.write(str(self._ndx * len(self._items) + i) + " " + str(self._property) + " " + str(qbConfig.inv_itemType[self._itemType])) 
            self.items()[i].write(file)
            file.write( "\n" )            
       
class cube_1D(cube):

    def __init__(self, constituentType, itemType, numberOfCubesInDim, numberOfItems, operations):   
        nodesNumber = [0,0]
        self._nodesNumber = nodesNumber
        cube.__init__(self, constituentType, itemType, numberOfCubesInDim, numberOfItems, operations)
    # memory
    def addItem(self, local_ndx):                  
        item_inst = qbItem.line(local_ndx) # next level   
        self._items.append(copy.deepcopy(item_inst))
    # content
    def modify(self):
        for i in range (0, len(self._operations)):
            self._property = self._operations[i].execute(self._gridVariable, 1, self._property)
                           
    def setNodesNumber(self):
        nodesNumber = [0,0]
               
        nodesNumber[0] = self._gridVariable[0]
        nodesNumber[1] = nodesNumber[0] + 1
       
        self._nodesNumber[0] = nodesNumber[0]
        self._nodesNumber[1] = nodesNumber[1]
        
class cube_2D(cube):

    def __init__(self, constituentType, itemType, numberOfCubesInDim, numberOfItems, operations):   
        nodesNumber = [0,0,0,0]
        self._nodesNumber = nodesNumber
        cube.__init__(self, constituentType, itemType, numberOfCubesInDim, numberOfItems, operations)
    # memory
    def addItem(self, local_ndx):    
        if (self._itemType == 1):    
            item_inst = qbItem.tri(local_ndx) # next level 
        elif (self._itemType == 2):    
            item_inst = qbItem.quad(local_ndx) # next level   
        else:
            print ("ERROR in qbConstituent addItem - type " + str(self._itemType) + " not supported")    
        self._items.append(item_inst)
    # content                           
    def modify(self):
        for i in range (0, len(self._operations)):
            self._property = self._operations[i].execute(self._gridVariable, 2, self._property)
            
    def setNodesNumber(self):
        nodesNumber = [0,0,0,0]
        
        nodesNumber[0] = self._gridVariable[0] + self._gridVariable[1] * (self._numberOfCubesInDim[0] + 1)  \
        +  self._gridVariable[2] * (self._numberOfCubesInDim[0] + 1) * (self._numberOfCubesInDim[1] + 1)
        nodesNumber[1] = nodesNumber[0] + 1                                         # 3 2                       
        nodesNumber[2] = nodesNumber[0] + 1 +(self._numberOfCubesInDim[0] + 1)      # 0 1         
        nodesNumber[3] = nodesNumber[2] - 1
        
        for i in range (0, 4):
            self._nodesNumber[i] = nodesNumber[i]
                                     
class cube_3D(cube):
      
    def __init__(self, constituentType, itemType, numberOfCubesInDim, numberOfItems, operations):  
        nodesNumber = [0,0,0,0,0,0,0,0]
        self._nodesNumber = nodesNumber 
        cube.__init__(self, constituentType, itemType, numberOfCubesInDim, numberOfItems, operations)
    # memory       
    def addItem(self, local_ndx): 
        if (self._itemType == 3):         
            item_inst = qbItem.pris(local_ndx) # next level
        elif (self._itemType == 4):         
            item_inst = qbItem.tet(local_ndx) # next level 
        elif (self._itemType == 5):         
            item_inst = qbItem.hexa(local_ndx) # next level
        else:
            print ("ERROR in qbConstituent addItem - type " + str(self._itemType) + " not supported")  
        self._items.append(item_inst)   
    # content
    def modify(self):
        for i in range (0, len(self._operations)):
            self._property = self._operations[i].execute(self._gridVariable, 3, self._property)
                                           
    def setNodesNumber(self):
        nodesNumber = [0,0,0,0,0,0,0,0]  
        
        numberOfNodesInLayer = (self._numberOfCubesInDim[0] + 1) * (self._numberOfCubesInDim[1] + 1)
        nodesNumber[0] = self._gridVariable[0] + self._gridVariable[1] * (self._numberOfCubesInDim[0] + 1)  \
        +  self._gridVariable[2] * numberOfNodesInLayer
        nodesNumber[1] = nodesNumber[0] + 1                                         # 3 2                       
        nodesNumber[2] = nodesNumber[0] + 1 +(self._numberOfCubesInDim[0] + 1)      # 0 1         
        nodesNumber[3] = nodesNumber[2] - 1
        
        nodesNumber[4] = nodesNumber[0] + numberOfNodesInLayer   # 7 6   z incr
        nodesNumber[5] = nodesNumber[1] + numberOfNodesInLayer   # 4 5 
        nodesNumber[6] = nodesNumber[2] + numberOfNodesInLayer
        nodesNumber[7] = nodesNumber[3] + numberOfNodesInLayer
        
        for i in range (0, 8):
            self._nodesNumber[i] = nodesNumber[i]     
