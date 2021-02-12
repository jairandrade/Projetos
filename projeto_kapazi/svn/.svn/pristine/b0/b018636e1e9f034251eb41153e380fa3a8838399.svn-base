user Function valBanco()
cArqTxt:=mv_par01
FT_FUse(cArqTxt) 
clinha := FT_FREADLN() 
IF 'ITAU'$CLINHA 
		cBanco:=Substr(cLinha,77,3)
		FT_FSKIP()
		clinha := FT_FREADLN() 
	 	DBSelectArea('SA6')
	 	DBSetOrder(1)
	 	dBSeek(xFilial('SA6')+cBanco+PADR(Substr(cLinha,18,4),TAMSX3('A6_AGENCIA')[1])+Substr(cLinha,24,5))
		MV_PAR03:=SA6->A6_COD
		MV_PAR04:=SA6->A6_AGENCIA
		MV_PAR05:=SA6->A6_NUMCON

EndIf		                           

Return .t.