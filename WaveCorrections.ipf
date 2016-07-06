#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function CurrentChecking()
setdatafolder root:
variable changesmade
do
	changesmade=0
	variable foundfolderwithwaves=0
	variable no_discharge_observed=0
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
					nvar /Z current_confirmed
					if (!nvar_exists(current_confirmed))
						foundfolderwithwaves=1 	//found a folder containing waves
						string firstchanges=wavelist("*",";","")
						wave current
						wavestats /q current
						if (v_min>=0)
							no_discharge_observed=1
						endif
						break
					endif
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

	//if (v_flag==1)
	//	Print "User clicked cancel"
	//	Abort
	//endif


if (foundfolderwithwaves==0)
	break
endif

if (no_discharge_observed==1)
	string howtofinddischarge
	string menustr="No discharge in this sequence;Use separate status/mode wave to select;Select discharge steps from StepID"
	string dopromptstr="No negative currents detected"
	string promptstr="Make selection for "+typename+":"+batteryname
	prompt howtofinddischarge, promptstr,popup,menustr
	variable alreadyselected=numtype(strlen(howtofinddischarge))
	switch (alreadyselected)
	case 0:
		if (cmpstr(howtofinddischarge,"No discharge in this sequence")!=0)
			doprompt dopromptstr,howtofinddischarge
		endif
		break
	case 2:
		doprompt dopromptstr,howtofinddischarge
		break
	endswitch
	
	strswitch (howtofinddischarge)
	case "No discharge in this sequence":
		break
	case "Use separate status/mode wave to select":
		string selectstr  = WaveList("Step*",";","")+WaveList("Mode*",";","")+WaveList("*",";","") // all strings in the first datafolder 
		string wn
		prompt wn, "Which wave to specify charge/discharge conditions?",popup,selectstr
		doprompt "Wave selection",wn
		wave /Z wa=$wn
		variable textornumber
		if (NumberByKey("NUMTYPE", waveinfo(wa,0))==0)
			textornumber=0
			wave /T tv=gettextvalues(wa)	
			variable vi=0
			menustr=""
			do
				menustr+=(tv[vi]+";")
				vi+=1
			while(vi<numpnts(tv))		

		else
			textornumber=1
			wave sv=getvalues(wa)
			vi=0
			menustr=""
			do
				menustr+=(num2str(sv[vi])+";")
				vi+=1
			while(vi<numpnts(tv))
		endif
		string whichvalue
		promptstr = "Which value in wave "+wn+"is discharge?"
		prompt whichvalue,promptstr,popup,menustr
		doprompt "Specify conditions for discharge",whichvalue
		break
	case "Select discharge steps from StepID":
		wave stepID
		wave steps=getvalues(stepID)
		wavestats /Q steps
		if (v_max > 500 + v_min)
			duplicate /FREE steps stepsreduced
			stepsreduced[] = (steps[p]<v_max) ? steps[p] : NaN
			wavestats /q stepsreduced
			if (v_max < 500 + v_min)
				wavetransform zapnans stepsreduced
				redimension /n=(numpnts(stepsreduced)) steps
				steps = stepsreduced
			endif
		endif
		variable lastpoint = 0
		variable si=0
		do
			duplicate /FREE /o stepID step_pts
			step_pts[] = (stepID[p]==steps[si]) ? stepID[p] : NaN
			wavestats /Q step_pts
			if (min(v_minloc,v_maxloc)>lastpoint)
				lastpoint = min(v_minloc,v_maxloc)
			endif

			si+=1
		while(si<numpnts(steps))
		wave voltage,current,runtime
		display /N=stepcheckchart /L=v voltage[0,lastpoint] vs runtime[0,lastpoint]
		appendtograph /W=stepcheckchart /L=a current[0,lastpoint] vs runtime[0,lastpoint]
		appendtograph /W=stepcheckchart /L=st stepID[0,lastpoint] vs runtime[0,lastpoint]
	//	string cursorcount="{"
	//	variable ci=0
	//	do
	//		cursorcount+=num2str(ci)+","
	//		ci+=2
	//	while(ci<numpnts(steps)/2)
	//	cursorcount +="}"
	//	showinfo/CP=$cursorcount /W=stepcheckchart
		cleanaxes("stepcheckchart")
		print steps
		break
	endswitch

endif

setdatafolder root:
typeindex=0
do
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
					nvar /Z current_confirmed
					if ( (!nvar_exists(current_confirmed)) && (cmpstr(firstchanges,wavelist("*",";",""))==0) )
						if (no_discharge_observed==1)
							strswitch (howtofinddischarge)
								case "Use separate status/mode wave to select":
									if (textornumber==0)
										wave /T wavt=$wn
										wave current
										current[]=(cmpstr(wavt[p],whichvalue)==0) ? -current[p] : current[p]
									else
										wave wav=$wn
										wave current
										current[]=(cmpstr(num2str(wav[p]),whichvalue)==0) ? -current[p] : current[p]
									endif
								break
								case "Select discharge steps from StepID":
								break
							endswitch
						endif
						variable /G current_confirmed =1
						changesmade+=1
					endif
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
while (changesmade!=0)
end

function capacities()
wave /z capacity,dischargecap,current,runtime,stepID
differentiate /METH=2 /EP=1 capacity /X=runtime /D=curcompare
make /N=(numpnts(capacity)) /FREE signcompare
signcompare = sign(current)/sign(curcompare)
signcompare[1,] = (stepID[p]==stepID[p-1]) ? signcompare[p] : NaN
killwaves curcompare
end


function /WAVE getvalues(wa)
wave wa
make /n=(numpnts(wa)) / FREE WaveValues
WaveValues[0] = wa[0]
WaveValues[1,] = (wa[p]!=wa[p-1]) ? wa[p] : NAN
sort WaveValues,WaveValues
	duplicate /FREE WaveValues wv
	multithread WaveValues[1,] = (wv[p]!=wv[p-1]) ? wv[p] : NaN
	wavestats /q WaveValues
	wavetransform zapNans WaveValues
	killwsv()
return WaveValues
end


function /WAVE gettextvalues(textwave)
wave /T textwave
make /n=(numpnts(textwave)) /FREE /T TextValues
TextValues[0] = textwave[0]
textvalues[1,] = SelectString( (cmpstr(textwave[p],textwave[p-1])==0), textwave[p], "")
sort /A textvalues,textvalues
make /N=(numpnts(textvalues))/FREE strilen
strilen = (strlen(textvalues)>0)
wavestats /q strilen; print v_maxloc
deletepoints 0,(v_maxloc), strilen,textvalues
duplicate /FREE /T textvalues tv
multithread textvalues[1,] = SelectString(  (cmpstr(tv[p],tv[p-1])==0), tv[p],"")
sort /A textvalues, textvalues
redimension /N=(numpnts(textvalues)) strilen
strilen=(strlen(textvalues)>0)
wavestats /q strilen
deletepoints 0,(v_maxloc),strilen,textvalues
killwsv()
return TextValues
end