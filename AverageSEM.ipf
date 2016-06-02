function avgsemvswave([ywaven,xwaven,chartname,SEMplot])
string ywaven, xwaven, chartname
variable SEMplot
string legendtext=""

if (paramisdefault(ywaven) ) //if y wave and x wave names weren't passed, then prompts user for names in first named folder
	gotofirstpopulatedfolder()
	string menustr = WaveList("*", ";", "" )
	prompt ywaven, "Which wave do you want average and SEM for?", popup, menustr
	prompt xwaven, "Which wave is the independent variable we want common values for?", popup, menustr
	doprompt "Select waves for average/SEM calculation", ywaven,xwaven
	if (v_flag==1)
		killwindow averageSEMchart
		Print "User clicked cancel"
		Abort
	endif
endif
					
if (paramisdefault(chartname))
	chartname = "Avg"+possiblyquotename(ywaven)+"vs"+possiblyquotename(xwaven)
endif

dowindow $chartname
if (v_flag==0)
	display /N=$chartname
endif

if (paramisdefault(semplot))
	semplot=4 //assumes that we want to add +/- SEM banded waves to back of chart instead of adding error bars
endif

string ListofWaves,ListofXWaves,AvgWname,SEMWname,XWName
AvgWName = ywaven+"avg"
SEMWName = ywaven+"SEM"
XWName = xwaven+"ind"

setdatafolder root:
variable typeindex=0
do
	string typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	ListofWaves=""
	ListofXWaves=""
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
					ListOfWaves += getdatafolder(1)+ywaven+";"
					ListofXwaves += getdatafolder(1)+xwaven+";"
				endif
				batteryindex+=1
				setdatafolder root:
				setdatafolder $typename
			while(1)
	endif
		avSEMcalc(ListofWaves,ListofXWaves,AvgWname,SEMWname,XWName)
	setdatafolder root:
	typeindex+=1
while(1)

if (semplot==2)
	setdatafolder root:
	typeindex=0
	do
		typename= GetIndexedObjName(":",4,typeindex)
		if (strlen(typename)==0)
			break
		endif
		setdatafolder $typename
		nvar red,green,blue
		nvar /Z skip
		if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
				wave yavg=$avgWName
				wave ysem=$SEMWname
				wave xind=$XWName
				string ypn=ywaven +"pSEM"
				string ymn=ywaven +"mSEM"
				duplicate yavg  $ypn, $ymn
				wave yp = $ypn
				wave ym =$ymn
				
				yp = yavg+ysem
				ym = yavg-ysem
				string tnp=typename+ypn
				string tnm=typename+ymn
				appendtograph /W=$chartname /L=$avgWName yp /TN=$tnp vs xind
				appendtograph /W=$chartname /L=$avgWName ym /TN=$tnm vs xind
				
				modifygraph rgb($tnp)=(red,green,blue,10000)
				modifygraph rgb($tnm)=(red,green,blue,10000)
				
				ModifyGraph mode($tnp)=7,lsize($tnp)=0,tomode($tnp)=1, hbFill($tnp)=2
				ModifyGraph lsize($tnm)=0

				waveclear yavg,ysem,yp,ym
		endif
		setdatafolder root:
		typeindex+=1
	while(1)
endif

setdatafolder root:
typeindex=0
do
	typename= GetIndexedObjName(":",4,typeindex)
	if (strlen(typename)==0)
		break
	endif
	setdatafolder $typename
	nvar red,green,blue
	nvar /Z skip
	if ( (!nvar_exists(skip)) || ( (nvar_exists(skip)) && (skip!=1) ) )
			wave yavg=$avgWName
			wave xind=$XWName
			wave ysem=$SEMWNAme
			string tn=typename+avgWname
			appendtograph /W=$chartname /L=$avgWName yavg /TN=$TN vs xind
			modifygraph rgb($tn)=(red,green,blue)
			ErrorBars $tn SHADE= {0,0,(red,green,blue,6554),(0,0,0,0)},wave=(ysem,ysem)
			modifygraph lsize($tn)=2
			waveclear yavg,ysem,xind
	endif
	setdatafolder root:
	typeindex+=1
while(1)


end

Function avsemcalc(ListOfWaves, ListOfXWaves, AvgWname, SEMWName,XWName)
	String ListOfWaves		// Y waves
	String ListOfXWaves		// X waves list. Pass "" if you don't have any.
	String AvgWname 
	String SEMWName
	String XWNAME
	Variable ErrorType		= 1 // (1 for SEM, 0 for no error wave)
	
	Variable numWaves = ItemsInList(ListOfWaves)
	if (numWaves < 2 )
		ErrorType= 0	// don't generate any errors when "averaging" one wave.
	endif
	
	// check the input waves, and choose an appropriate algorithm
	Variable maxLength = 0
	Variable differentLengths= 0
	Variable differentXRanges= 0
	Variable firstDeltaX=NaN					// 6.35: keep track of common deltaX for waveforms.
	Variable firstLeftX=NaN, firstRightX=NaN	// 6.38: keep track of common left/right x range (use point-by-point averaging if all X scaling is identical).
	Variable differentDeltax= 0	// 6.35: use interpolation if deltax's are different, even if simply reversed in sign.
	Variable thisXMin, thisXMax, thisDeltax
	Variable minXmin, maxXmax, minDeltax
	Variable numXWaves=0
	String firstXWavePath = StringFromList(0,ListOfXWaves)
	Variable XWavesAreSame=1	// assume they are until proven differently. Irrelevant if	numXWaves!=numWaves
	Variable i, tmp
	
	variable longestwaveindex=0
	for (i=0; i< numWaves; i+=1)
		variable maxwavept=-1
		string xwn=StringFromList(i,ListofXWaves)
		wave xw=$xwn
		wavestats /q xw
		if (v_max > maxwavept)
			maxwavept=v_max
			longestwaveindex=i
		endif
		waveclear xw
	endfor
	
	wave xw=$StringFromList(longestwaveindex,ListofXWaves)
	duplicate /o xw $XWName
	wave xind = $XWName
	
	Make/N=(numpnts(xind))/D/FREE AveW, TempNWave		// initially 0
	Wave w=$StringFromList(0,ListOfWaves)		
	for (i = 0; i < numWaves; i += 1)
			WAVE w=$StringFromList(i,ListOfWaves)
			WAVE x=$StringFromList(i,ListofXWaves)
			make /n=(numpnts(xind)) winterp
			MultiThread winterp = interp(xind, x, w )
			MultiThread winterp[] = (x[p]<=maxwavept) ? winterp[p] : NaN
			MultiThread AveW[]      += (numtype(winterp[p]) == 0) ? winterp[p] : 0
			MultiThread TempNWave[] += numtype(winterp[p]) ==0
			waveclear w,x
			killwaves winterp
	endfor
		
	MultiThread AveW /= TempNWave
	Duplicate/O AveW, $AvgWname
	
	if (ErrorType)
		Duplicate/O AveW, $SEMWName
		Wave SDW=$SEMWName
		SDW = 0
		i=0
		for (i = 0; i < numWaves; i += 1)
			WAVE w=$StringFromList(i,ListOfWaves)
			WAVE x=$StringFromList(i,ListofXWaves)
			make /n=(numpnts(xind)) winterp
			MultiThread winterp = interp(xind, x, w )
			MultiThread winterp[] = (x[p]<=maxwavept) ? winterp[p] : NaN
			MultiThread SDW[] += (numtype(winterp[p]) == 0) ? (winterp[p]-AveW[p])^2 : 0
			waveclear w,x
			killwaves winterp
		endfor
		MultiThread SDW /= (TempNWave-1)
		MultiThread SDW =sqrt(SDW)
		MultiThread SDW /=sqrt(TempNWave)
		//MultiThread SDW = sqrt(SDW)			// SDW now contains s.d. of the data for each point
		//MultiThread SDW /= sqrt(TempNWave)	// SDW now contains standard error of mean for each point
	else
		make /n=(numpnts(xind)) $SEMWName
		wave semw = $SEMWName
		semw = NaN
	endif
	
	
	
	//return doPointForPoint
End