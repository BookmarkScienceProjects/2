//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any 
//  copyright notices and prominently state that you modified it, giving a relevant date.

package main

import(
	. "mumax/common"
	"flag"
)

const WELCOME = `MuMax 2.0.0.70 FD Multiphysics Engine (C) Arne Vansteenkiste & Ben Van de Wiele, Ghent University.`

var (
	logfile      *string   = flag.String("log", "mumax.log", "Specify the log file.")
)

func main() {
	flag.Parse()
	InitLogger(*logfile)	
	Println(WELCOME)
	Println("Finished.")
}

