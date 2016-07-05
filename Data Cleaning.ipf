#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function WaveTypeCorrection()
setdatafolder root:
string allstrings ="RunTime; StepTime"
make /N=8 changes
changes=0
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
			variable i=0
			do
				string stringcheck="root:"+StringFromList(i, allstrings) //stringcheck is the name of the string containing wave information
				svar /Z scheck = $stringcheck				 //scheck is the global string variable we are looking at right now
				if (svar_exists(scheck))
					wave wa=$scheck					//wa is the wave with the local name 
					if (wavetype(wa,1)==2)
					changes[i]=1
					if  ((strsearch(stringcheck,"totaltimename",0)>=0) || (strsearch(stringcheck,"steptimename",0)>=0))
						stringtimetotime(waven=scheck)
					else
						wave /T wt=$scheck
						string corrwn = scheck +"corr"
						make /N=(numpnts(wt)) $corrwn
						wave wcorr=$corrwn
						variable j=0
						do
							wcorr[j] = str2num(wt[j])
							j+=1
						while (j<numpnts(wcorr))
					endif
				endif
			endif
			i+=1
			while (i<8)
			endif
			batteryindex+=1
			setdatafolder root:
			setdatafolder $typename
			while(1)
	endif
	setdatafolder root:
	typeindex+=1
while(1)

i=0
do
	stringcheck="root:"+StringFromList(i, allstrings) //stringcheck is the name of the string containing wave information
	svar /Z scheck = $stringcheck				 //scheck is the global string variable we are looking at right now
	if (changes[i]!=0)
	 scheck += "corr"
	endif
	i+=1
while (i<8)
killwaves changes

end



function textwavestowaves()
make /free /n=6 /T keywavenames ={"Voltage","Current","Capacity","DischargeCap","StepID","Cycle"}
variable i=0
do
	string wn=keywavenames[i]
	wave /Z wa = $wn
	if (waveexists(wa))
		if (numberbykey("NUMTYPE",waveinfo(wa,0))==0)
			string wnt = wn+"text"
			rename wa $wnt 
			wave /T wt = $wnt
			make /N=(numpnts(wt)) $wn
			wave wa=$wn
			variable commas,dots
			commas=0
			dots=0
			make /n=(numpnts(wt)) /FREE comma
			multithread comma = strsearch(wt,",",0)
			wavestats /q comma
			if (v_avg >0)
				commas=v_avg
				make /n=(numpnts(wt)) /FREE dot
				multithread dot = strsearch(wt,".",0)
				wavestats /q dot
				if (v_avg>0)
					dots=v_avg
					if (dots<commas)
						print "Dot is thousands separator and comma is decimal."
						duplicate /FREE /T wt wttemp
						wttemp = replacestring(".",wt,"")
						wttemp = replacestring(",",wttemp,".")
						wa=str2num(wttemp)
						
					else
						print "Comma comes before dot; must be thousands separator."
						duplicate /FREE /T wt wttemp
						wttemp = replacestring(",",wttemp,"")
						wa=str2num(wttemp)
					endif
				else
					make /n=(numpnts(wt)) /FREE nextcomma
					multithread nextcomma[] = strsearch(wt[p],"," ,comma[p]+1)
					make /n=(numpnts(wt)) /O len
					len = strlen(wt)
					len[] = (comma[p]>0) ? len[p]-comma[p]-1 : NaN
					len[] = (nextcomma[p] >0) ? nextcomma[p]-comma[p]-1 : len[p]
					wavestats /q len
					if (v_avg==3)
						print "Comma is thousands separator"
						duplicate /FREE /T wt wttemp
						wttemp = replacestring(",",wttemp,"")
						wa=str2num(wttemp)
					else
						print "Comma is probably decimal point"
						duplicate /FREE /T wt wttemp
						wttemp = replacestring(",",wttemp,".")
						wa=str2num(wttemp)
					endif
				endif
			else
				wa=str2num(wt)
			endif
			
		endif
	endif
	i+=1
while (i<6)

make /free /n=2 /T timewavenames={"RunTime","StepTime"}
i=0
do
	wn = timewavenames[i]
	wave /Z wa = $wn
	if (waveexists(wa))
		if (numberbykey("NUMTYPE",waveinfo(wa,0))==0)
			stringtimetotime(waven=wn)
		endif
	endif
	i+=1
while(i<2)

end


function stringtimetotime([waven])
string waven //wave name of HHH:MMM:SSS textwave

if (paramisdefault(waven))
string startfolder=getdatafolder(1)
	setdatafolder root:
	gotofirstpopulatedfolder()	
	string wl = wavelist("*time*",";","")
	wl += wavelist("*",";","")
	prompt waven, "Enter time wave to convert to numerical",popup, wl
	doprompt "Select time wave for conversion",waven
setdatafolder $startfolder
endif

wave /T watxt = $waven
string wnt=waven+"text"
rename watxt $wnt
make /N=(numpnts(watxt)) /D /O $waven
wave corrwa = $waven
variable i=0
do
	string ti = watxt[i]
	variable timestep = 0
	
	variable yearpos=strsearch(ti,"-",0)
	if (yearpos<0)									//any hyphenated date separation?
		variable hrpos=strsearch(ti,":",0)
		variable hr = str2num(ti[0,hrpos-1])
	else
		variable monpos=strsearch(ti,"-",yearpos+1)
		variable daypos=strsearch(ti," ",monpos+1)
		hrpos=strsearch(ti,":",daypos+1)

		variable year= str2num(ti[0,yearpos-1])
		variable month= str2num(ti[yearpos+1,monpos-1])
		variable day= str2num(ti[monpos+1,daypos-1])
		hr = str2num(ti[0,hrpos-1])		
		timestep = date2secs(year, month, day )/3600
	endif
	
	variable minpos=strsearch(ti,":",hrpos+1)
	variable mi = str2num(ti[hrpos+1,minpos-1])
		
	variable secpos=strsearch(ti,":",minpos+1)

	variable ms=0
	
	if (secpos<0)
		variable se = str2num(ti[minpos+1,strlen(ti)-1])
	else
		se = str2num(ti[minpos+1,secpos-1])
		ms = str2num(ti[secpos+1,strlen(ti)-1])
	endif
	timestep += hr + mi/60 + se/3600 +ms/3600000	
	corrwa[i] = timestep
	corrwa[i] -= corrwa[0]
	i+=1
while (i<numpnts(watxt))
end

function /S gettimelabel()
//Goes to the first populated folder and returns the first timeunit
gotofirstpopulatedfolder()
svar timeunit
string tu=timeunit
setdatafolder root:
return tu
end


function ConcatenateDataSets()
setdatafolder root:
svar totaltimename,cyclename
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
					variable folderaddendum=2
					do
						string nextfoldertoadd="::"+batteryname+"_"+num2str(folderaddendum)
						if (!datafolderexists(nextfoldertoadd))
							break
						endif
						string wl=wavelist("*",";","")
						variable i=0
						do
							string wn=stringfromlist(i,wl)
							if (strlen(wn)==0)
								break
							endif			
							wave wa=$wn
							variable cumulative=0
							if ((cmpstr(wn,totaltimename)==0) || (cmpstr(wn,cyclename)==0))
								cumulative=1
							endif
							if (strsearch(wn, "total",0,2)>=0)
								cumulative=1
							endif
							if (strsearch(wn, "cum",0,2)>=0)
								cumulative=1
							endif	
							
							if (strsearch(wn, "cyclenumber",0,2)>=0)
								cumulative=1
							endif
							
							if (cumulative>0)						
							wavestats /Q wa
							variable lastpt = v_max
							if (v_min<0)
								lastpt = v_min
							endif
							string wnextname = nextfoldertoadd+":"+wn
							wave wnext = $wnextname
							wnext += lastpt	
							waveclear wnext
							endif
							wnextname = nextfoldertoadd+":"+wn
							wave /Z wnext = $wnextname
							if (waveexists(wnext))
								Concatenate /NP {wnext}, wa
							endif
							waveclear wa, wnext
							i+=1
						while(1)
						folderaddendum+=1
					while(1)
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

function fixtime()
setdatafolder root:
svar totaltimename
string tsn
gotofirstpopulatedfolder()
string tsmenustr=wavelist("*Time*",";","")+wavelist("*",";","")
setdatafolder root:
prompt tsn, "Enter name of wave with date/time stamp information", popup, tsmenustr
doprompt "Select time stamp to re-create elapsed time wave",tsn
string /G timestampname = tsn
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
					variable pindex=1
					wave timestamp=$timestampname
					wave totaltime=$totaltimename
					redimension /D totaltime 
					totaltime= timestamp-timestamp[0]
					totaltime/=3600
					do
						do
							if (totaltime[pindex]<totaltime[pindex-1])
								totaltime[pindex] +=24
							else
								break
							endif
						while(1)
						pindex+=1
					while (pindex<numpnts(totaltime))
					waveclear timestamp,totaltime		
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