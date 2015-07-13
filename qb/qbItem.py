#!/usr/bin/python

########
#
# qb class item by JOD
# level 3
#


class item: # level3
   
    def __init__(self, local_ndx): 
        self._local_ndx = local_ndx
    # file stream   	     
    def write(self, file):
        for i in range (0, len(self._nodesNumber)):    
            file.write(" " + str(self._nodesNumber[i])) 
            
class line(item):          
    _nodesNumber = [-1,-1]    
        
    def __init__(self, local_ndx):
        nodesNumber = [-1,-1]  
        self._nodesNumber = nodesNumber         
        item.__init__(self, local_ndx)
    # content             
    def fill(self, cubeNodesNumber):
        for i in range (0, len(self._nodesNumber)):  
            self._nodesNumber[i] = int(cubeNodesNumber[i]) 
            
class tri(item):          
    _nodesNumber = [-1,-1,-1]    
        
    def __init__(self, local_ndx):
        nodesNumber = [-1,-1,-1]  
        self._nodesNumber = nodesNumber         
        item.__init__(self, local_ndx)
    # content               
    def fill(self, cubeNodesNumber):
        if(self._local_ndx == 0):
            self._nodesNumber[0] = int(cubeNodesNumber[0])    
            self._nodesNumber[1] = int(cubeNodesNumber[1]) 
            self._nodesNumber[2] = int(cubeNodesNumber[3])
        else:                 
            self._nodesNumber[0] = int(cubeNodesNumber[1])    
            self._nodesNumber[1] = int(cubeNodesNumber[2]) 
            self._nodesNumber[2] = int(cubeNodesNumber[3])    
                      
class quad(item):          
    _nodesNumber = [-1,-1,-1,-1]    
        
    def __init__(self, local_ndx):
        nodesNumber = [-1,-1,-1,-1]  
        self._nodesNumber = nodesNumber            
        item.__init__(self, local_ndx)   
    # content             
    def fill(self, cubeNodesNumber):
        for i in range (0, len(self._nodesNumber)):  
            self._nodesNumber[i] = int(cubeNodesNumber[i])          
        
class pris(item):          
    _nodesNumber = [-1,-1,-1,-1,-1,-1]    
        
    def __init__(self, local_ndx):
        nodesNumber = [-1,-1,-1,-1,-1,-1]   
        self._nodesNumber = nodesNumber         
        item.__init__(self, local_ndx)
    # content               
    def fill(self, cubeNodesNumber):
        if(self._local_ndx == 0):
            self._nodesNumber[0] = int(cubeNodesNumber[0])    
            self._nodesNumber[1] = int(cubeNodesNumber[1]) 
            self._nodesNumber[2] = int(cubeNodesNumber[3])
            self._nodesNumber[3] = int(cubeNodesNumber[4])    
            self._nodesNumber[4] = int(cubeNodesNumber[5]) 
            self._nodesNumber[5] = int(cubeNodesNumber[7])            
        else:                 
            self._nodesNumber[0] = int(cubeNodesNumber[1])    
            self._nodesNumber[1] = int(cubeNodesNumber[2]) 
            self._nodesNumber[2] = int(cubeNodesNumber[3]) 
            self._nodesNumber[3] = int(cubeNodesNumber[4])    
            self._nodesNumber[4] = int(cubeNodesNumber[5]) 
            self._nodesNumber[5] = int(cubeNodesNumber[6])             
                      
class tet(item):          
    _nodesNumber = [-1,-1,-1,-1]    
        
    def __init__(self, local_ndx):
        nodesNumber = [-1,-1,-1,-1]  
        self._nodesNumber = nodesNumber            
        item.__init__(self, local_ndx)   
    # content             
    def fill(self, cubeNodesNumber):
        pass  
                                         
class hexa(item):          
    _nodesNumber = [-1,-1,-1,-1,-1,-1,-1,-1]    
        
    def __init__(self, local_ndx):
        nodesNumber = [-1,-1,-1,-1,-1,-1,-1,-1]  
        self._nodesNumber = nodesNumber            
        item.__init__(self, local_ndx)          
    # content             
    def fill(self, cubeNodesNumber):
        for i in range (0, len(self._nodesNumber)):  
            self._nodesNumber[i] = int(cubeNodesNumber[i])       
          
