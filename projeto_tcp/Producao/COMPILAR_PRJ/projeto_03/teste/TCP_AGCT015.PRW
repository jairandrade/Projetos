USER function AGCT015(_nTpVal)

	Local _lRet := .T.
	Local oModel := FWModelActive()
	Local oModelCnd := oModel:GetModel("CNDMASTER")
	Local aArea := GetArea()
	Local _cMsg := ''
	dbSelectArea('CN9')
	CN9->(DbSetOrder(7))

	IF !EMPTY(oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_DTFIM' )) .AND. (_nTpVal == 1 .OR. (_nTpVal == 2 .AND. oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_CHECK' )) ) 

		IF (CN9->(DbSeek(oModelCnd:GetValue("CND_FILIAL")+oModelCnd:GetValue("CND_CONTRA")+'05'))) 
			dDtFimCt := IF(EMPTY(CN9->CN9_XDTFIM),CN9_DTFIM,CN9_XDTFIM)
			
			IF dDtFimCt+CN9->CN9_XVIGEN < DATE()
				_lRet := .F.
				_cMsg := 'Contrato fora da data de vig�ncia. Necess�rio fazer a renova��o do contrato para poder lan�ar medi��es.'
			ENDIF

			IF oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_DTFIM' )+CN9->CN9_XVIGEN  < DATE()
				_lRet := .F.	
				_cMsg := 'Esta planilha encontra-se vencida. Selecione outra planilha ou fa�a a renova��o deste contrato.'
			ENDIF

		else
			_lRet := .F.	
			_cMsg := 'Contrato n�o encontra-se vigente.'
		ENDIF
	ENDIF

	if !_lRet .AND. _nTpVal == 2
		Help("",1,"MEDICAO_INVALIDA",,_cMsg,4,1)
	endif

	RestArea(aArea)

Return _lRet
