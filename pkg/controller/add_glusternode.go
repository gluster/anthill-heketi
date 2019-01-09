package controller

import (
	"github.com/gluster/anthill-heketi/pkg/controller/glusternode"
)

func init() {
	// AddToManagerFuncs is a list of functions to create controllers and add them to a manager.
	AddToManagerFuncs = append(AddToManagerFuncs, glusternode.Add)
}
