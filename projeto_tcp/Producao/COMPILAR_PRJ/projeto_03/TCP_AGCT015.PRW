/*/{Protheus.doc} AGCT015(_nTpVal)
    Função para validar planilhas vencidas atraves do campo CN9_DTFIM+CN9_XVIGEN. 
	Chamada pelo pe TP_PE_CNTA121
    @type  Function
    @author Jair andrade
    @since 11/11/2020
    @version version
    @return return lRet
	 /*/
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

			IF dDtFimCt+CN9->CN9_XVIGEN < ddatabase
				_lRet := .F.
				_cMsg := 'Contrato fora da data de vigência. Necessário fazer a renovação do contrato para poder lançar medições.'
			ENDIF

			IF oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_DTFIM' )+CN9->CN9_XVIGEN  < ddatabase
				_lRet := .F.
				_cMsg := 'Esta planilha encontra-se vencida. Selecione outra planilha ou faça a renovação deste contrato.'
			ENDIF

		else
			_lRet := .F.
			_cMsg := 'Contrato não encontra-se vigente.'
		ENDIF
	ENDIF

	if !_lRet //.AND. _nTpVal == 2
		//Help("",1,"MEDICAO_INVALIDA",,_cMsg,4,1)
		ApMsgAlert(_cMsg, "MEDICAO_INVALIDA")
		//valida erro quando planilha está vencida. Jair 12-11-2020. Se o cursor estiver posicionado em uma planilha nao selecionada dá erro
	elseif 	_lRet .and. _nTpVal == 2 .and. !(oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_CHECK' ))//valida erro quando planilha está vencida. Jair 12-11-2020
		_lRet := .F.
	endif

	RestArea(aArea)

Return _lRet
/*/{Protheus.doc} AGCT015B(cContrato,cRevisao)
    Função para validar contratos vencidos atraves do campo CN9_DTFIM+CN9_XVIGEN. cHAMADA VIA X3_VLDUSER CAMPO CND_CONTRA
    @type  Function
    @author Jair andrade
    @since 11/11/2020
    @version version
    @return return lRet
	 /*/
User Function AGCT015B()
	Local lRet := .T.
	Local aArea := GetArea()

	dbSelectArea('CN9')
	CN9->(DbSetOrder(1))
	If CN9->(DbSeek(xfilial("CN9")+M->CND_CONTRA+M->CND_REVISA))
		If CN9_XDTFIM+CN9_XVIGEN < ddatabase
			Help(NIL, NIL, "CONTRATO VENCIDO", NIL,"O contrato está vencido. Data final: "+DTOC(CN9_XDTFIM)+" Dias a mais:"+str(CN9_XVIGEN), 1,0, NIL, NIL, NIL, NIL, NIL,{})
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)
Return lRet
