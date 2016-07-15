#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function ExecuteAllTypes(commandstring)
string commandstring
if (strlen(commandstring)==0)
	prompt commandstring, "What command do you want to execute for each type?"
	doprompt "Command sought",commandstring
endif
setdatafolder root:
variable typeindex=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		return typeindex
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			execute commandstring // here's where we execute whatever we want to be done for each type
	endif
	setdatafolder root:
	typeindex+=1
while(1)
end

function ExecuteAllBatteries(commandstring,[whichload])
string commandstring
variable whichload
if (strlen(commandstring)==0)
	prompt commandstring, "What command do you want to execute for each type?"
	doprompt "Command sought",commandstring
endif
setdatafolder root:
variable typeindex=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			variable batteryindex=0
			do
				string batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
						execute commandstring // here's where we execute whatever we want to be done for each type
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
end



function AverageandSEMbytypeVariable([varname,chartname,oktoadd])
string varname, chartname
variable oktoadd
string legendtext=""
variable leftaxes=0

setdatafolder root:
variable typeindex=0
if (paramisdefault(varname) )
variable baseline=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			variable batteryindex=0
			do
				string batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					if (baseline==0)
						string menustr = getlocalvariables() 
						prompt varname, "Which variable do you want average and SEM for?", popup, menustr
						doprompt "Select variable for average/SEM calculation", varname
						if (v_flag==1)
							killwindow averageSEMbarchart
							Print "User clicked cancel"
							Abort
						endif

						baseline=1
						break
					endif
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
						
	setdatafolder root:
	if (baseline==1)
		break
	endif
	typeindex+=1
while(1)
endif
if (paramisdefault(chartname))
	chartname = "Avg"+cleanupname(varname,0)+"vstype"
endif
dowindow $chartname

if (paramisdefault(oktoadd))
	oktoadd = 0
endif
if (v_flag==0)
	display /N=$chartname
elseif ((v_flag==1) && (oktoadd==0))
	do
		string cndpstring=chartname+" already exists as a chart name"
		string newchartname
		prompt newchartname,"Enter new name for chart or type \"add\" to add waves to existing."
		doprompt cndpstring, newchartname
		if (cmpstr(newchartname,"add")==0)
			break
		endif
		chartname = cleanupname(newchartname,0)
		if (checkname(chartname,6)!=0)
			chartname=uniquename(chartname,6,1)
		endif
		dowindow $newchartname
	while (v_flag!=0)
	if (cmpstr(newChartname,"add")!=0)
		display /N=$chartname
	endif
endif


setdatafolder root:
string avgn,semn,sdvn
avgn = varname + "avg"
semn = varname + "sem"
sdvn = varname + "sdev"
make /N=0 /O $avgn,$semn, $sdvn
wave avgw = $avgn
wave semw = $semn
wave sdevw= $sdvn
make /N=0 /O /T types
appendtograph /W=$chartname /L=$varname avgw /TN=$avgn vs types
appendtograph /W=$chartname /L=$varname avgw /TN=$semn vs types

typeindex=0
do
	typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	variable /G batterycount=0
	nvar /Z skip
	nvar /Z red,green,blue
	make /N=0 /o fullsetofvariables
	
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			batteryindex=0
			do
				batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					nvar /Z va=$varname
					if (!nvar_exists(va))
						print "Error! Variable doesn't exist for",typename," ",batteryname
					else
						variable numbatteries=numpnts(fullsetofvariables)
						redimension /N=(numbatteries+1) fullsetofvariables
						fullsetofvariables[numbatteries] = va
					endif
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	wavestats /Q fullsetofvariables
	variable typecount=numpnts(types)
	redimension /N=(typecount+1) types, avgw, semw, sdevw
	types[typecount] = typename
	avgw[typecount] = v_avg
	semw[typecount] = v_sem
	sdevw[typecount] = v_sdev
	
	variable /g $avgn = v_avg
	variable /g $semn = v_sem
	variable /g $sdvn = v_sdev
	modifygraph /W=$chartname rgb($avgn[typecount])=(red,green,blue)
	killwaves fullsetofvariables
	killwsv()
	setdatafolder root:
	typeindex+=1
while(1)
modifygraph /W=$chartname axisontop=1, axoffset=0, font="Arial",freepos=0,standoff=0
ModifyGraph /W=$chartname lblPosMode=1,lblMargin=5
SetAxis /A/N=1/E=1 /W=$chartname $varname
ModifyGraph hbFill($avgn)=2
ModifyGraph toMode($avgn)=-1,mode($semn)=0,lsize($semn)=0,rgb($semn)=(0,0,0)
ErrorBars $semn Y,wave=($semn,$semn)
cleanaxes(chartname) 
end

function /S getlocalvariables()

string menustr=variablelist("*", ";", 4 )
menustr=replacestring("red;",menustr,"")
menustr=replacestring("green;", menustr,"")
menustr=replacestring("blue;",menustr,"")
menustr=replacestring("timescaled;",menustr,"")
menustr=replacestring("names_standardized;",menustr,"")
menustr=replacestring("loadorder;",menustr,"")
return menustr
end

function killwsv() //kills variables generated by wavestats to keep folders clean
killvariables /Z V_npnts,V_numNaNs,V_numINFs,V_avg,V_sdev,V_sem,V_rms,V_minloc,V_min,V_maxloc,V_max,V_adev,V_skew,V_kurt
killvariables /Z V_minChunkLoc,V_maxChunkLoc,V_minLayerLoc,V_maxLayerLoc,V_maxRowLoc,V_minRowLoc,V_maxColLoc
killvariables /Z V_minColLoc,V_startRow,V_endRow,V_startCol,V_endCol,V_Sum,V_startLayer,V_startChunk,V_endLayer,V_endChunk
end

function killflv() //kills variables generated by findlevel to keep folders clean
killvariables /Z v_flag,v_levelX,V_rising
end

function AverageSEMbyTypeCategory([ywaven,xwaven,chartname,oktoadd])
string ywaven, xwaven, chartname
variable oktoadd
string legendtext=""
if (paramisdefault(chartname))
	chartname = "averageSEMbarchart"
endif
variable leftaxes=0
dowindow $chartname
if (v_flag==0)
	display /N=$chartname
endif

setdatafolder root:
string catmenustr=wavelist("*",";","TEXT:1")
variable typeindex=0
if (paramisdefault(xwaven) )
variable baseline=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			variable batteryindex=0
			do
				string batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					if (baseline==0)
						string menustr = WaveList("*", ";", "" )
						prompt ywaven, "Which wave do you want average and SEM for?", popup, menustr
						prompt xwaven, "Which wave is the independent variable we want common values for?", popup, catmenustr
						doprompt "Select waves for average/SEM calculation", ywaven,xwaven
						if (v_flag==1)
							killwindow averageSEMbarchart
							Print "User clicked cancel"
							Abort
						endif
						baseline=1
						break
					endif
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	if (baseline==1)
		break
	endif
	typeindex+=1
while(1)
endif

if (paramisdefault(chartname))
	chartname = "Avg"+possiblyquotename(ywaven)+"vs"+possiblyquotename(xwaven)
endif
dowindow $chartname
//if (v_flag==0)
//	display /N=$chartname
//else
if (paramisdefault(oktoadd))
	oktoadd = 0
endif
if (v_flag==0)
	display /N=$chartname
elseif ((v_flag==1) && (oktoadd==0))
	do
		string cndpstring=chartname+" already exists as a chart name"
		string newchartname
		prompt newchartname,"Enter new name for chart or type \"add\" to add waves to existing."
		doprompt cndpstring, newchartname
		if (cmpstr(newchartname,"add")==0)
			break
		endif
		chartname = newchartname
		dowindow $newchartname
	while (v_flag!=0)
	if (cmpstr(newChartname,"add")!=0)
		display /N=$chartname
	endif
endif

setdatafolder root:
wave /T xwave = $xwaven
typeindex=0
do
	typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	variable /G batterycount=0
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			batteryindex=0
			do
				batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					batterycount+=1
					string yavgn,ysemn,xtypen
					wave ywave = $ywaven
					yavgn 	= "root:"+typename+":"+ywaven+"avg"
					ysemn 	= "root:"+typename+":"+ywaven+"sem"
					wave /Z yavg=$yavgn, ysem=$ysemn
					if (!waveexists(yavg))
						duplicate ywave $yavgn
						wave yavg = $yavgn
						yavg = NaN
					endif
					if (!waveexists(ysem))
						duplicate ywave  $ysemn
						wave ysem = $ysemn
						ysem = NaN
					endif
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	waveclear yavg,ysem
	typeindex+=1
while(1)

setdatafolder root:
typeindex=0
do
	typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	yavgn = ywaven+"avg"
	ysemn = ywaven+"sem"
	wave yavg = $yavgn
	wave ysem = $ysemn
	
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
		nvar batterycount
		variable xindex=0
		variable maxindex=0
		do
			variable batterycounter=0
			batteryindex=0
			make /N=(batterycount) yvalues
			yvalues = NaN
			do

				batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					wave ywave = $ywaven
					if (xindex<numpnts(ywave))
						yvalues[batterycounter] = ywave[xindex]
						batterycounter+=1
						maxindex=max(maxindex,xindex)
					endif
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
		wavestats /q yvalues
		if (xindex<numpnts(yavg))
			yavg[xindex] = v_avg
			ysem[xindex] = v_sem
		endif
		killwaves yvalues
		xindex+=1
		while(xindex<numpnts(xwave))
	endif
	setdatafolder root:
	waveclear yavg,ysem
	typeindex+=1
while(1)

setdatafolder root:
typeindex=0
do
	typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar red,green,blue
	yavgn = ywaven+"avg"
	ysemn = ywaven+"sem"
	wave yavg = $yavgn
	wave ysem = $ysemn
	yavgN = typename + yavgn
	string yerrN = typename +yavgn + "errb"
	appendtograph /W=$chartname /L=$ywaven yavg /TN=$yavgN vs xwave
	appendtograph /W=$chartname /L=$ywaven yavg /TN=$yerrn vs xwave
	modifygraph /W=$chartname rgb($yavgN)=(red,green,blue)
	if (strlen(legendtext)>0)
		legendtext += "\r"
	endif
	legendtext+="\s("+yavgN+")"+ typename
	
	modifygraph /W=$chartname axisontop=1, axoffset=0, font="Arial",freepos=0,standoff=0
	ModifyGraph /W=$chartname lblPosMode=1,lblMargin=5
	ModifyGraph /W=$chartname fSize=16
	//SetAxis /A/N=1/E=1 /W=$chartname $varname
	ModifyGraph hbFill($yavgn)=2
	ModifyGraph toMode($yavgn)=-1,mode($yerrn)=0,lsize($yerrn)=0,rgb($yerrn)=(0,0,0)
	ErrorBars /W=$chartname $yerrn Y,wave=($ysemn, $ysemn)
	killvariables batterycount
	setdatafolder root:
	waveclear yavg,ysem
	typeindex+=1
while(1)
if (v_flag==0)
	Textbox /W=$chartname /N=legendary legendtext
endif
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
	if ((strsearch(axn, "bottom", 0)<0) && (strsearch(axn,"top",0)<0) )
		axcount+=1
	endif
	axi+=1
while(1)
print axcount
if (axcount>1)
	axi=0
	do
		axn=StringFromList(axi, axl)
		if (strlen(axn)==0)
			break
		endif
		if ((strsearch(axn, "bottom", 0)<0) && (strsearch(axn,"top",0)<0) )
			variable seg=1/axcount-.02
			variable gap=0.02
			variable lowfrac = axi/axcount*(seg+gap)
			variable hifrac = axi/axcount*(seg+gap)+seg
			if (hifrac>0.95)
				hifrac=1
			endif
			modifygraph /W=$chartname axisenab($axn)={lowfrac,hifrac}
		endif
		axi+=1
	while(1)
endif
end

function/S gotofirstpopulatedfolder([whichload])
variable whichload
setdatafolder root:
string folder=""
variable foundfolderwithwaves=0
variable typeindex=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
		variable batteryindex=0
		do
			string batteryname=GetIndexedObjName(":",4,batteryindex)
			if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip))  || ( (nvar_exists(skip)) && (skip!=1) ) )
					folder=getdatafolder(1)
					foundfolderwithwaves=1
					break
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
		endif
		if (foundfolderwithwaves==1)
			break //stops looking through type/ top-level folders once we've found waves in the battery subfolder
		endif
		setdatafolder root:
		typeindex+=1
	while(1)
	setdatafolder $folder
return folder
end

function/S gotofirstpopulatedvariant()
setdatafolder root:
string folder=""
variable foundvariantfolder=0
variable typeindex=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
		folder=getdatafolder(1)
		break
	endif
	setdatafolder root:
	typeindex+=1
	while(1)
return folder
end

function Intersect([ywaven,ywavev,xwaven,stepv,cyclev,multicycle,graphtype,charttitle])
string ywaven, xwaven, ywavev, charttitle, multicycle,graphtype
variable stepv, cyclev
setdatafolder root:
//Jeremy's type selection code
variable typeindex=0
variable baseline=0
variable commandline=1
if (paramisdefault(charttitle))
	if (paramisdefault(ywaven))
	else
		charttitle = xwaven+"_c"+num2str(cyclev)+"s"+num2str(stepv)
	endif
endif
if (paramisdefault(graphtype))
	graphtype="Bar (Avg/SEM)"
endif

if ((paramisdefault(ywaven)) || (paramisdefault(xwaven)) || (paramisdefault(ywavev)) || (paramisdefault(multicycle)))
commandline=0 //Will prompt for information now
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			variable batteryindex=0
			do
				string batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					if (baseline==0)
						multicycle = "No"
						string menustr = WaveList("*", ";", "" )
						prompt ywaven, "What is the common y-wave?", popup, menustr
						prompt ywavev, "Intersect value for y? (Or type min/max)"
						prompt xwaven, "What is the x-wave (unknown)?", popup, menustr
						prompt stepv, "Step number to isolate? (0 for no)"
						prompt cyclev, "Cycle number to isolate? (0 for no)"
						prompt multicycle, "Calculate across all cycles?", popup, "No;Yes"
						prompt graphtype, "What type of graph?", popup, "Bar (Avg/SEM);Line (Avg/SEM);Line (All Batteries)"
						doprompt/help="Intersect" "Intersection between two variables, for all batteries",ywaven, ywavev, xwaven, stepv, cyclev, multicycle, graphtype
						if (v_flag==1)
							Abort
						endif
						charttitle = xwaven+"_c"+num2str(cyclev)+"s"+num2str(stepv)
						prompt charttitle, "Optional: Custom name for the new chart/waves? (No spaces/symbols)"
						doprompt/help="Intersect" "Custom Intersect Name", charttitle
						charttitle=makequotename(charttitle)
						baseline=1
						break
					endif
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	if (baseline==1)
		break
	endif
	typeindex+=1
while(1)
endif

string ywavename=ywaven
string stepfind,cmd,intersectname
string stepappend=""
string cycleappend=""
ExecuteAllBatteries("duplicate /o "+ywaven+", intersecttemp")
ywaven="intersecttemp"
executeallbatteries("killwaves /z "+charttitle+"; killvariables /z "+charttitle)

string stepname = "StepID"
string cyclename="Cycle"

if(stepv==0) //If necessary, isolating the correct cycle
else
	//svar stepname
	string cs="intersecttemp *= ((" + stepname + "==" + num2str(stepv) + ")/(" + stepname + "==" + num2str(stepv) + "))"
	print cs
	ExecuteAllBatteries(cs)
	stepappend = " during step " + num2str(stepv)
endif

if(cyclev==0) //If necessary, isolating the correct cycle
else
	//svar cyclename
	cs = "intersecttemp *= ((" + cyclename + "==" + num2str(cyclev) + ")/(" + cyclename + "==" + num2str(cyclev) + "))"
	print cs
	ExecuteAllBatteries(cs)
	cycleappend = " (Cycle " + num2str(cyclev)+")"
endif

strswitch(multicycle) //Rename y wave before defining cmd, if necessary
	case "No":
	Break
	case "Yes":
		string ywavereal = ywaven
		ywaven="multitemp"
	Break
endswitch

strswitch(ywavev) //Deciding whether to use wavestats or findlevel
	case "":
		Abort "Error! No intersect value was entered"
	case "max":
		cmd = "wavestats/q/m=1 "+ywaven+"; variable /G "+charttitle+" = "+xwaven+"[v_maxloc]"
		intersectname = xwaven + " at which " + ywavename + " is at its maximum value" + stepappend+cycleappend
	Break
	case "min":
		cmd = "wavestats/q/m=1 "+ywaven+"; variable /G "+charttitle+" = "+xwaven+"[v_minloc]"
		intersectname = xwaven + " at which " + ywavename + " is at its minimum value" + stepappend+cycleappend
	Break
	default:
		string ywaveval=replacestring("i",ywavev,"")
		ywaveval=replacestring("d",ywaveval,"")
		variable edge=0 //no preference for increasing or decreasing values
		if ((strsearch(ywavev,"i",0)!=-1)) //checking if the i or d increase/decrease flags were trigerred, for nonmonotonic waves
			edge=1
		elseif ((strsearch(ywavev,"d",0)!=-1))
			edge=2
		endif
		cmd = "findlevel /edge="+num2str(edge)+" /q "+ywaven + ", "+ywaveval + ";variable /G "+charttitle+"="+xwaven+"[v_levelx];vflagswitch("+"\""+charttitle+"\""+")"
		intersectname = xwaven + " at which " + ywavename + " is at a value of " + ywavev + stepappend+cycleappend
	Break
endswitch

strswitch(multicycle) //Deciding between single and multi cycle data
	default:
		//Calculating the intersect wave and making the chart
		print intersectname+" (New wave is named "+charttitle+")"
		ExecuteAllBatteries(cmd)
		AverageandSEMbyTypeVariable(varname=charttitle, chartname=charttitle)
		DoWindow/C/T $charttitle,intersectname
		Label $charttitle charttitle
		ModifyGraph axOffset(bottom)=-1
	Break
	case "Yes":
		//svar cyclename
		cyclename="Cycle"

		maxcyclesglobal()
		setdatafolder root:
		wave cyclenumbertext
		variable maxcycle=numpnts(cyclenumbertext)
		variable ci=1
		typeindex=0
		executeallbatteries("wavestats/q/m=1 "+cyclename+";variable /g LastCycle=v_max;Make/N=(lastcycle)/D/O "+charttitle+"_m")
		do //Calculating the intersect value for every cycle, now with far more efficient code
			typename= GetIndexedObjName(":",4,typeindex)
			if (strlen(typename)==0)
				break
			endif
			setdatafolder $typename
			nvar /Z skip
			if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					batteryindex=0
					do
						batteryname=GetIndexedObjName(":",4,batteryindex)
						if (strlen(batteryname)==0)
							break
						endif
						setdatafolder $batteryname
						nvar /Z skip
						if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
							nvar lastcycle
							Make/N=(lastcycle)/D/O index;index=x+1
							do 
								stepfind= "duplicate /O " + ywavereal + ", multitemp; multitemp *= ((" + cyclename + "==" + num2str(ci) + ")/(" + cyclename + "==" + num2str(ci) + "))"
								execute stepfind
								Execute cmd
								Execute charttitle+"_m["+num2str(ci)+"-1] = "+charttitle
								ci+=1
							while (lastcycle>=ci)
							ci=1
						endif
						batteryindex+=1
						setdatafolder root:
						setdatafolder $typename
						while(1)
			endif
			setdatafolder root:
			typeindex+=1
		while(1)
		
		executeallbatteries("killvariables "+charttitle+";rename "+charttitle+"_m,"+charttitle)
		print intersectname + " (New wave is named " + charttitle + ")"
		strswitch(graphtype)
			case "Line (Avg/SEM)":
			avgsemvswave(ywaven=charttitle, xwaven="index", chartname=charttitle,SEMplot=2)
			break
			case "Line (All Batteries)":
			GraphItAll(ywaven=charttitle, xwaven="index", chartname=charttitle)
			break
			default:
			AverageSEMbyTypeCategory(ywaven=charttitle, xwaven="cyclenumberText", chartname=charttitle,oktoadd=1)
			ModifyGraph axOffset(bottom)=-1
			break
		endswitch
		DoWindow/C/T $charttitle,intersectname
		Label $charttitle charttitle
		Label bottom "Cycle"
	Break
endswitch
modifygraph minor=0
ExecuteAllBatteries("killwaves /z intersecttemp, multitemp")
if (commandline==0) //prints the command that corresponds to the chart just created, for easy future recreation
	print "intersect(ywaven=\""+ywavename+"\",ywavev=\""+ywavev+"\",xwaven=\""+xwaven+"\",stepv="+num2str(stepv)+",cyclev="+num2str(cyclev)+",multicycle=\""+multicycle+"\",graphtype=\""+graphtype+"\",charttitle=\""+charttitle+"\")"
endif
end


function Isolate([ywaven,ywavenew,xwaven,xwavenew,criterian,operation,criteriav,stepv,cyclev,chartname,avgsem])
string ywaven, ywavenew, xwaven, xwavenew, criterian, chartname, operation, avgsem
variable stepv, cyclev, criteriav
string stepappend=""
string cycleappend=""
string opappend="" 
string morecriteria,criterian1,criterian2,operation1,operation2 //Does anybody really need this to be command line accessible?
variable criteriav1,criteriav2
variable commandline=1
setdatafolder root:
//Jeremy's type selection code
variable typeindex=0,baseline=0
if ((paramisdefault(ywaven)) || (paramisdefault(xwaven)) || (paramisdefault(stepv)) || (paramisdefault(operation)))
commandline=0 //we're going to have to use prompts
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			variable batteryindex=0
			do
				string batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					if (baseline==0)
						operation="Skip"
						string menustr = WaveList("*", ";", "" )
						prompt ywaven, "Dependent y-wave?", popup, menustr
						prompt xwaven, "Independent x-wave?", popup, menustr
						prompt stepv, "Step number to isolate? (0 for no)"
						prompt cyclev, "Cycle number to isolate? (0 for no)"
						prompt avgsem, "Average and SEM by type?", popup, "Yes;No"
						prompt morecriteria, "Are there additional wave parameters?", popup, "No;Yes"
						doprompt /help="Isolate" "Isolation of waves to create line plot",ywaven, xwaven, stepv, cyclev, avgsem, morecriteria
						if (v_flag==1)
							Abort
						endif
						strswitch(morecriteria)
						case "Yes":
							prompt criterian, "1. Optional additional wave parameter", popup, menustr
							prompt operation, "1. Comparison operator to isolate by?", popup, "Skip;==;!=;>;<;>=;<="
							prompt criteriav, "1. What is the value to isolate that wave by?"
							prompt criterian1, "2. Optional additional wave parameter", popup, menustr
							prompt operation1, "2. Comparison operator to isolate by?", popup, "Skip;==;!=;>;<;>=;<="
							prompt criteriav1, "2. What is the value to isolate that wave by?"
							prompt criterian2, "3. Optional additional wave parameter", popup, menustr
							prompt operation2, "3. Comparison operator to isolate by?", popup, "Skip;==;!=;>;<;>=;<="
							prompt criteriav2, "3. What is the value to isolate that wave by?"
							doprompt /help="Isolate" "Create up to 3 additional wave parameters",criterian,operation,criteriav,criterian1,operation1,criteriav1,criterian2,operation2,criteriav2
							if (v_flag==1)
								Abort
							endif
						break
						default:
							operation="Skip"
							operation1="Skip"
							operation2="Skip"
						break
						endswitch
						baseline=1
						break
					endif
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	if (baseline==1)
		break
	endif
	typeindex+=1
while(1)
endif

//Making new waves, ready for transformation
if (commandline==0) //Prompt for custom wave names
	ywavenew=ywaven+"_c"+num2str(cyclev)+"s"+num2str(stepv)
	xwavenew=xwaven+"_c"+num2str(cyclev)+"s"+num2str(stepv)
	chartname="Isolation"+ywaven+"_c"+num2str(cyclev)+"s"+num2str(stepv)
	prompt ywavenew, "New y wave name ("+ywaven+")"
	prompt xwavenew, "New x wave name ("+xwaven+")"
	prompt chartname, "Chart name (click help for details)"
	doprompt /help="Pro tip: If you want multiple graphs in the same window, run this script again with a different y wave. Just be sure to keep the x wave and chart name the same!" "Optional: Custom wave names", ywavenew,xwavenew,chartname
	ywavenew=makequotename(ywavenew)
	xwavenew=makequotename(xwavenew)
	chartname=makequotename(chartname)
else
	operation1="Skip"
	operation2="Skip"
endif
ExecuteAllBatteries("duplicate /o "+ywaven+", "+ywavenew+"; duplicate /o "+xwaven+", "+xwavenew)
string stepname="StepID"
if (stepv==0) //Isolating the correct step
else
	ExecuteAllBatteries(ywavenew+"*= ((" + stepname + "==" + num2str(stepv) + ")/(" + stepname + "==" + num2str(stepv) + "))")
	ExecuteAllBatteries(xwavenew+"*= ((" + stepname + "==" + num2str(stepv) + ")/(" + stepname + "==" + num2str(stepv) + "))")
	stepappend = " during step " + num2str(stepv)
endif

if (cyclev==0) //Isolating the correct cycle
else
	string cyclename="Cycle"
	ExecuteAllBatteries(ywavenew+"*= ((" + cyclename + "==" + num2str(cyclev) + ")/(" + cyclename + "==" + num2str(cyclev) + "))")
	ExecuteAllBatteries(xwavenew+"*= ((" + cyclename + "==" + num2str(cyclev) + ")/(" + cyclename + "==" + num2str(cyclev) + "))")
	cycleappend = " (Cycle " + num2str(cyclev)+")"
endif

strswitch(operation) //Isolating optional parameter
	case "Skip":
	break
	default:
	ExecuteAllBatteries(ywavenew+"*= ((" + criterian + operation + num2str(criteriav) + ")/(" + criterian + operation + num2str(criteriav) + "))")
	ExecuteAllBatteries(xwavenew+"*= ((" + criterian + operation + num2str(criteriav) + ")/(" + criterian + operation + num2str(criteriav) + "))")
	opappend += " while isolating for "+criterian
	break
endswitch
strswitch(operation1) //Isolating optional parameter 2
	case "Skip":
	break
	default:
	ExecuteAllBatteries(ywavenew+"*= ((" + criterian1 + operation1 + num2str(criteriav1) + ")/(" + criterian1 + operation1 + num2str(criteriav1) + "))")
	ExecuteAllBatteries(xwavenew+"*= ((" + criterian1 + operation1 + num2str(criteriav1) + ")/(" + criterian1 + operation1 + num2str(criteriav1) + "))")
	opappend += " and for "+criterian1
	break
endswitch
strswitch(operation2) //Isolating optional parameter 3
	case "Skip":
	break
	default:
	ExecuteAllBatteries(ywavenew+"*= ((" + criterian2 + operation2 + num2str(criteriav2) + ")/(" + criterian2 + operation2 + num2str(criteriav2) + "))")
	ExecuteAllBatteries(xwavenew+"*= ((" + criterian2 + operation2 + num2str(criteriav2) + ")/(" + criterian2 + operation2 + num2str(criteriav2) + "))")
	opappend += " and for "+criterian2
	break
endswitch

//Making the line chart
string charttitle=ywaven+" vs "+xwaven+opappend+stepappend+cycleappend
ExecuteAllBatteries("wavetransform zapnans "+ywavenew+"; wavetransform zapnans "+xwavenew)
if ((strsearch(xwaven,"time",0,2)!=-1))//This wave is probably time, so might as well do a baseline correction
	ExecuteAllBatteries("wavestats/q/m=1 "+xwavenew+";"+xwavenew+"-=v_min")
endif
strswitch(avgsem)
case "No":
	GraphItAll(ywaven=ywavenew,xwaven=xwavenew,chartname=chartname)
break
default:
	avgsemvswave(ywaven=ywavenew,xwaven=xwavenew,chartname=chartname,SEMplot=2)
	ExecuteAllBatteries("killwaves "+ywavenew+", "+xwavenew)
break
endswitch
Label $ywavenew ywaven
Label bottom xwaven
DoWindow/T $chartname,charttitle
modifygraph minor=0
print charttitle + " (New waves are named " + ywavenew + " and "+xwavenew+")"
if (commandline==0) //prints the command that corresponds to the chart just created, for easy future recreation
	if ((cmpstr(operation1,"Skip")==0) && (cmpstr(operation2,"Skip")==0))
		if (cmpstr(operation,"Skip")==0)
			print "isolate(ywaven=\""+ywaven+"\",ywavenew=\""+ywavenew+"\",xwaven=\""+xwaven+"\",xwavenew=\""+xwavenew+"\",operation=\""+operation+"\",stepv="+num2str(stepv)+",cyclev="+num2str(cyclev)+",avgsem=\""+avgsem+"\",chartname=\""+chartname+"\")"
		else
			print "isolate(ywaven=\""+ywaven+"\",ywavenew=\""+ywavenew+"\",xwaven=\""+xwaven+"\",xwavenew=\""+xwavenew+"\",criterian=\""+criterian+"\",operation=\""+operation+"\",criteriav="+num2str(criteriav)+",stepv="+num2str(stepv)+",cyclev="+num2str(cyclev)+",avgsem=\""+avgsem+"\",chartname=\""+chartname+"\")"
		endif
	else
		print "Too many operations to print a command line version of this chart. It's not impossible, I just never thought it would be important enough to write."
	endif
endif
end

function CalculateRechargeFactor([multicycle])
string multicycle
setdatafolder root:
svar capname
if (paramisdefault(multicycle))
	multicycle="No"
	maxcyclesglobal()
	wave/t cyclenumbertext
	if (numpnts(cyclenumbertext)>1)
		multicycle="Yes"
		else
		killwaves/z cyclenumbertext
	endif		
endif

strswitch(multicycle)
	case "No":
		ExecuteAllBatteries("duplicate /o "+capname+", RechargeFactor; variable/g v_min=-wavemin("+capname+"); rechargefactor /= v_min")
	case "Yes":
		ExecuteAllBatteries("killwaves /z RechargeFactor")
		string cyclename="Cycle"
		variable typeindex=0,ci=1
		executeallbatteries("variable/g LastCycle=wavemax("+cyclename+")")
		do //Calculating the recharge factor for every cycle of every battery, now with more efficient code
			string typename= GetIndexedObjName(":",4,typeindex)
			if (strlen(typename)==0)
				break
			endif
			setdatafolder $typename
			nvar /Z skip
			if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					variable batteryindex=0
					do
						string batteryname=GetIndexedObjName(":",4,batteryindex)
						if (strlen(batteryname)==0)
							break
						endif
						setdatafolder $batteryname
						nvar /Z skip
						if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
							nvar lastcycle
							do
								RFWorker(capname,cyclename,ci)
								ci+=1
								//print ci
							while (lastcycle>=ci)
							ci=1
						endif
						batteryindex+=1
						setdatafolder root:
						setdatafolder $typename
							while(1)
			endif
			setdatafolder root:
			typeindex+=1
		while(1)
	ExecuteAllBatteries("wavestats/q/m=1 "+capname+"; redimension/n=(v_endrow) RechargeFactor;killwaves/z rftemp")		
endswitch
end

Function RFWorker(capname,cyclename,ci) //should greatly speed up calculation on large datasets
string capname,cyclename
variable ci
wave capn=$capname,cyclen=$cyclename
duplicate /o $capname, rftemp
multithread rftemp *= ((cyclen==ci)/(cyclen==ci))
wavetransform zapnans rftemp
variable rfmin=-wavemin(rftemp)
rftemp /= rfmin
concatenate /np {rftemp}, RechargeFactor
end

Function MacroMacro() //This procedure is somewhat antiquated at this point. Most of its functionality is in the Basic Battery Analysis program.
string macron
prompt macron, "What type of data are we analyzing?", popup, "Chaowei-Lantian eBike;HRPSoC"
doprompt "Batch Graph Creation", macron
if (v_flag==1)
	Abort
endif

strswitch(macron) //creating the selected string of graphs
	case "Chaowei-Lantian eBike":
		//calculaterechargefactor()
		intersect(ywaven="amp_hours",ywavev="max",xwaven="amp_hours",multicycle="yes",graphtype="Line (Avg/SEM)",charttitle="ChargeCapacity")
		Label ChargeCapacity "Ah In During Charge"
		intersect(ywaven="amp_hours",ywavev="min",xwaven="amp_hours",multicycle="yes",graphtype="Line (Avg/SEM)",charttitle="DischargeCapacity")
		executealltypes("dischargecapacityavg*=-1")
		Label DischargeCapacity "Discharge Capacity (Ah)"
		intersect(ywaven="voltage",ywavev="14.7",xwaven="steptimehr",stepv=3,multicycle="yes",graphtype="Line (Avg/SEM)",charttitle="PartA")
		Label PartA "Time to Reach 14.7V at 0.15C (hr)"
		intersect(ywaven="total_time",ywavev="max",xwaven="steptimehr",stepv=3,multicycle="yes",graphtype="Line (Avg/SEM)",charttitle="PartB")
		Label PartB "Time to Reach 0.35A at 0.15C (hr)"
		intersect(ywaven="rechargefactor",ywavev="max",xwaven="rechargefactor",multicycle="yes",graphtype="Line (Avg/SEM)",charttitle="RechargeFactorMax")
		Label RechargeFactorMax "%Ah In (Both Parts)";ModifyGraph prescaleExp(RechargeFactorMax)=2
		intersect(ywaven="voltage",ywavev="14.7",xwaven="amp_hours",stepv=3,multicycle="yes",graphtype="Line (Avg/SEM)",charttitle="PartAAh")
		Label PartAAh "Ah-In During Part A (0.15C to 14.7V)"
		intersect(ywaven="total_time",ywavev="max",xwaven="amp_hours",stepv=3,multicycle="yes",graphtype="Line (Avg/SEM)",charttitle="PartBAh")
		executealltypes("partbahavg-=partaahavg");executealltypes("partbavg-=partaavg")
		Label PartBAh "Ah-In During Part B (0.15C to 0.35A)"
	break
	case "HRPSoC":
		 intersect(ywaven="Total_Time",ywavev="min",xwaven="Voltage",stepv=3,cyclev=0,multicycle="Yes",graphtype="Line (All Batteries)",charttitle="BOCVoltage")
		 DoWindow/C EOCVoltage
		 intersect(ywaven="Total_Time",ywavev="max",xwaven="Voltage",stepv=3,cyclev=0,multicycle="Yes",graphtype="Line (All Batteries)",charttitle="EOCVoltage")
		 DoWindow/C/T ChargingVoltage,"ChargingVoltage"
		 Label BOCVoltage "BOC Voltage";DelayUpdate;Label EOCVoltage "EOC Voltage"
		 intersect(ywaven="Total_Time",ywavev="max",xwaven="Voltage",stepv=5,cyclev=0,multicycle="Yes",graphtype="Line (All Batteries)",charttitle="EODVoltage")
		 DoWindow/C BODVoltage
		 intersect(ywaven="Total_Time",ywavev="min",xwaven="Voltage",stepv=5,cyclev=0,multicycle="Yes",graphtype="Line (All Batteries)",charttitle="BODVoltage")
		 Label BODVoltage "BOD Voltage";DelayUpdate;Label EODVoltage "EOD Voltage"
		 DoWindow/C/T DischargingVoltage,"DischargingVoltage"
	break
endswitch
end


function vflagswitch(output) //sets a variable to 0 if v_flag=1
string output
nvar invar=v_flag
if ((invar)==1)
	execute "variable /g "+output+"=0"
endif
end

function MakeVariables(waven) //useful for putting in a variable for each battery, and then later graphing it
string waven
if (strlen(waven)==0) //if input is empty, will create list of all batteries
	make/t/o BatteryList
else
	string wavepath="root:"+waven
	wave wave0=$wavepath
endif
variable typeindex=0,ci=0
		do //Creating a variable for each battery, following the index
			string typename= GetIndexedObjName(":",4,typeindex)
			if (strlen(typename)==0)
				break
			endif
			setdatafolder $typename
			nvar /Z skip
			if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					variable batteryindex=0
					do
						string batteryname=GetIndexedObjName(":",4,batteryindex)
						if (strlen(batteryname)==0)
							break
						endif
						setdatafolder $batteryname
						nvar /Z skip
						if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
							if (strlen(waven)==0)
								execute "root:Batterylist["+num2str(ci)+"]={\""+getdatafolder(1)+"\"}"
							else
								execute "variable/g "+waven+"="+wavepath+"["+num2str(ci)+"]"
							endif
							ci+=1
						endif
						batteryindex+=1
						setdatafolder root:
						setdatafolder $typename
						while(1)
			endif
			setdatafolder root:
			typeindex+=1
		while(1)
if (strlen(waven)==0)
	redimension/n=(ci) root:BatteryList
endif
end

function GraphItAll([ywaven,xwaven,chartname]) //modified baselinerunchart to be generalized to all variables	
string ywaven, xwaven, chartname
if (paramisdefault(chartname))
	chartname = "GraphAll"
	if (!paramisdefault(ywaven))
		chartname += ywaven
		if (!paramisdefault(xwaven))
			chartname+="vs"+xwaven
		endif
	endif
endif
variable leftaxes=0
setdatafolder root:
string legendtext=""
variable typeindex=0
if (paramisdefault(xwaven))
variable baseline=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			variable batteryindex=0
			do
				string batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					if (baseline==0)
						string menustr = WaveList("*", ";", "" )
						prompt ywaven, "Which y-wave is the dependent variable?", popup, menustr
						prompt xwaven, "Which x-wave is the independent variable we want common values for?", popup, menustr
						prompt chartname, "Name for chart (reuse chart names to add more axes to the same chart)"
						doprompt/help="GraphItAll" "Select waves for GraphItAll calculation", ywaven,xwaven,chartname
						if (v_flag==1)
							Abort
						endif
						baseline=1
						break
					endif
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	if (baseline==1)
		break
	endif
	typeindex+=1
while(1)
endif

chartname=makequotename(chartname)
dowindow $chartname
if (v_flag==0)
	display /N=$chartname
endif
typeindex=0
do
	typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	nvar red,green,blue
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			batteryindex=0
			do
				batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					wave  xwave = $xwaven
					wave  ywave = $ywaven
					string bname = typename+batteryname
					string yN = ywaven+typename+batteryname
					yN = cleanupname(yN,0)
					if (checkname(yN, 15)!=0)
						yN = uniquename(yN,15,2)
					endif
					appendtograph /W=$chartname /L=$ywaven ywave /TN=$yN vs xwave
					modifygraph /W=$chartname rgb($yN) = (red,green,blue)
					modifygraph /W=$chartname lstyle($yN)= mod(batteryindex, 18)
					if (strlen(legendtext)>0)
						legendtext += "\r"
					endif
					legendtext+="\s("+yN+")"+ typename+" "+replacestring("Bat",batteryname,"")
					waveclear xwave,ywave
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)

if (v_flag==0)
	Textbox /C/W=$chartname /N=legendary legendtext
endif
ModifyGraph /W=$chartname lblPosMode=1,lblMargin=5
modifygraph /W=$chartname axisontop=1, axoffset=0, font="Arial",freepos=0,standoff=0

Label $ywaven ywaven
Label bottom xwaven

string axl=AxisList(chartname)
variable axi=0
variable axcount=0
do
	string axn=StringFromList(axi, axl)
	if (strlen(axn)==0)
		break
	endif
	string axinf=axisinfo(chartname,axn)
	if ((strsearch(axn, "bottom", 0)<0) && (strsearch(axn,"top",0)<0) )
		axcount+=1
	endif
	axi+=1
while(1)

if (axcount>1)
	axi=0
	variable axcounter=0
	do
		axn=StringFromList(axi, axl)
		if (strlen(axn)==0)
			break
		endif
		axinf=axisinfo(chartname,axn)
		if ((strsearch(axn, "bottom", 0)<0) && (strsearch(axn,"top",0)<0) )
			variable gap=0.03
			variable seg=(1-(axcount-1)*(gap))/axcount
			variable lowfrac = axcounter*(seg+gap)
			variable hifrac = (axcounter+1)*seg+(axcounter*gap)
			print axi, axcount, "2nd"
			if (hifrac>0.95)
				hifrac=1
			endif
			if (lowfrac<0.05)
				lowfrac=0
			endif
			modifygraph /W=$chartname axisenab($axn)={lowfrac,hifrac}
			axcounter+=1
		endif
		axi+=1
	while(1)
endif
end

function TempStats() //modified baselinerunchart to look at temperature as well and diagnose issues while running	
display /N=TempStat
setdatafolder root:
svar vwavename,curwavename,totaltimename,steptimename
string tempname="temperature_a1"
nvar timeunits
variable desiredtimeunits = 4
make /o /N=3 /T unitstrings={"sec","min","hr"}

do
	desiredtimeunits -= 1
	variable maxtime=-1
	variable typeindex=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	nvar red,green,blue
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			variable batteryindex=0
			do
				string batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					wave  rawtime = $totaltimename
					wave  steptime = $steptimename
					if (desiredtimeunits<3) //deletes waves we created the last time because of insufficient resolution
						string killtimename,killsteptimename
						killtimename="time"+unitstrings[desiredtimeunits]
						killsteptimename="steptime"+unitstrings[desiredtimeunits]
						wave kt=$killtimename
						wave kst=$killsteptimename
						killwaves kt,kst
					endif
					
					string newtimename,newsteptimename
					newtimename="time"+unitstrings[desiredtimeunits-1]
					newsteptimename="steptime"+unitstrings[desiredtimeunits-1]
					if (cmpstr(newtimename,totaltimename)!=0)
						duplicate /o rawtime $newtimename
						wave timew=$newtimename
						timew /=60^(desiredtimeunits-timeunits)
					else
						wave timew = $newtimename
					endif
					
					if (cmpstr(newsteptimename,steptimename)!=0)
						duplicate /o steptime $newsteptimename
						wave steptimew=$newsteptimename
						steptimew /=60^(desiredtimeunits-timeunits)
					endif
					
					wavestats/Q/m=1 timew
					maxtime=max(maxtime,v_max)
					
					waveclear rawtime,steptime,timew,steptimew
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
while (maxtime<1)

totaltimename = newtimename
steptimename = newsteptimename
timeunits = desiredtimeunits

string legendstring=""
typeindex=0
do
	typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	nvar red,green,blue
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			batteryindex=0
			do
				batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					wave  v = $vwavename
					wave  a = $curwavename
					wave t = $tempname
					wave  timew = $totaltimename
					wave  steptimew = $steptimename
					string vname = "V"+typename+batteryname
					string aname = "A"+typename+batteryname
					string tname = "T"+typename+batteryname
					appendtograph /W=tempstat /L=V v /TN=$vname vs timew
					appendtograph /W=tempstat /L=A a /TN=$aname vs timew
					appendtograph /W=tempstat /L=T t /TN=$tname vs timew
					modifygraph /W=tempstat rgb($vname) = (red,green,blue)
					modifygraph /W=tempstat rgb($aname) = (red,green,blue)
					modifygraph /W=tempstat rgb($tname) = (red,green,blue)
					modifygraph /W=tempstat lstyle($vname)= batteryindex, lstyle($aname)=batteryindex, lstyle($tname)=batteryindex
					if (strlen(legendstring)>0)
						legendstring += "\r"
					endif
					legendstring+="\s("+vname+")"+ typename+" "+replacestring("Bat",batteryname,"")
					waveclear v,a,t,timew,steptimew
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)

modifygraph /W=tempstat axisontop=1
modifygraph /W=tempstat axOffset=0
modifygraph /W=tempstat freePos=0
modifygraph /W=tempstat axisenab(V)={0,0.32}
modifygraph /W=tempstat axisenab(A)={0.34,0.66}
modifygraph /W=tempstat axisenab(T)={0.68,1}
label /W=tempstat V "Voltage(V)"
label /W=tempstat A "Current(A)"
label /W=tempstat T "Temperature(°C)"
setdatafolder root:
string /G timelabel = "Time("+unitstrings[desiredtimeunits-1]+")"
label /W=tempstat bottom timelabel
Textbox /W=tempstat /N=legendary legendstring
ModifyGraph /W=tempstat lblPosMode=1
modifygraph minor=0
killwaves unitstrings
end

function TempStatsSEM() //takes much longer, but gives sem
variable tim=startmstimer
setdatafolder root:
svar vwavename,curwavename,totaltimename
string tempname = "Temperature_A1"
avgsemvswave(ywaven=vwavename,xwaven=totaltimename,chartname="TempStat",semplot=2)
avgsemvswave(ywaven=curwavename, xwaven=totaltimename,chartname="TempStat",semplot=2)
avgsemvswave(ywaven=tempname,xwaven=totaltimename,chartname="TempStat",semplot=2)
Label /W=TempStat $vwavename "Voltage(V)"
Label /W=TempStat $curwavename "Current(A)"
Label /W=TempStat $tempname "Temperature (°C)"
modifygraph minor=0
svar timelabel
Label /W=TempStat bottom timelabel
variable timend=stopmstimer(tim)
print timend/100000, " microseconds"
end

function CreateBaselineRunChartSEM() //takes much longer, but gives sem
variable tim=startmstimer
setdatafolder root:
svar vwavename,curwavename,totaltimename,timelabel
avgsemvswave(ywaven=vwavename,xwaven=totaltimename,chartname="baselinerunchartSEM",semplot=2)
avgsemvswave(ywaven=curwavename, xwaven=totaltimename,chartname="baselinerunchartSEM",semplot=2)
Label /W=baselinerunchartSEM $vwavename "Voltage(V)"
Label /W=baselinerunchartSEM $curwavename "Current(A)"
ModifyGraph axisEnab($vwavename)={0,0.48},axisEnab($curwavename)={0.52,1}
modifygraph minor=0
Label /W=baselinerunchartSEM bottom timelabel
end


function ChangeColors([mode]) //switches between standard colors for PBL3 batteries
string mode
if (paramisdefault(mode))
	prompt mode, "Which variables should be grouped together?", popup, "MR;Surfactant"
	doprompt /help="Be sure to use standard folder names" "PBL3 Color Scheme" mode
		if (v_flag==1)
			Abort
		endif
endif
//setdatafolder root:
make/free/t folderw={"Con","BLCMCN","MRCMCN","MRCMCP","MRCMCNP","BLPSSN","MRPSSN","MRPSSP","MRPSSNP","BLPVAN","MRPVAN","MRPVAP","MRPVANP"}
//wave/t folderw
strswitch(mode)
	case "MR":
		make/free redw={65535,39835,0,65280,16385,39835,0,65280,16385,39835,0,65280,16385}
		make/free greenw={0,22873,52224,43520,28398,22873,52224,43520,28398,22873,52224,43520,28398}
		make/free bluew={0,46774,0,0,65535,46774,0,0,65535,46774,0,0,65535}
	break
	case "Surfactant":
		make/free redw={65535,0,0,0,0,65280,65280,65280,65280,16385,16385,16385,16385}
		make/free greenw={0,52224,52224,52224,52224,43520,43520,43520,43520,28398,28398,28398,28398}
		make/free bluew={0,0,0,0,0,0,0,0,0,65535,65535,65535,65535}
	break
	default:
		Abort "Invalid choice"
	break
endswitch
//wave redw,greenw,bluew

variable ci=0
do
	if (datafolderexists(folderw[ci])==1)
		setdatafolder root:$folderw[ci]:	
		variable /g red=redw[ci],green=greenw[ci],blue=bluew[ci]
	endif
	setdatafolder root:
	ci+=1
while (ci<13)
Print mode+" colors"
//killwaves redw,greenw,bluew,folderw
end

function ChangePatterns() //Adds appropriate stripes to bar graphs for PBL3
string axname=replacestring(";bottom;",axislist(""),"")
ModifyGraph rgb($axname+"avg"[0])=(65278,0,0)
ModifyGraph/Z rgb($axname+"avg"[1])=(3,52428,1)
ModifyGraph/Z rgb($axname+"avg"[2])=(3,52428,1)
ModifyGraph/Z rgb($axname+"avg"[3])=(3,52428,1)
ModifyGraph/Z rgb($axname+"avg"[4])=(3,52428,1)
ModifyGraph/Z rgb($axname+"avg"[5])=(65535,43690,0)
ModifyGraph/Z rgb($axname+"avg"[6])=(65535,43690,0)
ModifyGraph/Z rgb($axname+"avg"[7])=(65535,43690,0)
ModifyGraph/Z rgb($axname+"avg"[8])=(65535,43690,0)
ModifyGraph/Z rgb($axname+"avg"[9])=(1,16019,65535)
ModifyGraph/Z rgb($axname+"avg"[10])=(1,16019,65535)
ModifyGraph/Z rgb($axname+"avg"[11])=(1,16019,65535)
ModifyGraph/Z rgb($axname+"avg"[12])=(1,16019,65535)
ModifyGraph/Z hbFill($axname+"avg"[0])=52
ModifyGraph/Z hbFill($axname+"avg"[1])=52
ModifyGraph/Z hbFill($axname+"avg"[2])=7
ModifyGraph/Z hbFill($axname+"avg"[3])=27
ModifyGraph/Z hbFill($axname+"avg"[4])=48
ModifyGraph/Z hbFill($axname+"avg"[5])=52
ModifyGraph/Z hbFill($axname+"avg"[6])=7
ModifyGraph/Z hbFill($axname+"avg"[7])=27
ModifyGraph/Z hbFill($axname+"avg"[8])=48
ModifyGraph/Z hbFill($axname+"avg"[9])=52
ModifyGraph/Z hbFill($axname+"avg"[10])=7
ModifyGraph/Z hbFill($axname+"avg"[11])=27
ModifyGraph/Z hbFill($axname+"avg"[12])=48
end


Function/s MakeReadableNames(Str) //Makes legend text more human friendly, rather than using folder names
string Str
nvar/z NoNameChanges=root:NoNameChanges
if (NVAR_Exists(NoNameChanges))	//Manual override
	return Str
endif
Str=replacestring(" Bat",Str," ")
if ((strsearch(str,"ConCon",0,2)!=-1)||(strsearch(str,"ConMR",0,2)!=-1)||(strsearch(str,"MRCon",0,2)!=-1)||(strsearch(str,"MRMR",0,2)!=-1)) //Lantian
	Str=replacestring(" ConCon",Str," ")
	Str=replacestring(" ConMR",Str," ")
	Str=replacestring(" MRCon",Str," ")
	Str=replacestring(" MRMR",Str," ")
	return Str
endif
if ((strsearch(str,"%",0)!=-1))
	return Str //This dataset has already been made readable
endif
if ((strsearch(str,"MR ",0)!=-1)&(strsearch(str,"MR Tub",0,2)==-1))
	return Str //This dataset has already been made readable
endif
if ((strsearch(str,"\s(",0)==-1))
	Str=replacestring("Con",Str,"Control")
	Str=replacestring("MR03NP",Str,"0.10%MR+/0.03%MR-")
	Str=replacestring("MR05NP",Str,"0.10%MR+/0.05%MR-")
	Str=replacestring("MR07NP",Str,"0.10%MR+/0.07%MR-")
	Str=replacestring("MR03",Str,"0.03%MR-")
	Str=replacestring("MR05",Str,"0.05%MR-")
	Str=replacestring("MR07",Str,"0.07%MR-")
	Str=replacestring("MRPVA",Str,"MR PVA ")
	Str=replacestring("MRPSS",Str,"MR PSS ")
	Str=replacestring("MRCMC",Str,"MR CMC ")
	Str=replacestring("BLPVA",Str,"BL PVA ")
	Str=replacestring("BLPSS",Str,"BL PSS ")
	Str=replacestring("BLCMC",Str,"BL CMC ")
	Str=replacestring("%",Str,"% ")
	Str=replacestring("FlatCon",Str,"Control (Flat Plate)")
	Str=replacestring("FlatMR",Str,"MR (Flat Plate)")
	Str=replacestring("TubCon",Str,"Control (Tubular)")
	Str=replacestring("TubMR",Str,"MR (Tubular)")
	Str=replacestring("Controltrol",Str,"Control")
	Str=replacestring(")trol",Str,")")
	return Str //This is text wave data, not legend data
endif
if ((strsearch(str,"FlatCon",0,2)!=-1)||(strsearch(str,"FlatMR",0,2)!=-1)||(strsearch(str,"TubCon",0,2)!=-1)||(strsearch(str,"TubMR",0,2)!=-1)) //Eastman flat/tubular
	Str=replacestring(" FlatCon",Str," ")
	Str=replacestring(" FlatMR",Str," ")
	Str=replacestring(" TubCon",Str," ")
	Str=replacestring(" TubMR",Str," ")
	Str=replacestring(")FlatCon",Str,")Control (Flat Plate)")
	Str=replacestring(")FlatMR",Str,")MR (Flat Plate)")
	Str=replacestring(")TubCon",Str,")Control (Tubular)")
	Str=replacestring(")TubMR",Str,")MR (Tubular)")
	return Str
endif
Str=replacestring(" Con",Str," ")
Str=replacestring(" SLI",Str," ")
Str=replacestring(" EFB",Str," ")
Str=replacestring(")Con",Str,")Control")
Str=replacestring("Controltrol",Str,"Control")
Str=replacestring(")MR03NP",Str,")0.10%MR+/0.03%MR-")
Str=replacestring(")MR05NP",Str,")0.10%MR+/0.05%MR-")
Str=replacestring(")MR07NP",Str,")0.10%MR+/0.07%MR-")
Str=replacestring(")MR03",Str,")0.03%MR-")
Str=replacestring(")MR05",Str,")0.05%MR-")
Str=replacestring(")MR07",Str,")0.07%MR-")
Str=replacestring(" MR",Str," ")
Str=replacestring(" BL",Str," ")
Str=replacestring("%",Str,"% ")

Str=replacestring(" CMC",Str," ")
Str=replacestring(" PSS",Str," ")
Str=replacestring(" PVA",Str," ")
Str=replacestring(" N",Str," ")
Str=replacestring(" P",Str," ")
Str=replacestring(")MRPVA",Str,")MR PVA ")
Str=replacestring(")MRPSS",Str,")MR PSS ")
Str=replacestring(")MRCMC",Str,")MR CMC ")
Str=replacestring(")BLPVA",Str,")BL PVA ")
Str=replacestring(")BLPSS",Str,")BL PSS ")
Str=replacestring(")BLCMC",Str,")BL CMC ")
return Str
end

Function/s MakeQuoteName(Str) //Makes a string a quote-free name by removing common characters
String Str
Str=replacestring(" ",Str,"")
Str=replacestring("*",Str,"")
Str=replacestring("-",Str,"")
Str=replacestring(".",Str,"")
Str=replacestring("$",Str,"")
Str=replacestring("&",Str,"")
Str=replacestring("#",Str,"")
Str=replacestring("!",Str,"")
Str=replacestring("+",Str,"")
Str=replacestring("/",Str,"")
Str=replacestring("?",Str,"")
Str=replacestring(":",Str,"")
Str=replacestring(";",Str,"")
Return Str
end