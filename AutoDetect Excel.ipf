#pragma TextEncoding = "MacRoman"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <FilterDialog> menus=0


function ymd()
variable y, m, d
sscanf secs2date(datetime,-2), "%f-%f-%f",y,m,d
print y
print m
print d
end

function xl()

string fn=getXLfile()

XLLoadWave /J=1 /Q fn
print s_value

string sn
prompt sn, "Select sheetname",popup, s_value
doprompt "Which sheet to import?",sn
//=StringFromList(1, s_value)
XLLoadWave /J=2 /S=sn /Q fn
print s_value

variable timenum=startmstimer
variable firstrow=numberbykey("FIRSTROW",s_value)
variable lastrow=numberbykey("LASTROW",s_value)
XLLoadWave /J=3 /S=sn /Q fn
print s_value
string cellfirst=stringbykey("FIRST",s_value)
string celllast=stringbykey("LAST",s_value)
variable samplerow=min(100,floor(lastrow/2))
string cellsample=stripnumbers(celllast)+num2str(samplerow)

XLLoadWave /S=sn /Q /COLT="T" /o /R=($cellfirst,$cellsample) fn
XLLoadWave /S=sn /Q /A /C=(samplerow) /o /R=($cellfirst,$cellsample) fn


string wl=wavelist("Column*",";","")
string wn=stringfromlist(0,wl)
wave /T wa = $wn
variable k=(numpnts(wa)-1)
print "startingpoint= ",k

string wl2=wavelist("Wave*",";","")

variable i=0
wn=stringfromlist(0,wl)
wave /T wa=$wn
make /N=(numpnts(wa)) /o numberoftextwaves,totalstringlength
numberoftextwaves=0
totalstringlength=0
variable numberofnumericwaves=0
do
		wn=stringfromlist(i,wl)
		string wn2=stringfromlist(i,wl2)
		if (strlen(wn)==0)
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
print stopmstimer(timenum)/1e6
killwaves /a/z
cellfirst=stripnumbers(cellfirst)+num2str(firstrow+firstdatarow)
headerrow+=firstrow

XLLoadWave /S=sn /Q /W=(headerrow)  /C=(samplerow) /o /R=($cellfirst,$celllast) fn
print s_wavenames
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

