#include 'protheus.ch'


/*/{Protheus.doc} Acd166St
LOCALIZAÇÃO : Function VldCodSep() - Validação da Ordem de Separação. é executado antes da função MSCBFSem ()
 DESCRIÇÃO : É utilizado para validar a Ordem de Separação informada pelo coletor RF, permitindo ou
            não que o operador continue no processo de Separação.

@author Rafael Ricardo Vieceli
@since 15/07/2015
@version 1.0
@return lLiberada, lógico, Se for Ordem de Produção, verifica se esta liberada
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6091059
/*/
User Function Acd166St()

	Local cOrdemSeparacao := ParamIXB[1]
	Local lLiberada := .T.

	IF CB7->CB7_ORIGEM == "3" .And.  CB7->CB7_LIBOK == "B"
		VtAlert("Ordem Separacao pendente de Liberacao","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		lLiberada := .F.
	EndIF

Return lLiberada


User Function _ACD166FM()
Local dDataOp := ""

	DbSelectArea('ZD4')
	ZD4->(DbSetOrder(5))
	ZD4->(DbGoTop())
	ZD4->(DbSeek(xFilial('ZD4')+Alltrim(CB7->CB7_OP)))
	While !ZD4->(EOF()) .AND. Alltrim(ZD4->ZD4_OP) == Alltrim(CB7->CB7_OP)
		RecLock('ZD4',.F.)
        ZD4->ZD4_STATUS := '2'
		MsUnlock()
		ZD4->(DbSkip())
	EndDo

	DbSelectArea('CB9')
	CB9->(DbSetORder(1))
	CB9->(DbGoTop())
	If CB9->(DbSeek(xFilial('CB9')+Alltrim(CB7->CB7_ORDSEP))) .AND. Empty(Alltrim(CB9->CB9_DOC))
		DbSelectArea('SC2')
		SC2->(DbSetOrder(1))
		SC2->(DbGoTop())
		If SC2->(DbSeek(xFilial('SC2')+Alltrim(CB7->CB7_OP)))
			If !Empty(SC2->C2_DATRF)
	  			dDataOp := SC2->C2_DATRF
				RecLock('SC2',.F.)
				SC2->C2_DATRF := CTOD("  /  /  ")
				MsUnlock()
			EndIf
		EndIf

		lEmp := .T.

		While !CB9->(EOF()) .AND. CB9->CB9_FILIAL == CB7->CB7_FILIAL .AND. CB7->CB7_ORDSEP == CB9->CB9_ORDSEP
			DbSelectArea('SD4')
			SD4->(DbSetORder(2))
			SD4->(DbGoTop())
			If !SD4->(DbSeek(xFilial('SD4')+CB7->CB7_OP+CB9->CB9_PROD))
				BaixaSemTRT()//EXEC AUTO BAIXA SEM TRT
			Else
				If SD4->D4_QUANT == 0
					BaixaSemTRT()//EXEC AUTO BAIXA SEM TRT
				ElseIf SD4->D4_QUANT >= CB9->CB9_QTESEP
					DbSelectArea('SBF')
					SBF->(DbSetOrder(1))
					SBF->(DbGoTop())
					If SBF->(DbSeek(xFIlial('SBF')+CB9->CB9_LOCAL+CB9->CB9_LCALIZ+CB9->CB9_PROD))
						If SBF->BF_EMPENHO 	< CB9->CB9_QTESEP
							RecLock('SBF',.F.)
							SBF->BF_EMPENHO := CB9->CB9_QTESEP
							SBF->(MsUnlock())
						EndIf

						BaixaComTRT()//EXEC AUTO BAIXA COM TRT
					EndIf
				Else
					BaixaSemTrt()
				EndIf
			EndIf
			CB9->(DbSkip())
		EndDo


		DbSelectArea('SC2')
		SC2->(DbSetOrder(1))
		SC2->(DbGoTop())
		If SC2->(DbSeek(xFilial('SC2')+Alltrim(CB7->CB7_OP)))
			If !Empty(Alltrim(dDataOp))
				RecLock('SC2',.F.)
				SC2->C2_DATRF := dDataOp
				MsUnlock()
			EndIf
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} V166VL
DESCRIÇÃO : Rotina para barrar uso de estorno de separação no coletor.

@author Felipe Toazza Caldeira
@since 11/01/2017
@return lLiberada, lógico, Se for Ordem de Produção, verifica se esta liberada
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6091059
/*/
User Function ACD166VL()

	If CB7->CB7_STATUS == '9'
		VtAlert("Rotina de Estorno bloqueada para uso no coletor","Aviso",.t.,4000,3)
	EndIf

Return .F.

/*/{Protheus.doc} BaixaSemTRT
DESCRIÇÃO : Rotina para executar baixa em processo não finalizado de forma correta

@author Felipe Toazza Caldeira
@since 11/01/2017
@return lLiberada, lógico, Se for Ordem de Produção, verifica se esta liberada
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6091059
/*/
Static Function BaixaSemTRT(cNLocaliz)
Local _aSD3 := {}
Local _cTm	:= "501"//mudar para parametro

		cDoc := GetSxeNum("SD3","D3_DOC")
		ConfirmSx8()

		If Empty(Alltrim(cNLocaliz))
			cNLocaliz := CB9->CB9_LCALIZ
		EndIf

		_aSD3 := {}
		aAdd(_aSD3, {"D3_TM"     , _cTM           	, Nil})
		aAdd(_aSD3, {"D3_COD"    , CB9->CB9_PROD 	, Nil})
		aAdd(_aSD3, {"D3_QUANT"  , CB9->CB9_QTESEP 	, Nil})
		aAdd(_aSD3, {"D3_LOCAL"  , CB9->CB9_LOCAL  	, Nil})
		aAdd(_aSD3, {"D3_LOCALIZ", cNLocaliz	 	, Nil})
		aAdd(_aSD3, {"D3_EMISSAO", dDataBase      	, Nil})
		aAdd(_aSD3, {"D3_OP"	 , CB7->CB7_OP     	, Nil})
		aAdd(_aSD3, {"D3_DOC"	 , cDoc 	    	, Nil})

		lMsErroAuto := .f.
		msExecAuto({|x, y| mata240(x, y)}, _aSD3, 3)

		If lMsErroAuto
			mostraErro()
		Else
			RecLock("CB9",.F.)
			CB9->CB9_DOC := SD3->D3_DOC
			CB9->(MsUnlock())
		EndIf
Return


/*/{Protheus.doc} BaixaComTRT
DESCRIÇÃO : Rotina para executar baixa em processo não finalizado de forma correta

@author Felipe Toazza Caldeira
@since 11/01/2017
@return lLiberada, lógico, Se for Ordem de Produção, verifica se esta liberada
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6091059
/*/
Static Function BaixaComTRT
Local _aSD3 := {}
Local _cTm	:= "501"//mudar para parametro

		cDoc := GetSxeNum("SD3","D3_DOC")
		ConfirmSx8()
		_aSD3 := {}
		aAdd(_aSD3, {"D3_TM"     , _cTM           	, Nil})
		aAdd(_aSD3, {"D3_COD"    , CB9->CB9_PROD 	, Nil})
		aAdd(_aSD3, {"D3_QUANT"  , CB9->CB9_QTESEP 	, Nil})
		aAdd(_aSD3, {"D3_LOCAL"  , CB9->CB9_LOCAL  	, Nil})
		aAdd(_aSD3, {"D3_LOCALIZ", CB9->CB9_LCALIZ 	, Nil})
		aAdd(_aSD3, {"D3_EMISSAO", dDataBase      	, Nil})
		aAdd(_aSD3, {"D3_OP"	 , CB7->CB7_OP     	, Nil})
		aAdd(_aSD3, {"D3_DOC"	 , cDoc 	    	, Nil})
		aAdd(_aSD3, {"D3_TRT"	 , SD4->D4_TRT     	, Nil})

		lMsErroAuto := .f.
		msExecAuto({|x, y| mata240(x, y)}, _aSD3, 3)

		If lMsErroAuto
			mostraErro()
		Else
			RecLock("CB9",.F.)
			CB9->CB9_DOC := SD3->D3_DOC
			CB9->(MsUnlock())
		EndIf
Return
