//  This file is part of muQueue, a job scheduler for MuMax.
//  Copyright 2012  Arne Vansteenkiste.
//  Use of this source code is governed by the GNU General Public License version 3
//  (as published by the Free Software Foundation) that can be found in the license.txt file.

package main

// Implementation of "status" command

import (
	"fmt"
	"strings"
)

func init() {
	api["status"] = status
}

const STATLEN = 20 // show only this many que entries

// reports the queue status
func status(user string, argz []string) string {
	n := STATLEN
	args, _ := parse(argz)

	status := ""
	count := 0
	for i, job := range queue {
		if match(job, args) {
			count++
			if i < n {
				status += fmt.Sprint(job, "\n")
			}
		}
	}
	if count > STATLEN {
		status += fmt.Sprint(count-STATLEN, " more...")
	}
	return fmt.Sprint(count, " jobs\n",status)
}

func match(job *Job, regexp []string) bool {
	if len(regexp) == 0 {
		return true
	}
	for _, r := range regexp {
		if strings.Contains(job.String(), r) {
			return true
		}
	}
	return false
}
