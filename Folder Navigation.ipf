function navigatefolders(filetype)
string filetype
NewPath/O temporaryPath	// This will put up a dialog to select a folder to load from.

string pathname = "temporaryPath"
string objName
variable findex=0
string menulist=""
do
	objName = GetIndexedObjName(":", 4, findex)
	print objname
	if (strlen(objName) == 0)
			break
	endif
	if (findex>0)
		menulist+=";"
	endif
	menulist+= objName
	findex += 1
while(1)

string foldername
variable folderindex=0
string path
do
	path = indexeddir($pathname,folderindex,1)
	if (strlen(path)==0)
		break
	endif
	NewPath /q /o currentpath, path
	string battypeprompt="Select variant for data from "+path
	prompt foldername,battypeprompt,popup,menulist
	doprompt "Subfolder info",foldername
	
	if (cmpstr(filetype,"Excel")==0)
	autoloadexcel(defaulttype=foldername,pathname="currentpath")
	pathinfo $pathname
	print s_path
	elseif (cmpstr(filetype,"CSV")==0)
	loadallcsvs(defaulttype=foldername,pathname="currentpath")
	endif

	folderindex+=1
while(1)
end