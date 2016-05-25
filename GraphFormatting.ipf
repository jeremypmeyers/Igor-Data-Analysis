#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function PrepGraphForPresentationWide()
string wl=winlist("*",";","WIN:1") //Gets a list of all existing graph windows
print wl
string wn
string wtl=""
variable wi=0
do
	wn=StringFromList(wi,wl)
	if (strlen(wn)==0)
		break
	endif
	GetWindow $wn wtitle	
	wtl += ReplaceString(";", s_value, "") +";" //Creates a list of existing windows titles
	wi+=1
while(1)
variable wselect
prompt wselect, "Which graph do you want to apply style to?", popup, wtl
doprompt "Graph selection", wselect //Prompts the user to select which chart to change styles on

string chartname=Stringfromlist((wselect-1),wl)
Modifygraph/Z /W=$chartname standoff=0,fsize=18,freePos=0 //Eliminates standoffs, sets axis font size to 18
ModifyGraph /W=$chartname gFont="Corbel"

string al=annotationlist(chartname) 	//Creates a list of all annotations in the chart
variable ai=0
do											 	//Do-loop to change all annotations in the chart
	string an=stringfromlist(ai,al)
	if (strlen(an)==0)
		break
	endif
	string astring= annotationinfo(chartname,an,1)
	string tstring= StringByKey("TEXT", astring ) //Captures the existing annotation text
	variable start=0
	do
		variable fontsizestart=strsearch(tstring,"\Z",start) //Looks for places in the text where font size is declared
		if (fontsizestart<0)
			break
		endif
		tstring=ReplaceString(tstring[fontsizestart+2], tstring, "1",1,1) //there's got to be a more elegant way to replace the two digits of
		tstring=ReplaceString(tstring[fontsizestart+3], tstring, "6",1,1) //an existing font size with "16" but this is what I came up with.
		start=fontsizestart+3
	while(1)
//	tstring = ReplaceString("\\\\", tstring, "\\") //this gets most \ output formatted correctly so they're read
																//as control characters and not as the actual '\' character
	tstring = "\\Z16"+tstring //If font size is default, explicitly changes font size to 16 point.
	textbox/C/N=$an tstring
	ai+=1
while(1)
modifygraph /W=$chartname width=12*72
modifygraph /W=$chartname height=5*72
dowindow /F $chartname
SavePICT/E=-5/TRAN=1/B=360

end

function PrepGraphForPresentationHalf()
string wl=winlist("*",";","WIN:1") //Gets a list of all existing graph windows
print wl
string wn
string wtl=""
variable wi=0
do
	wn=StringFromList(wi,wl)
	if (strlen(wn)==0)
		break
	endif
	GetWindow $wn wtitle	
	wtl += ReplaceString(";", s_value, "") +";" //Creates a list of existing windows titles
	wi+=1
while(1)
variable wselect
prompt wselect, "Which graph do you want to apply style to?", popup, wtl
doprompt "Graph selection", wselect //Prompts the user to select which chart to change styles on

string chartname=Stringfromlist((wselect-1),wl)
Modifygraph/Z /W=$chartname standoff=0,fsize=18,freePos=0 //Eliminates standoffs, sets axis font size to 18
ModifyGraph /W=$chartname gFont="Corbel"

string al=annotationlist(chartname) 	//Creates a list of all annotations in the chart
variable ai=0
do											 	//Do-loop to change all annotations in the chart
	string an=stringfromlist(ai,al)
	if (strlen(an)==0)
		break
	endif
	string astring= annotationinfo(chartname,an,1)
	string tstring= StringByKey("TEXT", astring ) //Captures the existing annotation text
	variable start=0
	do
		variable fontsizestart=strsearch(tstring,"\Z",start) //Looks for places in the text where font size is declared
		if (fontsizestart<0)
			break
		endif
		tstring=ReplaceString(tstring[fontsizestart+2], tstring, "1",1,1) //there's got to be a more elegant way to replace the two digits of
		tstring=ReplaceString(tstring[fontsizestart+3], tstring, "6",1,1) //an existing font size with "16" but this is what I came up with.
		start=fontsizestart+3
	while(1)
//	tstring = ReplaceString("\\\\", tstring, "\\") //this gets most \ output formatted correctly so they're read
																//as control characters and not as the actual '\' character
	tstring = "\\Z16"+tstring //If font size is default, explicitly changes font size to 16 point.
	textbox/C/N=$an tstring
	ai+=1
while(1)
modifygraph /W=$chartname width=6*72
modifygraph /W=$chartname height=5*72
dowindow /F $chartname
SavePICT/E=-5/TRAN=1/B=360

end



	
function PrepGraphForJournal()
string wl=winlist("*",";","WIN:1") //Gets a list of all existing graph windows
print wl
string wn
string wtl=""
variable wi=0
do
	wn=StringFromList(wi,wl)
	if (strlen(wn)==0)
		break
	endif
	GetWindow $wn wtitle	
	wtl += ReplaceString(";", s_value, "") +";" //Creates a list of existing windows titles
	wi+=1
while(1)
variable wselect
prompt wselect, "Which graph do you want to apply style to?", popup, wtl
doprompt "Graph selection", wselect //Prompts the user to select which chart to change styles on

string chartname=Stringfromlist((wselect-1),wl)
Modifygraph/Z /W=$chartname standoff=0,fsize=18,freePos=0 //Eliminates standoffs, sets axis font size to 18
ModifyGraph /W=$chartname gFont="Corbel"

string al=annotationlist(chartname) 	//Creates a list of all annotations in the chart
variable ai=0
do											 	//Do-loop to change all annotations in the chart
	string an=stringfromlist(ai,al)
	if (strlen(an)==0)
		break
	endif
	string astring= annotationinfo(chartname,an,1)
	string tstring= StringByKey("TEXT", astring ) //Captures the existing annotation text
	variable start=0
	do
		variable fontsizestart=strsearch(tstring,"\Z",start) //Looks for places in the text where font size is declared
		if (fontsizestart<0)
			break
		endif
		tstring=ReplaceString(tstring[fontsizestart+2], tstring, "1",1,1) //there's got to be a more elegant way to replace the two digits of
		tstring=ReplaceString(tstring[fontsizestart+3], tstring, "6",1,1) //an existing font size with "16" but this is what I came up with.
		start=fontsizestart+3
	while(1)
//	tstring = ReplaceString("\\\\", tstring, "\\") //this gets most \ output formatted correctly so they're read
																//as control characters and not as the actual '\' character
	tstring = "\\Z16"+tstring //If font size is default, explicitly changes font size to 16 point.
	textbox/C/N=$an tstring
	ai+=1
while(1)
modifygraph /W=$chartname width=12*72
modifygraph /W=$chartname height=5*72
ModifyGraph rgb=(0,0,0)
ModifyGraph /W=$chartname tick(left)=1,tick(bottom)=1
//	ModifyGraph /W=$chartname font="LM Roman 12 Regular"
	ModifyGraph /W=chartname fSize=10
//	ModifyGraph lblMargin(left)=3,lblMargin(a)=3
//	ModifyGraph standoff=0
//	ModifyGraph lblPosMode(left)=1,lblPosMode(bottom)=1
dowindow /F $chartname
SavePICT/E=-5/TRAN=0/B=360

end