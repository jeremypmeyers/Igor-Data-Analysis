#pragma rtGlobals=3		// Use modern global access method and strict wave access.
// procedures for load Excel files
// latest update: May 27, 2016

function XLLoad([loadtype])
string loadtype
//This function figures out which Excel file to import via the getXLfile function.
//It then determines which sheets from that user-selected Excel file to import by calling
//the SelectSheets function.
//It then calls InputSheets to populate the data from each sheet in the appropriate
// root:Type:Battery: subfolder.
//The sheet selection process temporarily creates some textwaves to keep track of information.
//These waves are deleted and cleaned up with the cleanupfrom XLLoadfunction.
string filename = getXLfile() 					//prompts user to select Excel file for input
if (paramisdefault(loadtype))
	SelectSheets(filename)
else
	SelectSheets(filename,loadtype=loadtype) 	//generates a text wave "importedsheetnames" of the sheet names to input
endif

if (paramisdefault(loadtype))
	InputSheets(filename)
else
	InputSheets(filename,loadtype=loadtype)
endif
cleanupfromXLLoad()	
end

function /S getXLfile()

variable refnum=11
String message = "Select Excel File for input"
string outputPath																			
string fileFilters = "Excel Files (*.xls, *.xlsx,*xlsm): .xls,.xlsx, .xlsm ;" 
//This creates a filter to highlight Excel files
	   fileFilters+= "All Files :.*;"													
//Also allows the user to select from all files if extensions are wrong.

Open /D /R /F=fileFilters /M=message refnum // Prompts user to select file and saves path to chosen file as S_filename
outputPath = S_filename

if (strlen(S_filename)==0)
	Print "Cancelled opening file"
	Abort //If user cancels, aborts load.
endif
notebook Recording text="Loading from Excel file:\r"+outputPath+"\r"
return outputPath
end

function /S SelectSheets(filename,[loadtype])
string filename
string loadtype
XLLoadWave   /J=1  /Q filename

variable index=0
string sheetn
make /N=0 /T fullsheetnames
do
	sheetn = stringfromlist(index,s_value)
	if (strlen(sheetn)==0)
		break
	endif
	redimension /N=(numpnts(fullsheetnames)+1) fullsheetnames
	fullsheetnames[(numpnts(fullsheetnames)-1)] = sheetn
	index+=1
while(1)

string common
if (paramisdefault(loadtype))
	prompt common, "Enter string in sheetnames to prepopulate"
	string menustr="No;Yes;"
	string overrider
	prompt overrider, "Do you want to skip sheet selection?",popup,menustr
	DoPrompt "Sheet selection" , common,overrider
	if (V_flag)
		return common
	endif
elseif (cmpstr(loadtype,"Arbin")==0)
	common = "Channel"
	overrider="No"
endif
variable comv
variable numsheetsinfile=numpnts(fullsheetnames)

if (cmpstr(overrider,"No")==0)

	variable rowheight=30
	variable columnwidth=350
	variable windowheight = 15*rowheight + 100
	variable windowwidth = ceil(numpnts(fullsheetnames)/15)*columnwidth
	string checbxname
	NewPanel /W=(1,1,(windowwidth),(windowheight)) /N=sheetselect as "Select Sheets to Import"
	index=0
	do
		checbxname="cb"+num2str(index)
		comv=1
		if (strsearch(fullsheetnames[index],common,0)<0)
			comv=0
		endif
		variable hp =1 + trunc(index/15)*columnwidth
		variable vp = 1 +mod(index,15)*rowheight
		CheckBox $checbxname, fsize=14, value=comv,pos={hp,vp},title=(fullsheetnames[index])
		index+=1
	while (index<numpnts(fullsheetnames))
	variable bposw,bposh
	if (IgorVersion()>=7)
		bposw = windowwidth/2-200
		bposh = windowheight-150
	else
		bposw = windowwidth/2-150
		bposh = windowheight-50
	endif
	if (numsheetsinfile<75)
		Button b1,pos={(bposw),(bposh)},size={300,35},title="Close Window and Approve Selected Sheets", proc=StopProc
	else
		Button b1,pos={(0),(0)},size={300,35},title="Close Window and Approve Selected Sheets", proc=StopProc
	endif
	PauseForUser sheetselect
else
index=0
make /N=0 /T importedsheetnames
do
	comv=1
	if (strsearch(fullsheetnames[index],common,0)<0)
		comv=0
	endif
	if (comv==1)
		redimension /N=(numpnts(importedsheetnames)+1) importedsheetnames
		importedsheetnames[(numpnts(importedsheetnames)-1)]=fullsheetnames[index]
	endif
	index+=1
while (index<numpnts(fullsheetnames))
endif
return  sheetn
end

function stopproc(ctrlname) : buttoncontrol
	string ctrlname
	wave /T fullsheetnames
	make /N=0 /T importedsheetnames
	string checbxname
	variable index=0
	do
		checbxname = "cb"+num2str(index)
		variable sheetchecked
		controlinfo /W=sheetselect $checbxname
		sheetchecked=V_value
		print index, sheetchecked 
		if (sheetchecked==1)
			redimension /N=(numpnts(importedsheetnames)+1) importedsheetnames
			importedsheetnames[(numpnts(importedsheetnames)-1)]=fullsheetnames[index]
		endif
		index+=1
	while (index<numpnts(fullsheetnames))
	killwaves fullsheetnames
	KillWindow sheetselect // sheetselect
end

function InputSheets(filename,[loadtype])
string filename
string loadtype
string currentsheetname,currentfoldername,currentbattype
wave/Z /T importedsheetnames
variable /G startindex=0
variable /G finishindex=numpnts(importedsheetnames)-1
wave/Z /T batterynames

if (waveexists(batterynames))
	startindex=numpnts(batterynames)
	redimension /N=( numpnts(batterynames)+numpnts(importedsheetnames)) batterynames
	finishindex=numpnts(batterynames)-1
else
	make /T /N=(numpnts(importedsheetnames)) batterynames
endif

wave/Z /T foldernames
if (waveexists(foldernames))
	startindex=numpnts(foldernames)
	redimension /N=( numpnts(foldernames)+numpnts(importedsheetnames)) batterynames
	finishindex=numpnts(foldernames)-1
else
	make /T /N=(numpnts(importedsheetnames)) foldernames
endif 

if (paramisdefault(loadtype) )
	string leftcell=""
	string  rightcolumn=""
	variable headernamerow
	variable deducetyperow
	prompt leftcell, "What is the top left-most cell to input?"
	prompt rightcolumn, "What's the right-most column to input?"
	prompt headernamerow, "Which row contains wave/column header names?"
	prompt deducetyperow, "Which row should we use to deduce whether a column is number or string?"
	DoPrompt "Which rows and columns to input",leftcell, rightcolumn, headernamerow, deducetyperow
	rightcolumn+="999999"
elseif (cmpstr(loadtype,"Arbin")==0)
	leftcell="A1"
	rightcolumn="S999999"
	headernamerow=1
	deducetyperow=3
endif
setdatafolder root:
variable Qnamingprotocol=0
if (!paramisdefault(loadtype))
	if (cmpstr(loadtype,"Arbin")==0)
		string ms="Yes;No;"

		prompt Qnamingprotocol, "Is item ID naming protocol in place?",popup, ms
		doprompt "Naming protocol check",Qnamingprotocol

		if (Qnamingprotocol==1)
			XLLoadWave/S="Global_Info" /R=(L5,L40)/C=5/W=4 /Q filename
			XLLoadWave/S="Global_Info" /R=(A5,A40)/C=5/W=4 /Q filename
			wave /T Channel,Chan_Num
			make /T /N=(numpnts(Chan_Num)) batnamedefault, battypedefault
			variable spaceloc
			variable channelindex=0
			do
				spaceloc=strsearch(Chan_num[channelindex], " ",0)
				string batid=Chan_num[channelindex]
				batnamedefault[channelindex]=batid[0,(spaceloc-1)]
				battypedefault[channelindex]=batid[(spaceloc+1),(strlen(batid))]
				channelindex+=1
			while(channelindex<numpnts(chan_num))
		endif
	endif
endif

variable index=0
do
	setdatafolder root:
	currentsheetname=importedsheetnames[index]
	nvar loadcount
	currentfoldername=""
	string battypeprompt="Enter variable type for data from "+currentsheetname
	if (Qnamingprotocol==1)
		channelindex=0
		do
			if (strsearch(currentsheetname, channel[channelindex], 0)>=0)
				currentfoldername=batnamedefault[channelindex]
				battypeprompt="Enter variable type for "+battypedefault[channelindex]
			endif
			channelindex+=1
		while (channelindex<numpnts(channel))
	
	endif
	string foldernameprompt="Enter battery name for data imported from sheet "+currentsheetname
	prompt currentfoldername,foldernameprompt
	string menulist=""
	string objName
	variable findex=0
	do
		objName = GetIndexedObjName(":", 4, findex)
		if (strlen(objName) == 0)
			break
		endif
		if (findex>0)
			menulist+=";"
		endif
		menulist+= objName
		findex += 1
	while(1)
	currentbattype=GetIndexedObjName(":",4,0)
	prompt currentbattype,battypeprompt,popup,menulist
	string promptstring="Info for data from "+currentsheetname
	doprompt promptstring,currentbattype,currentfoldername
	
	currentfoldername = cleanupname(currentfoldername,1)
	if (checkname(currentfoldername,11)!=0)
		currentfoldername = uniquename(currentfoldername,11,1)
	endif
	
	setdatafolder $currentbattype
	nvar red,green,blue
	variable r=red
	variable g=green
	variable b=blue
	newdatafolder /o/s $currentfoldername
	XLLoadWave/S=currentsheetname /R=($leftcell,$rightcolumn)/C=(deducetyperow)/W=(headernamerow)/D/Q filename
	notebook Recording text="Import from "
	notebook Recording text=currentsheetname
	notebook Recording text=" to "
	notebook Recording text=getdatafolder(1)+"\r"
	variable /G red=r
	variable /G green=g
	variable /G blue=b
	variable /G loadorder=loadcount
	setdatafolder root:
	index+=1
while (index<numpnts(importedsheetnames))
if (Qnamingprotocol==1)
	killwaves Channel,Chan_Num, batnamedefault, battypedefault
endif
end

function cleanupfromXLLoad()	
wave /Z batterynames,foldernames,importedsheetnames,varnames,fullsheetnames
if (waveexists(batterynames))
	killwaves batterynames
endif
if (waveexists(foldernames))
	killwaves foldernames
endif
if (waveexists(importedsheetnames))
	killwaves importedsheetnames
endif
if (waveexists(varnames))
	killwaves varnames
endif
if (waveexists(fullsheetnames))
	killwaves fullsheetnames
endif
nvar /z finishindex,startindex
killvariables finishindex, startindex
end

Function LoadAllExcel([loadtype])
string loadtype
	String pathName			// Name of symbolic path or "" to get dialog
	String startfolder=getdatafolder(1)
	String fileName
	String graphName
	String sheetname=""
	Variable index=0

	NewPath/O temporaryPath			// This will put up a dialog
	if (V_flag != 0)
		Print "Cancelled opening file"
		Abort
	endif
	pathName = "temporaryPath"
	variable deducecolumns
	if (paramisdefault(loadtype))
		string leftcell="A1"
		string rightcolumn="Z"
		variable headernamerow=1
		variable deducetyperow=16
		prompt leftcell, "What is the top left-most cell to input?"
		prompt rightcolumn, "What's the right-most column to input?"
		prompt headernamerow, "Which row contains wave/column header names?"
		prompt deducetyperow, "Which row should we use to deduce whether a column is number or string?"
		prompt sheetname, "Is there a sheet name to input? Leave blank to input first sheet"
		DoPrompt "What should we input?",leftcell, rightcolumn, headernamerow, deducetyperow,sheetname
		deducecolumns=1
	else
		if (cmpstr(loadtype,"Eclipse 9-variable format")==0)
			leftcell="A2"
			rightcolumn="I"
			headernamerow=1
			deducetyperow=2
			deducecolumns=0
		elseif (cmpstr(loadtype,"Iontensity")==0)
			leftcell="A3"
			rightcolumn="L"
			headernamerow=2
			deducetyperow=3
			deducecolumns=0
			sheetname="Record"
		endif
	endif



	Variable result
	do			// Loop through each file in folder

		fileName = IndexedFile(temporarypath, index,".xlsx")
		if (strlen(filename)==0)
				fileName = IndexedFile(temporarypath, index,".xls")
		endif
		if (strlen(fileName) == 0)			// No more files?
			break									// Break out of loop
		endif

		string foldername=filename
		foldername = ReplaceString(".csv",foldername,"")
		foldername = ReplaceString(".xlsx",foldername,"")
		foldername = ReplaceString(".xls",foldername,"")
		foldername = ReplaceString(" ", foldername, "")
		foldername = ReplaceString("-", foldername,"")
		foldername = ReplaceString("_",foldername,"")

		setdatafolder root:
		string foldernameprompt="Enter battery name for data imported from file "+filename
		prompt foldername,foldernameprompt
		string battypeprompt="Enter variable type for data from "+filename
		string menulist=""
		string objName
		variable findex=0
		do
			objName = GetIndexedObjName(":", 4, findex)
			if (strlen(objName) == 0)
				break
			endif
			if (findex>0)
				menulist+=";"
			endif
			menulist+= objName
			findex += 1
		while(1)
		menulist+=";Skip this file"
		string currentbattype=GetIndexedObjName(":",4,0)
		prompt currentbattype,battypeprompt,popup,menulist
		string promptstring="Info for data from "+filename
		variable foldernamecheck

		foldernamecheck=0
		doprompt promptstring,currentbattype,foldername,leftcell,rightcolumn,headernamerow,deducetyperow
		if (cmpstr(currentbattype,"Skip this file")!=0)		
			foldername = cleanupname(foldername,1)
			if (checkname(foldername,11)!=0)
				foldername = uniquename(foldername,11,1)
			endif
			setdatafolder $currentbattype
			nvar red,green,blue
			variable r=red
			variable g=green
			variable b=blue
			newdatafolder /o/s $foldername
			variable/G red=r
			variable/G green=g
			variable/G blue=b
			
			string bottomrightcell = rightcolumn+num2str(99999)
			if (deducecolumns==1)
				XLLoadWave /R=($leftcell,$bottomrightcell)/S=sheetname /C=(deducetyperow) /W=(headernamerow) /Q /P=temporarypath  filename
			else
				if (cmpstr(loadtype,"Eclipse 9-variable format")==0)
					string coltstring="1T2N1T5N"
				elseif (cmpstr(loadtype,"Iontensity")==0)
					coltstring="3N1T8N"
				endif
				XLLoadWave /R=($leftcell,$bottomrightcell) /S=sheetname /COLT=coltstring /W=(headernamerow) /Q /P=temporarypath  filename
			endif
			setdatafolder root:
		endif
		index += 1
	while (1) 

	if (Exists("temporaryPath"))		// Kill temp path if it exists
		KillPath temporaryPath
	endif

	return 0						// Signifies success.
End