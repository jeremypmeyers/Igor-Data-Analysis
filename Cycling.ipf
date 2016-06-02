#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function Cycling([cleancycles,chargesteps,dischargesteps])
variable cleancycles
wave chargesteps,dischargesteps
string comparechart = "baselinerunchart"
excludeBadData(comparechart)

setdatafolder root:
svar /Z vwavename,curwavename,capname,discapname,cyclename,stepname,steptimename

if ((paramisdefault(cleancycles)) || (cleancycles==0) )
		CreateCycleChart()
		NewPanel /N=cyclecheck /Ext=0 /HOST=cyclechart /W=(1,1,500,300)  as "Does the cycle data appear to be intact?"
		
		popupmenu cyclecheckmenu win=cyclechart#cyclecheck, pos={50,50}, value="No;Yes;",mode=1, fsize=16,title="Is cycle data intact?", noproc // proc=popupmenuaction
		string /G ts="If there is no reliable cycle data, place the 'A' cursor on a point \rcorresponding to the last step in the cycle"
		titlebox explanatorytext win=cyclechart#cyclecheck, frame=0,pos={50,100},fsize=16, variable=ts
		button acceptance win=cyclechart#cyclecheck, pos={125,200},size={250,50},title="Enter selections and proceed",fsize=16,proc=cyclechecked
		pauseforuser cyclechart#cyclecheck,cyclechart
		nvar cycheck,laststep
		cleancycles = cycheck-1
		variable ls = laststep
		killvariables cycheck,laststep
		killstrings ts
endif
if (cleancycles==0)
		if (laststep<0)
			print "No step index or cycle index data, cannot proceed."
		else
			generatecycles(laststep)
		endif
endif

if (svar_exists(stepname))
	createstepselectionchart()
else
	print "No program step information available."
endif
if (paramisdefault(chargesteps))
	NewPanel /N=stepchecks /Ext=0 /HOST=stepselectionchart /W=(1,1,500,750)  as "Cycle program steps"
	SetVariable numchargesteps value=_NUM:1,title="How many charge steps per cycle?",pos={50,50},size={400,50},limits={1,5,1},fsize=18, noproc
	SetVariable numdischargesteps value=_NUM:1, title="How many discharge steps per cycle?",pos={50,100},size={400,50},limits={1,5,1},fsize=18, noproc
	button stepnumacceptance activate, fsize=18, win=stepselectionchart#stepchecks,size={250,50},pos={(500/2)-120,150},title="Number of steps is correct",proc=stepchecked
	pauseforuser stepselectionchart#stepchecks
	wave chargesteps = root:chargesteps	
	wave dischargesteps = root:dischargesteps
endif

generatecyclenumbers() 
maxcyclesglobal()			

generateEODVchart(dischargesteps) 

variable dcapsign=dischargecapacitysign(dischargesteps) 
variable dcapcontinuity,dtimecontinuity
if (numpnts(dischargesteps)>1)
	dcapcontinuity=dischargecapcontinuity(dischargesteps,dcapsign) 
	dtimecontinuity=dischargetimecontinuity(dischargesteps)			
endif
generateDischargeCapCycleChart(dischargesteps,dcapsign,dcapcontinuity)

generateEOCVchart(chargesteps)
generatedVchart(chargesteps,dischargesteps)

variable ccapcontinuity,ctimecontinuity
if (numpnts(chargesteps)>1)
	ccapcontinuity=chargecapcontinuity(chargesteps)
	ctimecontinuity=chargetimecontinuity(chargesteps)
endif
//generateChargeCapCycleChart(chargesteps,ccapcontinuity)
generateRechargeTimeChart(chargesteps,ctimecontinuity)
//generateRechargeFactorChart(chargesteps,ccapcontinuity,ctimecontinuity)

averageSEMbyTypeCategory(ywaven="discapcycletot",xwaven="cyclenumberText",chartname="dischargecapchart",oktoadd=1)
Label /W=dischargecapchart discapcycletot, "Discharge capacity(Ah)"
Label /W=dischargecapchart bottom, "Cycle number"

averageSEMbyTypeCategory(ywaven="rechargetimetot",xwaven="cyclenumberText",chartname="rechargetimechart",oktoadd=1)
svar timelabel
string rtaxistring = "Recharge "+timelabel
Label /W=rechargetimechart rechargetimetot,rtaxistring
Label /W=rechargetimechart bottom, "Cycle number"

end

function CreateCycleChart()
setdatafolder root:
svar /Z vwavename,curwavename,capname,discapname,cyclename,stepname,steptimename,totaltimename,timelabel
gotofirstpopulatedfolder()


if (svar_exists(stepname))
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
endif
wave timewave = $totaltimename

display /N=cyclechart
wave cy=$cyclename
if (svar_exists(cyclename))
	appendtograph /W=cyclechart /L=cycles cy[0,lastpoint] vs timewave[0,lastpoint]
else
	NewFreeAxis /L /W=cyclechart cycles
endif
if (svar_exists(stepname))
	appendtograph /W=cyclechart /L=step step[0,lastpoint] vs timewave[0,lastpoint]
	wavestats /Q /R=[0,lastpoint] step
	Cursor /W=cyclechart /P /A=1 a, $stepname,(v_maxrowloc)
else
	NewFreeAxis /L /W=cyclechart step
endif
modifygraph /W=cyclechart axisontop=1
modifygraph /W=cyclechart axOffset=0
modifygraph /W=cyclechart freePos=0
modifygraph /W=cyclechart axisenab(step)={0,0.48}
modifygraph /W=cyclechart axisenab(cycles)={0.52,1}
label /W=cyclechart step "Step index"
label /W=cyclechart cycles"Cycle index"
label /W=cyclechart bottom timelabel
ModifyGraph /W=cyclechart lblPosMode=1
ShowInfo /CP=0 /W=cyclechart
setdatafolder root:
end

function maxcyclesglobal()
setdatafolder root:
variable maxcycles=-1
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
					wave cycle
					wavestats /Q cycle
					maxcycles=max(maxcycles,v_max)
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
make /T /N=(maxcycles) /o cyclenumberText
cyclenumberText = num2str(p+1)
end

function CreateStepSelectionChart()
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
	wavestats /Q /R=[(lastpoint/2),lastpoint] A
	Cursor /W=stepselectionchart /P /A=1 a, $stepname,(v_maxrowloc)
	Cursor /W=stepselectionchart /P /A=1 b, $stepname,(v_minrowloc)
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

function dischargecapacitysign(dischargesteps)
wave dischargesteps
setdatafolder root:
svar /Z capname,discapname,stepname,cyclename
gotofirstpopulatedfolder()

if (svar_exists(discapname))
	wave cap=$discapname
else
	wave cap=$capname
endif
	wave step=$stepname
	wave cyc=$cyclename
	duplicate /o cap caplimited,boolean
	boolean=0

variable distep=1
do
	boolean += (step==dischargesteps[distep-1])
	distep+=1
while (distep<=numpnts(dischargesteps))
	caplimited *= ( (boolean)/(boolean) )
	caplimited *= ((cyc==1)/(cyc==1))
	wavetransform zapnans caplimited
	wavestats /Q caplimited
	variable dcsign =-1
	killwaves caplimited,boolean
	if (v_avg >0) 
		dcsign = 1
	endif
	setdatafolder root:
	return dcsign
end

function dischargecapcontinuity(dischargesteps,dcapsign)
wave dischargesteps
variable dcapsign
variable dcapcontinuous
setdatafolder root:
svar /Z capname,discapname,stepname,cyclename
gotofirstpopulatedfolder()
if (svar_exists(discapname))
	wave cap=$discapname
else
	wave cap=$capname
endif
	wave step=$stepname
variable i=0
do
	if ((step[i]==dischargesteps[0]) && (step[i+1]==dischargesteps[1]))
		 dcapcontinuous = (dcapsign*cap[i]<dcapsign*cap[i+1])
		break
	endif
	i+=1
while (i<numpnts(cap))
setdatafolder root:
return dcapcontinuous
end


function chargecapcontinuity(chargesteps)
wave chargesteps
variable ccapcontinuous
setdatafolder root:
svar /Z capname,stepname,cyclename
gotofirstpopulatedfolder()
wave cap=$capname
wave step=$stepname
variable i=0
do
	if ((step[i]==chargesteps[0]) && (step[i+1]==chargesteps[1]))
		 ccapcontinuous = (cap[i]<cap[i+1])
		break
	endif
	i+=1
while (i<numpnts(cap))
setdatafolder root:
return ccapcontinuous
end

function dischargetimecontinuity(dischargesteps)
wave dischargesteps
variable dcapsign
variable dtimecontinuous
setdatafolder root:
svar /Z capname,discapname,stepname,cyclename,steptimename
gotofirstpopulatedfolder()

wave step=$stepname
wave steptime = $steptimename

variable i=0
do
	if ((step[i]==dischargesteps[0]) && (step[i+1]==dischargesteps[1]))
		 dtimecontinuous = (steptime[i]<steptime[i+1])
		break
	endif
	i+=1
while (i<numpnts(steptime))
setdatafolder root:
return dtimecontinuous
end

function chargetimecontinuity(chargesteps)
wave chargesteps
variable ctimecontinuous
setdatafolder root:
gotofirstpopulatedfolder()

wave stepid
wave steptime
variable i=0
do
	if ((stepid[i]==chargesteps[0]) && (stepid[i+1]==chargesteps[1]))
		 ctimecontinuous = (steptime[i]<steptime[i+1])
		break
	endif
	i+=1
while (i<numpnts(steptime))
setdatafolder root:
return ctimecontinuous
end




function generateDischargeCapCycleChart(dischargesteps,dcapsign,dcapcontinuity) //jpmactive
wave dischargesteps
variable dcapsign
variable dcapcontinuity
display /N=discapallbatteries
setdatafolder root:
svar /Z stepname,vwavename,cyclename,capname,discapname
variable dstepindex=0
do

string discapcycle = "discapcycle"+num2str(dstepindex+1)
if (numpnts(dischargesteps)==1)
	discapcycle = "discapcycletot"
endif
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
					wave step=$stepname
					wave cyc=$cyclename
					if (svar_exists(discapname))
						wave cap=$discapname
					else
						wave cap=$capname
					endif
				
					wave cyclenumber
					wavestats /Q cyclenumber
					variable maxcycle = v_max
				
					duplicate /o cyclenumber $discapcycle
					wave discap=$discapcycle
					discap = NaN
				
					variable ci=1
					do
						duplicate cap capdischcycle
						capdischcycle *= ( (step==dischargesteps[dstepindex])/(step==dischargesteps[dstepindex]) )
						capdischcycle *= ( (cyc==ci)/(cyc==ci) )
						wavestats /Q capdischcycle
						if (dcapsign<0)
							discap[ci-1] = -v_min
						else
							discap[ci-1] = v_max
						endif
						if (dcapcontinuity!=1)
							if (dstepindex>1)
								if (dcapsign<0)
									discap[ci-1] += v_max
								else
									discap[ci-1] -= v_min
								endif
							endif
						endif
						killwaves capdischcycle
						ci+=1
					while (ci<=maxcycle)
				
					string dcn = "discap"+num2str(dstepindex)+typename+batteryname
					if (numpnts(dischargesteps)==1)
						dcn = "discap"+typename+batteryname
					endif
					appendtograph /W=discapallbatteries discap /TN=$dcn vs cyclenumber
					modifygraph rgb($dcn)=(red,green,blue)
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
dstepindex+=1
while (dstepindex<numpnts(dischargesteps))

if (numpnts(dischargesteps)>1)
dstepindex=0
do

discapcycle = "discapcycle"+num2str(dstepindex+1)
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
					wave discapstep = $discapcycle
					wave /Z discapcycletot
					if (!waveexists(discapcycletot))
						make /N=(numpnts(discapstep)) discapcycletot
					endif
					discapcycletot += discapstep
					
					if (dstepindex==(numpnts(dischargesteps)-1) )
						if (dcapcontinuity==1)
							wave cap=$discapcycle
							ci=1
							do
								duplicate cap capdischcycle
								capdischcycle *= ( (step==dischargesteps[dstepindex])/(step==dischargesteps[dstepindex]) )
								capdischcycle *= ( (cyc==ci)/(cyc==ci) )
								wavestats /Q capdischcycle
								killwaves capdischcycle
								waveclear cap
								if (dcapsign<0)
									discapcycletot[ci-1] = -v_min
								else
									discapcycletot[ci-1] = v_max
								endif
								ci+=1
							while (ci<=maxcycle)
						endif
						dcn = "discapcycletot"+typename+batteryname
						appendtograph /W=discapallbatteries discapcycletot /TN=$dcn vs cyclenumber
						modifygraph rgb($dcn)=(red,green,blue)
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
dstepindex+=1
while (dstepindex<numpnts(dischargesteps))
endif
label /W=discapallbatteries left, "Discharge capacity (Ah)"
label /W=discapallbatteries bottom, "Cycle number"
end

function generateRechargeTimeChart(chargesteps,ctimecontinuity)
wave chargesteps
variable ctimecontinuity
display /N=rechargetimesallbatteries
setdatafolder root:
svar /Z stepname,steptimename,totaltimename,cyclename,capname
variable cstepindex=0
do
string rechargetimen = "rechargetime"+num2str(cstepindex+1)
if (numpnts(chargesteps)==1)
	rechargetimen = "rechargetimetot"
endif
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
					wave step=$stepname
					wave cyc=$cyclename
					wave st = $steptimename
					wave tt = $totaltimename
					wave cyclenumber
					wavestats /Q cyclenumber
					variable maxcycle = v_max
				
					duplicate /o cyclenumber $rechargetimen
					wave rechargetime=$rechargetimen
					rechargetime = NaN
					
					if (ctimecontinuity !=0)
						if (cstepindex==0)
							duplicate /o cyclenumber laststamp
							wave laststamp
							laststamp = NaN
						else
							wave laststamp
						endif
					endif
					variable ci=1
					do
						duplicate st stcycle
						stcycle *= ( (step==chargesteps[cstepindex])/(step==chargesteps[cstepindex]) )
						stcycle *= ( (cyc==ci)/(cyc==ci) )
						wavestats /Q stcycle
						rechargetime[ci-1] = v_max
						killwaves stcycle
						
						if (ctimecontinuity!=0)
							duplicate tt ttcycle
							ttcycle *= ( (step==chargesteps[cstepindex])/(step==chargesteps[cstepindex]) )
							ttcycle *= ( (cyc==ci)/(cyc==ci) )
							wavestats /Q ttcycle
							killwaves ttcycle				
							if (cstepindex>0)
								rechargetime[ci-1] = v_max-laststamp[ci-1]
							endif
							laststamp[ci-1] = v_max
						endif
						ci+=1
					while (ci<=maxcycle)
					string rtn = "rechargetime"+num2str(cstepindex+1)+typename+batteryname
					if (numpnts(chargesteps)==1)
						rtn = "RechTimeTot"+typename+batteryname
					endif
					appendtograph /W=rechargetimesallbatteries rechargetime /TN=$rtn vs cyclenumber
					modifygraph /W=rechargetimesallbatteries rgb($rtn)=(red,green,blue)		
					waveclear step,cyc,rechargetime,st,tt,laststamp		
				endif

				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
cstepindex+=1
while (cstepindex<numpnts(chargesteps))

if (numpnts(chargesteps)>1)
cstepindex=0
do
rechargetimen = "rechargetime"+num2str(cstepindex+1)
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
					wave rt=$rechargetimen
					wave /z rechargetimetot
					if ((!waveexists(rechargetimetot)) || (cstepindex==0) )
						duplicate /o rt rechargetimetot
						wave rechargetimetot
						rechargetimetot = 0
					endif
					rechargetimetot += rt

					if (cstepindex==numpnts(chargesteps)-1)
						if (ctimecontinuity!=0)
							wave st=$steptimename
							wave step=$stepname
							wave cyc=$cyclename
							ci=1
							do
								duplicate st stcycle
								stcycle *= ( (step==chargesteps[cstepindex])/(step==chargesteps[cstepindex]) )
								stcycle *= ( (cyc==ci)/(cyc==ci) )
								wavestats /Q stcycle
								rechargetimetot[ci-1] = v_max
								killwaves stcycle
								ci+=1
							while (ci<=maxcycle)
							waveclear st
							killwaves laststamp
						endif
						rtn = "rechargetimetot"+typename+batteryname
						appendtograph /W=rechargetimesallbatteries rechargetimetot /TN=$rtn vs cyclenumber
						modifygraph rgb($rtn)=(red,green,blue)	
					endif	
					waveclear rt,rechargetimetot		
				endif

				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
cstepindex+=1
while (cstepindex<numpnts(chargesteps))
endif
svar timelabel
string rtaxistring ="Recharge "+timelabel
label /W=rechargetimesallbatteries left, rtaxistring
label /W=rechargetimesallbatteries bottom, "Cycle"
end




function cyclechecked(ctrlname) : buttoncontrol
	string ctrlname
	variable /G cycheck=0
	variable /G laststep=0
	controlinfo /W=cyclechart#cyclecheck cyclecheckmenu
	cycheck = v_value
	Variable aExists= (strlen(CsrInfo(A,"cyclechart")) > 0)
	laststep=-1
	if (aexists)
		laststep= vcsr(A,"cyclechart")
	endif
	killwindow cyclechart#cyclecheck
	killwindow cyclechart
end

function stepchecked(ctrlname) : buttoncontrol
	string ctrlname
	setdatafolder root:
	controlinfo /W=stepselectionchart#stepchecks numchargesteps
	variable /G numchargesteps
	numchargesteps = v_value
	controlinfo /W=stepselectionchart#stepchecks numdischargesteps
	variable /G numdischargesteps
	numdischargesteps = v_value
	make /N=(numchargesteps) /o root:chargesteps
	make /N=(numdischargesteps) /o root:dischargesteps

	wave chargesteps=root:chargesteps
	chargesteps= vcsr(A,"stepselectionchart")+p
	
	wave dischargesteps=root:dischargesteps
	dischargesteps=vcsr(B,"stepselectionchart")+p
	titlebox chargetext win=stepselectionchart#stepchecks, frame=0,pos={50,230},fsize=18, title="Charge steps"
	titlebox dischargetext win=stepselectionchart#stepchecks, frame=0,pos={300,230},fsize=18, title="Discharge steps"
	variable i=0
	do
		string svc="setvariablecharge"+num2str(i)
		SetVariable $svc value=chargesteps[i],title="Step # "+num2str(i+1),pos={50,270+65*i},fsize=16,size={100,65}, noproc
		i+=1
	while (i<numchargesteps)
	i=0
	do
		string svd="setvariabledischarge"+num2str(i)
		SetVariable $svd value=dischargesteps[i],title="Step # "+num2str(i+1),pos={300,270+65*i},fsize=16,size={100,65}, noproc
		i+=1
	while (i<numdischargesteps)
		button stepsprogrammed win=stepselectionchart#stepchecks, pos={150,620},size={200,65},fsize=18,title="Confirm step indices\rare correct",proc=stepsprogrammed

end

function stepsprogrammed(ctrlname) : buttoncontrol
	string ctrlname
	killwindow stepselectionchart#stepchecks
	killwindow stepselectionchart
end

function generatecycles(laststep)
variable laststep
setdatafolder root:
svar stepname
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
					wave step=$stepname
					duplicate /o step cycle
					cycle=1
					variable i=0
					do
						if ((step[i+1]!=laststep) && (step[i]==laststep) )
							cycle[i+1]=cycle[i]+1
						else
							cycle[i+1]=cycle[i]
						endif
						i+=1
					while(i<(numpnts(cycle)-1))
				endif
				waveclear step,cycle
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
end

function generatecyclenumbers()
setdatafolder root:
svar cyclename
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
					wave fullcycles=$cyclename
					wavestats /Q fullcycles
					make /N=(v_max) /o cyclenumber
					cyclenumber=p+1
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

function generateEODVchart(dischargesteps)
wave dischargesteps
display /N=EODVallbatteries
setdatafolder root:
svar stepname,vwavename,cyclename
variable dstepindex=0
do
string eodvwn = "EODV"+num2str(dstepindex+1)
if (numpnts(dischargesteps)==1)
	eodvwn = "EODV"
endif
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
				wave step=$stepname
				wave v=$vwavename
				wave cyc=$cyclename
				
				wave cyclenumber
				wavestats /Q cyclenumber
				variable maxcycle = v_max
				
				duplicate /o cyclenumber $eodvwn
				wave eodv=$eodvwn
				eodv = NaN
				

				variable ci=1
				do
					duplicate v vdischcycle
					vdischcycle *= ( (step==dischargesteps[dstepindex])/(step==dischargesteps[dstepindex]) )
					vdischcycle *= ( (cyc==ci)/(cyc==ci) )
					wavestats /Q vdischcycle
					eodv[ci-1] = v_min
					killwaves vdischcycle
					ci+=1
				while (ci<=maxcycle)
				endif
				string eodvn = "EODV"+num2str(dstepindex+1)+typename+batteryname
				if (numpnts(dischargesteps)==1)
					eodvn = "EODV"+typename+batteryname
				endif
				appendtograph /W=EODVallbatteries eodv /TN=$eodvn vs cyclenumber
				modifygraph rgb($eodvn)=(red,green,blue)
				modifygraph lstyle($eodvn)=batteryindex
				modifygraph lsize($eodvn)=dstepindex+1
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	Label /W=EODVallbatteries bottom, "Cycle"
	Label /W=EODVallbatteries left, "End of discharge voltage (V)"
	setdatafolder root:
	typeindex+=1
while(1)
dstepindex+=1
while (dstepindex<numpnts(dischargesteps))
end

function generateEOCVchart(chargesteps)
wave chargesteps
display /N=EOCVallbatteries
setdatafolder root:
svar stepname,vwavename,cyclename
variable cstepindex=0
do
string eocvwn = "EOCV"+num2str(cstepindex+1)
if (numpnts(chargesteps)==1)
	eocvwn = "EOCV"
endif
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
				wave step=$stepname
				wave v=$vwavename
				wave cyc=$cyclename
				
				wave cyclenumber
				wavestats /Q cyclenumber
				variable maxcycle = v_max
				
				duplicate /o cyclenumber $eocvwn
				wave eocv=$eocvwn
				eocv = NaN
				

				variable ci=1
				do
					duplicate v vchcycle
					vchcycle *= ( (step==chargesteps[cstepindex])/(step==chargesteps[cstepindex]) )
					vchcycle *= ( (cyc==ci)/(cyc==ci) )
					wavestats /Q vchcycle
					eocv[ci-1] = v_max
					killwaves vchcycle
					ci+=1
				while (ci<=maxcycle)
				endif
				string eocvn = "EOCV"+num2str(cstepindex+1)+typename+batteryname
				if (numpnts(chargesteps)==1)
					eocvn =  "EOCV"+typename+batteryname
				endif
				appendtograph /W=EOCVallbatteries eocv /TN=$eocvn vs cyclenumber
				modifygraph lstyle($eocvn)=batteryindex
				modifygraph lsize($eocvn)=cstepindex+1
				modifygraph rgb($eocvn)=(red,green,blue)
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	Label /W=EOCVallbatteries bottom, "Cycle"
	Label /W=EOCVallbatteries left, "End of charge voltage (V)"
	setdatafolder root:
	typeindex+=1
while(1)
cstepindex+=1
while (cstepindex<numpnts(chargesteps))
end

function generateDVchart(chargesteps,dischargesteps)
wave chargesteps,dischargesteps
display /N=dVcycleallbatteries
string eocvn,eodvn
if (numpnts(chargesteps)==1)
	eocvn = "EOCV"
else
	eocvn = "EOCV"+num2str(numpnts(chargesteps))
endif
if (numpnts(dischargesteps)==1)
	eodvn = "EODV"
else
	eodvn = "EODV"+num2str(numpnts(chargesteps))
endif

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
					wave eodv=$eodvn
					wave eocv=$eocvn
					wave cyclenumber
					duplicate /o eocv dvcycle
					wave dvcycle
					dvcycle -= eodv
				
					string dvn = "deltaV"+typename+batteryname
					appendtograph /W=dVcycleallbatteries dvcycle /TN=$dvn vs cyclenumber
					modifygraph rgb($dvn)=(red,green,blue)
					waveclear eodv,eocv,dvcycle,cyclenumber
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
Label /W=dVcycleallbatteries left, "Voltage difference, charge-discharge (V)"
Label /W=dVcycleallbatteries bottom, "Cycle" 


end

function generateDischargeCapCycleCharts(dischargesteps)
wave dischargesteps
end

function generateChargeCapCycleCharts(chargesteps,dischargesteps)
wave chargesteps,dischargesteps
end


