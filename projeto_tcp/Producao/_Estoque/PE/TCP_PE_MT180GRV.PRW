
User Function MT180GRV()


Local oManusis 

dbSelectArea('SB1')
DbsetOrder(1)
SB1->(DBSeek(xFilial('SB1')+SB5->B5_COD))  


If  SUPERGETMV( 'TCP_MANUSI', .f., .F. ) .AND. !EMPTY(SB1->B1_GRUPO) .AND. POSICIONE('SBM',1,xFilial('SBM')+SB1->B1_GRUPO,'BM_XMANUSI') == '1' .AND. SB1->B1_MSBLQL != '1'           
	     
   	oManusis  := ClassIntManusis():newIntManusis()  
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := SB1->B1_FILIAL+SB1->B1_COD
	oManusis:cTipo	    := 'E'
	oManusis:cStatus    := 'P'
	oManusis:cErro      := ''
	oManusis:cEntidade  := 'SB1'
	oManusis:cOperacao  := if(INCLUI,'I',IF(ALTERA,'A','E'))
	oManusis:cRotina    :=  FunName()
	oManusis:cErroValid := ''

	IF oManusis:gravaLog()  
		U_MNSINT03(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF  
	
	oManusis  := ClassIntManusis():newIntManusis()  
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := SB1->B1_FILIAL+SB1->B1_COD
	oManusis:cTipo	    := 'E'
	oManusis:cStatus    := 'P'
	oManusis:cErro      := ''
	oManusis:cEntidade  := 'SB9'
	oManusis:cOperacao  := if(INCLUI,'I',IF(ALTERA,'A','E'))
	oManusis:cRotina    :=  FunName()
	oManusis:cErroValid := ''

	IF oManusis:gravaLog()  
		U_MNSINT03(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF 
	
endif			

Return Nil