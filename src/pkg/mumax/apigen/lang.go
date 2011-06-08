//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any 
//  copyright notices and prominently state that you modified it, giving a relevant date.


package apigen

import (
	"io"
	"reflect"
)

// Represents a programming language.
type Lang interface {
	FileExt() string                                               // Extension of source files
	WriteHeader(out io.Writer)                                     // Write the header of the source file.
	WriteFunc(out io.Writer, name string, argTypes []reflect.Type) // Write a function wrapper to the source file.
}
