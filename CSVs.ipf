#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function LoadallCSVs([loadtype])
string loadtype
	String pathName			// Name of symbolic path or "" to get dialog
	String startfolder=getdatafolder(1)
	String fileName
	String graphName
	Variable index=0


	variable nameLine,firstLine,numLines,firstColumn,numColumns
	nameline = 0
	firstline = 0
	numlines= 0
	firstcolumn = 0
	numcolumns = 0
	if (paramisdefault(loadtype))
		prompt nameline, "What line are column names on?"
		prompt firstline, "What line is the first line of data?"
		prompt numlines, "How many lines?"
		prompt firstcolumn, "What is the first column of data?"
		prompt numcolumns, "How many columns?"
		doprompt "Input info",nameline,firstline,numlines, firstcolumn,numcolumns
	endif



	NewPath/O temporaryPath			// This will put up a dialog
	if (V_flag != 0)
		Print "Cancelled opening file"
		Abort
	endif
	pathName = "temporaryPath"
	pathinfo temporaryPath
	notebook recording text="Source folder is "+S_path+"\r"
	Variable result
	do			// Loop through each file in folder
		fileName = IndexedFile(temporarypath, index,".csv")
		
		if (strlen(fileName) == 0)			// No more files?
			break									// Break out of loop
		endif
		string foldername=filename
		foldername = ReplaceString(".csv",foldername,"")
		foldername = ReplaceString(" ", foldername, "")
		foldername = ReplaceString("-", foldername,"")
		foldername = ReplaceString("%",foldername,"pc")
		foldername = ReplaceString(".",foldername,"_")
		foldername = ReplaceString("txt",foldername,"")

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
	do
		foldernamecheck=0
		doprompt promptstring,currentbattype,foldername
		if (strsearch(foldername, "Bat", 0) !=0)
			foldername="Bat"+foldername
		endif
		if  (cmpstr(foldername, possiblyquotename(foldername))!=0)
			foldernamecheck=1
			promptstring = "Spaces/special characters used. Please re-enter."
		endif
		foldernamecheck*=cmpstr(currentbattype,"Skip this file")
	while (foldernamecheck !=0)
	if (cmpstr(currentbattype,"Skip this file")!=0)
	
	setdatafolder $currentbattype
	nvar red, green, blue
	variable r=red
	variable g=green
	variable b=blue
	newdatafolder /o/s $foldername
	variable /g red=r
	variable /g green=g
	variable /g blue=b
	notebook recording text= "Data imported from "+filename+" to "+getdatafolder(1)+"\r"
	if (paramisdefault(loadtype))
			LoadWave /J/D/O/W/A/Q/L={nameline,firstline,numlines,firstcolumn,numcolumns}/P=$pathName filename
	else
		string ColumnInfoStr=""
		strswitch(loadtype)	 
			case "Bitrode":	
				ColumnInfoStr += "C=1,F=0,T=4;" //Column A = Total Time
				ColumnInfoStr += "C=1,F=0,T=4;" //Column B = Cycle
				ColumnInfoStr += "C=1,F=0,T=4;" //Column C = Loop Counter #1
				ColumnInfoStr += "C=1,F=0,T=4;" //Column D = Loop Counter #2
				ColumnInfoStr += "C=1,F=0,T=4;" //Column E = Loop Counter #3
				ColumnInfoStr += "C=1,F=0,T=4;" //Column F = Step
				ColumnInfoStr += "C=1,F=0,T=4;" //Column G = Step time
				ColumnInfoStr += "C=1,F=0,T=4;" //Column H = Current
				ColumnInfoStr += "C=1,F=0,T=4;" //Column I = Voltage
				ColumnInfoStr += "C=1,F=0,T=4;" //Column J = Power
				ColumnInfoStr += "C=1,F=0,T=4;" //Column K = Constant Resistance
				ColumnInfoStr += "C=1,F=0,T=4;" //Column L = Amp-Hours
				ColumnInfoStr += "C=1,F=0,T=4;" //Column M = Watt-Hours
				ColumnInfoStr += "C=1,F=0,T=4;" //Column N = Temperature
				ColumnInfoStr += "C=1,F=0,T=4;" //Column O = Unassigned 
				ColumnInfoStr += "C=1,F=-2;" //Column P = Mode
				ColumnInfoStr += "C=1,F=-2;" //Column Q = Data Acquisition Flag	 
				LoadWave /J/O/W/A/Q /B=ColumnInfoStr /P=$pathName filename
			break	
								 

			
			case "Eclipse 9-variable format":
				ColumnInfoStr += "C=1,F=-2;" //Column A = Total Time
				ColumnInfoStr += "C=1,F=0,T=4;"//Column B = Cycle
				ColumnInfoStr += "C=1,F=0,T=4;" //Column C = Step
				ColumnInfoStr += "C=1,F=-2;" //Column D = Step time
				ColumnInfoStr += "C=1,F=0,T=4;" //Column E = Current
				ColumnInfoStr += "C=1,F=0,T=4;" //Column F = Voltage
				ColumnInfoStr += "C=1,F=0,T=4;" //Column G = Power
				ColumnInfoStr += "C=1,F=0,T=4;" //Column H = Amp Hours
				ColumnInfoStr += "C=1,F=0,T=4;" //Column I = Watt Hours
				LoadWave /J/O/W/A/Q /B=ColumnInfoStr /P=$pathName filename
			break		 
			case "Eclipse 10-variable format":
				ColumnInfoStr += "C=1,F=0,T=4;"//Column A = Test Time
				ColumnInfoStr += "C=1,F=0,T=4;"//Column B = Cycl
				ColumnInfoStr += "C=1,F=0,T=4;" //Column C = Step
				ColumnInfoStr += "C=1,F=0,T=4;"//Column D = Step Time
				ColumnInfoStr += "C=1,F=0,T=4;" //Column E = Amps
				ColumnInfoStr += "C=1,F=0,T=4;" //Column F = Volts
				ColumnInfoStr += "C=1,F=0,T=4;" //Column G = Watts
				ColumnInfoStr += "C=1,F=0,T=4;" //Column H = DegC
				ColumnInfoStr += "C=1,F=0,T=4;" //Column I = A-H
				ColumnInfoStr += "C=1,F=0,T=4;"//Column J = W-H
				LoadWave /J/O/W/A/Q /B=ColumnInfoStr /P=$pathName filename
			break
			case "Eclipse 20-variable format":
				ColumnInfoStr += "C=1,F=0,T=4;"//Column A = Time Stamp
				ColumnInfoStr += "C=1,F=0,T=32;"//Column B = Step
				ColumnInfoStr += "C=1,F=-2;" //Column C = Status
				ColumnInfoStr += "C=1,F=7;"//Column D = Prog Time
				ColumnInfoStr += "C=1,F=7;" //Column E = Step Time
				ColumnInfoStr += "C=1,F=0,T=32;" //Column F = Cycle			
				ColumnInfoStr += "C=1,F=-2;" //Column G = Procedure
				ColumnInfoStr += "C=1,F=0,T=4;" //Column H = Voltage
				ColumnInfoStr += "C=1,F=0,T=4;" //Column I = Current
				ColumnInfoStr += "C=1,F=0,T=4;" //Column J = Temp
				ColumnInfoStr += "C=1,F=0,T=4;"//Column K = HeatsinkVD
				ColumnInfoStr += "C=1,F=0,T=4;"//Column L = HeatsinkV		
				ColumnInfoStr += "C=1,F=0,T=4;"//Column M = AhAccu
				ColumnInfoStr += "C=1,F=0,T=4;"//Column N = AhStep
				ColumnInfoStr += "C=1,F=0,T=4;"//Column O = WhAccu
				ColumnInfoStr += "C=1,F=0,T=4;"//Column P = WhDch		
				ColumnInfoStr += "C=1,F=0,T=4;"//Column Q = WhStep
				ColumnInfoStr += "C=1,F=0,T=4;"//Column R = WhPrev
				ColumnInfoStr += "C=1,F=0,T=4;"//Column S = MaxChaW
				ColumnInfoStr += "C=1,F=0,T=4;"//Column T = MaxDChW				
				LoadWave /J/O/W/A/Q /B=ColumnInfoStr /L={12,13,0,0,20} /P=$pathName filename			
			break
			case "Instron":
				ColumnInfoStr += "C=1,F=-2;" //ColumnA = Time_s_
				ColumnInfoStr += "C=1,F=-2;" //ColumnB = Extension_mm_
				ColumnInfoStr += "C=1,F=-2;" //ColumnC = Load_N_
				LoadWave /J/O/W/A/Q /B=ColumnInfoStr /L={7,10,0,0,3} /P=$pathName filename			
		endswitch


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