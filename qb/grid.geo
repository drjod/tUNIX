------- qb Input


verbosity 1

output accumulated  ; direct 

mesh ogsFiniteElements hex

pcsType MASS_TRANSPORT

length 10 10 10
numberOfCubes 10 10 10


;                   row0_min row0_max  row1_min    row1_max   row2_min    row2_max
property impose  5  0        e         0           e          0           3
property increment  0        e         0           e          7           e


;                   x-direction y-direction z-direction   angle
position stretch    2           0           0
position rotate     1           0           0             90
position shift      0           0           -400



end

