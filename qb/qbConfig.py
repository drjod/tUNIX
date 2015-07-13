#!/usr/bin/python

verbosity = 1

identifier = ['pcsType']

outputMode = {'accumulated': 0, 'direct': 1}   # default 0
meshType = {'ogsFiniteElements': 0}
constituentType = {'cube': 0, 'node': 1}
itemType = {'line': 0, 'tri': 1, 'quad': 2, 'pris': 3, 'tet': 4, 'hex': 5}
#inv_itemType = {v: k for k, v in itemType.items()}
inv_itemType = dict((v,k) for k, v in itemType.items()) 
dim = {'line': 1, 'tri': 2, 'quad': 2, 'pris': 3, 'tet': 3, 'hex': 3}
numberOfItemsInCube = {'line': 1, 'tri': 2, 'quad': 1, 'pris': 3, 'tet': 6, 'hex': 1}

  
