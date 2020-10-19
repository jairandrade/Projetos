

User Function CN140GREV

Local xPar:=paramixb 


if CN0->CN0_ESPEC=='3'
	Reclock("CN9",.F.) 
	CN9->CN9_XDTFIM:=CN9->CN9_DTFIM
	CN9->CN9_DTFIM:=CN9->CN9_DTFIM+CN9->CN9_XVIGEN
	MSUNLOCK()			
EndIF
Return