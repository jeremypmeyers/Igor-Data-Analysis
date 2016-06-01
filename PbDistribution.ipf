Function email()
	String msg
	string subject=IgorInfo(1)+"initial analysis completed"
	string nbname=notebooksave()
	string nbloc=SharePointHTMLPath(nbname)
	string body= "Summary notebook available at\r"+nbloc+ "\r"
	string igorname=igorinfo(1)+".pxp"
	string igorloc=SharePointHTMLPath(igorname)
	body += "Igor experiment saved here: \r"
	body += igorloc+"\r"
	sprintf msg, "mailto:peverill@molecularrebar.com?subject=%s&body=%s", subject,body
	BrowseUrl msg

	end
	

Function /S NotebookSave()
	string dd=date()
	dd=dd[5,strlen(dd)-1]
	dd=replacestring(" ",dd,"-")
	dd=replacestring(",",dd,"")
	print dd
	string rn="ExptRecord"+dd+".rtf"
	SaveNotebook /P=home recording as rn
	return rn
end

Function /S SharePointHTMLPath(filename)
	string filename
	string htmlpath=	"https://blackdiamondstructures.sharepoint.com/leadacidbatteries/Shared%20Documents"
	pathinfo home
	variable colloc=strsearch(S_Path,":",0)
	string fpath=S_path[colloc,strlen(S_path)-1]
	fpath+=filename
	fpath=replacestring(":",fpath,"/")
	fpath=replacestring(" ",fpath,"%20")
	fpath=replacestring("&",fpath,"%26")
	fpath=replacestring("+",fpath,"%2B")
	fpath=replacestring(",",fpath,"%2C")
	htmlpath+=fpath
	return htmlpath
end

Function /S ExperimentSave()
	string expname=IgorInfo(1)
	expname+=".pxp"
	SaveExperiment as expname
end

