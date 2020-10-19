#include 'totvs.ch'

/*/{Protheus.doc} MATA131
//TODO
@description Ponto de entrada MVC rotina MATA131 - Gera Cota��o
@author willian.kaneta
@since 17/07/2020
@version 1.0
@type function
/*/
user function MATA131()
	Local aParam 	:= PARAMIXB
	Local xRet 		:= .T.
	Local oObj 		:= ""
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
	Local aArea		:= GetArea()
	Local aAreaSC8 	:= SC8->(GetArea())
	Local aAreaSC1 	:= SC1->(GetArea())
	Local oModel 	:= FWModelActive()

	If aParam <> NIL
		oObj 		:= aParam[1]
		cIdPonto 	:= aParam[2]
		cIdModel 	:= aParam[3]

		If cIdPonto == 'MODELPOS'
			xRet := VALHOMFOR(oModel)
		ElseIf cIdPonto == 'FORMLINEPRE' .AND. cIdModel == "SC8DETAIL"
			If aParam[5] == "SETVALUE" .AND. cIdModel == "SC8DETAIL"
				xRet := VALALTFOR(oModel,aParam[5])
			EndIf			
		//Tratativas para Produto X Forncedor Homolog
		ElseIf cIdPonto == 'FORMLINEPRE' .AND. cIdModel ==	"SC1DETAIL"
			xRet := RETFORHOMOL(oModel)
		ElseIf cIdPonto == "BUTTONBAR"
			xRet := {{"Legenda Fornecedor", "Legenda Fornecedor", {||U_TCCO01W()}}}
		EndIf

	EndIf

	RestArea(aAreaSC1)
	RestArea(aAreaSC8)
	RestArea(aArea)

return xRet

/*/{Protheus.doc} VALALTFOR
Fun��o utilizada para realizar a valida��o de Altera��o/ Delete da grid de Fornecedores "SC8DETAIL"
@type  Static Function
@author Willian Kaneta
@since 20/07/2020
@version 1.0
@return lRet = .T./.F.
@example
(examples)
@see (links_or_references)
/*/
Static Function VALALTFOR(oModel,cOperat)

	Local aAreaSA2	:= SA2->(GetArea())
	Local lRet 		:= .T.
	Local cFornece	:= ""

	If cOperat == "SETVALUE"
		cFornece	:= oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNECE")
		
		If Empty(cFornece)
			Help(NIL, NIL, "HELP: PEMTA131", NIL, "N�o informado fornecedor", 1,0, NIL, NIL, NIL, NIL, NIL,;
				{"N�o foi informado fornecedor para algum produto, verificar!"})
		EndIf
	EndIf

	RestArea(aAreaSA2)

Return lRet
/*/{Protheus.doc} RETFORHOMOL
	Fun��o utilizada para realizar a a tratativa Produto X Homologa��o Fornecedor
	@type  Static Function
	@author Willian Kaneta
	@since 20/07/2020
	@version 1.0
	@return lRet = .T./.F.
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RETFORHOMOL(oModel)

	Local lRet 		:= .T.
	Local aAreaSA2	:= SA2->(GetArea())
	Local oModGrpo	:= oModel:GetModel("SBMDETAIL")
	Local oModProd	:= oModel:GetModel("SC1DETAIL")
	Local oModForn	:= oModel:GetModel("SC8DETAIL")
	Local nLinGrp	:= oModGrpo:nLine
	Local nLinePrd	:= oModProd:nLine
	Local nLineFor	:= oModForn:nLine
	Local nDiasHom	:= SUPERGETMV("TCP_DIASHM",.F.,90)
	Local cProdut	:= ""
	Local cFornece	:= ""
	Local cProdQuim	:= ""
	Local nLinePro	:= 0
	Local nX, nY	:= 0

	For nX := 1 To oModGrpo:Length()
		oModGrpo:GoLine(nX)
		nLinePro := 0
		While nLinePro < oModProd:Length()
			++nLinePro
			oModProd:GoLine(nLinePro)
			cProdut := oModProd:Getvalue("C1_PRODUTO")

			cProdQuim := POSICIONE("SB1",1,xFilial("SB1")+cProdut,"B1_XQUIMI")

			If cProdQuim == "S"
				For nY := 1 To oModForn:Length()
					oModForn:GoLine(nY)
					If oModForn:IsDeleted()
						Loop
					Endif
					cFornece := oModForn:GetValue("C8_FORNECE")+oModForn:GetValue("C8_LOJA")

					DbSelectArea("SA2")
					SA2->(DbSetOrder(1))

					If SA2->(MsSeek(xFilial("SA2")+cFornece))
						If( SA2->A2_XHOMOL == "S" )
							//Apto e validade Homologa��o OK - OK
							If( SA2->A2_XVLDHOM >= DATE() )
								oModForn:LoadValue("C8_XHOMFOR","OK")
								oModForn:LoadValue("C8_XLEGEND","BR_VERDE")
								//Validade homologa��o vencida mas dentro do prazo parametro TCP_DIASHM - APTO
							ElseIf ( !Empty(A2_XVLDHOM) .And. Date()>A2_XVLDHOM .And. Date()-A2_XVLDHOM <= nDiasHom )
								oModForn:LoadValue("C8_XHOMFOR","AP")
								oModForn:LoadValue("C8_XLEGEND","BR_AMARELO")
								//Validade homologa��o vencida e fora do prazo parametro TCP_DIASHM - VENCIDA
							ElseIf ( !Empty(A2_XVLDHOM) .And. A2_XVLDHOM < Date() .And. Date()-A2_XVLDHOM > nDiasHom )
								oModForn:LoadValue("C8_XHOMFOR","VE")
								oModForn:LoadValue("C8_XLEGEND","BR_VERMELHO")
							EndIf
						Else
							//Produto Quimico, mas fornecedor com cadastro n�o preenchido
							oModForn:LoadValue("C8_XHOMFOR","NH")
							oModForn:LoadValue("C8_XLEGEND","BR_PRETO")
						EndIf
					EndIf
				Next nY
			Else
				For nY := 1 To oModForn:Length()
					oModForn:GoLine(nY)
					If oModForn:IsDeleted()
						Loop
					Endif

					oModForn:LoadValue("C8_XLEGEND","BR_BRANCO")
				Next nY
			EndIf
		EndDo
	Next nX

	oModGrpo:GoLine(nLinGrp)
	oModProd:GoLine(nLinePrd)
	oModForn:GoLine(nLineFor)

	RestArea(aAreaSA2)

Return lRet

/*/{Protheus.doc} VALHOMFOR
	Fun��o para validar se existe fornecedor com homologa��o vencida
	@type  Static Function
	@author user
	@since 13/08/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function VALHOMFOR(oModel)
	
	Local lRet 		:= .T.
	Local aAreaSA2	:= SA2->(GetArea())
	Local oModGrpo	:= oModel:GetModel("SBMDETAIL")
	Local oModProd	:= oModel:GetModel("SC1DETAIL")
	Local oModForn	:= oModel:GetModel("SC8DETAIL")
	Local nLinGrp	:= oModGrpo:nLine
	Local nLinePrd	:= oModProd:nLine
	Local nLineFor	:= oModForn:nLine
	Local nDiasHom	:= SUPERGETMV("TCP_DIASHM",.F.,0)
	Local cProdut	:= ""
	Local cFornece	:= ""
	Local cProdQuim	:= ""
	Local nLinePro	:= 0
	Local nX, nY	:= 0
	Local lHomVenc, lCadNot := .F.

	For nX := 1 To oModGrpo:Length()
		oModGrpo:GoLine(nX)
		nLinePro := 0
		While nLinePro < oModProd:Length()
			++nLinePro
			oModProd:GoLine(nLinePro)
			cProdut := oModProd:Getvalue("C1_PRODUTO")

			cProdQuim := POSICIONE("SB1",1,xFilial("SB1")+cProdut,"B1_XQUIMI")

			If cProdQuim == "S"
				For nY := 1 To oModForn:Length()
					oModForn:GoLine(nY)
					If oModForn:IsDeleted()
						Loop
					Endif
					cFornece := oModForn:GetValue("C8_FORNECE")+oModForn:GetValue("C8_LOJA")

					DbSelectArea("SA2")
					SA2->(DbSetOrder(1))

					If SA2->(MsSeek(xFilial("SA2")+cFornece))
						If SA2->A2_XHOMOL == "S"
							//Validade homologa��o vencida e fora do prazo parametro TCP_DIASHM - VENCIDA
							If (SA2->A2_XVLDHOM < DATE()) .AND. ((DATE() - SA2->A2_XVLDHOM) > nDiasHom)
								lHomVenc := .T.
								Exit
							EndIf
						Else
							//Produto Quimico, mas fornecedor com cadastro n�o preenchido
							lCadNot := .T.
							Exit
						EndIf
					EndIf
				Next nY
			EndIf
			If lHomVenc .OR. lCadNot
				Exit
			EndIf
		EndDo
		If lHomVenc .OR. lCadNot
			Exit
		EndIf
	Next nX

	If lHomVenc .OR. lCadNot
		lRet := MsgYesNo("Existem fornecedores com homologa��o vencida para produtos qu�micos, deseja continuar?", "Aten��o")

		If !lRet
			Help(NIL, NIL, "HELP: PEMTA131", NIL, "Opera��o cancelada.", 1,0, NIL, NIL, NIL, NIL, NIL,;
				{"Conforme op��o escolhida anteriormente opera��o cancelada, verificar fornecedores com homologa��o vencida para produtos qu�micos!"})
		EndIf
	EndIf

	oModGrpo:GoLine(nLinGrp)
	oModProd:GoLine(nLinePrd)
	oModForn:GoLine(nLineFor)

	RestArea(aAreaSA2)
Return lRet

/*/{Protheus.doc} TCCO01W
	Legenda Grid Fornecedores
	@type  Function
	@author Willian Kaneta
	@since 31/07/2020
	@version 1.0
	@return Nil
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function TCCO01W()
	
	Local aLegenda := {}

	aAdd(aLegenda, {"ENABLE"    	,"Fornecedor Homologado"})
	aAdd(aLegenda, {"BR_PRETO"		,"Fornecedor sem homologa��o"})
	aAdd(aLegenda, {"BR_VERMELHO"	,"Fornecedor com homologa��o vencida"})
	aAdd(aLegenda, {"BR_AMARELO"	,"Fornecedor com homologa��o vencida dentro do prazo"})
	aAdd(aLegenda, {"BR_BRANCO"   	,"N�o � Fornecedor Produto Qu�mico"})

	BrwLegenda("Homologa��o Fornecedores Prod. Qu�micos","Legenda" ,aLegenda)

Return Nil

