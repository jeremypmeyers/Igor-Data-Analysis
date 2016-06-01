//First function "batanalysis()" is user prompt for automated battery analysis.
//Presently has 7: formation, boost, cap measurement, cranking, charge acceptance, cycling.
//User can also opt out of automated analysis and move to data exploration.
//
//The actions initiated by each button select are shown immediately below.
//

function PbAnalysis()
//Creates window to prompt user for which automated procedures to run, depending upon the
//type of experiment. 
	NewPanel /FLT /W=(100,100,385,360) /N=AnalysisWindow as "Analysis"	
	ModifyPanel cbRGB=(32000,32000,32000), fixedSize=1
	SetDrawLayer UserBack
	DrawPict /W=AnalysisWindow /RABS 3,15,283,41, procglobal#mrdwordmark
	TitleBox  titleb,font="Arial",fcolor=(65535,65535,65535),fsize=16,pos={62,54},frame=0,title="Select experiment to analyze"
	Button pb font="Arial",fsize=14, pos={55,76},size={200,14},title="Formation",proc=form
	Button lib font="Arial",fsize=14, pos={55,94},size={200,14},title="Boost",proc=bst
	Button echem font="Arial",fsize=14, pos={55,112},size={200,14},title="Capacity measurement",proc=capmeas
	Button inst font="Arial",fsize=14, pos={55,130},size={200,14},title="High-rate discharge/cranking",proc=crank
	Button por font="Arial",fsize=14, pos={55,148},size={200,14},title="Charge Acceptance",proc=chargeacc
	Button cyc font="Arial",fsize=14, pos={55,166},size={200,14},title="Cycling", proc=cycl
	Button none font="Arial",fsize=14, pos={55,184},size={200,14},title="No automated analysis", proc=none
	DrawPict /W=AnalysisWindow /RABS 2,204,279,254, procglobal#bdslogo
end

function Form(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing formation data\r"
killwindow AnalysisWindow
Formation()
end

function Bst(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing boost data\r"
killwindow AnalysisWindow
BoostCharge()
end

function CapMeas(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing capacity measurement\r"
killwindow AnalysisWindow
end

function Crank(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing high-rate discharge/cranking experiment\r"
killwindow AnalysisWindow
CCA_HRD()
end

function ChargeAcc(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing charge acceptance experiment\r"
killwindow AnalysisWindow
end

function Cycl(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing cycling experiment\r"
killwindow AnalysisWindow
end

function None(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Manual data analysis; no automated procedure selected\r"
killwindow AnalysisWindow
end

//The following functions Formation() and FormationTopofCharge() is used to analyze formation data.


function Formation()
//Assumes that all batteries are subject to identical formation profiles, and plots voltage and current
//vs. time.
	setdatafolder root:
	string comparechart = "baselinerunchart"
	excludeBaddata(comparechart)
	setdatafolder root:
	avgsemvswave(ywaven="Voltage",xwaven="RunTime",chartname="FormationAvgbyType")
	avgsemvswave(ywaven="Current", xwaven="RunTime",chartname="FormationAvgByType")
	Label /W=FormationAvgByType VoltageAvg "Voltage (V)"
	Label /W=FormationAvgByType CurrentAvg "Current (A)"
	gotofirstpopulatedfolder()
	svar timeunit
	setdatafolder root:
	Label /W=FormationAvgByType bottom "Time ("+lowerstr(timeunit)+")"
	modifygraph /W=FormationAvgByType axOffset=0
	modifygraph /W=FormationAvgByType freepos=0
	cleanaxes("FormationAvgByType")
	Vformationaxisrange("FormationAvgByType","voltageavg")
	modifygraph /W=FormationAvgByType axisenab(voltageavg)={0,0.8}
	modifygraph /W=FormationAvgByType axisenab(currentavg)={0.85,1.0}
	doupdate /W=FormationAvgByType
	notebook recording text="Standard formation chart \r"
	notebook recording picture={FormationAvgByType,0,1}
	notebook recording text="\r"
	formationTopofCharge()
end

function formationTopofCharge()
	gotofirstpopulatedfolder()
	
	string commandstring = ""
	commandstring += "differentiate voltage /X=runtime /D=dvdt;" //differentiates v vs t to find rate of max increase
	commandstring += "wavestats /Q /R=[(numpnts(dvdt)/10),(numpnts(dvdt)*0.98)] dvdt;" //determines rate of maximum rate of increase after initial current
	commandstring += "variable /G timemax=runtime[v_maxloc];"
	commandstring += "dvdt = abs(dvdt); wavestats /Q /R=[v_maxloc,] dvdt;"
	commandstring += "variable /G tocv = voltage[v_minloc];"
	commandstring += "Killwaves dvdt"
	executeallbatteries(commandstring)
	AverageandSEMbyTypeVariable(varname="tocv",chartname="TopOfChargeChart",oktoadd=1)
	AverageandSEMbyTypeVariable(varname="timemax",chartname="TopofChargeChart",oktoadd=1)
	Label /W=TopOfChargeChart TOCV "Top of charge \r voltage, (V)"
	gotofirstpopulatedfolder()
	svar timeunit
	Label /W=TopOfChargechart timemax "Time to top \r of charge, ("+lowerstr(timeunit)+")"
	setdatafolder root:
	cleanaxes("TopOfChargeChart")
	doupdate /W=TopofChargeChart
	notebook recording text="Estimated top of charge characteristics \r"
	notebook recording picture={TopofChargeChart,0,1}
	notebook recording text="\r"
end

function Vformationaxisrange(chartname,axisname) 
//chartname is the name of the chart whose voltage axis we wish to crop.
//Because formation starts off at zero volts, autoscaling all data points can
//make it difficult to discern the details of characteristic voltage signatures.
//This function finds the minimum to which the voltage drops after the initial peak,
//and restricts the lower axis limit to 95% of that value.
string chartname,axisname
string tl=TraceNameList(chartname,";",1)
variable minr=1e9
variable i=0
do
	string tn=stringfromlist(i,tl)
	if(strlen(tn)==0)
		break
	endif
	string ti=traceinfo (chartname,tn,0)
	string ax=StringByKey("YAXIS", ti)
	if (cmpstr(ax,axisname)==0)
		wave w=tracenametowaveref(chartname,tn)
		wavestats /q /R=[(numpnts(w)/20),] w
		minr= (v_min<minr) ? v_min : minr
		print i,minr
	endif
	i+=1
while(1)
minr *=0.95
SetAxis /W=$chartname $axisname (minr),*
end
//end functions related to formation

function boostcharge()
//Generates plots and updates notebook for boost: shows voltage, current, and capacity 
//and calculates average and SEM for boost charge quantity for each type.
	setdatafolder root:
	string comparechart = "baselinerunchart"
	excludeBadData(comparechart)
	svar vwavename,curwavename,capname,totaltimename
	avgsemvswave(ywaven="Voltage",xwaven="RunTime",chartname="BoostByType")
	avgsemvswave(ywaven="Current", xwaven="RunTime",chartname="BoostByType")
	avgsemvswave(ywaven="Capacity",xwaven="RunTime",chartname="BoostByType")
	Label /W=BoostByType VoltageAvg "Voltage(V)"
	Label /W=BoostByType CurrentAvg "Current(A)"
	Label /W=BoostByType CapacityAvg "Capacity (Ah)"
	cleanaxes("BoostByType")
	string runtimelabel = gettimelabel()
	Label /W=BoostByType bottom "Time ("+lowerstr(runtimelabel)+")"
	notebook recording text="Standard boost chart\r"
	doupdate /W=BoostByType
	notebook recording picture={BoostByType,0,1}
	notebook recording text="Boost capacity comparison\r"
	ExecuteAllBatteries("wavestats /Q capacity; variable /G boostfullcharge=v_max")
	AverageandSEMbytypeVariable(varname="boostfullcharge",chartname="boostcapacitychart")
	Label /W=BoostCapacityChart boostfullcharge "Boost Charge (Ah)"
	doupdate /W=BoostCapacityChart
	notebook recording picture={BoostCapacityChart,0,1}
	notebook recording text="\r"
end


function CCA_HRD()
string CCAtype
string CCAmenustr="EN;JIS cold crank;JIS high-rate discharge;SAE;Custom protocol"
prompt CCAtype,"Select cranking protocol", popup, ccamenustr
doprompt "CCA/high-rate discharge protocol",CCAtype
strswitch(CCAtype)
case "EN":
	notebook recording text="EN cold crank specification\r"
	break
case "JIS cold crank":
		notebook recording text="JIS cold crank specification\r"
		JIScoldcrank()
	break
case "JIS high-rate discharge":
		notebook recording text="JIS high-rate discharge specification\r"
	break
case "SAE":
		notebook recording text="SAE cold crank specification\r"
	break
case "Custom protocol":
		notebook recording text="Custom protocol\r"
	break
endswitch


end

function JIScoldcrank()
string commandstring
commandstring = "wavestats /q current;"
commandstring += "variable /G fullcrankstep=stepid[v_minloc];"
commandstring += "duplicate /o current c60pc;"
commandstring += "c60pc = current[p]>0.7*v_min && current[p]<0.5*v_min ? c60pc[p] : NaN ;"
commandstring += "wavestats /q c60pc;"
commandstring += "variable /G partialcrankstep=stepid[((v_minloc+v_maxloc)/2)];"
commandstring += "killwaves c60pc; killwsv();"
executeallbatteries(commandstring)
commandstring = "duplicate /o steptime stfullcrank, stpartcrank;"
commandstring += " stfullcrank[] = (stepid[p]==fullcrankstep) ? steptime[p] : NaN ;"
commandstring += " stpartcrank[] = (stepid[p]==partialcrankstep) ? steptime[p] : NaN ;"
commandstring += "findlevel /Q /P stfullcrank,(10/60) ;"
commandstring += "variable /G v10sec=voltage[v_levelx];"
commandstring += "wavestats /q stfullcrank;"
commandstring += "variable /g timefullcrank = V_max*60;"
executeallbatteries(commandstring)
commandstring += "wavestats /q stpartcrank;"
commandstring += "variable /G crankduration = (v_max*60 +timefullcrank/0.6);"
commandstring += "print timefullcrank, crankduration, crankduration>90"
executeallbatteries(commandstring)
end