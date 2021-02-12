#Include "protheus.ch"
#Include "Rwmake.ch"

/*
EXIBE TELA PARA INFORMAR JUSTIFICATIVA NA ALTERAÇÃO DO PEDIDO DE VENDA
*/
User Function KFATR16(cPedido)
	Local	aArea 		:= GetArea()
	Local	lRet		:= .T.
	Local 	bOkb 		:= {|| lRet := .T.,Close(oDlgJust) }
	Local 	bCancel 	:= {|| lRet := .F.,Close(oDlgJust) }
	Local 	lMsgDel		:= .F.
	Local 	_aButtons	:= {}
	Local 	nRecno 		:= Nil
	Local 	cAlias		:= Nil
	Local 	lMashups	:= .F.
	Local 	lImpCad		:= .F.
	Local 	lPadrao		:= .F.
	Local 	lHasOk		:= .T.
	Local 	lWalkThru	:= .F.
	
	Private	oGetJust
	Private	cGetJust 	:= ""
	Private	oGetDes
	Private	cGetDes		:= ""
	
	Static	oDlgJust
	
	If SC5->( FieldPos("C5_XJUSTIF") ) == 0 .or. M->C5_TIPO <> 'N' 
		lRet := .T.
	Endif

	If lRet
		cGetJust:= CriaVar("C5_XJUSTIF")
		lRet	:= .F.

		DEFINE MSDIALOG oDlgJust TITLE "Jusitificativa Alteração Protheus" FROM 000,000 TO 150,450 PIXEL
		
 			@ 043,007 MSGET oGetJust	VAR cGetJust 	SIZE 030, 010 OF oDlgJust PIXEL F3 "ZB" valid VldJust()
 			@ 043,050 MSGET oGetDes		VAR cGetDes		SIZE 165, 010 OF oDlgJust PIXEL when .F.

		ACTIVATE MSDIALOG oDlgJust CENTERED ON INIT EnchoiceBar( oDlgJust ,bOkb,bCancel,lMsgDel,_aButtons,nRecno,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)
		
		If lRet 
			M->C5_XJUSTIF := cGetJust
			If Empty(AllTrim(M->C5_XJUSTIF))
				MsgStop("Para alterar o pedido é obrigatório informar a justificativa.")
				lRet := .F.
			Endif
		Endif
		
	Endif
	
	RestArea(aArea)
return lRet

Static Function VldJust()
	Local aArea	:= GetArea()
	Local lRet	:= .T.
	Local cMsg	:= ""
	
	cGetDes := ""	
	If !Empty(AllTrim(cGetJust))
		If SX5->( MsSeek(xFilial("SX5")+"ZB"+cGetJust ) )
			cGetDes := AllTrim( SX5->X5_DESCRI )
		Else
			lRet := .F.
			cMsg := "Justificativa não encontrada."
		Endif
	Endif

	If !lRet
		MsgStop(cMsg)
	Endif
	
	RestArea(aArea)
Return lRet