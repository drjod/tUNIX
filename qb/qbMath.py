#!/usr/bin/python

#######################################################################
#
# qbMath by JOD
#
#


import math
#import copy
#import numpy as np
          
def absolute ( values ):
    sumOfSquares = 0
    for i in range ( 0, len ( values ) ):
        sumOfSquares = sumOfSquares + values[i] * values[i]    
    return math.sqrt ( sumOfSquares )
       
def normalize ( values ):
    abs_value = absolute ( values ) 
    if ( abs_value != 0 ):
        for i in range ( 0, len ( values ) ):
            values[i] = values[i] / abs_value
        return values       
    else:  
        print ( "ERROR in qbMath normalize - absolute value is 0 - return 0" )         
        
def add(list_a, list_b):
    list_c = []
    for i in range (0, len(list_a)):
        list_c.append(list_a[i] + list_b[i])
    return list_c  
    
      
