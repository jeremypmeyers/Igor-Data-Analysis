function csv(pathname,filename)
//variable numwaves=V_flag
string pathname//=S_path
string filename//=S_filename
pathinfo pathname
print "Successfully found \"pathname\" and location is ",s_path 
loadwave /A /j /B="C=100,F=-2;" /L={0,0,90,0,0} /P=$pathname filename

//string pathname="X:Data, Partners:Eastman, India:Tubular, 80Ah Rickshaw, 12V:Raw Data:"
//string filename="Test_20160223095539_C4 Flat MR1.csv"
//NewPath /o defpath  , pathname
//pathinfo defpath

loadwave /A /j /B="C=100,F=-2;" /L={0,0,90,0,0} /P=$pathname filename

//loadwave /A /j /B="C=500,F=-2;" /L={0,0,90,0,0} /P=$"defpath"  filename
string stext=s_wavenames

loadwave /A /j /L={0,0,90,0,0} /P=$pathname  filename
string smixed=s_wavenames

variable numwaves=V_flag
make /n=90 numberoftextwaves,stringlength
numberoftextwaves=0
stringlength=0
variable i=0
do
	string textwn=stringfromlist(i,stext)
	if (strlen(textwn)==0)
		break
	endif
	wave /t tw=$textwn
	make /n=(numpnts(tw)) nt,asl
	multithread nt=(numtype(str2num(tw))==2)
	multithread asl=nt*strlen(tw)
	numberoftextwaves+=nt
	stringlength+=asl
	killwaves nt,asl 
	i+=1
while(i<numwaves)

	stringlength/=numwaves
	wavestats /q numberoftextwaves
	variable firstdatarow=v_minloc
	multithread stringlength[]= (numberoftextwaves==v_max) ? stringlength[p] : NaN
	wavestats /q stringlength
	if (numberoftextwaves[v_maxloc]>= (0.8*itemsinlist(smixed)) )
		variable headerrow=v_maxloc
		i=0
		string columninfostring=""
		do
			string wn=stringfromlist(i,smixed)
			wave wa=$wn
			wavestats /q /R=[firstdatarow] wa
			if (v_numNans>0.5*V_npnts)
				columninfostring+="C=1,F=-2;"
			else
				columninfostring+="C=1,F=0,T=4;"
			endif
		i+=1
		while(i<numwaves)
		killwaves /a/z
		loadwave /J/O/W/A/Q /B=ColumnInfoString /L={(headerrow),(firstdatarow),0,0,0} /P=$pathname  filename
	else
		print "No column headers provided"
		i=0
		do
			string dw=stringfromlist(i,stext)
			if (strlen(dw)==0)
				break
			endif
			wave wa = $dw
			killwaves wa
			i+=1
		while(1)
	endif
end