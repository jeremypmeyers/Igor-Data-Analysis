function /s lcs(s,t)
string s
string t
variable m = strlen(s)
variable n = strlen(t)
make /n=(m+1,n+1) /free counter
variable longest=0
string lc=""
variable i,j
	for(i=0;i<m;i+=1)	
		for(j=0;j<n;j+=1)
			if (cmpstr(s[i],t[j])==0)
				variable c=counter[i][j]+1
				counter[i+1][j+1]=c
				if (c>longest)
					lc=""
					longest=c
					lc+=S[i-c+1,i]
				elseif (c==longest)
					lc+=";"+S[i-c+1,i]
				endif
			endif
		endfor
	endfor						// Execute body code until continue test is FALSE
return lc
end

function folder(pn)
string pn
variable nv=executealltypes(" ")
print nv
setdatafolder root:
string pathname = pn
string fl=indexedfile($pathname,-1,".csv")
fl+=indexedfile($pathname,-1,".xlsx")
fl+=indexedfile($pathname,-1,".xls")
fl+=indexedfile($pathname,-1,".txt")

wave /T filew
wave filetypes
print "# items = ",itemsinlist(fl,";")
redimension /n=(itemsinlist(fl,";")) filew
print numpnts(filew)
redimension /n=(itemsinlist(fl,";")) filetypes
print numpnts(filetypes)
print StringByKey("NUMTYPE", waveinfo(filew,0))


wave /t fw=ListToTextWave(fl, ";")
filew = fw

fl=replacestring(".csv",fl,"")
fl=replacestring(".xlsx",fl,"")
fl=replacestring(".xls",fl,"")
fl=replacestring(".txt",fl,"")


fl=replacestring("_",fl," ")
fl=replacestring("-",fl," ")
fl=replacestring("__",fl," ")
fl=replacestring("%",fl,"")
string completelist=fl
//removes standard Bitrode test datestamps
fl=replacestring("Test",fl,"")
string regexp="([[:digit:]]{10,} [A-E][[:digit:]]{1,2})"
string extracted
splitstring /E=regexp fl, extracted
do
	fl=replacestring(extracted,fl,"")
	splitstring /E=regexp fl, extracted
while (strlen(extracted)>0)


fl=mrprotect(fl)

variable i
for(i=0;i<20;i+=1)	
	fl=replacestring(" ;",fl,";")
	fl=replacestring("; ",fl,";")
endfor	
fl=trimstring(fl,1)
print fl
variable li=itemsinlist(fl)
make /n=(li,li) /FREE levarray

i=0
do
	variable j=0
	do
		levarray[i][j]=lev(stringfromlist(i,fl),stringfromlist(j,fl))
		j+=1
	while(j<li)
	i+=1
while(i<(li))
wavestats /q levarray
i=0
do	
	levarray[i][i] = NaN
	i+=1
while(i<li)
i=0
	make /n=(li) /FREE /T indices	
do 
	duplicate /o /free levarray w
	redimension /n=(li) indices
	indices=num2str(p)
	grouping(w,indices,(2^(1-i)))
	if (numpnts(indices)>=nv)
		break
	endif
	print "levdistance=",2^(1-i),"number of groups=",numpnts(indices)
	i+=1
while(i<=2)
i=0
do
	j=0
	do
		string index=stringfromlist(j,indices[i])
		if (strlen(index)==0)
			break
		endif
		print i,stringfromlist(str2num(index),completelist)
		filetypes[str2num(index)]=i
		j+=1
	while(1)
i+=1
while(i<numpnts(indices))
end


function lev(s1,s2)
string s1
string s2
variable m=strlen(s1)
variable n=strlen(s2)
make /N=(m+1,n+1) /free D
D=0
variable i,j
for(i=0;i<=m;i+=1)	
	for(j=0;j<=n;j+=1)
		D[i][0]=i
		D[0][j]=j
	endfor
endfor

for(j=1;j<=n;j+=1)
	for(i=1;i<=m;i+=1)
		if (cmpstr(s1[i-1],s2[j-1])==0)
			D[i][j]=D[i-1][j-1]
		else
			D[i][j]=min(D[i-1][j]+1,min(D[i][j-1]+1,D[i-1][j-1]+1))
		endif
	endfor
endfor	
return d[m][n]
end

function /S reduction(w,sl)
wave w
string sl
wave /t combo=listtotextwave(sl,";")
do
	wavestats /q w
	print v_min,v_minrowloc,v_mincolloc
	if (v_min>1)
		break
	endif
	variable minloc=min(v_mincolloc,v_minrowloc)
	variable maxloc=max(v_mincolloc,v_minrowloc)
	combo[minloc] = "("+combo[minloc]+","+combo[maxloc]+")"
	deletepoints maxloc,1,combo
	variable i=0
	do
		w[minloc][i]=max(w[v_minrowloc][i],w[v_mincolloc][i])
		i+=1
	while(i<dimsize(w,0))
	i=0
	do
		w[i][minloc]=w[minloc][i]
		w[i][i]=NaN
		i+=1
	while(i<dimsize(w,0))
	deletepoints /M=0 (maxloc),1, w
	deletepoints /M=1 (maxloc),1, w
while(dimsize(w,0)>1)
print combo
string sn=" "+combo[0]
return sn
end

function grouping(w,indices,ld)
wave w
wave /t indices
variable ld
//make /N=(dimsize(w,0)) /T indices
//indices=num2str(p)
do
	wavestats /q w
	if (v_min>ld)
		break
	endif
	variable minloc=min(v_mincolloc,v_minrowloc)
	variable maxloc=max(v_mincolloc,v_minrowloc)
	indices[minloc] = indices[minloc]+";"+indices[maxloc]
	deletepoints maxloc,1,indices
	variable i=0
	do
		w[minloc][i]=max(w[v_minrowloc][i],w[v_mincolloc][i])
		i+=1
	while(i<dimsize(w,0))
	i=0
	do
		w[i][minloc]=w[minloc][i]
		w[i][i]=NaN
		i+=1
	while(i<dimsize(w,0))
	deletepoints /M=0 (maxloc),1, w
	deletepoints /M=1 (maxloc),1, w
while(dimsize(w,0)>1)
end

function /S MRprotect(fn)
string fn
string completed=""
wave /t checkw=listtotextwave(fn,";")
variable i=0
	for(i=0;i<numpnts(checkw);i+=1)	// Initialize variables;continue test
		string		regexp ="(MR[[:digit:]]{1,3}?[. ][[:digit:]]{1,3}"
					regexp+="|MR[[:digit:]]{1,3})"

		string extracted
		splitstring /E=regexp checkw[i], extracted
		string mrcontent=extracted
		checkw[i] =ReplaceString(extracted, checkw[i], "%%%%%%")
		regexp="([[:digit:]])"
		splitstring /E=regexp checkw[i], extracted
		do
			checkw[i]=replacestring(extracted,checkw[i],"")
			splitstring /E=regexp checkw[i],extracted
		while(strlen(extracted)>0)
		checkw[i]=replacestring("%%%%%%",checkw[i],mrcontent)
		if (strlen(completed)>0)
			completed+=";"
		endif
		completed+=checkw[i]
	endfor	
return completed
end

function gendefaulttypes()
wave /T filew
wave filetypes
wavestats /q filetypes
make /n=(v_max+1)/o filenumbers
make /n=(v_max+1)/o /T defaultfolders
string flist=""
variable i=0
do
	filenumbers[i]=i
	defaultfolders[i] = getindexedobjname(":",4,i)
	i+=1
while (i<=v_max)
END