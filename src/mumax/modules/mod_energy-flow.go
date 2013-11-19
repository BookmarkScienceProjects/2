//  This file is part of MuMax, a high-performance micromagnetic simulator.
//  Copyright 2011  Arne Vansteenkiste and Ben Van de Wiele.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.
//  Note that you are welcome to modify this code under the condition that you do not remove any
//  copyright notices and prominently state that you modified it, giving a relevant date.

package modules

import (
	. "mumax/common"
	. "mumax/engine"
	"mumax/gpu"
)

var inEF = map[string]string{
	"": "",
}

var depsEF = map[string]string{
	"R":  "R",
	"mf": "mf",
	"Tc": "Tc",
	"J":  "J",
	"n":  "n",
}

var outEF = map[string]string{
	"q_s": "q_s",
}

// Register this module
func init() {
	args := Arguments{inEF, depsEF, outEF}
	RegisterModuleArgs("mfa/energy-flow", "Energy density dissipation rate", args, LoadEFArgs)
}

// There is a problem, since LLB torque is normalized by msat0T0 (zero-temperature value), while LLG torque is normalized by msat
// This has to be explicitly accounted when module is loaded

func LoadEFArgs(e *Engine, args ...Arguments) {

	// make it automatic !!!
	var arg Arguments

	if len(args) == 0 {
		arg = Arguments{inEF, depsEF, outEF}
	} else {
		arg = args[0]
	}
	//

	// make sure the effective field is in place
	LoadMFAParams(e)

	q_s := e.AddNewQuant(arg.Outs("q_s"), SCALAR, FIELD, Unit("J/(s*m3)"), "Spins energy density dissipation rate according to MFA")

	e.Depends(arg.Outs("q_s"), arg.Deps("mf"), arg.Deps("R"), arg.Deps("J"), arg.Deps("Tc"), arg.Deps("n"))
	q_s.SetUpdater(&EFUpdater{
		q_s: q_s,
		J:   e.Quant(arg.Deps("J")),
		Tc:  e.Quant(arg.Deps("Tc")),
		n:   e.Quant(arg.Deps("n")),
		R:   e.Quant(arg.Deps("R")),
		mf:  e.Quant(arg.Deps("mf"))})
}

type EFUpdater struct {
	q_s *Quant
	J   *Quant
	Tc  *Quant
	n   *Quant
	R   *Quant
	mf  *Quant
}

func (u *EFUpdater) Update() {

	Tc := u.Tc.Multiplier()[0]
	n := u.n.Multiplier()[0]

	// Spin should be accounted in the kernel since it enters S(S+1) term
	mult := 6.0 * Kb * Tc * n

	// Account for msat multiplier, because it is a mask
	u.q_s.Multiplier()[0] = u.R.Multiplier()[0]
	// Account for - 2.0 * 0.5 * mu0
	u.q_s.Multiplier()[0] *= u.mf.Multiplier()[0]
	u.q_s.Multiplier()[0] *= mult

	stream := u.q_s.Array().Stream

	gpu.EnergyFlowAsync(u.q_s.Array(),
		u.mf.Array(),
		u.R.Array(),
		u.Tc.Array(),
		u.J.Array(),
		u.n.Array(),
		u.J.Multiplier()[0],
		stream)
	stream.Sync()
}
