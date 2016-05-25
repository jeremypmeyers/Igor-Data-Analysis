function batanalysis()
	NewPanel /FLT /W=(100,100,385,360) /N=AnalysisWindow as "Analysis"	
	ModifyPanel cbRGB=(32000,32000,32000), fixedSize=1
	SetDrawLayer UserBack
	DrawPict /W=AnalysisWindow /RABS 3,15,283,41, procglobal#mrdwordmark
	TitleBox  titleb,font="Arial",fcolor=(65535,65535,65535),fsize=16,pos={62,54},frame=0,title="Select data type to import"
	Button pb font="Arial",fsize=14, pos={55,76},size={200,14},title="Formation",proc=form
	Button lib font="Arial",fsize=14, pos={55,94},size={200,14},title="Boost",proc=bst
	Button echem font="Arial",fsize=14, pos={55,112},size={200,14},title="Capacity measurement",proc=capmeas
	Button inst font="Arial",fsize=14, pos={55,130},size={200,14},title="High-rate discharge/cranking",proc=crank
	Button por font="Arial",fsize=14, pos={55,148},size={200,14},title="Charge Acceptance",proc=chargeacc
	Button none font="Arial",fsize=14, pos={55,166},size={200,14},title="Cycling", proc=cycl
	DrawPict /W=AnalysisWindow /RABS 2,200,279,250, procglobal#bdslogo
end

function Form(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing formation data\r"
Formation()
killwindow AnalysisWindow
end

function Bst(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing boost data\r"
killwindow AnalysisWindow
end

function CapMeas(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing capacity measurement\r"
killwindow AnalysisWindow
end

function Crank(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing high-rate discharge/cranking experiment\r"
killwindow AnalysisWindow
end

function ChargeAcc(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing charge acceptance experiment\r"
killwindow AnalysisWindow
end

function Cycl(ctrlname) : buttoncontrol
string ctrlname
notebook Recording text="Analyzing cycling experiment\r"
killwindow AnalysisWindow
end



