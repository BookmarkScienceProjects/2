//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any 
//  copyright notices and prominently state that you modified it, giving a relevant date.

package gpu

// This file implements 3-dimensional arrays of N-vectors distributed over multiple GPUs.
// Author: Arne Vansteenkiste

import (
	. "mumax/common"
	"mumax/host"
	cu "cuda/driver"
)


// A MuMax Array represents a 3-dimensional array of N-vectors.
//
// Layout example for a (3,4) vsplice on 2 GPUs:
// 	GPU0: X0 X1  Y0 Y1 Z0 Z1
// 	GPU1: X2 X3  Y2 Y3 Z2 Z3
// TODO: get components as array (slice in J direction), get device part as array.
type Array struct {
	Comp [][]slice // List of components, e.g. vector or tensor components
	list []slice   // All elements as a single, contiguous list. 
	// The memory layout is not simple enough for a host array to be directly copied to it.
	_size  [4]int // INTERNAL {components, size0, size1, size2}
	size4D []int  // {components, size0, size1, size2}
	size3D []int  // {size0, size1, size2}
}


// Initializes the array to hold a field with the number of components and given size.
// E.g.: Init(3, 1000) gives an array of 1000 3-vectors
// E.g.: Init(1, 1000) gives an array of 1000 scalars
// E.g.: Init(6, 1000) gives an array of 1000 6-vectors or symmetric tensors
func (t *Array) InitArray(components int, size3D []int) {
	Assert(components > 0)
	Assert(len(size3D) == 3)
	length := Prod(size3D)

	devices := getDevices()
	t.list = make([]slice, len(devices))
	slicelen := distribute(components*length, devices)
	for i := range devices {
		t.list[i].init(devices[i], slicelen[i])
	}

	Ndev := len(devices)
	compSliceLen := distribute(length, devices)

	t.Comp = make([][]slice, components)
	for i := range t.Comp {
		t.Comp[i] = make([]slice, Ndev)
		for j := range t.Comp[i] {
			cs := &(t.Comp[i][j])
			start := i * compSliceLen[j]
			stop := (i + 1) * compSliceLen[j]
			cs.initSlice(&(t.list[j]), start, stop)
		}
	}

	t._size[0] = components
	for i := range size3D {
		t._size[i+1] = size3D[i]
	}
	t.size4D = t._size[:]
	t.size3D = t._size[1:]
	t.Zero()
}


// Returns an array which holds a field with the number of components and given size.
func NewArray(components int, size3D []int) *Array {
	t := new(Array)
	t.InitArray(components, size3D)
	return t
}


// Frees the underlying storage and sets the size to zero.
func (v *Array) Free() {
	for i := range v.list {
		(&(v.list[i])).free()
	}

	//TODO(a) Destroy streams.
	// nil pointers, zero lengths, just to be sure
	for i := range v.Comp {
		slice := v.Comp[i]
		for j := range slice {
			// The slice must not be freed because the underlying list has already been freed.
			slice[j].devId = -1 // invalid id 
			slice[j].stream.Destroy()
		}
	}
	v.Comp = nil

	for i := range v._size {
		v._size[i] = 0
	}
}


// Address of part of the array on device deviceId.
func (a *Array) DevicePtr(deviceId int) cu.DevicePtr {
	return a.list[deviceId].array
}

// True if unallocated/freed.
//func (a *Array) IsNil() bool {
//	return a.splice.IsNil()
//}

// Total number of elements
func (a *Array) Len() int {
	return a._size[0] * a._size[1] * a._size[2] * a._size[3]
}

// Number of components (1: scalar, 3: vector, ...).
func (a *Array) NComp() int {
	return a._size[0]
}

// Size of the vector field
func (a *Array) Size3D() []int {
	return a.size3D
}
func (dst *Array) CopyFromDevice(src *Array) {
	// test for equal size
	for i, d := range dst._size {
		if d != src._size[i] {
			panic(MSG_ARRAY_SIZE_MISMATCH)
		}
	}
	d := dst.list
	s := src.list
	Assert(len(d) == len(s)) // in principle redundant
	start := 0
	// copies run concurrently on the individual devices
	for i := range s {
		length := s[i].length // in principle redundant
		Assert(length == d[i].length)
		cu.MemcpyDtoDAsync(cu.DevicePtr(s[i].array), cu.DevicePtr(d[i].array), SIZEOF_FLOAT*int64(length), s[i].stream)
		start += length
	}
	// Synchronize with all copies
	for i := range s {
		s[i].stream.Synchronize()
	}

}


// Copy from host array to device array.
func (dst *Array) CopyFromHost(srca *host.Array) {
	src := srca.Comp

	Assert(dst.NComp() == len(src))
	// we have to work component-wise because of the data layout on the devices
	for i := range src {
		//Assert(len(dst.Comp[i]) == len(src[i])) // TODO(a): redundant
		//dst.Comp[i].CopyFromHost(src[i])

		h := src[i]
		s := dst.Comp[i]
		//Assert(len(h) == len(s)) // in principle redundant
		start := 0
		for i := range s {
			length := s[i].length
			cu.MemcpyHtoD(cu.DevicePtr(s[i].array), cu.HostPtr(&h[start]), SIZEOF_FLOAT*int64(length))
			start += length
		}
	}
}


// Copy from device array to host array.
func (src *Array) CopyToHost(dsta *host.Array) {
	dst := dsta.Comp

	Assert(src.NComp() == len(dst))
	for i := range dst {
		//Assert(len(src.Comp[i]) == len(dst[i])) // TODO(a): redundant
		//src.Comp[i].CopyToHost(dst[i])

		h := dst[i]
		s := src.Comp[i]
		//Assert(len(h) == len(s)) // in principle redundant
		start := 0
		for i := range s {
			length := s[i].length
			cu.MemcpyDtoH(cu.HostPtr(&h[start]), cu.DevicePtr(s[i].array), SIZEOF_FLOAT*int64(length))
			start += length
		}

	}

}


// DEBUG: Make a freshly allocated copy on the host.
func (src *Array) LocalCopy() *host.Array {
	dst := host.NewArray(src.NComp(), src.Size3D())
	src.CopyToHost(dst)
	return dst
}


func (a *Array) Zero() {
	slices := a.list
	for i := range slices {
		assureContextId(slices[i].devId)
		cu.MemsetD32Async(slices[i].array, 0, int64(slices[i].length), slices[i].stream)
	}
	for i := range slices {
		slices[i].stream.Synchronize()
	}
}

// Error message.
const MSG_ARRAY_SIZE_MISMATCH = "array size mismatch"