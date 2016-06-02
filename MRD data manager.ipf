#pragma rtGlobals=3		// Use modern global access method and strict wave access.
// front-end built-in procedures for loading standard data formats and 
// menu-driven macros for 
// latest update: September 9, 2015

menu "Data"
	"Load Battery Data /1" , LoadBatData() 
end
	
menu "Battery Analysis"
	"Load Battery Data /1", LoadBatData() 
	"Routine Battery Analysis /2", BasicBatteryAnalysis()
	Submenu "Data cleaning"
		"Extract time from text", StringTimeToTime()
		"Concatenate data sets", ConcatenateDataSets()
	end
	Submenu "Full-Sized Battery Single sequence"
		"Formation", Formation()
		"Boost Charge", BoostCharge()
		"Capacity Measurement", CapacityMeasurement()
		"Cold Cranking Amps", ColdCrankingAmps()
		"Cold Charge Acceptance", ColdChargeAcceptance()
	end
	"Full-Sized Battery Cycling /3", Cycling()
	Submenu "Utilities"
		"Execute command on elements in all type folders", ExecuteAllTypes("")
		"Execute command on elements in all data subfolders", ExecuteAllBatteries("")
		"Plot average + SEM vs continuous x-value, line plot", avgsemvswave()
		"Plot average + SEM vs ordinal x-value, bar plot", AverageSEMbyTypeCategory()
		"Plot average + SEM single value vs battery type, bar plot", AverageandSEMbyTypeVariable()
		"Simple line plot for all batteries", GraphItAll()
		"Calculate Recharge Factor", calculaterechargefactor()
		"Plot average + SEM of condition at specified value", Intersect()
		"Plot isolated subsets of data: cycle, step, etc.",Isolate()
		"Go to first populated battery folder", gotofirstpopulatedfolder()
	end
	Submenu "Frequently used charts"
		"Create Baseline Run Chart", createbaselinerunchart()
		"Baseline Run Chart with SEM", CreateBaselineRunChartSEM()
		"Run Chart with Temperature", Tempstats()
	end
	Submenu "Modify charts for output"
		"Modify chart for presentation, full-size", PrepGraphForPresentationWide()
		"Modify chart for presentation, half-size", PrepGraphForPresentationHalf()

	end

end


macro LoadBatteryData()
	LoadBatData()
endmacro

function LoadBatData()
	setdatafolder root:
	nvar /Z loadcount
	if (!nvar_exists(loadcount))
		variable /G loadcount = 1
	else
		loadcount+=1
	endif
	
	String loadtypes= "Arbin;Bitrode;Eclipse 9-variable format;Eclipse 10-variable format;Eclipse 20-variable format;Single Excel file;Single CSV file;Single Text File;All Excel files in a folder;All CSV files in a folder;Instron" 
	String loadtype
	if (IgorVersion()>=7)
		execute("SetIgorOption PanelResolution = 0")
	endif

variable done=0
	do
	Prompt loadtype, "Select what data you want to load", popup, loadtypes
	variable numberofvariables
	string nvstring = "How many battery types or experimental variables in this experiment? (0-10)" 
	if (strlen(GetIndexedObjName(":", 4,0))>0)
		nvstring = "How many NEW battery types do you need to record? (0-10)"
	endif
	Prompt numberofvariables, nvstring
	string multmenu="No;Yes"
	string combine
	Prompt combine, "Do you need to combine multiple sheets/files for each battery?",popup, multmenu
	string multiload
	Prompt multiload, "Do you need to input from multiple sources beyond this import?",popup, multmenu
	DoPrompt "What type of data are we about to import and process?", loadtype,numberofvariables,combine,multiload
	if (v_flag==1)
		Print "User clicked cancel"
		Abort
	endif
	if (numberofvariables>0)
		make/N=(numberofvariables) /T varnames
		InputVariableNamesAndColors(numberofvariables)
	endif

	
	strswitch(loadtype)
		case "Arbin":
			XLLoad(loadtype="Arbin")
			StandardWavenames(loadtype="Arbin")
			break
		case "Bitrode":
			LoadAllCSVs(loadtype="Bitrode")
			StandardWaveNames(loadtype="Bitrode")
			break

		case "Eclipse 9-variable format":
			LoadAllExcel(loadtype="Eclipse 9-variable format")
			StandardWaveNames(loadtype="Eclipse 9-variable format")
			wavetypecorrection()
			break
		case "Eclipse 10-variable format":
			LoadAllCSVs(loadtype="Eclipse 10-variable format")
			StandardWaveNames(loadtype="Eclipse 10-variable format")
			break
		case "Eclipse 20-variable format":
			LoadAllCSVs(loadtype="Eclipse 20-variable format")
			StandardWaveNames(loadtype="Eclipse 20-variable format")			
			break
		case "Single Excel file":
			XLLoad()
			StandardWaveNames()
			wavetypecorrection()
			break
		case "Single CSV file":
			StandardWaveNames()
			wavetypecorrection()
			break
		case "All Excel files in a folder":
			LoadAllExcel()
			StandardWaveNames()
			wavetypecorrection()
			break
		case "All CSV files in a folder":
			LoadAllCSVs()
			StandardWaveNames()
			wavetypecorrection()
			break
		case "Iontensity":
			LoadAllExcel(loadtype="Iontensity")
			StandardWaveNames(loadtype="Iontensity")
			wavetypecorrection()
			break
		case "Instron":
			LoadAllCSVs(loadtype="Instron")
			break
	endswitch
	timeconvert()
	if (cmpstr("Instron",loadtype)!=0)
		createbaselinerunchart()
	endif
	if ((cmpstr(combine,"No")==0) && (cmpstr(multiload,"No")==0))
		done=1
	endif
	while (done<1)
	SaveExperiment
	PbAnalysis()

end

function acceptvariables(ctrlname) : buttoncontrol
	string ctrlname
	KillWindow editvarnames // sheetselect
end


function InputVariableNamesAndColors(numberofvariables)
variable numberofvariables
	wave /T varnames
	string vartype1,vartype2,vartype3,vartype4,vartype5,vartype6,vartype7,vartype8,vartype9,vartype10
	Prompt vartype1,"Enter name/desigation for variable type 1"
	Prompt vartype2,"Enter name/desigation for variable type 2"
	Prompt vartype3,"Enter name/desigation for variable type 3"
	Prompt vartype4,"Enter name/desigation for variable type 4"
	Prompt vartype5,"Enter name/desigation for variable type 5"
	Prompt vartype6,"Enter name/desigation for variable type 6"
	Prompt vartype7,"Enter name/desigation for variable type 7"
	Prompt vartype8,"Enter name/desigation for variable type 8"
	Prompt vartype9,"Enter name/desigation for variable type 9"
	Prompt vartype10,"Enter name/desigation for variable type 10"
	string promptitle="Enter variable names (begin with letter,no special chars)"
	
	switch (numberofvariables)
		case 1: 
			DoPrompt promptitle,vartype1
			varnames[0]=vartype1
			break
		case 2: 
			DoPrompt promptitle,vartype1,vartype2
			varnames[0]=vartype1
			varnames[1]=vartype2
			break
		case 3: 
			DoPrompt promptitle,vartype1,vartype2,vartype3
			varnames[0]=vartype1
			varnames[1]=vartype2
			varnames[2]=vartype3
			break
		case 4: 
			DoPrompt promptitle,vartype1,vartype2,vartype3,vartype4
			varnames[0]=vartype1
			varnames[1]=vartype2
			varnames[2]=vartype3
			varnames[3]=vartype4
			break
		case 5: 
			DoPrompt promptitle,vartype1,vartype2,vartype3,vartype4,vartype5
			varnames[0]=vartype1
			varnames[1]=vartype2
			varnames[2]=vartype3
			varnames[3]=vartype4
			varnames[4]=vartype5
			break
		case 6: 
			DoPrompt promptitle,vartype1,vartype2,vartype3,vartype4,vartype5,vartype6
			varnames[0]=vartype1
			varnames[1]=vartype2
			varnames[2]=vartype3
			varnames[3]=vartype4
			varnames[4]=vartype5
			varnames[5]=vartype6
			break
		case 7: 
			DoPrompt promptitle,vartype1,vartype2,vartype3,vartype4,vartype5,vartype6,vartype7
			varnames[0]=vartype1
			varnames[1]=vartype2
			varnames[2]=vartype3
			varnames[3]=vartype4
			varnames[4]=vartype5
			varnames[5]=vartype6
			varnames[6]=vartype7
			break
		case 8: 
			DoPrompt promptitle,vartype1,vartype2,vartype3,vartype4,vartype5,vartype6,vartype7,vartype8
			varnames[0]=vartype1
			varnames[1]=vartype2
			varnames[2]=vartype3
			varnames[3]=vartype4
			varnames[4]=vartype5
			varnames[5]=vartype6
			varnames[6]=vartype7
			varnames[7]=vartype8
			break
		case 9: 
			DoPrompt promptitle,vartype1,vartype2,vartype3,vartype4,vartype5,vartype6,vartype7,vartype8,vartype9
			varnames[0]=vartype1
			varnames[1]=vartype2
			varnames[2]=vartype3
			varnames[3]=vartype4
			varnames[4]=vartype5
			varnames[5]=vartype6
			varnames[6]=vartype7
			varnames[7]=vartype8
			varnames[8]=vartype9
			break
		case 10: 
			DoPrompt promptitle,vartype1,vartype2,vartype3,vartype4,vartype5,vartype6,vartype7,vartype8,vartype9,vartype10
			varnames[0]=vartype1
			varnames[1]=vartype2
			varnames[2]=vartype3
			varnames[3]=vartype4
			varnames[4]=vartype5
			varnames[5]=vartype6
			varnames[6]=vartype7
			varnames[7]=vartype8
			varnames[8]=vartype9
			varnames[9]=vartype10
			break
	endswitch
	//varnames = cleanupname(varnames,1)
	//varnames = uniquename(varnames,11,0)

	variable index=0
	string varname
	do
		varname = varnames[index]
		varname = cleanupname(varname,1)
		if (checkname(varname,11)!=0)
			varname = uniquename(varname,11,1)
		endif
		setdatafolder root:
		newdatafolder $varname
		index+=1
	while (index<numpnts(varnames))
	Colors(numberofvariables,varnames) 
end

function Colors(numberofvariables,varnames)
	variable numberofvariables
	wave /T varnames
	make /N=10 defaultR,defaultG,defaultB
	defaultR={65280,7168,7168,0,65280,16384,36864,65280,39168,0,0,39168}
	defaultG={0,28416,12544,52224,43520,28160,14592,0,39168,0,52224,26112}
	defaultB={0,48896,19712,0,0,65280,58880,52224,39168,0,52224,0}
	execute "SetIgorOption panelresolution=0"
	//defaultcolors={"(65280,0,0)","(65280,43520,0)","(0,52224,0)","(16384,28160,65280)","(36864,14592,58880)","(65280,0,5224)","(39168,39168,39168)","(0,0,0)","(0,52224,052224)","(39168,26112,0)"}
	variable wbottom=50+numberofvariables*18+55
	NewPanel /W=(150,50,550,wbottom) /N=colorcontrol as "Select colors for plotting each variable"
	string popupname
	variable popindex=0
	do
		popupname="popup"+num2str(popindex)
		popupmenu $popupname,bodywidth=50,font="Arial",fsize=14,pos={10,(popindex+1)*16},size={120,15},proc=ColorPopMenuProc,title=varnames[popindex]
		popupmenu $popupname,mode=0,popColor=(defaultR[popindex],defaultG[popindex],defaultB[popindex]),value="*COLORPOP*"
	popindex+=1
	while (popindex<numpnts(varnames))
	
	button colorbutton,pos={50,(numberofvariables*18+30)},size={300,20},fsize=16,font="Arial",title="Close Window and Approve Colors", proc=stopcolorproc
	PauseForUser colorcontrol
	variable typeindex=0
	variable typenewindex=0
	
	do
	string typename = GetIndexedObjName(":", 4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z red
	if (!nvar_exists(red))
		variable /G red=defaultR[typenewindex]
	endif
	nvar /Z green
	if (!nvar_exists(green))
		variable /G green=defaultG[typenewindex]
	endif
	nvar /Z blue
	if (!nvar_exists(blue))
		variable /G blue=defaultB[typenewindex]
		typenewindex+=1
	endif
	setdatafolder root:
		typeindex+=1
	while(1)
	
	killwaves defaultR,defaultG,defaultB
End

function stopcolorproc(ctrlname) : buttoncontrol
	string ctrlname
	
	setdatafolder root:
	wave /T varnames
	wave defaultR,defaultG,defaultB
	string popupname
	variable popindex=0
	do
		popupname="popup"+num2str(popindex)
		ControlInfo $popupname
		defaultR[popindex] = V_red
		defaultG[popindex]= V_green
		defaultB[popindex]= V_blue
	popindex+=1
	while (popindex<numpnts(varnames))
	killwindow colorcontrol
end

Function ColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Variable r,g,b
	MyRGBstrToRGB(popStr,r,g,b)		// One way to get r, g, b
	ControlInfo $ctrlName				// Another way: sets V_Red, V_Green, V_Blue
End

Function MyRGBstrToRGB(rgbStr,r,g,b)
	String rgbStr
	Variable &r, &g, &b

	r= str2num(rgbStr[1,inf])
	variable spos= strsearch(rgbStr,",",0)
	g= str2num(rgbStr[spos+1,inf])
	spos= strsearch(rgbStr,",",spos+1)
	b= str2num(rgbStr[spos+1,inf])
	return 1
End

function excludeBadData(excludechart)
string excludechart
setdatafolder root:
variable rowheight=16
variable columnwidth=250
variable windowheight=rowheight*20
variable windowwidth=400
dowindow /F $excludechart
NewPanel /N=excludebat /Ext=0 /HOST=$excludechart /W=(1,1,(windowwidth),(windowheight))  as "Any batteries we should exclude from summary?"
string /G panelname = excludechart + "#excludebat"
string checkbxname
variable comv=0
variable index=0
variable typeindex=0
do
	string typename = GetIndexedObjName(":", 4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	variable batteryindex=0
	do
		string batteryname = GetIndexedObjName(":",4,batteryindex)
		if (strlen(batteryname)==0)
			break
		endif
		setdatafolder $batteryname
		
		checkbxname = "cb" + typename+batteryname
		checkbxname = cleanupname(checkbxname,0)

		comv=0
		CheckBox $checkbxname, win=$panelname, fsize=14, font="Arial", value=comv,pos={1,1+index*rowheight},title=(typename+" "+batteryname)
		setdatafolder root:
		setdatafolder $typename
		index+=1
		batteryindex+=1
	while(1)
		setdatafolder root:
	typeindex+=1
while(1)
button badbutton,pos={(windowwidth/2-150),(windowheight-50)},size={300,35},font="Arial",fsize=14,win=$panelname,title="Close Window and Confirm Exclusions",proc=stopexclude
PauseForUser $panelname, $excludechart
killstrings panelname
setdatafolder root: 
end

function stopexclude(ctrlname) : buttoncontrol
string ctrlname
string checkbxname
setdatafolder root:
svar panelname
variable typeindex=0
do
	string typename = GetIndexedObjName(":", 4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	variable batteryindex=0
	do
		string batteryname = GetIndexedObjName(":",4,batteryindex)
		if (strlen(batteryname)==0)
			break
		endif
		setdatafolder $batteryname
		
		checkbxname = "cb" + typename+batteryname
		checkbxname = cleanupname(checkbxname,0)

		controlinfo /W=$panelname $checkbxname
		variable /G skip=V_value

		setdatafolder root:
		setdatafolder $typename
		batteryindex+=1
	while(1)
		setdatafolder root:
	typeindex+=1
while(1)
	killwindow $panelname
end

function PreSelectKeyWaveNames([loadtype])
string loadtype
setdatafolder root:
svar /Z vwavename
if (!svar_exists(vwavename))
string /G vwavename,curwavename
string /G totaltimename,steptimename
string /G capname,discapname
string /G stepname,cyclename
variable /G timeunits
setdatafolder root:
if (paramisdefault(loadtype))
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
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					foundfolderwithwaves=1 	//found a folder containing waves
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
	string fullstr  = WaveList("*",";","") // all strings in the first datafolder 
	string nullstr = "No such wave;" //allows user to indicate that there is no wave of this type
	string vmenustr =WaveList("Volt*", ";", "" ) +fullstr+nullstr
	string curmenustr = WaveList("Cur*",";","") + fullstr+nullstr
	string totaltimemenustr = WaveList("*Time*",";","") + fullstr + nullstr
	string steptimemenustr= WaveList("*Time*",";","")+ fullstr + nullstr
	string capmenustr = WaveList("*Cap*",";","")+WaveList("*Charge*",";","") +fullstr + nullstr
	string discapmenustr = WaveList("*Dis*",";","") + nullstr + fullstr
	string stepmenustr = WaveList("*Step*",";","") + nullstr + fullstr
	string cyclemenustr = WaveList("*Cycle*",";","") + nullstr + fullstr
	string unitsmenu = "Seconds; Minutes; Hours;" 
	string vwn,cwn,rtwn, rstwn, capwn, discapwn,stpwn,cycwn
	variable rtu
	prompt vwn, "Select voltage wave", popup, vmenustr
	prompt cwn, "Select current wave", popup, curmenustr
	prompt rtwn, "Select total elapsed time wave", popup, totaltimemenustr
	prompt rstwn, "Select step time wave", popup, steptimemenustr
	prompt capwn, "Select charge capacity/ step capacity", popup, capmenustr
	prompt discapwn, "Select discharge capacity if specialized wave exists", popup,discapmenustr
	prompt stpwn, "Select index for step in program", popup, stepmenustr
	prompt cycwn, "Select cycle counter for step in program", popup, cyclemenustr
	prompt rtu, "What units does data file report time in?", popup, unitsmenu 
	doprompt "Select wave names/units for this experiment",vwn,cwn,rtwn,rstwn,capwn,discapwn,stpwn,cycwn,rtu
	if (v_flag==1)
		Print "User clicked cancel"
		Abort
	endif
	vwavename =vwn
	curwavename=cwn
	totaltimename=rtwn
	steptimename=rstwn
	capname=capwn
	discapname = discapwn
	stepname = stpwn
	cyclename = cycwn
	timeunits	= rtu
	setdatafolder root:
	string allstrings="vwavename;curwavename;totaltimename;steptimename;capname;discapname;stepname;cyclename"
	variable i=0
	do
		string stringcheck=StringFromList(i, allstrings)
		svar scheck = $stringcheck
		if (strsearch(scheck, "No such wave",0)>=0)
			killstrings scheck
		endif
		i+=1
	while (i<8)
else //if paramisdefault
	strswitch(loadtype)	// string switch
		case "Bitrode":		// execute if case matches expression
			vwavename = "Voltage"
			curwavename = "Current"
			totaltimename = "Total_Time"
			steptimename = "Step_Time"
			capname = "Amp_Hours"
			stepname = "Step"
			cyclename = "Cycle"
			killstrings discapname
			timeunits = 1
			break					// exit from switch			
		case "Arbin":		// execute if case matches expression
			vwavename = "Voltage_V_"
			curwavename = "Current_A_"
			totaltimename = "Test_Time_S_"
			steptimename = "Step_Time_S_"
			capname = "Charge_Capacity_Ah_"
			discapname = "Discharge_Capacity_Ah_"
			cyclename = "Cycle_Index"
			stepname = "Step_Index"
			timeunits = 1
			break
		case "Eclipse 9-variable format":
			vwavename = "Voltage__V"
			curwavename = "Current__A"
			totaltimename = "Total_Time___h_m_s_"
			steptimename = "Step_Time___h_m_s_"
			capname = "Amp_Hours__AH"
			stepname = "Step"
			cyclename = "Cycle"
			timeunits= 1
			break
		case "Eclipse 10-variable format":
			vwavename = "Volts"
			curwavename = "Amps"
			totaltimename = "Test_Time"
			steptimename = "Step_Time"
			stepname = "Step"
			cyclename = "Cycl"
			capname = "A_H"
			killstrings discapname
			timeunits = 1
			break
		case "Eclipse 20-variable format":
			vwavename = "Voltage"
			curwavename = "Current"
			totaltimename = "Prog_Time"
			steptimename = "Step_Time"
			stepname = "Step"
			cyclename = "Cycle"
			capname = "AhStep"
			killstrings discapname
			timeunits = 1
			break
		case "Iontensity":
			vwavename = "Vol"
			curwavename = "Cur"
			steptimename="Time_H_M_S_ms_"
			totaltimename="Realtime"
			cyclename="Cycle_ID"
			stepname="Step_ID"
			capname="CmpCap"
			break
	endswitch
setdatafolder root:
endif
endif
end

function StandardWaveNames([loadtype])
string loadtype
setdatafolder root:

if (paramisdefault(loadtype))
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
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					foundfolderwithwaves=1 	//found a folder containing waves
					nvar /Z names_standardized
					if (!nvar_exists(names_standardized))
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
	string fullstr  = WaveList("*",";","") // all strings in the first datafolder 
	string nullstr = "No such wave;" //allows user to indicate that there is no wave of this type
	string vmenustr =WaveList("Volt*", ";", "" ) +fullstr+nullstr
	string curmenustr = WaveList("Cur*",";","") + fullstr+nullstr
	string totaltimemenustr = WaveList("*Time*",";","") + fullstr + nullstr
	string steptimemenustr= WaveList("*Time*",";","")+ fullstr + nullstr
	string capmenustr = WaveList("*Cap*",";","")+WaveList("*Charge*",";","") +fullstr + nullstr
	string discapmenustr = WaveList("*Dis*",";","") + nullstr + fullstr
	string stepmenustr = WaveList("*Step*",";","") + nullstr + fullstr
	string cyclemenustr = WaveList("*Cycle*",";","") + nullstr + fullstr
	string unitsmenu = "Seconds; Minutes; Hours;" 
	string vwn,cwn,rtwn, rstwn, capwn, discapwn,stpwn,cycwn
	string rtu
	prompt vwn, "Select voltage wave", popup, vmenustr
	prompt cwn, "Select current wave", popup, curmenustr
	prompt rtwn, "Select total elapsed time wave", popup, totaltimemenustr
	prompt rstwn, "Select step time wave", popup, steptimemenustr
	prompt capwn, "Select charge capacity/ step capacity", popup, capmenustr
	prompt discapwn, "Select discharge capacity if specialized wave exists", popup,discapmenustr
	prompt stpwn, "Select index for step in program", popup, stepmenustr
	prompt cycwn, "Select cycle counter for step in program", popup, cyclemenustr
	prompt rtu, "What units does data file report time in?", popup, unitsmenu 
	doprompt "Select wave names/units for this experiment",vwn,cwn,rtwn,rstwn,capwn,discapwn,stpwn,cycwn,rtu
	if (v_flag==1)
		Print "User clicked cancel"
		Abort
	endif

else //if paramisdefault
	strswitch(loadtype)	// string switch
		case "Bitrode":		// execute if case matches expression
			vwn = "Voltage"
			cwn = "Current"
			rtwn = "Total_Time"
			rstwn = "Step_Time"
			capwn = "Amp_Hours"
			discapwn="No such wave"
			stpwn = "Step"
			cycwn = "Cycle"
			rtu = "Seconds"
			break					// exit from switch			
		case "Arbin":		// execute if case matches expression
			vwn = "Voltage_V_"
			cwn = "Current_A_"
			rtwn = "Test_Time_S_"
			rstwn = "Step_Time_S_"
			capwn = "Charge_Capacity_Ah_"
			discapwn = "Discharge_Capacity_Ah_"
			cycwn = "Cycle_Index"
			stpwn = "Step_Index"
			rtu = "Seconds"
			break
		case "Eclipse 9-variable format":
			vwn = "Voltage__V"
			cwn = "Current__A"
			rtwn = "Total_Time___h_m_s_"
			rstwn = "Step_Time___h_m_s_"
			capwn = "Amp_Hours__AH"
			stpwn = "Step"
			cycwn = "Cycle"
			rtu= "Seconds"
			break
		case "Eclipse 10-variable format":
			vwn = "Volts"
			cwn = "Amps"
			rtwn = "Test_Time"
			rstwn = "Step_Time"
			stpwn = "Step"
			cycwn = "Cycl"
			capwn = "A_H"
			discapwn="No such wave"
			rtu = "Seconds"
			break
		case "Eclipse 20-variable format":
			vwn = "Voltage"
			cwn = "Current"
			rtwn = "Prog_Time"
			rstwn = "Step_Time"
			stpwn = "Step"
			cycwn = "Cycle"
			capwn = "AhStep"
			discapwn="No such wave"
			rtu = "Seconds"
			break
		case "Iontensity":
			vwn = "Vol"
			cwn = "Cur"
			rtwn="Time_H_M_S_ms_"
			rstwn="Realtime"
			cycwn="Cycle_ID"
			stpwn="Step_ID"
			capwn="CmpCap"
			discapwn="No such wave"
			rtu = "Seconds"
			break
	endswitch
setdatafolder root:
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
				print getdatafolder(1)
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					nvar /Z names_standardized
					if (!nvar_exists(names_standardized))
						if (cmpstr(vwn,"No such wave")!=0)
							wave v =$vwn
							rename v Voltage
							waveclear v
						endif
						if (cmpstr(cwn,"No such wave")!=0)
							wave a =$cwn
							rename a Current
							waveclear a
						endif
						if (cmpstr(rtwn,"No such wave")!=0)
							wave rt =$rtwn
							rename rt RunTime
							waveclear rt
						endif
						if (cmpstr(rstwn,"No such wave")!=0)
							wave st =$rstwn
							rename st StepTime
							waveclear st
						endif
						if (cmpstr(capwn,"No such wave")!=0)
							wave cap =$capwn
							rename cap Capacity
							waveclear cap
						endif			
									
						if (cmpstr(discapwn,"No such wave")!=0)
							wave dc =$discapwn
							rename dc DischargeCap
							waveclear dc
						endif							
											
						if (cmpstr(stpwn,"No such wave")!=0)
							wave step =$stpwn
							rename step StepID
							waveclear step
						endif		
						
						if (cmpstr(cycwn,"No such wave")!=0)
							wave cyc =$cycwn
							rename cyc Cycle
							waveclear cyc
						endif		
						
						string /G timeunit=rtu
						
						variable /G names_standardized =1
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
end

function timeconvert()
//scans through ALL BATTERY FOLDERS and looks for properly named waves for time and step time
//assumes that user will want to express time in hours. If recorded timewave is expressed in
//another unit, converts time to to hours. If maximum time is < 1 hour, converts to minutes.
//If maximum time is < 1 minute, converts to seconds.
//Once the conversion is complete, leaves a variable called "timescaled" set = to 1 in folder.
//Will not try to convert again once completed.
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
					nvar /Z timescaled
					svar timeunit
					wave RunTime, StepTime
					if (!nvar_exists(timescaled))		
						variable unit=0
						make /N=3 /T timeunits={"Seconds","Minutes","Hours"}
						do
							if (cmpstr(timeunit,timeunits[unit])==0)
								break
							endif
							unit+=1
						while (unit<=2)
					
						variable maxtime=-1
						variable desiredtimeunits = 2 //assumes that we usually want to express time in hours (0=sec,1=min,2=hr)
						
						do
							
	
							if (desiredtimeunits!=unit)
								RunTime /=60^(desiredtimeunits-unit)
								StepTime /=60^(desiredtimeunits-unit)
								unit=desiredtimeunits
								timeunit=TimeUnits[unit]
							endif
							wavestats /Q runtime
							maxtime=max(maxtime,v_max)
							desiredtimeunits -=1
						while (maxtime<1)

						variable /G timescaled=1 //creates a flag indicating that we've already corrected time units for this folder
					endif // folder hasn't had time scaled properly yet
				endif 	// no imperative to skip
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
killwaves timeunits
end
// end time convert


function createBaselineRunchart()
	
display /N=baselinerunchart

variable typeindex,batteryindex
string typename,batteryname

string legendstring=""
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
				nvar red,green,blue
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					wave  Voltage
					wave  Current
					wave RunTime

					string vname = maketracename("V",typename,batteryname,"baselinerunchart")
					string aname = maketracename("A",typename,batteryname,"baselinerunchart")
					
					
					appendtograph /W=baselinerunchart /L=V voltage /TN=$vname vs RunTime
					appendtograph /W=baselinerunchart /L=A current /TN=$aname vs RunTime
					modifygraph /W=baselinerunchart rgb($vname) = (red,green,blue)
					modifygraph /W=baselinerunchart rgb($aname) = (red,green,blue)
					modifygraph /W=baselinerunchart lstyle($vname)= batteryindex, lstyle($aname)=batteryindex
					if (strlen(legendstring)>0)
						legendstring += "\r"
					endif
					legendstring+="\s("+vname+")"+ typename+" "+replacestring("Bat",batteryname,"")
					waveclear Voltage,Current,Runtime
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)


modifygraph /W=baselinerunchart axisontop=1
modifygraph /W=baselinerunchart axOffset=0
modifygraph /W=baselinerunchart freePos=0
modifygraph /W=baselinerunchart axisenab(V)={0,0.48}
modifygraph /W=baselinerunchart axisenab(A)={0.52,1}
label /W=baselinerunchart V "Voltage(V)"
label /W=baselinerunchart A "Current(A)"
setdatafolder root:
gotofirstpopulatedfolder()
svar timeunit
string timelabel = "Time("+lowerstr(timeunit)+")"
setdatafolder root:
label /W=baselinerunchart bottom timelabel
Textbox /W=baselinerunchart /N=legendary legendstring
ModifyGraph /W=baselinerunchart lblPosMode=1
DoUpdate /W=baselinerunchart
notebook recording picture={baselinerunchart,0,1}
notebook recording text="\r"
end

