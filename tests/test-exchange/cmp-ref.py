# -*- coding: utf-8 -*-

from mumax2 import *
from random import *
from math import *
# Standard Problem 4

# define geometry

eps = 1.0e-6

# number of cells
Nx = 64
Ny = 64
Nz = 64
setgridsize(Nx, Ny, Nz)

# physical size in meters
sizeX = 320e-9
sizeY = 160e-9
sizeZ = 64e-9
setcellsize(sizeX/Nx, sizeY/Ny, sizeZ/Nz)

seed(0)

# load modules

load('exchange6')

Aex = 1.3e-11
Msat = 800e3
lex0 = sqrt(2*Aex/(mu0*Msat*Msat))
setv('lex', lex0)
setv('Msat', Msat)
setv('Msat0T0', Msat)

# set parameters
msk=makearray(1, Nx, Ny, Nz)
for k in range(Nz):
    for j in range(Ny):
        for i in range(Nx):
            msk[0][i][j][k] = random() 
setmask('Msat', msk)

lex = makearray(1, Nx, Ny, Nz)
for k in range(Nz):
    for j in range(Ny):
        for i in range(Nx):
            lex[0][i][j][k] = random() / (msk[0][i][j][k]**2.0)
setmask('lex', lex)

# set magnetization
m=makearray(3, Nx, Ny, Nz)
for k in range(Nz):
    for j in range(Ny):
        for i in range(Nx):
            mx = float(random()) 
            my = float(random())
            mz = float(random())
            l = sqrt(mx**2.0 + my**2.0 + mz**2.0)
            m[0][i][j][k] = mx / l * msk[0][i][j][k]
            m[1][i][j][k] = my / l * msk[0][i][j][k]
            m[2][i][j][k] = mz / l * msk[0][i][j][k]
setarray('mf', m)

saveas('H_ex', "omf", ["Text"], "hex_new.omf")
ref = readfile(outputdirectory()+"/../hex_ref.omf")
new = getarray('H_ex')

dirty = 0

for k in range(Nz):
    for j in range(Ny):
        for i in range(Nx):
            for c in range(3):
               diff = abs(new[c][i][j][k] - ref[c][i][j][k])
               if diff > eps:
                   dirty = dirty + 1
                   print new[c][i][j][k], "!=", ref[c][i][j][k]
                   print diff, ">", eps

if dirty > 0:
    print "\033[31m" + "✘ FAILED" + "\033[0m"
    sys.exit(1)
else:
    print "\033[32m" + "✔ PASSED" + "\033[0m"
    sys.exit()
