#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function architectureupdate()
setdatafolder root:
svar /Z vwavename
svar /Z curwavename
svar /Z totaltimename
svar /Z steptimename
svar /Z capname
svar /Z discapname
svar /Z stepname
svar /Z cyclename
nvar /Z timeunits

setdatafolder root:
variable /G procedureversion=1.0
variable typeindex=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
	nvar red,green,blue
	variable r=red
	variable g=green
	variable b=blue
			variable batteryindex=0
			do
				string batteryname=GetIndexedObjName(":",4,batteryindex)
				if (strlen(batteryname)==0)
					break
				endif
				setdatafolder $batteryname
				nvar /Z skip
				if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
					variable /g red=r
					variable /g green=g
					variable /g blue=b
					if (svar_exists(vwavename))
						wave v=$vwavename
						rename v Voltage
						waveclear v
					endif
					if (svar_exists(curwavename))
						wave a=$curwavename
						rename a Current
						waveclear a
					endif
					if (svar_exists(totaltimename))
						wave rt=$totaltimename
						rename rt RunTime
						waveclear rt
					endif		
					if (svar_exists(steptimename))
						wave st=$steptimename
						rename st StepTime
						waveclear st
					endif				
					if (svar_exists(capname))
						wave cap=$capname
						rename cap Capacity
						waveclear cap
					endif	
					if (svar_exists(discapname))
						wave dc=$discapname
						rename dc DischargeCap
						waveclear dc
					endif	
					if (svar_exists(stepname))
						wave step=$stepname
						rename step StepID
						waveclear step
					endif	
					if (svar_exists(cyclename))
						wave cyc=$cyclename
						rename cyc Cycle
						waveclear cyc
					endif	
				variable /G names_standardized = 1
				string /G timeunit
				switch (timeunits)
				case 0:
					timeunit="Seconds"
					break
				case 1:
					timeunit="Minutes"
					break
				case 2:
					timeunit="Hours"
					break
				endswitch
				variable /G timescaled=1
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			endif
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)
	setdatafolder root:
	variable /g procedureversion=1.0
end
