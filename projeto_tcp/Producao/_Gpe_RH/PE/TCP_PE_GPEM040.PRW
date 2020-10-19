

User Function GPEM040()                 
Local aParam     := PARAMIXB
Local oManusis   := ClassIntManusis():newIntManusis()       

If aParam <> NIL .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. ) .AND. (ALLTRIM(SRA->RA_CC) $ ALLTRIM(SUPERGETMV( 'TCP_MANCC', .f., '001032' )  ))
   
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3] 
	 
	If cIdPonto == 'MODELCOMMITNTTS'   
		oManusis:cFilZze    := xFilial('ZZE')
		oManusis:cChave     := SRA->RA_FILIAL+SRA->RA_MAT
		oManusis:cTipo	    := 'E'
		oManusis:cStatus    := 'P'
		oManusis:cErro      := ''
		oManusis:cEntidade  := 'SRA'
		oManusis:cOperacao  := if(INCLUI,'I',IF(ALTERA,'A','E'))
		oManusis:cRotina    :=  FunName()
		oManusis:cErroValid := ''
	
		IF oManusis:gravaLog()  
			//Não integra na hora, pois neste momento a SRA não foi atualizada. O schedule enviará, já com o cadastro atualizado.
			//U_MNSINT03(oManusis:cChaveZZE)              
		ELSE
			ALERT(oManusis:cErroValid)
		ENDIF			
	ENDIF
ENDIF

Return .T.
