//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any 
//  copyright notices and prominently state that you modified it, giving a relevant date.

package engine

// This file implements the simulation engine client. The engine client connects
// to an engine server which stores the entire simulation state.
// The engine client in turn exposes the client API to a driver
// program written in a scripting language.
// Author: Arne Vansteenkiste

type Client struct {

}