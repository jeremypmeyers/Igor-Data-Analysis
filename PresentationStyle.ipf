#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Proc PresentationStyle(): GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z standoff=0
	ModifyGraph/Z fsize=18
	ModifyGraph/Z standoff=0
	ModifyGraph/Z freePos=0
EndMacro
