#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function eRickshaw()
	setdatafolder root:
	createErickshawRuncharts()
	string comparechart = "eRickshawRunchart"
	excludeBaddata(comparechart)
	setdatafolder root:
	RickshawstatsIndividual()
	RickshawstatsTypes()
end


function createErickshawRuncharts()
dowindow eRickshawRunchart
if (v_flag==0)
	display /N=eRickshawRunchart
endif
string legendstring=""
variable typeindex=0
do
	string typename = GetIndexedObjName(":", 4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar red,green,blue
	variable batteryindex=0
	do
		string batteryname = GetIndexedObjName(":",4,batteryindex)
		if (strlen(batteryname)==0)
			break
		endif
		setdatafolder $batteryname
		wave voltage, current, step_time,total_time
		duplicate /o total_time timehr
		duplicate /o step_time steptimehr
		timehr/=3600
		steptimehr/=3600
		string vname = "V" + typename+replacestring("Bat",batteryname,"")
		string cname = "A" + typename+replacestring("Bat",batteryname,"")
			appendtograph /W=eRickshawRunchart /L=V voltage /TN=$vname vs timehr
			appendtograph /W=eRickshawRunchart /L=A current /TN=$cname vs timehr
			ModifyGraph /W=eRickshawRunchart lstyle($vname)=(batteryindex),lstyle($cname)=(batteryindex)
			ModifyGraph /W=eRickshawRunchart rgb($vname)=(red,green,blue)
			ModifyGraph /W=eRickshawRunchart rgb($cname)=(red,green,blue)
			legendstring+="\s("+vname+")"+ typename+" "+replacestring("Bat",batteryname,"") + "\r"
		waveclear voltage, current, step_time,total_time, steptimehr, timehr
		setdatafolder root:
		setdatafolder $typename
		batteryindex+=1
	while(1)
		setdatafolder root:
	typeindex+=1
while(1)
ModifyGraph /W=eRickshawRunchart standoff(V)=0,standoff(A)=0,axisEnab(V)={0,0.48},axisEnab(A)={0.52,1}
ModifyGraph /W=eRickshawRunchart freePos(V)=0,freePos(A)=0
Textbox /W=eRickshawRunchart /N=legendary legendstring
end


function RickshawstatsIndividual()
dowindow eRickshawRechargeTimes
if (v_flag==0)
	display /N=eRickshawRechargetimes
endif


variable typeindex=0
do
	string typename = GetIndexedObjName(":", 4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar red,green,blue
	variable batteryindex=0
	do
		string batteryname = GetIndexedObjName(":",4,batteryindex)
		if (strlen(batteryname)==0)
			break
		endif
		setdatafolder $batteryname
		if ((batteryindex==0) && (typeindex==0))
			wave current, step
			display /N=checkgraph current
			appendtograph /W=checkgraph /R step
			modifygraph /W=checkgraph rgb(current)=(0,0,0)
			Label /W=checkgraph left "Current (A)"
			Label /W=checkgraph right "Step ID"
			ModifyGraph /W=checkgraph axRGB(right)=(65280,0,0),tlblRGB(right)=(65280,0,0)
			ModifyGraph /W=checkgraph alblRGB(right)=(65280,0,0)

			variable windowwidth=700
			variable windowheight=200
			NewPanel /N=checkinpanel /Ext=0 /HOST=checkgraph /W=(1,1,(windowwidth),(windowheight))  as "Make sure you've identified charge/discharge steps"
			string panelname="checkgraph#checkinpanel"
			button bb,pos={(windowwidth/2-150),(windowheight-50)},size={300,35},win=$panelname,title="Note Step IDs and Close Window ",proc=checkedin
			PauseForUser $panelname, checkgraph
			nvar rechargestep =root:rechargestep
			nvar dischargestep = root:dischargestep
			waveclear current, step
		endif
		nvar /Z skip
		if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
		wave amp_hours, steptimehr,step
		make /N=0 /o cycles,rechargetime
		duplicate /o amp_hours rechargefactor
		rechargefactor = 0
		variable i=1
		do
			if ((step[i]!=dischargestep) && (step[i-1]==dischargestep) )
				variable discap=-amp_hours[i-1]
			endif
			if (step[i]==rechargestep)
				rechargefactor[i] = amp_hours[i]/discap
			endif
			if (((step[i]!=rechargestep) && (numtype(step[i])==0) )&& (step[i-1]==rechargestep) )
				variable numcycles=numpnts(cycles)
				redimension /N=(numcycles+1) cycles,rechargetime
				if (numcycles==0)
					cycles[numcycles]=1
				else
					cycles[numcycles]=cycles[numcycles-1]+1
				endif
					rechargetime[numcycles]=steptimehr[i-1]
			endif
			i+=1
		while (i<numpnts(rechargefactor))
			string rtname = "rechargetime"+getdatafolder(0)
			appendtograph /W=eRickshawRechargetimes rechargetime/TN=$rtname vs cycles
			modifygraph /W=eRickshawRechargetimes rgb($rtname)=(red,green,blue)
			modifygraph /W=eRickshawRechargetimes lstyle($rtname)=batteryindex
		endif
		setdatafolder root:
		setdatafolder $typename
		batteryindex+=1
	while(1)
		setdatafolder root:
	typeindex+=1
while(1)
Label /W=eRickshawRechargeTimes left "Recharge time (hr)"
Label /W=eRickshawRechargeTimes bottom "Cycle number"
setdatafolder root:
killvariables dischargestep,rechargestep
end

function checkedin(ctrlname) : buttoncontrol
string ctrlname
killwindow checkgraph#checkinpanel
killwindow checkgraph
variable /G root:rechargestep
variable /G root:dischargestep
variable dis
variable re
wave step
wave /T mode
string chargemenustr=""
string dischargemenustr=""
variable i=0
do
	if (cmpstr(mode[i],"CHRG")==0)
		if (strsearch(chargemenustr,num2str(step[i]),0)<0)
			chargemenustr += num2str(step[i])+";"
		endif
	endif
	if (cmpstr(mode[i],"DCHG")==0)
		if (strsearch(dischargemenustr,num2str(step[i]),0)<0)
			dischargemenustr += num2str(step[i])+";"
		endif
	endif
	i+=1
while (i<numpnts(step))
prompt dis, "Which program step refers to discharge step during cycling?",popup,dischargemenustr
prompt re, "Which program step refers to the recharge step during cycling?",popup,chargemenustr
doprompt "Specify program steps for cycle charge and discharge",dis,re
nvar r=root:rechargestep
r = str2num(StringFromList((re-1), chargemenustr))
nvar dee=root:dischargestep
dee = str2num(StringFromList((dis-1), dischargemenustr))
end

function RickshawstatsTypes()
dowindow eRickshawRechargeTypeChart
if (v_flag==0)
	display /N=eRickshawRechargeTypeChart
endif

variable maxcyclesglobal=-1
variable maxcyclesfolder=0
variable typeindex=0
do
	string typename = GetIndexedObjName(":", 4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	variable numcycles=0
	variable batteryindex=0
	do
		string batteryname = GetIndexedObjName(":",4,batteryindex)
		if (strlen(batteryname)==0)
			break
		endif
		string folderwavename = ":"+batteryname+":rechargetime"
		wave wa = $folderwavename
		
		if ((numpnts(wa)+1)>numcycles)
			numcycles=numpnts(wa)+1
		endif
		batteryindex+=1
	while(1)
	variable imax = batteryindex-1
	numcycles -=1
	if (numcycles>maxcyclesglobal)
		maxcyclesglobal=numcycles
		maxcyclesfolder=typeindex
	endif

	make /N=(numcycles) /o rechargetimeavg,rechargetimeSEM
	make /N=(numcycles) /o /T cyclenumber
	rechargetimeavg=NaN
	rechargetimeSEM = NAN
	
	variable cycindex=1
	do
		make /N=(imax+1) /o PCwave // wave including all data of type for given cycle
		variable i=0
		do
		batteryname = GetIndexedObjName(":",4,i)
		folderwavename = ":"+batteryname+":rechargetime"
		wave wa = $folderwavename
		
			if (cycindex <= numpnts(wa))
				PCwave[i] = wa[cycindex-1]
			else
				PCwave[i] = NaN
			endif
			i+=1
		while (i<=imax)
		wavestats /Q PCwave	
		killwaves PCwave
		rechargetimeAVG[cycindex-1] = v_avg
		rechargetimeSEM[cycindex-1] = v_sem
		cyclenumber[cycindex-1] = num2str(cycindex)
		cycindex+=1
	while (cycindex<=numcycles)
	setdatafolder root:
	string rtname="RT"+typename
	typeindex+=1
while(1)
setdatafolder root:

typename = GetIndexedObjName(":",4,maxcyclesfolder)
setdatafolder $typename
wave cyc = cyclenumber
setdatafolder root:

typeindex=0
do
	typename = GetIndexedObjName(":", 4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
		nvar red,green,blue
	wave rechargetimeavg,rechargetimeSEM
	rtname = "RT"+getdatafolder(0)
	string rtname2 = "RTerr"+getdatafolder(0)
	appendtograph /W=eRickshawRechargeTypeChart rechargetimeavg /TN=$rtname vs cyc
	ModifyGraph hbFill($rtname)=2,toMode($rtname)=-1
	appendtograph /W=eRickshawRechargeTypeChart rechargetimeavg /TN=$rtname2 vs cyc
	ErrorBars /W=eRickshawRechargeTypeChart $rtname2 Y,wave=(rechargetimeSEM,rechargetimeSEM)
	ModifyGraph  /W=eRickshawRechargeTypeChart  mode($rtname2)=0,lsize($rtname2)=0
	modifygraph /W=eRickshawRechargeTypeChart rgb($rtname)=(red,green,blue)
	modifygraph /W=eRickshawRechargeTypeChart rgb($rtname2)=(0,0,0)
	killwaves /a/z
setdatafolder root:
	typeindex+=1
while(1)

Label /W=eRickshawRechargeTypeChart left "Recharge time (hr)"
Label /W=eRickshawRechargeTypeChart bottom "Cycle number"
end