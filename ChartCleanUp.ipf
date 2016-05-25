function cleanaxes(chartname)
string chartname
modifygraph /W=$chartname axisontop=1, axoffset=0, font="Arial",freepos=0,standoff=0
ModifyGraph lblPosMode=1,lblMargin=5

string axl=AxisList(chartname)
variable axi=0
variable axcount=0
do
	string axn=StringFromList(axi, axl)
	if (strlen(axn)==0)
		break
	endif
	string axinf=axisinfo(chartname,axn)
	//print axinf
	if (cmpstr("left",StringByKey("AXTYPE", axinf))==0)
		axcount+=1
		print axn,axcount
	endif
	axi+=1
while(1)
print "check",axcount
if (axcount>1)
	axi=0
	variable axcounter=0
	do
		axn=StringFromList(axi, axl)
		if (strlen(axn)==0)
			break
		endif
		axinf=axisinfo(chartname,axn)
		print axn,stringbykey("AXTYPE",axinf)
		if (cmpstr("left",StringByKey("AXTYPE", axinf))==0)		
			variable gap=0.03
			variable seg=(1-axcount*gap)/axcount
			variable lowfrac = axcounter*(seg+gap)
			variable hifrac = axcounter*(seg+gap)+seg
			if (hifrac>0.95)
				hifrac=1
			endif
			modifygraph /W=$chartname axisenab($axn)={lowfrac,hifrac}
			axcounter+=1
		endif
		axi+=1
	while(1)
endif
end