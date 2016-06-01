function /S maketracename(yname,type,battery,chartname)
string yname,type,battery,chartname
string tn=(yname+type+battery)
tn =ReplaceString("'", tn, "")
tn=cleanupname(tn,0)
tn =ReplaceString("_",tn,"")

if (strlen(tn)>31)
	tn=tn[0,30]
	if (StringMatch(TraceNameList(chartname, ";", 1 ), "*"+tn+"*" )!=0)
		variable i=50
		do
			if (i==58)
				i+=7
			endif
			tn[strlen(tn)-2,strlen(tn)-1]="_"+num2char(i)
			i+=1
		while (StringMatch(TraceNameList(chartname, ";", 1 ), "*"+tn+"*" )!=0)
	endif
else
	If (StringMatch(TraceNameList(chartname, ";", 1 ), "*"+tn+"*" )!=0)
		tn+="__"
		i=50
		do
			if (i==58)
				i+=7
			endif
			if (i==91)
				i+=6
			endif
			tn[strlen(tn)-2,strlen(tn)-1]="_"+num2char(i)
			i+=1
		while (StringMatch(TraceNameList(chartname, ";", 1 ), "*"+tn+"*" )!=0)
	endif
endif
return tn
end



function cleanaxes(chartname)
string chartname
modifygraph /W=$chartname axisontop=1, axoffset=0, font="Arial",freepos=0,standoff=0
ModifyGraph lblPosMode=1,lblMargin=5

string axl=AxisList(chartname)
variable axi=0
variable axcount=0
do
	string axn=StringFromList(axi, axl)
	if (strlen(axn)==0)
		break
	endif
	string axinf=axisinfo(chartname,axn)
	//print axinf
	if (cmpstr("left",StringByKey("AXTYPE", axinf))==0)
		axcount+=1
		print axn,axcount
	endif
	axi+=1
while(1)
print "check",axcount
if (axcount>1)
	axi=0
	variable axcounter=0
	do
		axn=StringFromList(axi, axl)
		if (strlen(axn)==0)
			break
		endif
		axinf=axisinfo(chartname,axn)
		print axn,stringbykey("AXTYPE",axinf)
		if (cmpstr("left",StringByKey("AXTYPE", axinf))==0)		
			variable gap=0.03
			variable seg=(1-axcount*gap)/axcount
			variable lowfrac = axcounter*(seg+gap)
			variable hifrac = axcounter*(seg+gap)+seg
			if (hifrac>0.95)
				hifrac=1
			endif
			modifygraph /W=$chartname axisenab($axn)={lowfrac,hifrac}
			axcounter+=1
		endif
		axi+=1
	while(1)
endif
end


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
ModifyGraph /W=$chartname gFont="Arial"

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
ModifyGraph /W=$chartname gFont="Arial"

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
ModifyGraph /W=$chartname gFont="Arial"

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

	tstring = "\\Z16"+tstring //If font size is default, explicitly changes font size to 16 point.
	textbox/C/N=$an tstring
	ai+=1
while(1)
modifygraph /W=$chartname width=12*72
modifygraph /W=$chartname height=5*72
ModifyGraph rgb=(0,0,0)
ModifyGraph /W=$chartname tick(left)=1,tick(bottom)=1
	ModifyGraph /W=chartname fSize=10

dowindow /F $chartname
SavePICT/E=-5/TRAN=0/B=360

end