#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function boostcharge()
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

function capacitymeasurement()
setdatafolder root:
string comparechart="baselinerunchart"
excludeBadData(comparechart)
svar vwavename,curwavename,capname,discapname,totaltimename
createsinglestepselectionchart(-1)
NewPanel /N=stepcheck /Ext=0 /HOST=stepselectionchart /W=(1,1,500,300) as "Step selection"
string /G ts="Confirm that the 'A' (circular) cursor is resting on the step index \rcorresponding to the capacity measurement step and then\rhit the button to proceed."
titlebox explanatory win=stepselectionchart#stepcheck,frame=0, pos={25,25},size={250,100},fsize=16,variable=ts
button accept win=stepselectionchart#stepcheck, pos={125,200}, size={250,50},title="Confirm step and proceed",fsize=16, proc = capstepprogrammed
pauseforuser stepselectionchart#stepcheck
nvar capstep
capmeasurement(capstep)
AverageandSEMbytypeVariable(varname="capmeasured",chartname="DischargeCapacity")
Label /W=DischargeCapacity capmeasured, "Capacity (Ah)"
end


function coldcrankingamps()
setdatafolder root:
string comparechart="baselinerunchart"
excludebaddata(comparechart)
svar vwavename,curwavename,capname,discapname,steptimename
nvar timeunits
createsinglestepselectionchart(-1)
NewPanel /N=stepcheck /Ext=0 /HOST=stepselectionchart /W=(1,1,500,300) as "Step selection"
string /G ts="Confirm that the 'A' (circular) cursor is resting on the step index \rcorresponding to the discharge step and then\rhit the button to proceed."
titlebox explanatory win=stepselectionchart#stepcheck,frame=0, pos={25,25},size={250,100},fsize=16,variable=ts
button CCAaccept win=stepselectionchart#stepcheck, pos={125,200}, size={250,50},title="Confirm step and proceed",fsize=16, proc = CCAstepselect
pauseforuser stepselectionchart#stepcheck
nvar ccastep
ccameasurements(ccastep)
AverageandSEMbytypeVariable(varname="Vcca30sec",chartname="V30sec")
Label /W=V30Sec Vcca30sec, "Voltage at 30 seconds of discharge (V)"
AverageandSEMbytypeVariable(varname="CCAdurationMin",chartname="CCAduration")
Label /W=CCAduration CCAdurationMin,"CCA duration (minutes)"
end

function coldchargeacceptance()
setdatafolder root:
string comparechart="baselinerunchart"
excludebaddata(comparechart)
svar vwavename,curwavename,capname,discapname,steptimename
nvar timeunits
createsinglestepselectionchart(1)
NewPanel /N=stepcheck /Ext=0 /HOST=stepselectionchart /W=(1,1,500,300) as "Step selection"
string /G ts="Confirm that the 'A' (circular) cursor is resting on the step index \rcorresponding to the charging step and then\rhit the button to proceed."
titlebox explanatory win=stepselectionchart#stepcheck,frame=0, pos={25,25},size={250,100},fsize=16,variable=ts
button coldchargeaccept win=stepselectionchart#stepcheck, pos={125,200}, size={250,50},title="Confirm step and proceed",fsize=16, proc = coldchargestepselect
pauseforuser stepselectionchart#stepcheck
nvar coldchargestep
coldchargemeasurements(coldchargestep)
AverageandSEMbytypeVariable(varname="Current10min",chartname="ColdCharge10min")
Label /W=ColdCharge10min Current10min, "Current at 10 minutes (A)"
AverageandSEMbytypeVariable(varname="TotalColdCharge",chartname="TotalChargeAcceptance")
Label /W=TotalChargeAcceptance TotalColdCharge,"Total charge accepted (Ah)"
end

function coldchargestepselect(ctrlname) : buttoncontrol
	string ctrlname
	setdatafolder root:
	variable /G coldchargestep = vcsr(A, "stepselectionchart")
	killwindow stepselectionchart#stepcheck
	killwindow stepselectionchart
end

function CCAstepselect(ctrlname) : buttoncontrol
	string ctrlname
	setdatafolder root:
	variable /G ccastep = vcsr(A, "stepselectionchart")
	killwindow stepselectionchart#stepcheck
	killwindow stepselectionchart
end

function coldchargemeasurements(coldchargestep)
variable coldchargestep
setdatafolder root:
svar /Z capname,stepname,steptimename,vwavename,curwavename
nvar /Z timeunits

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
					wave steptime = $steptimename
					wave step = $stepname
					wave v = $vwavename	
					wave a = $curwavename
					wave cap = $capname
					duplicate /o steptime steptimeCCA
					steptimeCCA *=((step==coldchargestep)/(step==coldchargestep))
					steptimeCCA *= 60^(timeunits-2)
					duplicate /o cap capCCA
					capCCA *= ((step==coldchargestep)/(step==coldchargestep))
					wavestats /Q capCCA
					variable /G totalcoldcharge = v_max
					variable i=1
					do
						if ( (numtype(steptimeCCA[i])==0) && (numtype(steptimeCCA[i+1])==0) ) 
							if ((steptimeCCA[i]<=10) && (steptimeCCA[i+1]>=10))
								variable /G current10min = (a[i+1]-a[i])*(10-steptimeCCA[i])/(steptimeCCA[i+1]-steptimeCCA[i])
								current10min /= (steptimeCCA[i+1]-steptimeCCA[i]) 
								current10min += a[i]
								break
							endif
						endif
						i+=1
					while (i<numpnts(steptimeCCA))
					waveclear steptimeCCA
				
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


function ccameasurements(ccastep)
variable ccastep
setdatafolder root:
svar /Z capname,discapname,stepname,steptimename,vwavename
nvar /Z timeunits
if (svar_exists(discapname))
	string capacityname = discapname
else
	capacityname = capname
endif

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
					wave steptime = $steptimename
					wave step = $stepname
					wave v = $vwavename	
					duplicate /o steptime steptimeCCA
					steptimeCCA *=((step==ccastep)/(step==ccastep))
					steptimeCCA *= 60^(timeunits-2)
					wavestats /Q steptimeCCA
					variable /G CCAdurationmin = v_max
					variable i=1
					do
						if ( (numtype(steptimeCCA[i])==0) && (numtype(steptimeCCA[i+1])==0) ) 
							if ((steptimeCCA[i]<=0.5) && (steptimeCCA[i+1]>=0.5))
								variable /G Vcca30sec = (v[i+1]-v[i])*(0.5-steptimeCCA[i])/(steptimeCCA[i+1]-steptimeCCA[i])
								Vcca30sec /= (steptimeCCA[i+1]-steptimeCCA[i]) 
								Vcca30sec += v[i]
								break
							endif
						endif
						i+=1
					while (i<numpnts(steptimeCCA))
					waveclear steptimeCCA
				
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


function capmeasurement(capstep)
variable capstep
setdatafolder root:
svar /Z capname,discapname,stepname
if (svar_exists(discapname))
	string capacityname = discapname
else
	capacityname = capname
endif

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
					wave capwave= $capacityname
					wave step = $stepname
					duplicate capwave capstepw
					capstepw *= ( (step==capstep)/(step==capstep) )
					wavestats /Q capstepw
					variable /G capmeasured
					if (v_max>0)
						capmeasured = v_max
					else
						capmeasured = -v_min
					endif
					killwaves capstepw
					waveclear capwave,step
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



end

function capstepprogrammed(ctrlname) : buttoncontrol
	string ctrlname
	setdatafolder root:
	variable /G capstep = vcsr(A, "stepselectionchart")
	killwindow stepselectionchart#stepcheck
	killwindow stepselectionchart
end


function CreateSingleStepSelectionChart(stepsign)
variable stepsign
setdatafolder root:
svar /Z vwavename,curwavename,capname,discapname,cyclename,stepname,steptimename,totaltimename,timelabel
gotofirstpopulatedfolder()

	wave step=$stepname
	make /N=25 /o stepnumbers
	stepnumbers=0
	variable lastpoint = numpnts(step)-1
	variable multiplecyclesfound=0
	variable stepindex=0
	do
		variable index=1
		do
			if ((step[index]==stepindex) && (step[index-1]!=stepindex))
				stepnumbers[stepindex]+=1
			endif
			wavestats /Q stepnumbers
			if (v_max >2)
				lastpoint = index
				multiplecyclesfound=1
				break
			endif
			index+=1
		while (index<numpnts(step))
		if (multiplecyclesfound==1)
			break
		endif
		stepindex+=1
	while (stepindex<25)

wave timewave = $totaltimename
wave V = $vwavename
wave A= $curwavename
display /N=stepselectionchart
	appendtograph /W=stepselectionchart /L=step step[0,lastpoint] vs timewave[0,lastpoint]
	appendtograph /W=stepselectionchart /L=V V[0,lastpoint] vs timewave[0,lastpoint]
	appendtograph /W=stepselectionchart /L=A A[0,lastpoint] vs timewave[0,lastpoint]
	wavestats /Q /R=[0,lastpoint] A
	print "steps",A[v_maxrowloc],step[v_maxrowloc],A[v_minrowloc],step[v_minrowloc]
	if (stepsign>0)
		Cursor /W=stepselectionchart /P /A=1 a, $stepname,(v_maxrowloc)
	else
		Cursor /W=stepselectionchart /P /A=1 a, $stepname,(v_minrowloc)
	endif
modifygraph /W=stepselectionchart axisontop=1
modifygraph /W=stepselectionchart axOffset=0
modifygraph /W=stepselectionchart freePos=0
modifygraph /W=stepselectionchart axisenab(V)={0,0.3}
modifygraph /W=stepselectionchart axisenab(A)={0.33,0.67}
modifygraph /W=stepselectionchart axisenab(step)={0.7,1}
modifygraph /W=stepselectionchart grid(step)=1

label /W=stepselectionchart step "Step index"
label /W=stepselectionchart A "Current (A)"
label /W=stepselectionchart V "Voltage (V)"
label /W=stepselectionchart bottom timelabel
ModifyGraph /W=stepselectionchart lblPosMode=1
ShowInfo /CP=0 /W=stepselectionchart
setdatafolder root:
end
