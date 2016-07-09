#pragma TextEncoding = "MacRoman"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <FilterDialog> menus=0

function xl(fn,pathname,sheetselection,sheetname,sheetnumber)
string fn
string pathname
string sheetselection
string sheetname
variable sheetnumber

XLLoadWave /J=1 /Q /P=$pathname fn
string sheetnamelist=s_value
string sn

strswitch (sheetselection)
case "Location-based (1st, 2nd sheet, etc.)":
	sn=stringfromlist(sheetnumber-1,sheetnamelist)
	break
case "Specific sheet name":
	sn=sheetname
	break
case "Search for sheet with greatest number of columns":
	variable maxcol=0
	variable i=0
	do
		string sh=stringfromlist(i,sheetnamelist)
		if (strlen(sh)==0)
			break
		endif
		XLLoadWave /J=2 /S=sh /Q /P=$pathname fn
		variable cols=numberbykey("LASTCOL",s_value)-numberbykey("FIRSTCOL",s_value)
		if (cols>maxcol)
			maxcol=cols
			sn=sh
		endif
		print sh,sn,cols,maxcol
		i+=1
	while(1)
	break
endswitch
//string sn
//prompt sn, "Select sheetname",popup, s_value
//doprompt "Which sheet to import?",sn
//=StringFromList(1, s_value)
XLLoadWave /J=2 /S=sn /Q /P=$pathname fn
variable firstrow=numberbykey("FIRSTROW",s_value)
variable lastrow=numberbykey("LASTROW",s_value)
XLLoadWave /J=3 /S=sn /Q /P=$pathname fn
string cellfirst=stringbykey("FIRST",s_value)
string celllast=stringbykey("LAST",s_value)
variable samplerow=min(100,floor(lastrow/2))
string cellsample=stripnumbers(celllast)+num2str(samplerow)
XLLoadWave /S=sn /Q /A /COLT="T" /o /R=($cellfirst,$cellsample)/P=$pathname fn
XLLoadWave /S=sn /Q /C=(samplerow) /o /R=($cellfirst,$cellsample) /P=$pathname fn


string wl=wavelist("Wave*",";","")
string wn=stringfromlist(0,wl)
wave /T wa = $wn
variable k=(numpnts(wa)-1)

string wl2=wavelist("Column*",";","")
print itemsinlist(wl) , itemsinlist(wl2)
i=0
wn=stringfromlist(0,wl)
wave /T wa=$wn
//make /N=(numpnts(wa)) /o numberoftextwaves,totalstringlength
make /n=(samplerow-firstrow) /FREE /o numberoftextwaves, totalstringlength
numberoftextwaves=0
totalstringlength=0
variable numberofnumericwaves=0
do
		wn=stringfromlist(i,wl)
		string wn2=stringfromlist(i,wl2)
		if ((strlen(wn)==0)||(strlen(wn2)==0))
			break
		endif
		wave /T wa=$wn
		wave wb=$wn2
		if (NumberByKey("NUMTYPE", (waveinfo(wb,0)))!=0)
			numberofnumericwaves +=1
			make /N=(numpnts(wa)) nt,asl
			multithread nt=(numtype(str2num(wa))==2)
			multithread asl=nt*strlen(wa)
			numberoftextwaves +=nt
			totalstringlength +=asl
			killwaves nt,asl
		endif
	i+=1
while(1)
totalstringlength /=numberofnumericwaves
wavestats /q numberoftextwaves
variable firstdatarow=v_minloc
multithread totalstringlength[]= (numberoftextwaves==v_max) ? totalstringlength[p] : NaN
wavestats /q totalstringlength
variable headerrow=v_maxloc

cellfirst=stripnumbers(cellfirst)+num2str(firstrow+firstdatarow)
headerrow+=firstrow

if (numberoftextwaves[v_maxloc] > 0.5*itemsinlist(wl2))
	killwaves /a/z
	XLLoadWave /S=sn /Q /W=(headerrow)  /C=(samplerow) /o /R=($cellfirst,$celllast)/P=$pathname fn
else
	i=0
	print "No header/wave name information in file."
	killwaves /a/z
	XLLoadWave /S=sn /Q /C=(samplerow) /o /R=($cellfirst,$celllast)/P=$pathname fn
endif
end

function /s stripnumbers(stripstring)
string stripstring
variable i=0
do
	stripstring=replacestring(num2str(i),stripstring,"")
	i+=1
while(i<=9)
return stripstring
end

