//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any 
//  copyright notices and prominently state that you modified it, giving a relevant date.

package common

// This file implements safe wrappers for strconv that panic on illegal input.
// Author: Arne Vansteenkiste

import (
	"strconv"
)


// Safe strconv.Atof32
func Atof32(s string) float32 {
	f, err := strconv.Atof32(s)
	if err != nil {
		panic(InputErr(err.String()))
	}
	return f
}

// Safe strconv.Atoi
func Atoi(s string) int {
	i, err := strconv.Atoi(s)
	if err != nil {
		panic(InputErr(err.String()))
	}
	return i
}

// Safe strconv.Atob
func Atob(str string) bool {
	b, err := strconv.Atob(str)
	if err != nil {
		panic(InputErr(err.String()))
	}
	return b
}

// Safe strconv.Atoi64
func Atoi64(str string) int64 {
	i, err := strconv.Atoi64(str)
	if err != nil {
		panic(InputErr(err.String()))
	}
	return i
}

// Safe strconv.Atof64
func Atof64(str string) float64 {
	i, err := strconv.Atof64(str)
	if err != nil {
		panic(InputErr(err.String()))
	}
	return i
}
