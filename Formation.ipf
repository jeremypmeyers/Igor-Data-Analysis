function Formation()
setdatafolder root:
string comparechart = "baselinerunchart"
excludeBaddata(comparechart)
setdatafolder root:
avgsemvswave(ywaven="Voltage",xwaven="RunTime",chartname="FormationAvgbyType")
avgsemvswave(ywaven="Current", xwaven="RunTime",chartname="FormationAvgByType")
Label /W=FormationAvgByType VoltageAvg "Voltage (V)"
Label /W=FormationAvgByType CurrentAvg "Current (A)"
firstpopulatedfolder(setf=1)
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
firstpopulatedfolder(setf=1)
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
