#!/usr/bin/python

#######
#
# qbOperation by JOD
#
#

import math
import qbMath
import sys

    
class assignment: 
    _row_ndx_min = [-1,-1,-1]
    _row_ndx_max = [-1,-1,-1]
    
    def __init__(self, row_ndx_min, row_ndx_max):
        self._row_ndx_min = row_ndx_min
        self._row_ndx_max = row_ndx_max
        
    def assignPotentially(self, cube_row_ndx, dim, property):
        newProperty = property
        if(dim < 0):       
            newProperty = self.assign(property) # new value     
        else:          
            if(cube_row_ndx[dim] >= self._row_ndx_min[dim] and cube_row_ndx[dim] < self._row_ndx_max[dim]):
                newProperty = self.assignPotentially(cube_row_ndx, dim - 1, property)    
        return newProperty
        
    def execute(self, cube_row_ndx, dim, property):            
        property = self.assignPotentially(cube_row_ndx, dim - 1, property)
        return property                    
                
class increment(assignment):
 
    def __init__(self, variables, numberOfCubesInDim):
        row_ndx_min = [-1,-1,-1]
        row_ndx_max = [-1,-1,-1]
        for i in range(0, int(( len(variables) - 2) / 2)):
            row_ndx_min[i] = int(variables[int(2 * i + 2)])
            if (str(variables[int(2 * i + 3)]) == "e"):
                row_ndx_max[i] = numberOfCubesInDim[i]
            else:   
                row_ndx_max[i] = int(variables[int(2 * i + 3)]) 
        assignment.__init__(self, row_ndx_min, row_ndx_max)    
          
    def assign(self, property):  
        newProperty = int(property) + 1
        return newProperty

    def writeScreen(self, dim):
        sys.stdout.write("            increment")
        for i in range(0, dim):
            sys.stdout.write(" - " + str(self._row_ndx_min[i]) + " to " + str(self._row_ndx_max[i]) )
        sys.stdout.write("\n") 
         
class imposement(assignment):
    __value = 0   
    def __init__(self, variables, numberOfCubesInDim):
        row_ndx_min = [-1,-1,-1]
        row_ndx_max = [-1,-1,-1]    
        self.__value = int(variables[2])
        for i in range(0, int(( len(variables) - 3) / 2)):
            row_ndx_min[i] = int(variables[int(2 * i + 3)])
            if (str(variables[int(2 * i + 4)]) == "e"):
                row_ndx_max[i] = numberOfCubesInDim[i]
            else:   
                row_ndx_max[i] = int(variables[int(2 * i + 4)]) 
        assignment.__init__(self, row_ndx_min, row_ndx_max)                     

    def assign(self, cube):                   
        return self.__value
        
    def writeScreen(self, dim):
        sys.stdout.write("            impose " + str(self.__value))
        for i in range(0, dim):
            sys.stdout.write(" - " + str(self._row_ndx_min[i]) + " to " + str(self._row_ndx_max[i]) )
        sys.stdout.write("\n") 
            
        
class transformation: 

    _direct = [0.,0.,0.]  
    def __init__(self, variables):
        direct = [0.,0.,0.]     
        direct[0] = float(variables[2])
        direct[1] = float(variables[3])
        direct[2] = float(variables[4])
        self._direct = direct
        
class shift(transformation):
 
    def __init__(self, variables):
        transformation.__init__(self, variables)    
        
    def execute(self, coords):                                                    
        for i in range(0, 3):                               
            coords[i] = coords[i] + self._direct[i]    
        return coords       
        
    def writeScreen(self):                                                                                    
            print("            shift by " + str(self._direct[0]) + " " + str(self._direct[1]) + " " + str(self._direct[2]))      
   
                                         
class rotation(transformation):
    __angle = 0
    
    def __init__(self, variables):
        transformation.__init__(self, variables)
        self.__angle = float(variables[5])
        self._direct = qbMath.normalize(self._direct)
        self.__sinAngle = math.sin(math.radians(self.__angle))
        self.__cosAngle = math.cos(math.radians(self.__angle))
        self.__n0 = self._direct[0] * self.__sinAngle
        self.__n1 = self._direct[1] * self.__sinAngle
        self.__n2 = self._direct[2] * self.__sinAngle
        self.__n00 = self._direct[0] * self._direct[0] * (1 - self.__cosAngle)
        self.__n01 = self._direct[0] * self._direct[1] * (1 - self.__cosAngle)
        self.__n02 = self._direct[0] * self._direct[2] * (1 - self.__cosAngle)
        self.__n11 = self._direct[1] * self._direct[1] * (1 - self.__cosAngle)
        self.__n12 = self._direct[1] * self._direct[2] * (1 - self.__cosAngle)
        self.__n22 = self._direct[2] * self._direct[2] * (1 - self.__cosAngle)         
                 
    def execute(self, coords):    
        newCoords = [0., 0., 0.]  
        newCoords[0] =(self.__n00 + self.__cosAngle) * coords[0] +(self.__n01 - self.__n2)       * coords[1] +(self.__n02  + self.__n1)       * coords[2]     
        newCoords[1] =(self.__n01 + self.__n2)       * coords[0] +(self.__n11 + self.__cosAngle) * coords[1] +(self.__n12  - self.__n0)       * coords[2]
        newCoords[2] =(self.__n02 - self.__n1)       * coords[0] +(self.__n12 + self.__n0)       * coords[1] +(self.__n22  + self.__cosAngle) * coords[2] 
        for i in range(0, 3):  
            if (coords[i] < 1e-10 and coords[i] > -1e-10):
                coords[i] = 0.0
        return coords
        
    def writeScreen(self):                                                                                                                                 
        print("            rotate by angle " + str(self.__angle) + " - axis  "  + str(self._direct[0]) + " " + str(self._direct[1]) + " " + str(self._direct[2]))    
     
     
class stretch(transformation):
 
    def __init__(self, variables):
        transformation.__init__(self, variables)  
        
    def execute(self, coords):    
        if(coords[0] > 0):                                                                                   
            coords[0] =  coords[0] * self._direct[0]   
        if(coords[1] > 0):                                            
            coords[1] =  coords[1] * self._direct[1]     
        if(coords[2] > 0):                                                                                                                 
            coords[2] =  coords[2] * self._direct[2]             
        return coords
      
    def writeScreen(self):             
        print("            stretch by " + str(self._direct[0]) + " " + str(self._direct[1]) + " " + str(self._direct[2]))             
   
                                   
      
