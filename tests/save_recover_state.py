# -*- coding: utf-8 -*-
from mumax2 import *
from math import *
# Standard Problem 4

# define geometry

# number of cells
Nx = 32
Ny = 32
Nz = 32
setgridsize(Nx, Ny, Nz)

# physical size in meters
sizeX = 32e-9
sizeY = 32e-9
sizeZ = 32e-9
setcellsize(sizeX/Nx, sizeY/Ny, sizeZ/Nz)


load('micromagnetism')

m = [[[[1.0]]], [[[1.0]]], [[[1.0]]]]

setarray('m', m)

savestate('m_0', 'm')

m = [[[[1.0]]], [[[0.0]]], [[[0.0]]]]

setarray('m', m)

savestate('m_1', 'm')

recoverstate('m', 'm_0')

m0 = getarray('m')

ok = True

valx = sqrt(1./3.)
valy = sqrt(1./3.)
valz = sqrt(1./3.)

for kk in range(Nz):
    for jj in range(Ny):
        for ii in range(Nx):
            diff = (m0[0][ii][jj][kk] - valx) + (m0[1][ii][jj][kk] - valy) + (m0[2][ii][jj][kk] - valz)
            if diff > 1e-15:
                ok = None

recoverstate('m', 'm_1')

m0 = getarray('m')

valx = 1.0
valy = 0.0
valz = 0.0

for kk in range(Nz):
    for jj in range(Ny):
        for ii in range(Nx):
            diff = (m0[0][ii][jj][kk] - valx) + (m0[1][ii][jj][kk] - valy) + (m0[2][ii][jj][kk] - valz)
            if diff > 1e-15:
                ok = None

if ok :
    print "\033[32m" + "✔ PASSED" + "\033[0m"
    sys.exit()
else:
    print "\033[31m" + "✘ FAILED" + "\033[0m"
    sys.exit(1)

