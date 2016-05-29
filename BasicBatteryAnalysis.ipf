#pragma rtGlobals=3, version = 160120		// Use modern global access method and strict wave access.

Function BasicBatteryAnalysis()
	setdatafolder root:
	svar/z capname,stepname
	if (!svar_exists(capname)) //Battery data has not yet been loaded
		Abort "Please import battery data before performing analysis"
	endif
	nvar/z chstep,dischstep,laststep
	if ((!nvar_exists(chstep)) || (!nvar_exists(dischstep)) || (!nvar_exists(laststep)))
		string topfolder=firstpopulatedfolder()
		setdatafolder $topfolder //aka nothing will work in the experiment if  the top folder is bad/unusual
		wave stepwave=$stepname
		wavestats/q/m=1 $capname//figure out the likely charge/discharge steps
		variable/g root:chstep=stepwave[v_maxloc]
		variable/g root:dischstep=stepwave[v_minloc]
		variable/g root:laststep=wavemax(stepwave)
		setdatafolder root:
		nvar chstep,dischstep
	endif
	
	DoWindow/K TaskSelection //Delete old panel and start making a new one
	NewPanel /W=(984,115,1430,580)/K=1
	DoWindow/C/T TaskSelection,"Basic Battery Analysis"
	ModifyPanel cbRGB=(17476,17476,17476), fixedSize=1
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (65535,65535,65535)
	DrawText 12,31,"MRD Basic Battery Analysis"
	DrawPict 380,10,.6,.6,ProcGlobal#logo
	SetVariable chstep,pos={22.00,54.00},size={150.00,18.00},title="\\K(65535,65535,65535)Charge Step"
	SetVariable chstep value=chstep,limits={0,laststep,1}
	SetVariable dischstep,pos={210.00,54.00},size={150.00,18.00},title="\\K(65535,65535,65535)Discharge Step"
	SetVariable dischstep value=dischstep,limits={0,laststep,1}
	Button buttonhelp,pos={287.00,9.00},size={40.00,20.00},proc=BBAhelp,title="Help",help={"Click here for help"}
	TabControl tab0,pos={19.00,87.00},size={413.00,361.00},proc=TabProc
	TabControl tab0,labelBack=(32768,54528,65280),tabLabel(0)="RC",tabLabel(1)="CCA"
	TabControl tab0,tabLabel(2)="MultiCycle",value= 0
	TabControl tab0,tabLabel(3)="Custom",value= 0
	TabControl tab0,tabLabel(4)="Other",value= 0 //add more tabs here if needed
	
	GroupBox group0_tab0,pos={26.00,130.00},size={398.00,306.00},title="Choose graphs to be created"
	Button button0_tab0,pos={317.00,119.00},size={100.00,20.00},proc=DoAnalysisFromTab,title="Perform Analysis"
	CheckBox check0_tab0,pos={45.00,167.00},size={116.00,15.00},title="Discharge Capacity (Ah)"
	CheckBox check0_tab0,value= 0
	CheckBox check1_tab0,pos={45.00,207.00},size={123.00,15.00},title="Reserve Capacity (minutes)"
	CheckBox check1_tab0,value= 0
	CheckBox check2_tab0,pos={45.00,247.00},size={235.00,15.00},title="Ah In During Charge"
	CheckBox check2_tab0,value= 0
	CheckBox check3_tab0,pos={45.00,287.00},size={174.00,15.00},title="%Ah In During Charge"
	CheckBox check3_tab0,value= 0
	CheckBox check4_tab0,pos={45.00,327.00},size={174.00,15.00},title="Time to 100% Recharge Factor"
	CheckBox check4_tab0,value= 0
	CheckBox check5_tab0,pos={45.00,367.00},size={187.00,15.00},title="Time to x% Recharge Factor"
	CheckBox check5_tab0,value= 0
	CheckBox check6_tab0,pos={45.00,407.00},size={187.00,15.00},title="Time to ToCV"
	CheckBox check6_tab0,value= 0
	
	GroupBox group0_tab1,pos={26.00,130.00},size={398.00,306.00},title="Choose graphs to be created"
	Button button1_tab1,pos={317.00,119.00},size={100.00,20.00},proc=DoAnalysisFromTab,title="Perform Analysis"
	CheckBox check0_tab1,pos={45.00,167.00},size={116.00,15.00},title="CCA Duration (seconds)"
	CheckBox check0_tab1,value= 0
	CheckBox check1_tab1,pos={45.00,207.00},size={123.00,15.00},title="Voltage after xs of Discharge"
	CheckBox check1_tab1,value= 0
	CheckBox check2_tab1,pos={45.00,247.00},size={235.00,15.00},title="Voltage after 30s of Discharge"
	CheckBox check2_tab1,value= 0
	CheckBox check3_tab1,pos={45.00,287.00},size={174.00,15.00},title="Time to xV"
	CheckBox check3_tab1,value= 0
	CheckBox check4_tab1,pos={45.00,327.00},size={174.00,15.00},title="Time to 6V"
	CheckBox check4_tab1,value= 0	
	
	GroupBox group0_tab2,pos={26.00,130.00},size={398.00,306.00},title="Choose graphs to be created, across all cycles"
	Button button2_tab2,pos={317.00,119.00},size={100.00,20.00},proc=DoAnalysisFromTab,title="Perform Analysis"
	CheckBox check0_tab2,pos={45.00,167.00},size={116.00,15.00},title="BOC Voltage"
	CheckBox check0_tab2,value= 0
	CheckBox check1_tab2,pos={45.00,207.00},size={123.00,15.00},title="EOC Current"
	CheckBox check1_tab2,value= 0
	CheckBox check2_tab2,pos={45.00,247.00},size={235.00,15.00},title="Minimum Discharge Voltage"
	CheckBox check2_tab2,value= 0	
	CheckBox check3_tab2,pos={45.00,287.00},size={235.00,15.00},title="Minimum Resting Voltage"
	CheckBox check3_tab2,value= 0
	
	GroupBox group0_tab3,pos={26.00,130.00},size={398.00,306.00},title="Custom Analysis"
	Button button2_tab3,pos={317.00,119.00},size={100.00,20.00},proc=DoAnalysisFromTab,title="Perform Tasks"
	CheckBox check0_tab3,pos={45.00,167.00},size={116.00,15.00},title="Simple line graph for all batteries"
	CheckBox check0_tab3,value= 0
	CheckBox check1_tab3,pos={45.00,207.00},size={123.00,15.00},title="Average/SEM line graph for all batteries"
	CheckBox check1_tab3,value= 0
	CheckBox check2_tab3,pos={45.00,247.00},size={123.00,15.00},title="Intersect between two waves (bar graph)"
	CheckBox check2_tab3,value= 0
	CheckBox check3_tab3,pos={45.00,287.00},size={235.00,15.00},title="Isolate two waves (line graph)"
	CheckBox check3_tab3,value= 0	
	CheckBox check4_tab3,pos={45.00,327.00},size={235.00,15.00},title="Execute command on elements in all type folders"
	CheckBox check4_tab3,value= 0
	CheckBox check5_tab3,pos={45.00,367.00},size={235.00,15.00},title="Execute command on elements in all data subfolders"
	CheckBox check5_tab3,value= 0
	
	GroupBox group0_tab4,pos={26.00,130.00},size={398.00,306.00},title="Other tasks"
	Button button2_tab4,pos={317.00,119.00},size={100.00,20.00},proc=DoAnalysisFromTab,title="Perform Tasks"
	CheckBox check0_tab4,pos={45.00,167.00},size={116.00,15.00},title="Create Baseline Run Chart"
	CheckBox check0_tab4,value= 0
	CheckBox check1_tab4,pos={45.00,207.00},size={123.00,15.00},title="Create Baseline Run Chart (Avg/SEM)"
	CheckBox check1_tab4,value= 0
	CheckBox check2_tab4,pos={45.00,247.00},size={123.00,15.00},title="Custom Baseline Run Chart with step selection"
	CheckBox check2_tab4,value= 0
	CheckBox check3_tab4,pos={45.00,287.00},size={235.00,15.00},title="Graph Temperature Statistics"
	CheckBox check3_tab4,value= 0	
	CheckBox check4_tab4,pos={45.00,327.00},size={235.00,15.00},title="Reduce File Size (Kill unnecessary/unused waves)"
	CheckBox check4_tab4,value= 0
	CheckBox check5_tab4,pos={45.00,367.00},size={235.00,15.00},title="Add dashed line to top graph at given value"
	CheckBox check5_tab4,value= 0
	//SetActiveSubwindow _endfloat_
	
	ModifyControlList ControlNameList("", ";", "*_tab1") disable=1
	ModifyControlList ControlNameList("", ";", "*_tab2") disable=1
	ModifyControlList ControlNameList("", ";", "*_tab3") disable=1
	ModifyControlList ControlNameList("", ";", "*_tab4") disable=1
end

Function TabProc(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum
	ModifyControlList ControlNameList("", ";", "*_tab0") disable=tabNum!=0
	ModifyControlList ControlNameList("", ";", "*_tab1") disable=tabNum!=1
	ModifyControlList ControlNameList("", ";", "*_tab2") disable=tabNum!=2
	ModifyControlList ControlNameList("", ";", "*_tab3") disable=tabNum!=3
	ModifyControlList ControlNameList("", ";", "*_tab4") disable=tabNum!=4
	return 0
End

Function DoAnalysisFromTab(ctrlname) : ButtonControl
 	string ctrlname
 	controlinfo /w=TaskSelection tab0
	string pname = "TaskSelection"
	string tname = "tab"+num2str(v_value)
	string fname = ""
	string cname
	variable ic,nc, nt = 0
	strswitch(tname)
	case "tab0"://RC
		nc=7
		make/N=(nc)/FREE/T dowhat = {"DischargeCapacity","ReserveCapacity","ChargeCapacity","RFMax","TimeTo100RF","TimeToxRF","TimeToCV"}
	break
	case "tab1"://CCA
		nc=5
		make/N=(nc)/FREE/T dowhat = {"CCADuration","Vxs","V30s","TimeToxV","TimeTo6V"}
	break
	case "tab2"://MultiCycle
		nc=4
		make/N=(nc)/FREE/T dowhat = {"BOCVoltage","EOCCurrent","MinVoltage","RestVoltage"}
	break
	case "tab3"://Other
		nc=6
		make/N=(nc)/FREE/T dowhat = {"GraphItAll","AverageandSEMbyTypeWave","Intersect","Isolate","ExecuteAllTypes","ExecuteAllBatteries"}
	break
	case "tab4"://Other
		nc=6
		make/N=(nc)/FREE/T dowhat = {"baselinerunchart","BRCSEM","CustomBRC","TempStat","Cleanup","DashedLine"}
	break
	endswitch
	make/N=(nc)/FREE doit = 0
 
	for (ic=0;ic<nc;ic+=1) //collect all checkbox states
		sprintf cname, "check%d_%s", ic, tname
		ControlInfo/W=$pname $cname
		doit[ic] = v_value
		nt += v_value
	endfor
 
	if (nt == 0)
		DoAlert 0, "No analysis selected!"
		return 0
	endif
 
	for (ic=0;ic<nc;ic+=1)//run selected functions using special executor
		if (doit[ic])
			sprintf fname, "BasicBatteryAnalysisExecute("+"\"%s\""+")", dowhat[ic]
			Execute/Q fname
			AutoPositionWindow/E/M=1
		endif
	endfor
	return 0
end

Function BasicBatteryAnalysisExecute(task)
string task
setdatafolder root:
nvar chstep,dischstep
variable inval
string axisn
svar capname,curwavename,steptimename,totaltimename,vwavename,stepname,timelabel
nvar timeunits
DoWindow/K $task //delete the old windows before making new ones
strswitch(task)
	//RC
	case "DischargeCapacity":
	intersect(ywaven=capname,ywavev="min",xwaven=capname,multicycle="No",stepv=dischstep,charttitle="DischargeCapacity")
	execute "root:dischargecapacityavg*=-1"
	Label DischargeCapacity "Discharge Capacity (Ah)"
	break
	case "ReserveCapacity":
	intersect(ywaven=steptimename,ywavev="max",xwaven=steptimename,multicycle="No",stepv=dischstep,charttitle="ReserveCapacity")
	Label ReserveCapacity "Reserve Capacity (mins)"
	setdatafolder root:
	execute "ReserveCapacityavg*=(60^"+num2str(timeunits-2)+");ReserveCapacitysem*=(60^"+num2str(timeunits-2)+")"
	break
	case "ChargeCapacity":
	intersect(ywaven=capname,ywavev="max",xwaven=capname,multicycle="No",stepv=chstep,charttitle="ChargeCapacity")
	Label ChargeCapacity "Ah In During Charge"
	break
	case "RFMax":
	calculateRechargeFactor()
	intersect(ywaven="RechargeFactor",ywavev="max",xwaven="RechargeFactor",multicycle="No",stepv=chstep,charttitle="RFMax")
	Label RFMax "%Ah In During Charge"
	ModifyGraph prescaleExp(RFMax)=2
	SetAxis RFMax 1,*
	break
	case "TimeTo100RF":
	calculateRechargeFactor()
	intersect(ywaven="RechargeFactor",ywavev="1",xwaven=steptimename,multicycle="No",stepv=chstep,charttitle="TimeTo100RF")
	Label TimeTo100RF "Time to 100% Recharge Factor (hr)"
	break
	case "TimeToxRF":
	prompt inval, "What % Recharge Factor? (eg 100 or 107)"
	doprompt "Time to x% Recharge Factor", inval
	if (v_flag==1)
		Abort
	endif
	calculateRechargeFactor()
	axisn="TimeTo"+makequotename(num2str(inval))+"RF"
	DoWindow/K $axisn
	intersect(ywaven="RechargeFactor",ywavev=num2str(inval/100),xwaven=steptimename,multicycle="No",stepv=chstep,charttitle="TimeTo"+makequotename(num2str(inval))+"RF")
	Label $axisn "Time to "+num2str(inval)+"% Recharge Factor (hr)"
	break
	case "TimeToCV":
	executeallbatteries("differentiate "+vwavename+" /x=timehr /d=Voltagedx;voltagedx*=((voltagedx==0)/(voltagedx==0))")
	intersect(ywaven="Voltagedx",ywavev="0",xwaven=steptimename,multicycle="No",stepv=chstep,charttitle="TimeToCV")
	executeallbatteries("killwaves voltagedx")
	Label TimeToCV "Time to ToCV (hr)"
	break
	//CCA
	case "CCADuration":
	intersect(ywaven=steptimename,ywavev="max",xwaven=steptimename,multicycle="No",stepv=dischstep,charttitle="CCADuration")
	Label CCADuration "CCA Duration (s)"
	setdatafolder root:
	execute "CCADurationavg*=(60^"+num2str(timeunits-1)+");CCADurationsem*=(60^"+num2str(timeunits-1)+")"
	break
	case "Vxs":
	prompt inval, "Check voltage after how many seconds?"
	doprompt "Voltage After xs of Discharge", inval
	if (v_flag==1)
		Abort
	endif
	axisn="V"+makequotename(num2str(inval))+"s"
	DoWindow/K $axisn
	variable invalfixed=inval/(60^(timeunits-1))
	intersect(ywaven=steptimename,ywavev=num2str(invalfixed),xwaven=vwavename,multicycle="No",stepv=dischstep,charttitle="V"+makequotename(num2str(inval))+"s")
	Label $axisn "Voltage After "+num2str(inval)+"s of Discharge (V)"
	break
	case "V30s":
	inval=30/(60^(timeunits-1))
	intersect(ywaven=steptimename,ywavev=num2str(inval),xwaven=vwavename,multicycle="No",stepv=dischstep,charttitle="V30s")
	Label V30s "Voltage After 30s of Discharge (V)"
	break
	case "TimeToxV":
	prompt inval, "Check time to which voltage?"
	doprompt "Time to xV", inval
	if (v_flag==1)
		Abort
	endif
	axisn="TimeTo"+makequotename(num2str(inval))+"V"
	DoWindow/K $axisn
	intersect(ywaven=vwavename,ywavev=num2str(inval),xwaven=steptimename,multicycle="No",stepv=dischstep,charttitle=axisn)
	Label $axisn "Time to "+num2str(inval)+"V (s)"
	setdatafolder root:
	execute axisn+"avg*=(60^"+num2str(timeunits-1)+");"+axisn+"sem*=(60^"+num2str(timeunits-1)+")"
	break
	case "TimeTo6V":
	intersect(ywaven=vwavename,ywavev="6",xwaven=steptimename,multicycle="No",stepv=dischstep,charttitle="TimeTo6V")
	Label TimeTo6V "Time to 6V (s)"
	setdatafolder root:
	execute "TimeTo6Vavg*=(60^"+num2str(timeunits-1)+");TimeTo6Vsem*=(60^"+num2str(timeunits-1)+")"
	break
	//MultiCycle
	case "BOCVoltage":
	intersect(ywaven=totaltimename,ywavev="min",xwaven=vwavename,stepv=chstep,cyclev=0,multicycle="Yes",graphtype="Line (All Batteries)",charttitle="BOCVoltage")
	Label BOCVoltage "BOC Voltage"
	break
	case "EOCCurrent":
	intersect(ywaven=totaltimename,ywavev="min",xwaven=curwavename,stepv=chstep,cyclev=0,multicycle="Yes",graphtype="Line (All Batteries)",charttitle="EOCCurrent")
	Label EOCCurrent "BOC Current"
	break
	case "MinVoltage":
	intersect(ywaven=vwavename,ywavev="min",xwaven=vwavename,stepv=dischstep,cyclev=0,multicycle="Yes",graphtype="Line (All Batteries)",charttitle="MinVoltage")
	Label MinVoltage "Minimum Discharge Voltage"
	break
	case "RestVoltage":
	executeallbatteries("duplicate/o "+vwavename+",VRest;vrest*=(("+curwavename+"<=0.01)/("+curwavename+"<=0.01));vrest*=(("+curwavename+">=-0.01)/("+curwavename+">=-0.01))")
	intersect(ywaven="VRest",ywavev="min",xwaven="VRest",stepv=0,cyclev=0,multicycle="Yes",graphtype="Line (All Batteries)",charttitle="RestVoltage")
	executeallbatteries("killwaves vrest")
	Label RestVoltage "Minimum Resting Voltage"
	break
	//Custom
	case "GraphItAll":
	GraphItAll()
	break
	case "AverageandSEMbyTypeWave":
	avgsemvswave()
	break
	case "Intersect":
	Intersect()
	break
	case "Isolate":
	Isolate()
	break
	case "ExecuteAllTypes":
	ExecuteAllTypes("")
	break
	case "ExecuteAllBatteries":
	ExecuteAllBatteries("")
	break
	//Other
	case "baselinerunchart":
	createbaselinerunchart();Textbox /C/N=legendary makereadablenames(stringbykey("TEXT",(annotationinfo("baselinerunchart","legendary",1))));modifygraph minor=1
	break
	case "BRCSEM":
	CreateBaselineRunChartSEM()
	break
	case "CustomBRC": //chops down a baseline runchart into the selected step range
	variable lowstep,highstep
	string newappend,avgsem
	prompt lowstep, "What is the first step to be graphed?"
	prompt highstep, "What is the last step to be graphed?"
	prompt avgsem, "Calculate Average/SEM?",popup,"No;Yes"
	doprompt "Custom Baseline Run Chart",lowstep,highstep,avgsem
	if (v_flag==1)
		Abort
	endif
	if (lowstep==highstep)
		newappend=num2str(lowstep)
	else
		newappend=num2str(lowstep)+num2str(highstep)
	endif
	ExecuteAllBatteries("duplicate/o "+vwavename+","+vwavename+newappend)
	ExecuteAllBatteries("duplicate/o "+curwavename+","+curwavename+newappend)
	ExecuteAllBatteries("duplicate/o "+totaltimename+","+totaltimename+newappend)
	ExecuteAllBatteries(vwavename+newappend+"*=((" + stepname + ">=" + num2str(lowstep) + ")/(" + stepname + ">=" + num2str(lowstep) + "))")
	ExecuteAllBatteries(vwavename+newappend+"*=((" + stepname + "<=" + num2str(highstep) + ")/(" + stepname + "<=" + num2str(highstep) + "))")
	ExecuteAllBatteries(curwavename+newappend+"*=((" + stepname + ">=" + num2str(lowstep) + ")/(" + stepname + ">=" + num2str(lowstep) + "))")
	ExecuteAllBatteries(curwavename+newappend+"*=((" + stepname + "<=" + num2str(highstep) + ")/(" + stepname + "<=" + num2str(highstep) + "))")
	ExecuteAllBatteries(totaltimename+newappend+"*=((" + stepname + ">=" + num2str(lowstep) + ")/(" + stepname + ">=" + num2str(lowstep) + "))")
	ExecuteAllBatteries(totaltimename+newappend+"*=((" + stepname + "<=" + num2str(highstep) + ")/(" + stepname + "<=" + num2str(highstep) + "))")
	ExecuteAllBatteries("wavestats/q/m=1 "+totaltimename+newappend+";"+totaltimename+newappend+"-=v_min")
	strswitch (avgsem)
		case "No":
		graphitall(ywaven=vwavename+newappend,xwaven=totaltimename+newappend,chartname="baselinerunchart"+newappend)
		graphitall(ywaven=curwavename+newappend,xwaven=totaltimename+newappend,chartname="baselinerunchart"+newappend)
		break
		case "Yes":
		avgsemvswave(ywaven=vwavename+newappend,xwaven=totaltimename+newappend,chartname="baselinerunchart"+newappend,semplot=2)
		avgsemvswave(ywaven=curwavename+newappend,xwaven=totaltimename+newappend,chartname="baselinerunchart"+newappend,semplot=2)
		Textbox /C/W=$("baselinerunchart"+newappend) /N=legendary makereadablenames(stringbykey("TEXT",(annotationinfo("baselinerunchart"+newappend,"legendary",1))))
		modifygraph minor=1
		break
	endswitch
	Label $vwavename+newappend "Voltage(V)"
	Label $curwavename+newappend "Current(A)"
	ModifyGraph axisEnab($(vwavename+newappend))={0,0.48},axisEnab($(curwavename+newappend))={0.52,1}
	Label bottom timelabel
	break
	case "TempStat":
	TempStats()
	break
	case "Cleanup": //kills loop counters to reduce file size on very large tests
	executeallbatteries("killwaves/z Loop_Counter__1,Loop_Counter__2,Loop_Counter__3,Data_Acquisition_Flag,Mode")
	executealltypes("killwaves/a/z")
	break
	case "DashedLine":
	string color="Red"
	prompt axisn, "Which axis should the line be drawn on?",popup,replacestring(";bottom",axislist(""),"")
	prompt inval, "At what value of that axis should the line be drawn?"
	prompt color, "What color should the line be?",popup,"Red;Gray"
	if (itemsinlist(axislist(""))>2) //no need to show unnecessary options
		doprompt "Add dashed line to "+WinName(0,1),axisn,inval,color
	else
		axisn=replacestring(";bottom;",axislist(""),"")
		doprompt "Add dashed line to "+WinName(0,1),inval,color
	endif
	if (v_flag==1)
		Abort
	endif
	strswitch(color)//Are more colors needed?
		case "Red":
		SetDrawEnv/w=$WinName(0,1) ycoord=$axisn,linefgc=(65278,0,0),dash=8,linethick=2.00
		break
		case "Gray":
		SetDrawEnv/w=$WinName(0,1) ycoord=$axisn,linefgc=(26214,26214,26214),dash=8,linethick=2.00
		break
	endswitch
	DrawLine/w=$WinName(0,1) 0,inval,1,inval
	TextBox/w=$WinName(0,1) /C/N=$axisn+"Caption"/A=MB/X=0.00/Y=5.00 "Add Caption Here"
	break
	default:
	break
endswitch
end

Function BBAHelp(ctrlname) : ButtonControl
 	string ctrlname
	DisplayHelpTopic/k=1 "Basic Battery Analysis"
end

Picture Logo
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!"L!!!"D#R18/!':/V^An66)0A;LFAm*iFE_/6AH5#,Ddm9#8SqmKAQ!
	)JA9i1:ANTqm"!_MZ=EIY>9KH[%D(]7-Ddm91G\qC"z4?n(0@:O(aF<G%(B5)6H,4E.Y+s:T14X*rb
	9e]:\6Y0qF8:#;f;gM2<@sVp#3Fj<u4s2t43d>L\D.Rft+F%a>DK@j`4X+<FDdm9=DK@jUATV?6+s;
	+kG\qDACHWk-A8bpg+BV?7+@C'fAKWi_2(`;l0f1"33A*$D0f1jE/0H]%0f(I:1G:I=/MT"A0KD0K2
	'="a+<VdL+<iul4E=tE3`8@8+F%a>DK@jZA7dtKBQS?83\N.1GBYZ`1G3TdB.ku"3B8`H1+tC</TPB
	6/TZ2TFCBDGDK@$H4s2t.A7dkjATM@%BlJ0.Df-\<A7dl2@W-C24X)'mG\q87F#nP_E'5CYFEDI_0/
	%3a/n&:/@V%0%Df%.P@;mkS/heq&+F%a>DK@j`D/`3D4X+Q]FDs8o05bh`@:X:cAM.J2D(g-BE%`pu
	0J@9[0-VN`D/=*23cfC@AS+(LBQS?83\N.(F"Um3Ddm91@rH3;G[YPE0eP.5F&[F(AM6qmF)Q2A@qA
	PLAg8KBG\qC\6ZQaHFDl2!Df9GT,!faX@V$ZYBQ&!2F(fK2+@AL=-r",[Bl8$2F(d!H+F%aB9hdZ?D
	KBo.DI[6L6p2`=D/_+ABk07Z1cI?Q75Zeh0fCdA0h!iX68D"i0K)?Z2`F&`6UO9d+F%aB9hdZ:De!p
	,ASuT]6p2`=D/_+<Bk07Z1cI?Q75Zhi0fCdA0h!iX68D"i0K)?Z2`F&`6UO9d4s2t4D/`3D3^dP"Bm
	+&u7WNEa+EMX&AS*u;DKBo.DI[6L6p2`=D/_+ABk07Z1cI?Q75RJ'0fCdA0h!iX68D"i0K)?Z2`F&`
	6UO9d+EMX&AS*u6De!p,ASuT]6p2`=D/_+<Bk07Z1cI?Q75Zbg0fCdA0h!iX68D"i0K)?Z2`F&`6UO
	9d00UL@061T83^dP#@rc:&FD5Z24s2s@Eb&cC;FEu<+?V<%3d>L\D.Rft4s2sPG]7)$CLqT1ASu$A,
	'"kl51<0$;ucn1]h(UX<-[-`SU5>+`>-EPQWG;a5`do1-mBe4<,,VhIh]"_'[^A3<3S>W[G'?7'r-;
	l@P(-QXc=FO[aOGs0C!&I[;*`Ce.Jqm[1l"0%Bfau8-n0#8btUGI2=fNQfR#Yhu2B;+Zjc-Q^cTFn"
	.js4aVX)cHS)8[LQe[jkt/"j;(9NaGbO#cWOXZ>"UBe6cJf<ANo0q81p\>EZ!4>nda_"!26,U[ET*[
	-sdTO"*,1<!#<6b;TiE]%I$G$-38]7>L_t!!)Ru*/or/!+bc"@OE/F9#6(]cZ5@Ts5cABoZY'8'nR'
	,okE)l6C8gbsI[s0UV)?m8\I]=RdI=kr9q9lXQe9m.F/rIEpj],u$,73q4es_G/nTQ^'E;VPdL@CQ4
	qeLObG+"B,LGUnq3h]tSo4WP;#DG@IK:;oBgnkV</5RRI"Li/X[,BD8f+.Y\5VWZTZ*(:i"G^IpaQ9
	;k-tNoMP#LD<6,Wl4q:>b9V^nr:'LhSA5Mfoi?Hib%"U%/mnt187.l(X-K"uX%uqS/T_Ndho6JVts#
	d%1(V6q+9Eu/e^BU$s5mA\CFGsF*)2GbQT_Na4TS`hMmVLjVD!pX/!shr(U%E5-^91!/kS#)p+Y+]P
	!JF`U%RquW$>@cY0H8.nFM]qVi)]p"ktP"P=GR*N8g+iSoENC^-<N'\AX%-_/A_@Wctk96*PSqCO0]
	*W+pW)k*Q6bC-s`@PR?/jSh:APeR"6Pu$08]q3/CF9JDkUg1aq6XM)+s_MH'YLQR,K+foWsGff+!#C
	g`4\@*&9qK5?-uQRhKN7WSZ>-iq]EUd(?Z2#J4&[%lXX6:B5i66n7m%Itr6aQ1Q-81;HTGRo4ih4+H
	^(no!BC6Q'8#0VOfeJBn^oa07Hr=Sb"Q54';A-O0$+*(h3!8o,V(;PnE\D&ppc5k&JJ$"?J)BHb7q$
	oYC`>1]=E1OdCPe_%#."Ut]5k$>"N*ZQ^W7V0Y@;N`f50@9h9a>YX*Q0*b!g'U5$/"=Om]Ndtej5N;
	`ZhSdJ9TfbQZe7QJ2VNED!S/:elqnsgO-=-_qFj#`>7B!kB3A:=?$$[^bE_0C'Skr@fQZ86M#6*_)D
	@K.NVE3Cb$+3Q$b`XQE!D/XQt69i+1q*lHm83kNmDoQ.EZQ?s!405[WUQlucX,Wk>NIlf,J3=b(D4S
	LX@oquGgYKGKl6&qJ9M#BdZM\sIG>p\5#Ep2/>LkB0kfYjV&hJ.?(%j`-B1fiE5n%dR0Q/AOMgWG3+
	Li-Nr@Q,?eb)Z\^(cd#HOW;j#)r$TeVa`5]:^fmoA_#F0f>U4I(LBE1/D&&L6+0u!K>,;5+#qH2kW=
	oOC,YR9)Y,u^uUn&\0%\S;PiI_ijI[N/."BqK;JBgTYnfdTIlQA,G&1fcVF7r[0&/a].E*G38kWZ@O
	]lil#d]gu'=Gh<d+=3=+VcY"UpTMMXbjP:".fk2`b.JEM"%i<;Ljm/uPF\V)1#Cf9ZI[@c5.%UKliB
	XYl)c,X+>SaG+X=Kk&PmNsYO]BOpmj."20]OrrnMtqO4Za_j[Tf.aR]^pWr48^;WK91U>dP:W6)/%B
	dc05,Y5Ce0gRYc:QT@"%;MCm_;2WVAqG+#T4Q(EPP6OSOp\-m3UT$L+MQk7&p=<H?CimffmF+9lrF7
	>*2tI)&hl(V!'p(R-:,5f(2f3klp<tAeq)aq>[F:7+?pAel(SWP?GM"R%@I^FmqCpG!5`r!q#auA;m
	Is1eTql/N/nYQ-p<M789`alKc?lkJcuVeD5j1J+j@Y__B^R9EmeS$Pl>>Gs+&4`iiin;"PKsEd2VW^
	!4Y$%!2+Qcg+^\Q#:'e"[dO[I7-Bct]#n=ZTu$ihHas"!"HgT$*5kn'CmVp4/*%0g5-;U,5e+u?`?+
	_bE/@0kBSiM^(]Z,2(][BY'M4ChH1!ui3Y;q9j?Oio:BF(b-SbL=3SO]e3C>G%F:T'-Rb7lJ,Ig,VL
	:fo#$hRlas10m_aE&??9-U*tj0+SaldS?8^UI@NO$g(1EtFBiqdNNL-P"Wj9i*D3X\<l##oQO-TLN?
	:*Q7YNH9Sg:^P1GN`J<l:\,\(tjU?%_p1M4[=U.f9qaH$CN<@!&Re+gX5g3Y,.R:G+;?X!TWfAi'CJ
	i._U'l(%5Ym$\Qc8u6^ME:sPrr;V'/fh0kV-SSb%A?0?@ZFT"$p]`LmLH(VG8k1r`llmb%/au3GGpk
	qFA\+Bl0hk!P46EjOm@WAXq31rC]k]la^h,#6YFO"CO1?=Ud7Tl;dP8EtDiMME`kEHTK2a8!4@VN;E
	o\]Yl)V1idT1dW&*2U+0od2"&,s=osA70E@1Gm2"/i(!`bQ?:RW&!Wod+?NIuGFO7TUiZP[QS@Z:X"
	H_@O`V-##X#]4$'lU'15(MS1-3F80([qXpN4qXuej18b#i8Mh6&Z<5"Iem:kJnT&g[dDE^IkkuK@3Q
	VD#\YcnWnKtEDuN>/-+]*^MZA12TS-&^nos27X8L+Va#3<X#SjL3PMsgnZ*<OILP6gkKnNSR+)IWeL
	QUe#hGdY^l@+NQ7*bT3N(aV!,OJ51dFmY?&P4*Q7&73T_O.Z8f(!!Wh3W3;S8it!t>OuV#nF7ZN$d4
	TWQ=>2ZV!]R:ag=p^o@SUGEU&E?46t!+C(]K.F(=d<u5eJEKN@Gf@i)P[hCnk'CA=DHFq>N]b)/LjM
	o%"OB#;2Pb&fL>fR;'-XZSr.S+m0=f]D7Aoijn@!5rZR+hQ'85kB!,,/]f]fXAQpLd@n[ftdk;%WCJ
	_"5]YlH1+]$J3XH91rX1!gTb'@`ndHDPW/Vs0$<k[8M)KA5VSlp&DOW/=J?T0o3FbQ.k869<^!J/uE
	s7XlW#LRnR?XX]34)Kui;Qlq8Nb8a$/&.uAp7X&S%Vdi2?kn]`oZ-lPN:/O-^ig1W#!)?P^!*8Q[^N
	>C3!;',P[ZrSB3sa?UAERo(=KS(`Yq6UhH7F+=b<6%pHW?;.!MG?k1UY,1!7Y(=Z00IjS#OXrC7b<=
	mDUF($NR^aj<W-74'CS-m/M[b?YjbB!-"P:&i@0<I@hf:Sb+cF1u.:J2YfWI>:dnfq^Q<FW*ih@(>u
	s!!\dH]q)<>7W:!dg+HWqmP'?VD6D1#k6]CTMVZ:B`1pPpJZ69@++;^O*Lf-EfBU-P3epXuW'UA/%J
	DSG>lTOn@E'RN9Je4eAJa6sCYO%Op_36;$4!&;@:K234FsR9A&<oNB)1bc4kRiAu.$g`lAlGj1ZsaO
	B0Zml*3[qN<>E0#?"2_/eW9eZZA>ZY6HNGOj>3(LhSWJlAmhLq,`p`%YZ,oK0s%pZ)c:+MH*'XfC+$
	kp"V%]FpQiouNZsG76RO!"WDPK5*]PRT-n+r^QIb3H0h<7(5nPN0a=9fG)9*%@?Q+c1@+<Q9\Nd(&e
	F9tYXS)@5UoBE?to(+bgFtXsdnpgc<(g-_SMl+u0lH\eV@+0AZL4i-[;#9biB"ORsQWaCPd!66Sj(?
	?a$5jHn3ZfJ\=)7m_K39sr99"sBgN]:1&V(oK%i9.[Vb5Th',6?s<7rd1&u7LRECq#qVEoYrjmFi4B
	?.C=mtl>'%M1b"(kRL^-_!g]EF1-/Fd"@A*!BWejY'U*2CbY3&gW^U0YqRl0WCj#?,1C3,fjNVk+1]
	P84N"MJ=n*]\^T&BZ18'Bf/O>3_t!!4nN!P@RrSM=!!%+7)ZW34.sm-+'1LCs5sk+Bj-21&p4na!\O
	KV>[dQkAjIVlMirHp$/1UWm';TuGDh>im(BB+?KV31<%WiO^'`U/n3%5OA*"\p-_'`(WkAcCJc.RQ6
	$(a95fcGm'S3oplDsGr)i79;h4"aD9q'KuhX8'EqB+Ebu#Te,i5uT;+KcP)o;bA,4J<?N,OMK(Ic@,
	YZoE/WC16it*99)!0+4EM,c(O(n''Sk-C_HhT^u1WFOLYcB*$b[CBH`/"B^6/J=&GFo!1q==!)U>h^
	eHQ"E@C/&*K#YjlQG$a#Sr,qGU\e)l.j/_[&qtXgW1!Rd#SD7D`QAkMUK"kWi/XEinobTTj]Fc*=$5
	4M6=ePYoL\`(d'jDL=-GHPIQeUf?X)#s/3Ish%'d/E?N>%Bj<UREhnR2'OQ-e%Yb:?GeM:6MR1"H3A
	UI3_-8?<?Hu&3g&#j$<neVnVU![$Zqf1<guLGN@?ed>nWj6FHhmH+@OV2cAH"8V!2R\hD#6Cr'(@k9
	qZ+GaN@8'P\(`4C@"P;=[UMa/[0^$a:QbPP";!]T=G)HP&-]<*.6,E=nJ2G8'g_@o;]2Ab!OrB$*uS
	>h3UQ0s\A[TU#8)i[ZM,!=\]?$tp-.;E*CPa]Nf.riP:]Jq(7eV^nJ9259dq,$2?6C[(Y0A![16X\!
	9d1s9+XaR17i)U07+el&llnV_G\Dm1fPCFc?@+]KZs-il$A4q2Q\&4>tsM,?,L6alHeR,Mhs?(02CR
	t:;Adgj8JZV:oN_;CpgKr>hcl[UCW`&$ec3-GB(4:[qeO%9m`]K2p#S1f?J-&g8X0B(\"R4"L8/Y*S
	+UC'J"kWqTqO@_upf@V)7NXR2D/B>A#um=oiToIk<*hZM_f&$n3Y"&O<i4&1iL?V/P5o#W_Z@@h4a>
	?39\VmUK(_iiJE21OHDqD5A?F+<YnLP05-pUJDIh!rrh(9nh#C&9<2h2m*V@$MjsI(@o0fDA]5S(eK
	lJT7U2Z\!>BTXU\3Oq?Fb"7X$>H=FaE,!hM^h>k<!DhDYF0<PAR6/XudM%8goEMfe%,VG@3a2]eb]Y
	miGalQWJ)%0/%ZU"BPfh1ZfJYn\ha%05dp:p*`nq#d@fYE;7"_ZW5O.[9g`XJ^)@bC'N/Mc;+50$7V
	Yi=u?H7?`$9:K!n=:/Kg!c+[>25t6>RP`5^bf=B%jJ.93nE3]`'WYKnEf]]9lh%6Z'I078c*,hs$5c
	^G\6Hup#XTeK\DZIjUn<Md8jXV<I2u@9m@e8K73a(\^!17&4eET[R8G&-k5S"P-UZSeh<LT8T\u2Oh
	$gum?Rg$#=aIuF%S>`)<aAoaPlD#>L8.X4'5"bp-3&(;*n56&<fS*IO!$tde4UBKRkRI]]Gms`sW.B
	?R"<#+OJA-DP;)L@VgQgo-Pl4!T$m8?n&f#<c[WrC6"2[]1IM<9dc&V&+?&?f%M<I;Mj;I.TjE$K.Y
	s7Uj>(B>l"optd!Ke(sgG@n5b,g`PY+5'Jk7KAgf=:"3EJgr8E3M7I1.]\qDuOU6+q(V=ar<hH`X@\
	O8]4H2?[C,LV;pso<P%+is3q0/%3L\n-eX!rC$N&59lT`.QDmac^4AO3"ctpq/--jr1AcP3\]P&sOL
	nDt=<0ENV=0RR2%</bdFA-q!a1h"WB/?Fc"bNnlTg@b$imAH[K&90N5=U)Y'\nAR=4JHd/jQF&YQb/
	psA`XEZX*@3J*EV,>l?,;VU6\]`dOlgc@gI('$ZD$C*aQ06>Jjj8,(f_%?[56fpYuY@OXtJ3Zj:]uH
	J-mLj)o"F:<(0"-V2c.3,5!!GmLQ6Js,\1Cb$=)j56",`0+"/GsL-tE\^,5^rbON-!TltAbZB0kdcA
	TR4gHpS)]Yd7-6B2T0/T!6DNU^2N^3A1]T6#:%k<pYp,h^9R'TQh3DLp$+i@d6S)6LhZEoE>fed6Sc
	&":$ZBMO.Ft,c&Y>da])@<!Rrn"qYZ/_%Y/7*5km<;g4Vug]>BpXaJt,5k5IWn48Elo];7o3f*/`gE
	e0i\U@?]q`ZG-YkIhA!^Q#n4D]V1eL@D'@*@C[j_S;le,*h[TP4srVLp9Q>ft:7K]9%[HnYL5?i[*1
	76cAJFERWa!!#SZ:.26O@"J
	ASCII85End
End