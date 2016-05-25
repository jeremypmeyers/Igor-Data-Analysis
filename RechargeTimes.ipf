#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function RTextraction()

//determine structure of this particular Igor Experiment
string menulist1 = "Do extraction of the present data folder "+ getdatafolder(0)+";"
menulist1 += "All folders on the top root level;"
menulist1 += "Folders nested by battery type;"
variable extractiontype
prompt extractiontype, "What type of extraction to perform?", popup, menulist1
doprompt  "Extraction type", extractiontype
print "Extraction type = ",extractiontype

string startfolder = getdatafolder(1)
setdatafolder root:

make /N=0 /o rt90_100,rt100_102,rt102_105, rt105_107, rt107_110
make /N=0 /o rV90_100,rV100_102,rV102_105,rV105_107, rV107_110
make /N=0 /T /o rechargeBatteryDescription, type, variant, exptype

if (extractiontype==1)
	setdatafolder $startfolder
endif

variable batteryindex, typeindex
variable maxbatteryindex, maxtypeindex
maxbatteryindex = 0
maxtypeindex= 0
if (extractiontype >1)
	maxbatteryindex = 99999
	if (extractiontype >2)
		maxtypeindex=99999
	endif
endif

typeindex=0
string typename = ""
do
	if (extractiontype == 3) 
		typename = GetIndexedObjName(":", 4,typeindex)
		if (strlen(typename)==0)
			break
		endif
		setdatafolder $typename

		print typename

		nvar red,green,blue
	endif
	nvar /Z skip
 	batteryindex=0
	string batteryname
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
	do
		if (extractiontype != 1)
			batteryname = GetIndexedObjName(":",4,batteryindex)
			if (strlen(batteryname)==0)
				break
			endif
			setdatafolder $batteryname
		else
			prompt batteryname, "How to name/designate this battery type?"
			doprompt "Specify this battery", batteryname
		endif
	
	
		if ((batteryindex==0) && (typeindex==0))
			string cwname,vwname,tiwname, rfwname, menulist,timeunits
			variable units
			menulist = "Not present in this folder;"
			menulist += wavelist("*",";","")
			timeunits = "Hours; Minutes; Seconds;"
			prompt cwname, "Which wave is the current?", popup, menulist
			prompt vwname, "Which wave is the voltage?", popup, menulist
			prompt tiwname, "Which wave is the time?", popup, menulist
			prompt units, "What units are the time wave recorded in?",popup, timeunits
			prompt rfwname, "Which wave is the recharge factor?", popup, menulist
			doprompt "Select waves for analysis",cwname,vwname,tiwname,units,rfwname
		endif

		wave rf = $rfwname
		wave ti = $tiwname

		wave /Z cur = $cwname
		if (!waveexists(cur))
			string wl= WaveList("*Current*",";","")
			wave cur = $StringFromList(0, wl)
		endif
		
		wave /Z v = $vwname 
		if (!waveexists(v))
			wl= WaveList("*Volt*",";","")
			wave v = $StringFromList(0, wl)
		endif
		
		wave /Z ti = $tiwname 
		if (!waveexists(ti))
			wl= WaveList("*Total_Time*",";","")
			wave ti = $StringFromList(0, wl)
		endif
		
		duplicate /o ti times
		times /=(60^(units-1))
		wave times



		variable CVreqt = 0.003

variable i=1
do
	if ( (rf[i-1] <=0.9) && (rf[i] >=0.9) )
		variable t90 = (times[i]-times[i-1])*(0.9-rf[i-1])/(rf[i]-rf[i-1]) + times[i-1]

		wavestats /Q rf
		print typename, batteryname, t90, times[v_maxrowloc],v_max,v_min
		variable index90 = i-1
	endif

	if ( (rf[i-1] <=1) && (rf[i] >=1) )
		variable t100 =  (times[i]-times[i-1])*(1.0-rf[i-1])/(rf[i]-rf[i-1]) + times[i-1]
		variable index100 = i
		wavestats /Q /R=[index90,index100] V

			variable nrfs= numpnts(rechargeBatteryDescription)
			redimension /N=(nrfs+1) rechargeBatteryDescription,rt90_100, rt100_102, rt102_105, rt105_107, rt107_110
			redimension /N=(nrfs+1) rV90_100,rV100_102,rV102_105,rv105_107, rv107_110
			redimension /N=(nrfs+1) type, variant, exptype
			if (extractiontype==3)
				rechargeBatteryDescription[nrfs]=typename + " " + batteryname
				type[nrfs] = typename
				variant[nrfs] = "Ca"
				exptype[nrfs] = "1"
//need to automate/specify variant and experiment

			else
				rechargeBatteryDescription[nrfs] = batteryname
			endif
			
			rt90_100[nrfs] = NaN
			rV90_100[nrfs] = NaN		
			rt100_102[nrfs] = NaN
			rV100_102[nrfs] = NaN
			rt102_105[nrfs] = NaN
			rV102_105[nrfs] = NaN
			rt105_107[nrfs] = NaN
			rv105_107[nrfs] = NaN
			rt107_110[nrfs] = NaN
			rv107_110[nrfs] = NaN
		if (v_sdev/v_avg < CVreqt)		
			rt90_100[nrfs] = t100-t90
			rV90_100[nrfs] = v_avg
			print v_sdev, v_avg, CVreqt, typename, batteryname
		endif
	endif
	
	if ( (rf[i-1] <=1.02) && (rf[i] >=1.02) )
		variable t102 =  (times[i]-times[i-1])*(1.02-rf[i-1])/(rf[i]-rf[i-1]) + times[i-1]
		variable index102 = i
		wavestats /Q /R=[index100,index102] V

		if (v_sdev/v_avg < CVreqt)
			rt100_102[nrfs] = t102-t100
			rV100_102[nrfs] = v_avg
		endif		
	endif

	if ( (rf[i-1] <=1.05) && (rf[i] >=1.05) )
		variable t105 =  (times[i]-times[i-1])*(1.05-rf[i-1])/(rf[i]-rf[i-1]) + times[i-1]
		variable index105 = i
		wavestats /Q /R=[index102,index105] V
		if (v_sdev/v_avg < CVreqt)
			rt102_105[nrfs] = t105-t102
			rV102_105[nrfs] = v_avg
		endif		
	endif
	
	if ( (rf[i-1] <=1.07) && (rf[i] >=1.07) )
		variable t107 =  (times[i]-times[i-1])*(1.07-rf[i-1])/(rf[i]-rf[i-1]) + times[i-1]
		variable index107 = i
		wavestats /Q /R=[index105,index107] V
		if (v_sdev/v_avg < CVreqt)
			rt105_107[nrfs] = t107-t105
			rV105_107[nrfs] = v_avg
		endif		
	endif
	if ( (rf[i-1] <=1.1) && (rf[i] >=1.1) )
		variable t110 =  (times[i]-times[i-1])*(1.1-rf[i-1])/(rf[i]-rf[i-1]) + times[i-1]
		variable index110 = i
		wavestats /Q /R=[index107,index110] V
		if (v_sdev/v_avg < CVreqt)
			rt107_110[nrfs] = t110-t107
			rV107_110[nrfs] = v_avg
		endif		
	endif

	i+=1
while (i<numpnts(rf))

		waveclear rf,ti, times, cur, v

	
	
		setdatafolder root:
		if (extractiontype==3)
			setdatafolder $typename
		elseif (extractiontype==2)
			setdatafolder root:
		endif
		batteryindex+=1
	while(batteryindex<=maxbatteryindex)
	endif
		setdatafolder root:
	typeindex+=1
while(typeindex<=maxtypeindex)


end





function RTsummary()
wave rt90_100,rt100_102,rt102_105,rt105_107,rt107_110
wave rV90_100,rV100_102,rV102_105,rV105_107,rV107_110
wave /T type, variant
duplicate /o /T type fulltype
fulltype = type+" "+variant

make /N=4 /T /O typelist={"ConCon","MRCon","ConMR","MRMR"}
make /N=2 /T /O variantlist={"Ca","Sb"}

make /N=( numpnts(typelist)*numpnts(variantlist) ) /o rt90_100avg,rt100_102avg,rt102_105avg,rt105_107avg,rt107_110avg
make /N=( numpnts(typelist)*numpnts(variantlist) ) /o rt90_100sem,rt100_102sem,rt102_105sem,rt105_107sem,rt107_110sem
make /N=( numpnts(typelist)*numpnts(variantlist) ) /o rV90_100avg,rV100_102avg,rV102_105avg,rV105_107avg,rV107_110avg

make /N=( numpnts(typelist)*numpnts(variantlist) ) /o /T BatTypeDescriptionFull
make /N=( (numpnts(typelist)-1)*numpnts(variantlist) ) /o /T BatTypeDescriptionRel
variable typeindex=0
do
	variable variantindex=0
	do
			extract /o /indx fulltype, destwave,  ((strsearch(fulltype,typelist[typeindex],0)>=0)&&(strsearch(fulltype,variantlist[variantindex],0)>=0))
			variable windex = (variantindex+numpnts(variantlist)*typeindex)
			BatTypeDescriptionFull[windex] = typelist[typeindex]+" "+variantlist[variantindex]

			make /N=(numpnts(destwave)) rt90,rt100,rt102,rt105,rt107,rV90,rV100,rV102,rV105,rV107
			print BatTypeDescriptionFull[windex],numpnts(destwave)
			if (numpnts(destwave)>0)
				variable i=0
				do
					rt90[i] = rt90_100[destwave[i]]
					rt100[i] = rt100_102[destwave[i]]
					rt102[i] = rt102_105[destwave[i]]
					rt105[i] = rt105_107[destwave[i]]
					rt107[i] = rt107_110[destwave[i]]
					
					rV90[i] = rV90_100[destwave[i]]
					rV100[i] = rV100_102[destwave[i]]
					rV102[i] = rV102_105[destwave[i]]
					rV105[i] = rV105_107[destwave[i]]
					rV107[i] = rV107_110[destwave[i]]
										
					i+=1
				while (i<numpnts(destwave))

				wavestats /Q rt90
				rt90_100avg[windex] = v_avg
				rt90_100sem[windex] = v_sem
				wavestats /Q rV90
				rV90_100avg[windex] = v_avg
				
				wavestats /Q rt100
				rt100_102avg[windex] = v_avg
				rt100_102sem[windex] = v_sem
				wavestats /Q rV100
				rV100_102avg[windex] = v_avg

				wavestats /Q rt102
				rt102_105avg[windex] = v_avg
				rt102_105sem[windex] = v_sem
				wavestats /Q rV102
				rV102_105avg[windex] = v_avg
				
				wavestats /Q rt105
				rt105_107avg[windex] = v_avg
				rt105_107sem[windex] = v_sem
				wavestats /Q rV105
				rV105_107avg[windex] = v_avg
				
				wavestats /Q rt107
				rt107_110avg[windex] = v_avg
				rt107_110sem[windex] = v_sem
				wavestats /Q rV107
				rV107_110avg[windex] = v_avg
			else
				rt90_100avg[windex] = NAN
				rt90_100sem[windex] = NAN
				
				wavestats /Q rt100
				rt100_102avg[windex] = NAN
				rt100_102sem[windex] = NAN

				wavestats /Q rt102
				rt102_105avg[windex] = NAN
				rt102_105sem[windex] = NAN
				
				wavestats /Q rt105
				rt105_107avg[windex] = NAN
				rt105_107sem[windex] = NAN
				
				wavestats /Q rt107
				rt107_110avg[windex] = NAN
				rt107_110sem[windex] = NAN

			endif
			killwaves destwave,rt90,rt100,rt102,rt105,rt107,rV90,rV100,rV102,rV105,rV107
		variantindex+=1
	while ( variantindex<=1)
	typeindex+=1
while (typeindex<=3)
killwaves fulltype
end

function relsummary()
make /N=4 /T /O typelist={"ConCon","MRCon","ConMR","MRMR"}
make /N=2 /T /O variantlist={"Ca","Sb"}

wave rt90_100avg,rt100_102avg,rt102_105avg,rt105_107avg,rt107_110avg
wave rt90_100sem,rt100_102sem,rt102_105sem,rt105_107sem,rt107_110sem
wave rV90_100avg,rV100_102avg,rV102_105avg,rV105_107avg,rV107_110avg
make /N=( (numpnts(typelist)-1)*numpnts(variantlist)) /o rt90_100avgRel,rt100_102avgRel,rt102_105avgRel,rt105_107avgRel,rt107_110avgRel
make /N=( (numpnts(typelist)-1)*numpnts(variantlist)) /o rt90_100semRel,rt100_102semRel,rt102_105semRel,rt105_107semRel,rt107_110semRel
make /N=( (numpnts(typelist)-1)*numpnts(variantlist)) /o Rel90_100V,Rel100_102V,Rel102_105V,Rel105_107V,Rel107_110V

wave /T BatTypeDescriptionRel
variable typeindex=1
do
	variable variantindex=0
	do
			variable relindex = (variantindex+numpnts(variantlist)*(typeindex-1))
			variable fullindex = (variantindex+numpnts(variantlist)*typeindex)
			variable conindex = variantindex
			BatTypeDescriptionRel[relindex] = typelist[typeindex]+" "+variantlist[variantindex]
			Rel90_100V[relindex] = rV90_100avg[fullindex]
			Rel100_102V[relindex] = rV100_102avg[fullindex]
			Rel102_105V[relindex] = rV102_105avg[fullindex]			
			Rel105_107V[relindex] = rV105_107avg[fullindex]
			Rel107_110V[relindex] = rV107_110avg[fullindex]
						
			rt90_100avgRel[relindex] = 1-rt90_100avg[fullindex]/rt90_100avg[conindex]
			rt90_100semRel[relindex] = rt90_100avgRel[relindex]*sqrt( (rt90_100sem[fullindex]/rt90_100avg[fullindex])^2 + (rt90_100sem[conindex]/rt90_100avg[conindex])^2 )
			rt100_102avgRel[relindex] = 1-rt100_102avg[fullindex]/rt100_102avg[conindex]
			rt100_102semRel[relindex] = rt100_102avgRel[relindex] * sqrt( (rt100_102sem[fullindex]/rt100_102avg[fullindex])^2 + (rt100_102sem[conindex]/rt100_102avg[conindex])^2 )
			rt102_105avgRel[relindex] = 1-rt102_105avg[fullindex]/rt102_105avg[conindex]
			rt102_105semRel[relindex] = rt102_105avgRel[relindex] * sqrt( (rt102_105sem[fullindex]/rt102_105avg[fullindex])^2 + (rt102_105sem[conindex]/rt102_105avg[conindex])^2 )
			rt105_107avgRel[relindex] = 1-rt105_107avg[fullindex]/rt105_107avg[conindex]
			rt105_107semRel[relindex] = rt105_107avgRel[relindex] * sqrt( (rt105_107sem[fullindex]/rt105_107avg[fullindex])^2 + (rt105_107sem[conindex]/rt105_107avg[conindex])^2 )
			rt107_110avgRel[relindex] = 1-rt107_110avg[fullindex]/rt107_110avg[conindex]
			rt107_110semRel[relindex] = rt107_110avgRel[relindex] * sqrt( (rt107_110sem[fullindex]/rt107_110avg[fullindex])^2 + (rt107_110sem[conindex]/rt107_110avg[conindex])^2 )

		variantindex+=1
	while ( variantindex<=1)
	typeindex+=1
while (typeindex<=3)
end

function reductioninrechargetimeplots()
//DISPLAY /N=reductionchart
string descrip
prompt descrip, "Which batteries are these?"
doprompt "Enter data for plotting/legend", descrip
wave /T bt = root:BatTypeDescriptionRel
wave rt90_100avgrel,rt100_102avgrel,rt102_105avgrel,rt105_107avgrel,rt107_110avgrel
wave rt90_100semrel,rt100_102semrel,rt102_105semrel,rt105_107semrel,rt107_110semrel
wave Rel90_100V,Rel100_102V,Rel102_105V,Rel105_107V,Rel107_110V

string r90100n = "r90100"+descrip
string r100102n = "r100102"+descrip
string r102105n = "r102105"+descrip
string r105107n = "r105017"+descrip
string r107110n = "r107110"+descrip

string V90100n = "V90100"+descrip
string V100102n = "V100102"+descrip
string V102105n = "V102105"+descrip
string V105107n = "V105017"+descrip
string V107110n = "V107110"+descrip

appendtograph /L=L90100 rt90_100avgrel /TN=$r90100n vs bt
appendtograph /L=L100102 rt100_102avgrel /TN=$r100102n vs bt
appendtograph /L=L102105 rt102_105avgrel /TN=$r102105n vs bt
appendtograph /L=L105107 rt105_107avgrel /TN=$r105107n vs bt
appendtograph /L=L107110 rt107_110avgrel /TN=$r107110n vs bt

appendtograph /R=V90100 Rel90_100V /TN=$V90100n vs bt
appendtograph /R=V100102 Rel100_102V /TN=$V100102n vs bt
appendtograph /R=V102105 Rel102_105V /TN=$V102105n vs bt
appendtograph /R=V105107 Rel105_107V /TN=$V105107n vs bt
appendtograph /R=V107110 Rel107_110V /TN=$V107110n vs bt

variable i=0
variable red,green,blue
do
	if (strsearch(bt[i],"MRCon",0)>=0)
		red = 65280
		green = 43520
		blue = 0
	elseif (strsearch(bt[i],"ConMR",0)>=0)
		red = 0
		green = 52224
		blue = 0
	else 
		red = 0
		green = 0 
		blue =65280
	endif
	modifygraph rgb($r90100n[i]) = (red,green,blue)
	modifygraph rgb($V90100n[i]) = (red,green,blue)
	
	modifygraph rgb($r100102n[i]) = (red,green,blue)
	modifygraph rgb($V100102n[i]) = (red,green,blue)
	
	modifygraph rgb($r102105n[i]) = (red,green,blue)
	modifygraph rgb($V102105n[i]) = (red,green,blue)
	
	modifygraph rgb($r105107n[i]) = (red,green,blue)
	modifygraph rgb($V105107n[i]) = (red,green,blue)

	modifygraph rgb($r107110n[i]) = (red,green,blue)
	modifygraph rgb($V107110n[i]) = (red,green,blue)

	
	i+=1
while (i<numpnts(bt))
ErrorBars $r90100n Y,wave=(rt90_100semrel,rt90_100semrel)
ErrorBars $r100102n Y,wave=(rt100_102semrel,rt100_102semrel)
ErrorBars $r102105n Y,wave=(rt102_105semrel,rt102_105semrel)
ErrorBars $r105107n Y,wave=(rt105_107semrel,rt105_107semrel)
ErrorBars $r107110n Y,wave=(rt107_110semrel,rt107_110semrel)
ModifyGraph standoff(L90100)=0,standoff(V90100)=0,axisEnab(L90100)={0,0.2};DelayUpdate
ModifyGraph freePos(L90100)=0,freePos(V90100)=0;DelayUpdate
SetAxis L90100 0,1
ModifyGraph axisOnTop(L90100)=1,axisOnTop(L100102)=1,axisOnTop(L102105)=1;DelayUpdate
ModifyGraph axisOnTop(L105107)=1,axisOnTop(L107110)=1,standoff(L100102)=0;DelayUpdate
ModifyGraph standoff(L102105)=0,standoff(L105107)=0,standoff(L107110)=0;DelayUpdate
ModifyGraph freePos(L100102)=0,freePos(L102105)=0,freePos(L105107)=0;DelayUpdate
ModifyGraph freePos(L107110)=0;DelayUpdate
SetAxis L100102 0,1;DelayUpdate
SetAxis L102105 0,1;DelayUpdate
SetAxis L105107 0,1;DelayUpdate
SetAxis L107110 0,1
ModifyGraph axisEnab(L100102)={0.2,0.4},axisEnab(L102105)={0.4,0.6};DelayUpdate
ModifyGraph axisEnab(L105107)={0.6,0.8},axisEnab(L107110)={0.8,1}
ModifyGraph standoff(bottom)=0
ModifyGraph tickZap(L100102)={0},tickZap(L102105)={0},tickZap(L105107)={0};DelayUpdate
ModifyGraph tickZap(L107110)={0}
ModifyGraph mode=3,marker(V90100L2140)=9,marker(V100102L2140)=9;DelayUpdate
ModifyGraph marker(V102105L2140)=9,marker(V105017L2140)=9,marker(V107110L2140)=9
ModifyGraph axisOnTop(V90100)=1,axisOnTop(V100102)=1,axisOnTop(V102105)=1;DelayUpdate
ModifyGraph axisOnTop(V105107)=1,axisOnTop(V107110)=1,standoff=0;DelayUpdate
ModifyGraph freePos(V100102)=0,freePos(V102105)=0,freePos(V105107)=0;DelayUpdate
ModifyGraph freePos(V107110)=0;DelayUpdate
SetAxis V90100 14,16;DelayUpdate
SetAxis V100102 14,16;DelayUpdate
SetAxis V102105 14,16;DelayUpdate
SetAxis V105107 14,16;DelayUpdate
SetAxis V107110 14,16
ModifyGraph axisEnab(V90100)={0,0.2},axisEnab(V100102)={0.2,0.4};DelayUpdate
ModifyGraph axisEnab(V102105)={0.4,0.6},axisEnab(V105107)={0.6,0.8};DelayUpdate
ModifyGraph axisEnab(V107110)={0.8,1}
ModifyGraph msize(r90100L2140)=3,msize(r100102L2140)=3,msize(r102105L2140)=3;DelayUpdate
ModifyGraph msize(r105017L2140)=3,msize(r107110L2140)=3
ModifyGraph tkLblRot(bottom)=60
end	

function novelplot()
//display /N=rtVplot
string descrip
prompt descrip, "Which batteries are these?"
doprompt "Enter data for plotting/legend", descrip
wave /T bt = root:BatTypeDescriptionRel
wave rt90_100avgrel,rt100_102avgrel,rt102_105avgrel,rt105_107avgrel,rt107_110avgrel
wave rt90_100semrel,rt100_102semrel,rt102_105semrel,rt105_107semrel,rt107_110semrel
wave Rel90_100V,Rel100_102V,Rel102_105V,Rel105_107V,Rel107_110V



variable i=0
do
	string axname = bt[i]

string r90100n = "r90100"+bt[i]+descrip
string r100102n = "r100102"+bt[i]+descrip
string r102105n = "r102105"+bt[i]+descrip
string r105107n = "r105017"+bt[i]+descrip
string r107110n = "r107110"+bt[i]+descrip

r90100n = ReplaceString(" ", r90100n, "")
r100102n = ReplaceString(" ", r100102n, "")
r102105n = ReplaceString(" ", r102105n, "")
r105107n = ReplaceString(" ", r105107n, "")
r107110n = ReplaceString(" ", r107110n, "")

strswitch (bt[i])
case "MRCon Ca":
	appendtograph /L=L90100 /B=MRConCa rt90_100avgrel[i,i] /TN=$r90100n vs Rel90_100v[i,i]
	appendtograph /L=L100102 /B=MRConCa rt100_102avgrel[i,i] /TN=$r100102n vs Rel100_102V[i,i]
	appendtograph /L=L102105 /B=MRConCa rt102_105avgrel[i,i] /TN=$r102105n vs Rel102_105V[i,i]
	appendtograph /L=L105107 /B=MRConCa rt105_107avgrel[i,i] /TN=$r105107n vs Rel105_107V[i,i]
	appendtograph /L=L107110 /B=MRConCa rt107_110avgrel[i,i]  /TN=$r107110n vs Rel107_110V[i,i]
	break
case "MRCon Sb":
	appendtograph /L=L90100 /B=MRConSb rt90_100avgrel[i,i] /TN=$r90100n vs Rel90_100v[i,i]
	appendtograph /L=L100102 /B=MRConSb rt100_102avgrel[i,i] /TN=$r100102n vs Rel100_102V[i,i]
	appendtograph /L=L102105 /B=MRConSb rt102_105avgrel[i,i] /TN=$r102105n vs Rel102_105V[i,i]
	appendtograph /L=L105107 /B=MRConSb rt105_107avgrel[i,i] /TN=$r105107n vs Rel105_107V[i,i]
	appendtograph /L=L107110 /B=MRConSb rt107_110avgrel[i,i]  /TN=$r107110n vs Rel107_110V[i,i]
	break
case "ConMR Ca":
	appendtograph /L=L90100 /B=ConMRCa rt90_100avgrel[i,i] /TN=$r90100n vs Rel90_100v[i,i]
	appendtograph /L=L100102 /B=ConMRCa rt100_102avgrel[i,i] /TN=$r100102n vs Rel100_102V[i,i]
	appendtograph /L=L102105 /B=ConMRCa rt102_105avgrel[i,i] /TN=$r102105n vs Rel102_105V[i,i]
	appendtograph /L=L105107 /B=ConMRCa rt105_107avgrel[i,i] /TN=$r105107n vs Rel105_107V[i,i]
	appendtograph /L=L107110 /B=ConMRCa rt107_110avgrel[i,i]  /TN=$r107110n vs Rel107_110V[i,i]
	break
case "ConMR Sb":
	appendtograph /L=L90100 /B=ConMRSb rt90_100avgrel[i,i] /TN=$r90100n vs Rel90_100v[i,i]
	appendtograph /L=L100102 /B=ConMRSb rt100_102avgrel[i,i] /TN=$r100102n vs Rel100_102V[i,i]
	appendtograph /L=L102105 /B=ConMRSb rt102_105avgrel[i,i] /TN=$r102105n vs Rel102_105V[i,i]
	appendtograph /L=L105107 /B=ConMRSb rt105_107avgrel[i,i] /TN=$r105107n vs Rel105_107V[i,i]
	appendtograph /L=L107110 /B=ConMRSb rt107_110avgrel[i,i]  /TN=$r107110n vs Rel107_110V[i,i]
	break
case "MRMR Ca":
	appendtograph /L=L90100 /B=MRMRCa rt90_100avgrel[i,i] /TN=$r90100n vs Rel90_100v[i,i]
	appendtograph /L=L100102 /B=MRMRCa rt100_102avgrel[i,i] /TN=$r100102n vs Rel100_102V[i,i]
	appendtograph /L=L102105 /B=MRMRCa rt102_105avgrel[i,i] /TN=$r102105n vs Rel102_105V[i,i]
	appendtograph /L=L105107 /B=MRMRCa rt105_107avgrel[i,i] /TN=$r105107n vs Rel105_107V[i,i]
	appendtograph /L=L107110 /B=MRMRCa rt107_110avgrel[i,i]  /TN=$r107110n vs Rel107_110V[i,i]
	break
case "MRMR Sb":
	appendtograph /L=L90100 /B=MRMRSb rt90_100avgrel[i,i] /TN=$r90100n vs Rel90_100v[i,i]
	appendtograph /L=L100102 /B=MRMRSb rt100_102avgrel[i,i] /TN=$r100102n vs Rel100_102V[i,i]
	appendtograph /L=L102105 /B=MRMRSb rt102_105avgrel[i,i] /TN=$r102105n vs Rel102_105V[i,i]
	appendtograph /L=L105107 /B=MRMRSb rt105_107avgrel[i,i] /TN=$r105107n vs Rel105_107V[i,i]
	appendtograph /L=L107110 /B=MRMRSb rt107_110avgrel[i,i]  /TN=$r107110n vs Rel107_110V[i,i]
	break	
endswitch
variable red,green,blue
	if (strsearch(bt[i],"MRCon",0)>=0)
		red = 65280
		green = 43520
		blue = 0
	elseif (strsearch(bt[i],"ConMR",0)>=0)
		red = 0
		green = 52224
		blue = 0
	else 
		red = 0
		green = 0 
		blue =65280
	endif
	modifygraph rgb($r90100n) = (red,green,blue)	
	modifygraph rgb($r100102n) = (red,green,blue)	
	modifygraph rgb($r102105n) = (red,green,blue)	
	modifygraph rgb($r105107n) = (red,green,blue)
	modifygraph rgb($r107110n) = (red,green,blue)
	
	ErrorBars $r90100n Y,wave=(rt90_100semrel[i,i],rt90_100semrel[i,i])
	ErrorBars $r100102n Y,wave=(rt100_102semrel[i,i],rt100_102semrel[i,i])
	ErrorBars $r102105n Y,wave=(rt102_105semrel[i,i],rt102_105semrel[i,i])
	ErrorBars $r105107n Y,wave=(rt105_107semrel[i,i],rt105_107semrel[i,i])
	ErrorBars $r107110n Y,wave=(rt107_110semrel[i,i],rt107_110semrel[i,i])
	
	
	
	
	i+=1
while (i<numpnts(bt))

ModifyGraph standoff(L90100)=0,standoff(V90100)=0,axisEnab(L90100)={0,0.2};DelayUpdate
ModifyGraph freePos(L90100)=0,freePos(V90100)=0;DelayUpdate
SetAxis L90100 0,1
ModifyGraph axisOnTop(L90100)=1,axisOnTop(L100102)=1,axisOnTop(L102105)=1;DelayUpdate
ModifyGraph axisOnTop(L105107)=1,axisOnTop(L107110)=1,standoff(L100102)=0;DelayUpdate
ModifyGraph standoff(L102105)=0,standoff(L105107)=0,standoff(L107110)=0;DelayUpdate
ModifyGraph freePos(L100102)=0,freePos(L102105)=0,freePos(L105107)=0;DelayUpdate
ModifyGraph freePos(L107110)=0;DelayUpdate
SetAxis L100102 0,1;DelayUpdate
SetAxis L102105 0,1;DelayUpdate
SetAxis L105107 0,1;DelayUpdate
SetAxis L107110 0,1
ModifyGraph axisEnab(L100102)={0.2,0.4},axisEnab(L102105)={0.4,0.6};DelayUpdate
ModifyGraph axisEnab(L105107)={0.6,0.8},axisEnab(L107110)={0.8,1}
ModifyGraph standoff(bottom)=0
ModifyGraph tickZap(L100102)={0},tickZap(L102105)={0},tickZap(L105107)={0};DelayUpdate
ModifyGraph tickZap(L107110)={0}

ModifyGraph axisEnab(V107110)={0.8,1}
ModifyGraph msize(r90100L2140)=3,msize(r100102L2140)=3,msize(r102105L2140)=3;DelayUpdate
ModifyGraph msize(r105017L2140)=3,msize(r107110L2140)=3
ModifyGraph tkLblRot(bottom)=60
ModifyGraph axisEnab(L100102)={0,1},axisEnab(L102105)={0,1};DelayUpdate
ModifyGraph axisEnab(L105107)={0,1},axisEnab(L107110)={0,1};DelayUpdate
SetAxis L90100 0,0.8;DelayUpdate
SetAxis L100102 0,0.8;DelayUpdate
SetAxis L102105 0,0.8;DelayUpdate
SetAxis L105107 0,0.8;DelayUpdate
SetAxis L107110 0,0.8
ModifyGraph standoff(MRConSb)=0,standoff(ConMRCa)=0,standoff(ConMRSb)=0;DelayUpdate
ModifyGraph standoff(MRMRCa)=0,axisEnab(MRConCa)={0,0.16};DelayUpdate
ModifyGraph axisEnab(MRConSb)={0.17,0.32},axisEnab(ConMRCa)={0.33,0.5};DelayUpdate
ModifyGraph axisEnab(ConMRSb)={0.51,0.67},axisEnab(MRMRCa)={0.68,0.84};DelayUpdate
ModifyGraph axisEnab(MRMRSb)={0.85,1}

ModifyGraph standoff=0,freePos(MRConCa)=0,freePos(MRConSb)=0,freePos(ConMRCa)=0;DelayUpdate
ModifyGraph freePos(ConMRSb)=0,freePos(MRMRCa)=0,freePos(MRMRSb)=0;DelayUpdate
SetAxis MRConCa 14,15;DelayUpdate
SetAxis MRConSb 14,15;DelayUpdate
SetAxis ConMRCa 14,15;DelayUpdate
SetAxis ConMRSb 14,15;DelayUpdate
SetAxis MRMRCa 14,15;DelayUpdate
SetAxis MRMRSb 14,15
ModifyGraph nticks(MRConCa)=2,nticks(MRConSb)=2,nticks(ConMRCa)=2;DelayUpdate
ModifyGraph nticks(ConMRSb)=2,nticks(MRMRCa)=2,nticks(MRMRSb)=2
ModifyGraph tickZap(MRConSb)={14},tickZap(ConMRCa)={14},tickZap(ConMRSb)={14};DelayUpdate
ModifyGraph tickZap(MRMRCa)={14},tickZap(MRMRSb)={14}
Label MRConCa "MR Con Ca"
Label MRConSb "MR Con Sb"
Label ConMRCa "Con MR Ca"
Label ConMRSb "Con MR Sb"
Label MRMRCa "MRMR Ca"
Label MRMRSb "MRMR Sb"
ModifyGraph lblPosMode(MRConCa)=1,lblPosMode(MRConSb)=1,lblPosMode(ConMRCa)=1;DelayUpdate
ModifyGraph lblPosMode(ConMRSb)=1,lblPosMode(MRMRCa)=1,lblPosMode(MRMRSb)=1

ModifyGraph axisEnab(L100102)={0.2,0.4},axisEnab(L102105)={0.4,0.6};DelayUpdate
ModifyGraph axisEnab(L105107)={0.6,0.8},axisEnab(L107110)={0.8,1}
end	