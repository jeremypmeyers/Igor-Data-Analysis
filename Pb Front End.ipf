function panelcontroltype() 
	NewPanel /W=(502.5,94.5,1026,510)/N=ControlWindow
	SetDrawLayer UserBack
	SetDrawEnv linethick= 2
	DrawLine 309.75,240,309.75,399
	
	string yyyy, mm, dd
	string regexp="([[:digit:]]{1,4})-([[:digit:]]{1,2})-([[:digit:]]{1,2})"
	splitstring /E=regexp secs2date(datetime,-2),yyyy,mm,dd
	variable yr=str2num(yyyy)
	variable mo=str2num(mm)
	variable da=str2num(dd)
	
	TitleBox controltitle,pos={126.00,3.00},size={243.75,15.75},title="Enter data for control pasting (no MR)"
	TitleBox controltitle,font="Arial",frame=0,fStyle=1,focusRing=0,anchor= MT
	
	SetVariable pastedatemonth,pos={107.25,105.00},size={136.50,18.00},bodyWidth=30,title="Pasting date: mm"
	SetVariable pastedatemonth,help={"Enter numerical value for month of pasting (01-12)."}
	SetVariable pastedatemonth,font="Arial",focusRing=0
	SetVariable pastedatemonth,limits={1,12,1},value= _NUM:mo
	
	SetVariable pastingdatedd,pos={252.00,105.00},size={57.00,18.00},bodyWidth=35,title="-dd"
	SetVariable pastingdatedd,font="Arial",focusRing=0,limits={1,31,1},value= _NUM:da
	
	SetVariable pastingdateyyyy,pos={312.00,105.00},size={84.00,18.00},bodyWidth=50,title="-yyyy"
	SetVariable pastingdateyyyy,font="Arial",focusRing=0
	SetVariable pastingdateyyyy,limits={2010,inf,1},value= _NUM:yr
	
	PopupMenu posgrid,pos={6.00,147.00},size={108.00,21.75},title="Positive grid"
	PopupMenu posgrid,help={"Select the type of grid used in the positive electrode."}
	PopupMenu posgrid,font="Arial",focusRing=0
	string posgridmenustring="\"Ca;Sb;Other\""
	string neggridmenustring="\"Ca;Sb;Other\""
	string batterytypemenu="\"Flooded;VRLA;Tubular;Other\""
	string appmenu="\"Auto-SLI;Auto-EFB;Auto-VRLA;e-Bike;e-Rickshaw;Industrial;Inverter;Motorcycle;Renewables;Solar\""
	
	PopupMenu posgrid,mode=1,value=#posgridmenustring //#"\"Ca;Sb;Other\""
	PopupMenu neggrid,pos={375.00,147.00},size={132.00,21.75},title="Negative grid"
	PopupMenu neggrid,font="Arial",focusRing=0
	PopupMenu neggrid,mode=1,value= #neggridmenustring
	
	SetVariable poscount,pos={6.00,171.00},size={165.00,18.00},bodyWidth=45,title="Positive plate count"
	SetVariable poscount,font="Arial",focusRing=0,limits={1,100,1},value= _NUM:0
	
	SetVariable negcount,pos={321.00,171.00},size={186.00,18.00},bodyWidth=60,title="Negative plate count"
	SetVariable negcount,font="Arial",focusRing=0,limits={1,100,1},value= _NUM:0
	
	SetVariable company,pos={24.00,24.00},size={447.00,18.00},bodyWidth=300,title="Company/partner name:"
	SetVariable company,font="Arial",focusRing=0,value= _STR:""
	TitleBox redblock,pos={30.00,282.00},size={51.00,24.75},title="            "
	TitleBox redblock,labelBack=(65535,0,0),frame=2,focusRing=0
	TitleBox BDSblue,pos={30.00,312.00},size={51.00,24.75},title="            "
	TitleBox BDSblue,labelBack=(5654,28270,61937),frame=2,focusRing=0
	TitleBox BDSyellow,pos={114.00,282.00},size={39.75,24.75},title="         "
	TitleBox BDSyellow,labelBack=(65535,57568,13364),frame=2,focusring=0
	TitleBox BDSpurple,pos={30.00,369.00},size={51.00,24.75},title="            "
	TitleBox BDSpurple,labelBack=(21588,1799,39064),frame=2,focusring=0
	TitleBox BDSelectric,pos={30.00,339.00},size={51.00,24.75},title="            "
	TitleBox BDSelectric,labelBack=(26728,51143,65535),frame=2,focusring=0
	TitleBox BDSlavender,pos={114.00,339.00},size={39.75,24.75},title="         "
	TitleBox BDSlavender,labelBack=(49601,23387,57568),frame=2,focusring=0
	TitleBox BDSperiwinkle,pos={114.00,312.00},size={39.75,24.75},title="         "
	TitleBox BDSperiwinkle,labelBack=(34695,40606,53970),frame=2,focusring=0
	TitleBox BDSnavy,pos={114.00,369.00},size={39.75,24.75},title="         "
	TitleBox BDSnavy,labelBack=(5654,5911,25957),frame=2,focusring=0
	TitleBox MRDdarkgray,pos={177.00,369.00},size={39.75,24.75},title="         "
	TitleBox MRDdarkgray,labelBack=(7967,10023,15163),frame=2,focusring=0
	TitleBox MRDgreen,pos={177.00,312.00},size={39.75,24.75},title="         "
	TitleBox MRDgreen,labelBack=(13364,35723,23130),frame=2,focusring=0
	TitleBox MRDgray,pos={177.00,282.00},size={39.75,24.75},title="         "
	TitleBox MRDgray,labelBack=(37008,37779,39835),frame=2,focusring=0
	TitleBox MRDteal,pos={177.00,339.00},size={39.75,24.75},title="         "
	TitleBox MRDteal,labelBack=(13364,35466,36494),frame=2,focusring=0
	
	SetVariable batterymodel,pos={26.25,81.00},size={288.75,18.00},bodyWidth=200,title="Battery model:"
	SetVariable batterymodel,help={"Battery model type (NS40, S500, etc.)"},focusring=0
	SetVariable batterymodel,font="Arial",value= _STR:""
	
	PopupMenu batterytype,pos={45.00,51.00},size={140.25,21.75},title="Battery type"
	PopupMenu batterytype,font="Arial",focusring=0
	PopupMenu batterytype,mode=1,popvalue="Flooded",value=#batterytypemenu 
	
	GroupBox divider,pos={9.00,138.00},size={495.00,3.00},frame=0
	
	TitleBox defaultred,pos={33.00,286.50},size={43.50,15.75},title="Control"
	TitleBox defaultred,font="Arial",frame=0,focusring=0
	TitleBox defaultBDSblue,pos={42.00,315.00},size={25.50,15.75},title="MR-"
	TitleBox defaultBDSblue,font="Arial",frame=0,focusring=0
	TitleBox defaultBDSelectric,pos={42.00,342.75},size={29.25,15.75},title="MR+"
	TitleBox defaultBDSelectric,font="Arial",frame=0,focusring=0
	TitleBox defaultBDSpurple,pos={36.00,372.00},size={37.50,15.75},title="MR+/-"
	TitleBox defaultBDSpurple,font="Arial",frame=0,fColor=(61166,61166,61166)
	
	GroupBox divider1,pos={12.00,237.00},size={495.00,3.00},frame=0,focusring=0

	
	TitleBox def,pos={6.00,264.00},size={82.50,15.75},title="Default colors"
	TitleBox def,font="Arial",frame=0,fStyle=0,focusring=0
	TitleBox bdscolors,pos={105.00,264.00},size={36.00,15.75},title="+BDS"
	TitleBox bdscolors,font="Arial",frame=0,fStyle=0,focusring=0
	
	CheckBox redbox,pos={15.00,288.00},size={10.50,10.50},proc=redboxproc,title=""
	CheckBox redbox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox redbox,value= 1,mode=1
	CheckBox mrminusbox,pos={15.00,318.00},size={10.50,10.50},proc=mrminusboxproc,title=""
	CheckBox mrminusbox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,focusring=0
	
	CheckBox mrplusbox,pos={15.00,345.00},size={10.50,10.50},title="",proc=mrplusbox
	CheckBox mrplusbox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,focusring=0
	CheckBox mrbothbox,pos={15.00,375.00},size={10.50,10.50},title="",proc=mrbothbox
	CheckBox mrbothbox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,focusring=0
	TitleBox colorselecttitle,pos={66.00,243.00},size={176.25,18.00},title="Select color for plotting"
	TitleBox colorselecttitle,font="Arial",fSize=16,frame=0,fStyle=1,focusring=0
	TitleBox MRDcolors,pos={177.00,264.00},size={30.75,15.75},title="MRD"
	TitleBox MRDcolors,font="Arial",frame=0,fStyle=0,focusring=0
	CheckBox bdsyellowbox,pos={99.00,288.00},size={10.50,10.50},title="",proc=bdsyellow
	CheckBox bdsyellowbox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,focusring=0
	CheckBox bdsperiwinklebox,pos={99.00,318.00},size={10.50,10.50},title="",proc=bdsperi
	CheckBox bdsperiwinklebox,labelBack=(65535,0,0),fColor=(65535,0,0),focusring=0
	CheckBox bdsperiwinklebox,value= 0,mode=1
	
	CheckBox bdslavenderbox,pos={99.00,345.00},size={10.50,10.50},title="",focusring=0
	CheckBox bdslavenderbox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,proc=bdslav
	
	CheckBox bdsnavybox,pos={99.00,378.00},size={10.50,10.50},title="",focusring=0
	CheckBox bdsnavybox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,proc=bdsnavy
	
	CheckBox mrdgraybox,pos={162.00,288.00},size={10.50,10.50},title="",focusring=0
	CheckBox mrdgraybox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,proc=mrdgray
	
	CheckBox mrdgreenbox,pos={162.00,318.00},size={10.50,10.50},title="",focusring=0
	CheckBox mrdgreenbox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,proc=mrdgreen
	
	CheckBox mrdtealbox,pos={162.00,345.00},size={10.50,10.50},title="",focusring=0
	CheckBox mrdtealbox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,proc=mrdteal
	
	CheckBox mrddarkgraybox,pos={162.00,375.00},size={10.50,10.50},title="",focusring=0
	CheckBox mrddarkgraybox,labelBack=(65535,0,0),fColor=(65535,0,0),value= 0,mode=1,proc=mrddarkgray
	
	PopupMenu colorfull,pos={231.00,282.00},size={49.50,21.75},fColor=(65535,0,0)
	PopupMenu colorfull,mode=1,popColor= (65535,0,0),value= #"\"*COLORPOP*\"",proc=colorpop,focusring=0
	
	TitleBox CustomTitle,pos={231.00,264.00},size={45.75,15.75},title="Custom"
	TitleBox CustomTitle,font="Arial",frame=0,focusring=0
	
	SetVariable notes,pos={27.75,216.00},size={466.50,18.00},bodyWidth=350,title="Pasting/build notes"
	SetVariable notes,help={"Provide brief description of expander type, if known"},focusring=0
	SetVariable notes,font="Arial",limits={1,100,1},value= _STR:""
	
	Button NoControl,pos={339.00,249.00},size={150.00,45.00},proc=nocontroldone,title="Skip control data"
	Button NoControl,labelBack=(3,52428,1),font="Arial",fSize=16,fStyle=1
	Button NoControl,fColor=(65535,0,0),focusRing=0
	
	Button ControlDataAndQuit,pos={339.00,303.00},size={150.00,45.00},proc=controlcomplete,title="Accept control info\rNo other types"
	Button ControlDataAndQuit,labelBack=(3,52428,1),font="Arial",fSize=16,fStyle=1,focusring=0
	Button ControlDataAndQuit,fColor=(34952,34952,34952)
	
	Button AcceptAllDoNext,pos={339.00,354.00},size={150.00,45.00},proc=controlcomplete,title="Accept Settings+\rAdd Next Type"
	Button AcceptAllDoNext,labelBack=(3,52428,1),font="Arial",fSize=16,fStyle=1,focusring=0
	Button AcceptAllDoNext,fColor=(3,52428,1)
	
	PopupMenu batteryapp,pos={285.00,51.00},size={181.50,21.75},title="Battery application",focusring=0
	PopupMenu batteryapp,font="Arial"
	PopupMenu batteryapp,mode=1,popvalue="Auto-SLI",value= #appmenu 
	PopupMenu expander,pos={369.00,192.00},size={140.25,21.75},title="Expander",focusring=0
	PopupMenu expander,font="Arial"
	PopupMenu expander,mode=1,popvalue="Hammond",value= #"\"APG/Texex;Hammond;PENOX;SSRL;In-House;Other\""
	SetVariable ratedcap,pos={329.25,80.25},size={165.75,18.00},bodyWidth=45,title="Rated capacity (Ah)",focusring=0
	SetVariable ratedcap,font="Arial",limits={0,inf,0},value= _NUM:0
end

function colorpop(ctrlname,popnum,popstr): PopupMenuControl
string ctrlname
variable popnum
string popstr
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
end

function redboxproc(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=1
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=(65535,0,0)
endif
end

function mrminusboxproc(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=1
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=(5654,28270,61937)
endif
end

function mrplusbox(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=1
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=(26728,51143,65535)
endif
end

function mrbothbox(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=1
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=	(21588,1799,39064)
endif
end

function bdsyellow(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=1
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=	(65535,57568,13364)
endif
end

function bdsperi(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=1
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=	(34695,40606,53970)
endif
end

function bdslav(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=1
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=	(49601,23387,57568)
endif
end

function bdsnavy(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=1
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=(5654,5911,25957)
endif
end

function mrdgray(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=1
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=(37008,37779,39835)
endif
end

function mrdgreen(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=1
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=(13364,35723,23130)
endif
end

function mrdteal(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=1
	checkbox mrddarkgraybox,value=0
	popupmenu colorfull, popcolor=(13364,35466,36494)
endif
end

function mrddarkgray(ctrlname,checked): CheckBoxControl
string ctrlname
variable checked
if (checked)
	checkbox redbox,value=0
	checkbox mrminusbox,value=0
	checkbox mrplusbox,value=0
	checkbox mrbothbox,value=0
	checkbox bdsyellowbox,value=0
	checkbox bdsperiwinklebox,value=0
	checkbox bdslavenderbox,value=0
	checkbox bdsnavybox,value=0
	checkbox mrdgraybox,value=0
	checkbox mrdgreenbox,value=0
	checkbox mrdtealbox,value=0
	checkbox mrddarkgraybox,value=1
	popupmenu colorfull, popcolor=(7967,10023,15163)
endif
end

function nocontroldone(ctrlname): buttoncontrol
	string ctrlname
	killwindow ControlWindow
	nvar done
	done=1
end

function controlcomplete(ctrlname): buttoncontrol
	string ctrlname
	setdatafolder root:
	newdatafolder /o/s Control
	
	controlinfo colorfull
	variable /g red= v_red
	variable /g blue=v_blue
	variable /g green=v_green
	
	controlinfo pastingdateyyyy
	variable y=V_value
	controlinfo pastingdatemonth
	variable m=V_value
	controlinfo pastingdatedd
	variable d=V_value
	string /g pastingdate=num2str(m)+"-"+num2str(d)+"-"+num2str(y)
	controlinfo posgrid
	string /G PositiveGrid=s_value
	controlinfo neggrid
	string /G NegativeGrid=s_value
	controlinfo poscount
	variable /G PositivePlateCount=v_Value
	controlinfo negcount
	variable /G NegativePlateCount=v_value
	
	
	controlinfo company
	string /G Manufacturer=s_value
	
	controlinfo batterymodel
	string /G BatteryModel=S_value
	
	controlinfo batterytype
	string /G BatteryType=S_value
	
	controlinfo notes
	string /G notes=S_value
	
	controlinfo batteryapp
	string /G BatteryApplication=S_value
	
	controlinfo expander
	string /G Expander=S_Value
	
	controlinfo ratedcap
	variable /G RatedCapacity=V_Value	

	if (cmpstr(ctrlname,"ControlDataAndQuit")==0)
		nvar done
		done=1
	endif
	
	killwindow ControlWindow

end



function panelvariant() 
	NewPanel /W=(553.5,38.2,1077,562.5) /N=VariantWindow
	SetDrawLayer UserBack
	SetDrawEnv linethick= 2
	DrawLine 309.75,326.25,309.75,530
	TitleBox controltitle,pos={168.00,3.00},size={159.75,11.25},title="Enter data for experimental variable #"
	TitleBox controltitle,font="Arial",frame=0,fStyle=1,focusRing=0,anchor= MT
	SetVariable pastedatemonth,pos={134.25,105.00},size={105.75,13.50},bodyWidth=30,title="Pasting date: mm"
	SetVariable pastedatemonth,help={"Enter numerical value for month of pasting (01-12)."}
	SetVariable pastedatemonth,font="Arial",focusRing=0
	SetVariable pastedatemonth,limits={1,12,1},value= _NUM:6
	SetVariable pastingdatedd,pos={258.00,105.00},size={51.00,13.50},bodyWidth=35,title="-dd"
	SetVariable pastingdatedd,font="Arial",focusRing=0
	SetVariable pastingdatedd,limits={1,31,1},value= _NUM:15
	SetVariable pastingdateyyyy,pos={323.25,105.00},size={70.50,13.50},bodyWidth=50,title="-yyyy"
	SetVariable pastingdateyyyy,font="Arial",focusRing=0
	SetVariable pastingdateyyyy,limits={2010,inf,1},value= _NUM:2016
	PopupMenu posgrid,pos={8.25,145.50},size={79.50,14.25},title="Positive grid"
	PopupMenu posgrid,help={"Select the type of grid used in the positive electrode."}
	PopupMenu posgrid,font="Arial",focusRing=0
	PopupMenu posgrid,mode=1,popvalue="Ca",value= #"\"Ca;Sb;Other\""
	PopupMenu neggrid,pos={337.50,147.00},size={83.25,14.25},title="Negative grid"
	PopupMenu neggrid,font="Arial",focusRing=0
	PopupMenu neggrid,mode=1,popvalue="Ca",value= #"\"Ca;Sb;Other\""
	SetVariable poscount,pos={8.25,171.00},size={127.50,13.50},bodyWidth=45,title="Positive plate count"
	SetVariable poscount,font="Arial",focusRing=0,limits={1,100,1},value= _NUM:0
	SetVariable negcount,pos={337.50,171.00},size={146.25,13.50},bodyWidth=60,title="Negative plate count"
	SetVariable negcount,font="Arial",focusRing=0,limits={1,100,1},value= _NUM:0
	SetVariable company,pos={65.25,24.00},size={402.75,13.50},bodyWidth=300,title="Company/partner name:"
	SetVariable company,font="Arial",focusRing=0,value= _STR:""
	TitleBox redblock,pos={30.00,366.75},size={33.00,17.25},title="            "
	TitleBox redblock,labelBack=(65535,0,0),frame=2,focusRing=0
	TitleBox BDSblue,pos={30.00,396.75},size={33.00,17.25},title="            "
	TitleBox BDSblue,labelBack=(5654,28270,61937),frame=2,focusRing=0
	TitleBox BDSyellow,pos={114.00,366.75},size={26.25,17.25},title="         "
	TitleBox BDSyellow,labelBack=(65535,57568,13364),frame=2,focusRing=0
	TitleBox BDSpurple,pos={30.00,453.75},size={33.00,17.25},title="            "
	TitleBox BDSpurple,labelBack=(21588,1799,39064),frame=2,focusRing=0
	TitleBox BDSelectric,pos={30.00,423.75},size={33.00,17.25},title="            "
	TitleBox BDSelectric,labelBack=(26728,51143,65535),frame=2,focusRing=0
	TitleBox BDSlavender,pos={114.00,423.75},size={26.25,17.25},title="         "
	TitleBox BDSlavender,labelBack=(49601,23387,57568),frame=2,focusRing=0
	TitleBox BDSperiwinkle,pos={114.00,396.75},size={26.25,17.25},title="         "
	TitleBox BDSperiwinkle,labelBack=(34695,40606,53970),frame=2,focusRing=0
	TitleBox BDSnavy,pos={114.00,453.75},size={26.25,17.25},title="         "
	TitleBox BDSnavy,labelBack=(5654,5911,25957),frame=2,focusRing=0
	TitleBox MRDdarkgray,pos={177.00,453.75},size={26.25,17.25},title="         "
	TitleBox MRDdarkgray,labelBack=(7967,10023,15163),frame=2,focusRing=0
	TitleBox MRDgreen,pos={177.00,396.75},size={26.25,17.25},title="         "
	TitleBox MRDgreen,labelBack=(13364,35723,23130),frame=2,focusRing=0
	TitleBox MRDgray,pos={177.00,366.75},size={26.25,17.25},title="         "
	TitleBox MRDgray,labelBack=(37008,37779,39835),frame=2,focusRing=0
	TitleBox MRDteal,pos={177.00,423.75},size={26.25,17.25},title="         "
	TitleBox MRDteal,labelBack=(13364,35466,36494),frame=2,focusRing=0
	SetVariable batterymodel,pos={51.00,81.00},size={261.00,13.50},bodyWidth=200,title="Battery model:"
	SetVariable batterymodel,help={"Battery model type (NS40, S500, etc.)"}
	SetVariable batterymodel,font="Arial",focusRing=0,value= _STR:""
	PopupMenu batterytype,pos={45.00,51.00},size={97.50,14.25},title="Battery type"
	PopupMenu batterytype,font="Arial",focusRing=0
	PopupMenu batterytype,mode=1,popvalue="Flooded",value= #"\"Flooded;VRLA;Tubular;Other\""
	GroupBox divider,pos={9.00,138.00},size={495.00,3.00},frame=0
	TitleBox defaultred,pos={30.75,369.75},size={30.00,11.25},title="Control"
	TitleBox defaultred,font="Arial",frame=0,focusRing=0
	TitleBox defaultBDSblue,pos={37.50,399.75},size={16.50,11.25},title="MR-"
	TitleBox defaultBDSblue,font="Arial",frame=0,focusRing=0
	TitleBox defaultBDSelectric,pos={36.00,426.75},size={18.75,11.25},title="MR+"
	TitleBox defaultBDSelectric,font="Arial",frame=0,focusRing=0
	TitleBox defaultBDSpurple,pos={36.00,456.75},size={24.00,11.25},title="MR+/-"
	TitleBox defaultBDSpurple,font="Arial",frame=0,fColor=(61166,61166,61166)
	GroupBox divider1,pos={12.00,321.75},size={495.00,3.00},frame=0,focusRing=0
	TitleBox def,pos={6.00,348.75},size={57.00,11.25},title="Default colors"
	TitleBox def,font="Arial",frame=0,fStyle=0,focusRing=0
	TitleBox bdscolors,pos={105.00,348.75},size={24.00,11.25},title="+BDS"
	TitleBox bdscolors,font="Arial",frame=0,fStyle=0,focusRing=0
	CheckBox redbox,pos={15.00,372.75},size={10.50,10.50},proc=redboxproc,title=""
	CheckBox redbox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox redbox,value= 1,mode=1
	CheckBox mrminusbox,pos={15.00,402.75},size={10.50,10.50},proc=mrminusboxproc,title=""
	CheckBox mrminusbox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox mrminusbox,value= 0,mode=1
	CheckBox mrplusbox,pos={15.00,429.75},size={10.50,10.50},proc=mrplusbox,title=""
	CheckBox mrplusbox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox mrplusbox,value= 0,mode=1
	CheckBox mrbothbox,pos={15.00,459.75},size={10.50,10.50},proc=mrbothbox,title=""
	CheckBox mrbothbox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox mrbothbox,value= 0,mode=1
	TitleBox colorselecttitle,pos={66.00,327.75},size={176.25,18.00},title="Select color for plotting"
	TitleBox colorselecttitle,font="Arial",fSize=16,frame=0,fStyle=1,focusRing=0
	TitleBox MRDcolors,pos={177.00,348.75},size={20.25,11.25},title="MRD"
	TitleBox MRDcolors,font="Arial",frame=0,fStyle=0,focusRing=0
	CheckBox bdsyellowbox,pos={99.00,372.75},size={10.50,10.50},proc=bdsyellow,title=""
	CheckBox bdsyellowbox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox bdsyellowbox,value= 0,mode=1
	CheckBox bdsperiwinklebox,pos={99.00,402.75},size={10.50,10.50},proc=bdsperi,title=""
	CheckBox bdsperiwinklebox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox bdsperiwinklebox,value= 0,mode=1
	CheckBox bdslavenderbox,pos={99.00,429.75},size={10.50,10.50},proc=bdslav,title=""
	CheckBox bdslavenderbox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox bdslavenderbox,value= 0,mode=1
	CheckBox bdsnavybox,pos={99.00,462.75},size={10.50,10.50},proc=bdsnavy,title=""
	CheckBox bdsnavybox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox bdsnavybox,value= 0,mode=1
	CheckBox mrdgraybox,pos={162.00,372.75},size={10.50,10.50},proc=mrdgray,title=""
	CheckBox mrdgraybox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox mrdgraybox,value= 0,mode=1
	CheckBox mrdgreenbox,pos={162.00,402.75},size={10.50,10.50},proc=mrdgreen,title=""
	CheckBox mrdgreenbox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox mrdgreenbox,value= 0,mode=1
	CheckBox mrdtealbox,pos={162.00,429.75},size={10.50,10.50},proc=mrdteal,title=""
	CheckBox mrdtealbox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox mrdtealbox,value= 0,mode=1
	CheckBox mrddarkgraybox,pos={162.00,459.75},size={10.50,10.50},proc=mrddarkgray,title=""
	CheckBox mrddarkgraybox,labelBack=(65535,0,0),fColor=(65535,0,0),focusRing=0
	CheckBox mrddarkgraybox,value= 0,mode=1
	PopupMenu colorfull,pos={231.00,366.75},size={49.50,14.25},proc=colorpop
	PopupMenu colorfull,fColor=(65535,0,0),focusRing=0
	PopupMenu colorfull,mode=1,popColor= (65535,0,0),value= #"\"*COLORPOP*\""
	TitleBox CustomTitle,pos={231.00,348.75},size={33.00,11.25},title="Custom"
	TitleBox CustomTitle,font="Arial",frame=0,focusRing=0
	SetVariable notes,pos={59.25,210.00},size={432.00,13.50},bodyWidth=350,title="Pasting/build notes"
	SetVariable notes,help={"Provide brief description of expander type, if known"}
	SetVariable notes,font="Arial",focusRing=0,limits={1,100,1},value= _STR:""
	PopupMenu batteryapp,pos={285.00,51.00},size={128.25,14.25},title="Battery application"
	PopupMenu batteryapp,font="Arial",focusRing=0
	PopupMenu batteryapp,mode=1,popvalue="Auto-SLI",value= #"\"Auto-SLI;Auto-EFB;Auto-VRLA;e-Bike;e-Rickshaw;Industrial;Inverter;Motorcycle;Renewables;Solar\""
	PopupMenu expander,pos={337.50,192.00},size={101.25,14.25},title="Expander"
	PopupMenu expander,font="Arial",focusRing=0
	PopupMenu expander,mode=1,popvalue="Hammond",value= #"\"APG/Texex;Hammond;PENOX;SSRL;In-House;Other\""
	SetVariable ratedcap,pos={363.75,78.00},size={126.75,13.50},bodyWidth=45,title="Rated capacity (Ah)"
	SetVariable ratedcap,font="Arial",focusRing=0,limits={0,inf,0},value= _NUM:0	
	gotofirstpopulatedvariant()
	if (cmpstr(getdatafolder(0),"root")!=0)
		svar positivegrid//
		svar pastingdate
		svar negativegrid//
		svar manufacturer//
		svar expander//
		svar batterytype//
		svar batterymodel//
		svar batteryapplication//
		nvar ratedcapacity//
		nvar positiveplatecount//
		nvar negativeplatecount
	
		setvariable poscount,value=_NUM:positiveplatecount
		setvariable negcount,value=_NUM:negativeplatecount
		setvariable company,value=_STR:manufacturer
		setvariable ratedcap,value=_NUM:ratedcapacity
		setvariable batterymodel,value=_STR:batterymodel
		
		popupmenu posgrid,popmatch=positivegrid
		popupmenu neggrid,popmatch=negativegrid
		popupmenu expander,popmatch=expander
		popupmenu batterytype,popmatch=batterytype
		popupmenu batteryapp,popmatch=batteryapplication
	endif
	
	Button Done,pos={336.75,336.75},size={159.75,45.00},proc=cancelvariant,title="Cancel data loading"
	Button Done,labelBack=(3,52428,1),font="Arial",fSize=16,fStyle=1
	Button Done,fColor=(65535,0,0),focusRing=0
	Button AcceptAndQuit,pos={336.75,390.75},size={159.75,45.00},proc=variantaccept,title="Accept Settings\rNo additional info"
	Button AcceptAndQuit,labelBack=(3,52428,1),font="Arial",fSize=16,fStyle=1
	Button AcceptAndQuit,fColor=(34952,34952,34952),focusRing=0
	Button AcceptAllDoNext,pos={336.75,441.75},size={159.75,45.00},proc=variantaccept,title="Accept Settings+\rAdd Next Type"
	Button AcceptAllDoNext,labelBack=(3,52428,1),font="Arial",fSize=16,fStyle=1
	Button AcceptAllDoNext,fColor=(3,52428,1),focusRing=0

	SetVariable MRpos,pos={12.00,240.75},size={149.25,13.50},bodyWidth=50,title="Positive MR content (%)"
	SetVariable MRpos,font="Arial",limits={0,0.35,0.01},value= _NUM:0,proc=changeMR
	SetVariable MRneg,pos={293.25,240.75},size={153.00,13.50},bodyWidth=50,title="Negative MR content (%)"
	SetVariable MRneg,font="Arial",limits={0,0.35,0.01},value= _NUM:0,proc=changeMR
	PopupMenu posSurf,pos={12.00,259.50},size={114.75,14.25},title="Positive Surfactant"
	PopupMenu posSurf,font="Arial",proc=changeMRpop
	PopupMenu posSurf,mode=1,popvalue="CMC",value= #"\"CMC;Lignin;PVA;PSS;Other\""
	PopupMenu negSurf,pos={293.25,259.50},size={118.50,14.25},title="Negative Surfactant"
	PopupMenu negSurf,font="Arial",proc=changeMRpop
	PopupMenu negSurf,mode=1,popvalue="CMC",value= #"\"CMC;Lignin;PVA;PSS;Other\""
	SetVariable PosBatch,pos={12.00,277.50},size={175.50,13.50},bodyWidth=100,title="Positive MR batch"
	SetVariable PosBatch,help={"Battery model type (NS40, S500, etc.)"},font="Arial"
	SetVariable PosBatch,value= _STR:"",focusring=0
	SetVariable NegBatch,pos={293.25,277.50},size={212.25,13.50},bodyWidth=133,title="Negative MR batch"
	SetVariable NegBatch,help={"Battery model type (NS40, S500, etc.)"},font="Arial"
	SetVariable NegBatch,value= _STR:"",focusring=0
	SetVariable Naming,pos={30.00,299.25},size={426.00,13.50},bodyWidth=300,title="Name for experimental variant"
	SetVariable Naming,help={"Naming convention positive | negative"},font="Arial"
	SetVariable Naming,value= _STR:""
	GroupBox divider2,pos={9.00,231.00},size={495.00,3.00},frame=0,focusRing=0
end

Function slide(S_Struct) : SliderControl
	STRUCT WMSliderAction &S_Struct
	ControlInfo slider0
	wave testwave, tw2
	testwave[1,]=(tw2[p]==v_Value) ? p : nan
End

function changeMR(ctrlName,varNum,varStr,varName) : SetVariableControl
	string ctrlname
	variable varnum
	string varstr
	string varname
	controlinfo MRneg
	variable nMR=v_value
	if (nmr==0)
		string nameneg="Con"
	else
		nameneg=num2str(nMR)+"%MR"
		controlinfo negSurf
		nameneg+=" "+S_value
	endif
	controlinfo MRpos
	variable pMR=v_Value
	if (pmr==0)
		string namepos="Con"
	else
		namepos=num2str(pMR)+"%MR"
		controlinfo posSurf
		namepos+=" "+S_value
	endif
	variable mrloading=(nmr>0)+(pmr>0)*2
	switch(mrloading)	// numeric switch
		case 0:	// execute if case matches expression
			checkbox redbox,value=0
			checkbox mrminusbox,value=0
			checkbox mrplusbox,value=0
			checkbox mrbothbox,value=0
			checkbox bdsyellowbox,value=1
			checkbox bdsperiwinklebox,value=0
			checkbox bdslavenderbox,value=0
			checkbox bdsnavybox,value=0
			checkbox mrdgraybox,value=0
			checkbox mrdgreenbox,value=1
			checkbox mrdtealbox,value=0
			checkbox mrddarkgraybox,value=0
			popupmenu colorfull, popcolor=(65535,57568,13364)
			break
		case 1:
			checkbox redbox,value=0
			checkbox mrminusbox,value=1
			checkbox mrplusbox,value=0
			checkbox mrbothbox,value=0
			checkbox bdsyellowbox,value=0
			checkbox bdsperiwinklebox,value=0
			checkbox bdslavenderbox,value=0
			checkbox bdsnavybox,value=0
			checkbox mrdgraybox,value=0
			checkbox mrdgreenbox,value=0
			checkbox mrdtealbox,value=0
			checkbox mrddarkgraybox,value=0
			popupmenu colorfull, popcolor=(5654,28270,61937)
		break
		case 2:
			checkbox redbox,value=0
			checkbox mrminusbox,value=0
			checkbox mrplusbox,value=1
			checkbox mrbothbox,value=0
			checkbox bdsyellowbox,value=0
			checkbox bdsperiwinklebox,value=0
			checkbox bdslavenderbox,value=0
			checkbox bdsnavybox,value=0
			checkbox mrdgraybox,value=0
			checkbox mrdgreenbox,value=0
			checkbox mrdtealbox,value=0
			checkbox mrddarkgraybox,value=0
			popupmenu colorfull, popcolor=(26728,51143,65535)
		break
		case 3:
			checkbox redbox,value=0
			checkbox mrminusbox,value=0
			checkbox mrplusbox,value=0
			checkbox mrbothbox,value=1
			checkbox bdsyellowbox,value=0
			checkbox bdsperiwinklebox,value=0
			checkbox bdslavenderbox,value=0
			checkbox bdsnavybox,value=0
			checkbox mrdgraybox,value=0
			checkbox mrdgreenbox,value=0
			checkbox mrdtealbox,value=0
			checkbox mrddarkgraybox,value=0
			popupmenu colorfull, popcolor=(21588,1799,39064)
		break
	endswitch 	
	setvariable naming value=_STR:namepos+"|"+nameneg
end

function changemrpop(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr	
	controlinfo MRneg
	variable nMR=v_value
	if (nmr==0)
		string nameneg="Con"
	else
		nameneg=num2str(nMR)+"%MR"
		controlinfo negSurf
		nameneg+=" "+S_value
	endif
	controlinfo MRpos
	variable pMR=v_Value
	if (pmr==0)
		string namepos="Con"
	else
		namepos=num2str(pMR)+"%MR"
		controlinfo posSurf
		namepos+=" "+S_value
	endif
	setvariable naming value=_STR:namepos+"|"+nameneg
end

function cancelvariant(ctrlname): buttoncontrol
	string ctrlname
	killwindow variantwindow
	setdatafolder root:
	nvar done
	done=1
end

function variantaccept(ctrlname): buttoncontrol
	string ctrlname
	setdatafolder root:
	controlinfo naming
	string foldername=s_value
	if (checkname(foldername,11)!=0)
		foldername=uniquename(foldername,11,1)
	endif
	newdatafolder /o/s $foldername
	
	controlinfo colorfull
	variable /g red= v_red
	variable /g blue=v_blue
	variable /g green=v_green
	
	controlinfo pastingdateyyyy
	variable y=V_value
	controlinfo pastingdatemonth
	variable m=V_value
	controlinfo pastingdatedd
	variable d=V_value
	string /g pastingdate=num2str(m)+"-"+num2str(d)+"-"+num2str(y)
	controlinfo posgrid
	string /G PositiveGrid=s_value
	controlinfo neggrid
	string /G NegativeGrid=s_value
	controlinfo poscount
	variable /G PositivePlateCount=v_Value
	controlinfo negcount
	variable /G NegativePlateCount=v_value
	
	
	controlinfo company
	string /G Manufacturer=s_value
	
	controlinfo batterymodel
	string /G BatteryModel=S_value
	
	controlinfo batterytype
	string /G BatteryType=S_value
	
	controlinfo notes
	string /G notes=S_value
	
	controlinfo batteryapp
	string /G BatteryApplication=S_value
	
	controlinfo expander
	string /G Expander=S_Value
	
	controlinfo ratedcap
	variable /G RatedCapacity=V_Value	
	
	
	controlinfo MRPos
	variable /G PositiveMRContent=v_value
	
	controlinfo MRNeg
	variable /g NegativeMRContent=v_value
	
	controlinfo PosSurf
	string /G PositiveSurfactant=s_value
	
	controlinfo NegSurf
	string /G NegativeSurfactant=s_value
	
	controlinfo PosBatch
	string /G PositiveMRBatch=s_value
	
	controlinfo NegBatch
	string /G NegativeMRBatch=s_value
	
	
	setdatafolder root:
	if (cmpstr(ctrlname,"AcceptAndQuit")==0)
		nvar done
		done=1
	endif
	killwindow VariantWindow

end
