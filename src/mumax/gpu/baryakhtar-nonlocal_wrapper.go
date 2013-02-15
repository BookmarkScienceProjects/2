//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any 
//  copyright notices and prominently state that you modified it, giving a relevant date.

package gpu

// CGO wrappers for baryakhtar-nonlocal.cu
// Author: Mykola Dvornik

//#include "libmumax2.h"
import "C"

import (
	. "mumax/common"
	"unsafe"
)

func BaryakhtarNonlocalAsync(t *Array, h *Array, msat0T0 *Array, lambda_e *Array, lambda_eMul []float64, cellsizeX float32, cellsizeY float32, cellsizeZ float32, pbc []int) {

	// Bookkeeping 
	CheckSize(t.Size3D(), h.Size3D())
	Assert(h.NComp() == 3)
    
	// Calling the CUDA functions
	C.baryakhtar_nonlocal_async(
		(**C.float)(unsafe.Pointer(&(t.Comp[X].Pointers()[0]))),
		(**C.float)(unsafe.Pointer(&(t.Comp[Y].Pointers()[0]))),
		(**C.float)(unsafe.Pointer(&(t.Comp[Z].Pointers()[0]))),

		(**C.float)(unsafe.Pointer(&(h.Comp[X].Pointers()[0]))),
		(**C.float)(unsafe.Pointer(&(h.Comp[Y].Pointers()[0]))),
		(**C.float)(unsafe.Pointer(&(h.Comp[Z].Pointers()[0]))),
		
		(**C.float)(unsafe.Pointer(&(msat0T0.Comp[X].Pointers()[0]))),
		
		(**C.float)(unsafe.Pointer(&(lambda_e.Comp[XX].Pointers()[0]))),
		(**C.float)(unsafe.Pointer(&(lambda_e.Comp[YY].Pointers()[0]))),
		(**C.float)(unsafe.Pointer(&(lambda_e.Comp[ZZ].Pointers()[0]))),
		(**C.float)(unsafe.Pointer(&(lambda_e.Comp[YZ].Pointers()[0]))),
		(**C.float)(unsafe.Pointer(&(lambda_e.Comp[XZ].Pointers()[0]))),
		(**C.float)(unsafe.Pointer(&(lambda_e.Comp[XY].Pointers()[0]))),
		
		(C.float)(float32(lambda_eMul[XX])),
        (C.float)(float32(lambda_eMul[YY])),
        (C.float)(float32(lambda_eMul[ZZ])),
        (C.float)(float32(lambda_eMul[YZ])),
        (C.float)(float32(lambda_eMul[XZ])),
        (C.float)(float32(lambda_eMul[XY])),
        
		(C.int)(t.PartSize()[X]),
		(C.int)(t.PartSize()[Y]),
		(C.int)(t.PartSize()[Z]),

		(C.float)(cellsizeX),
		(C.float)(cellsizeY),
		(C.float)(cellsizeZ),

		(C.int)(pbc[X]),
		(C.int)(pbc[Y]),
		(C.int)(pbc[Z]),

		(*C.CUstream)(unsafe.Pointer(&(t.Stream[0]))))
}
