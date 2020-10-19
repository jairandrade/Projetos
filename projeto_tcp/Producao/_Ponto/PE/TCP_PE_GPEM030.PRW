
User Function GPEM030()                 
Local aParam     := PARAMIXB
Local oManusis   := ClassIntManusis():newIntManusis()       
 
If aParam <> NIL .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. ) .AND. (ALLTRIM(SRA->RA_CC) $ ALLTRIM(SUPERGETMV( 'TCP_MANCC', .f., '001032' )  ))
   
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3] 
	 
	If cIdPonto == 'MODELCOMMITNTTS'   
		dbSelectArea('SRH')
		DbsetOrder(1)             
		
		SRH->(DBSeek(ALLTRIM(xFilial('SRH')+M->(RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI)))))
		
		oManusis:cFilZze    := xFilial('ZZE')
		oManusis:cChave     := ALLTRIM(xFilial('SRH')+M->(RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI)))
		oManusis:cTipo	    := 'E'
		oManusis:cStatus    := 'P'
		oManusis:cErro      := ''
		oManusis:cEntidade  := 'SRH'
		oManusis:cOperacao  := 'I'
		oManusis:cRotina    :=  FunName()
		oManusis:cErroValid := ''
	
		IF oManusis:gravaLog()  
			U_MNSINT03(oManusis:cChaveZZE)              
		ELSE
			ALERT(oManusis:cErroValid)
		ENDIF	
	
	ENDIF
ENDIF

Return .T.
