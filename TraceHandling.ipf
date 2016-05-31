function /S maketracename(yname,type,battery,chartname)
string yname,type,battery,chartname
string tn=(yname+type+battery)
tn =ReplaceString("'", tn, "")
tn=cleanupname(tn,0)
tn =ReplaceString("_",tn,"")

if (strlen(tn)>31)
	tn=tn[0,30]
	if (StringMatch(TraceNameList(chartname, ";", 1 ), "*"+tn+"*" )!=0)
		variable i=50
		do
			if (i==58)
				i+=7
			endif
			tn[strlen(tn)-2,strlen(tn)-1]="_"+num2char(i)
			i+=1
		while (StringMatch(TraceNameList(chartname, ";", 1 ), "*"+tn+"*" )!=0)
	endif
else
	If (StringMatch(TraceNameList(chartname, ";", 1 ), "*"+tn+"*" )!=0)
		tn+="__"
		i=50
		do
			if (i==58)
				i+=7
			endif
			if (i==91)
				i+=6
			endif
			tn[strlen(tn)-2,strlen(tn)-1]="_"+num2char(i)
			i+=1
		while (StringMatch(TraceNameList(chartname, ";", 1 ), "*"+tn+"*" )!=0)
	endif
endif
return tn
end