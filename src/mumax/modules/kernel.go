//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any 
//  copyright notices and prominently state that you modified it, giving a relevant date.

package modules

// Common functions for all kernels.
// Author: Arne Vansteenkiste

import (
//. "mumax/common"
)

// Modulo-like function:
// Wraps an index to [0, max] by adding/subtracting a multiple of max.
func Wrap(number, max int) int {
	for number < 0 {
		number += max
	}
	for number >= max {
		number -= max
	}
	return number
}

// Add padding x 2 in all directions where periodic == 0, except when a dimension == 1 (no padding necessary)
func padSize(size []int, periodic []int) []int {
	paddedsize := make([]int, len(size))
	for i := range size {
		if size[i] > 1 && periodic[i] == 0 {
			paddedsize[i] = 2 * size[i]
		} else {
			paddedsize[i] = size[i]
		}
	}
	return paddedsize
}
