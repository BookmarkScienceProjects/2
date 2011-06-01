//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any 
//  copyright notices and prominently state that you modified it, giving a relevant date.

package gpu

// Author: Arne Vansteenkiste

import (
	//. "mumax/common"
	//"mumax/host"
	"testing"
)

func TestIndex1D(test *testing.T) {
	// fail test on panic, do not crash
	defer func(){
		if err := recover(); err != nil{ test.Error(err) }
	}()

	size := []int{4, 8, 16}
	a := NewArray(1, size)

	set := Global("debug", "SetIndex1D")
	set.Configure1D(a.Len())
	set.SetArgs(a)
	set.Call()
}

func TestIndex3D(test *testing.T) {
	// fail test on panic, do not crash
	defer func(){
		if err := recover(); err != nil{ test.Error(err) }
	}()

	size := []int{4, 8, 16}
	a := NewArray(1, size)

	set := Global("debug", "SetIndex3D")
	set.Configure2D(a.Size3D())
	set.SetArgs(a)
	set.Call()
}
