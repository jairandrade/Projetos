User Function xCODBAR(_cCodBar)
local cret:=""
If Len(alltrim(_cCodBar))== 48
	cret:=substr(alltrim(_cCodBar),1,11)+substr(alltrim(_cCodBar),13,11)+substr(alltrim(_cCodBar),25,11)+substr(alltrim(_cCodBar),37,11)
	if !VLDCODBAR(cret)
		alert("Verificar digitacao!")
		cret:=""
	EndIF
	
	Return cRet
	
EndIF
