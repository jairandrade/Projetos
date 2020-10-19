
USER FUNCTION GP030CAN()

	oManusis   := ClassIntManusis():newIntManusis() 
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := SRH->(RH_FILIAL+RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI))
	oManusis:cTipo	    := 'E'
	oManusis:cStatus    := 'P'
	oManusis:cErro      := ''
	oManusis:cEntidade  := 'SRH'
	oManusis:cOperacao  := 'E'
	oManusis:cRotina    :=  FunName()
	oManusis:cErroValid := ''

	IF oManusis:gravaLog()  
		U_MNSINT03(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF		
RETURN