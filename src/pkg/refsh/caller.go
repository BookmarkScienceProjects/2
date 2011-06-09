//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any 
//  copyright notices and prominently state that you modified it, giving a relevant date.

package refsh

// Caller unifies anything that can be called: a Method or a FuncValue.

// Author: Arne Vansteenkiste

import (
	"reflect"
)


// Caller unifies anything that can be called:
// a Method or a FuncValue
type Caller interface {
	Call(args []reflect.Value) []reflect.Value // Call it
	In(i int) reflect.Type                     // Types of the input parameters
	NumIn() int                                // Number of input parameters
	Out(i int) reflect.Type                    // Return type
	NumOut() int
}


// Wraps a method in the Caller interface
type MethodWrapper struct {
	reciever reflect.Value
	function reflect.Value
}

// Implements Caller
func (m *MethodWrapper) Call(args []reflect.Value) []reflect.Value {
	methargs := make([]reflect.Value, len(args)+1) // TODO(a): buffer in method struct
	methargs[0] = m.reciever
	for i, arg := range args {
		methargs[i+1] = arg
	}
	return m.function.Call(methargs)
}

// Implements Caller
func (m *MethodWrapper) In(i int) reflect.Type {
	return (m.function.Type()).In(i + 1) // do not treat the reciever (1st argument) as an actual argument
}

// Implements Caller
func (m *MethodWrapper) NumIn() int {
	return (m.function.Type()).NumIn() - 1 // do not treat the reciever (1st argument) as an actual argument
}

// Implements Caller
func (m *MethodWrapper) Out(i int) reflect.Type {
	return (m.function.Type()).Out(i)
}

// Implements Caller
func (m *MethodWrapper) NumOut() int {
	return (m.function.Type()).NumOut()
}


// Wraps a function in the Caller interface
type FuncWrapper reflect.Value

// Implements Caller
func (f FuncWrapper) In(i int) reflect.Type {
	return (reflect.Value)(f).Type().In(i)
}

// Implements Caller
func (f FuncWrapper) NumIn() int {
	return (reflect.Value)(f).Type().NumIn()
}

// Implements Caller
func (f FuncWrapper) Call(args []reflect.Value) []reflect.Value {
	return (reflect.Value)(f).Call(args)
}


// Implements Caller
func (f FuncWrapper) Out(i int) reflect.Type {
	return (reflect.Value)(f).Type().Out(i)
}

// Implements Caller
func (f FuncWrapper) NumOut() int {
	return (reflect.Value)(f).Type().NumOut()
}
