#Include "protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"

#Define ENTER chr(13)+chr(10)

/*
	Funcao que faz o inicio / fim da producao
*/
User Function KESTR15(cPedido,cOper)
	Local aArea 	:= GetArea()
	Local lContinua	:= .T.

	// Default cPedido := "284962"
	Default cPedido := ""
	Default cOper	:= "INICIO"

	U_KFATR15C("21","INICIO PRODUCAO")
	U_KFATR15C("22","FIM DE PRODUCAO")

	While lContinua

		lContinua := TelaPedido(cPedido,cOper)

	Enddo

	RestArea(aArea)
Return

/*
	Funcao que faz o fim da producao
*/
User function KESTR15F(cPedido)
	Local 	aArea 	:= GetArea()
	Default cPedido := ""
	// Default cPedido := "284962"

	U_KESTR15(cPedido,"FIM")

	RestArea(aArea)
Return

Static Function TelaPedido(_cPedido,_cOper)
	// retorno
	Local lRet		:= .T.
	// posicao dos objetos
	Local nLinha	:= 30
	// funcao botao ok
	Local bOkb	 	:= {|| iif(VldPedido(cPedido),Close(oDlgPedido),nil)}
	// funcao cancelar
	Local bCancel 	:= {|| lRet := .F.,Close(oDlgPedido) }
	// msg ao deletar
	Local lMsgDel	:= .F.
	// botoes
	Local aButtons	:= {}
	// registro
	Local nRecno 	:= Nil
	// alias
	Local cAlias	:= Nil
	// exibe mashups
	Local lMashups	:= .F.
	// imprime padrao
	Local lImpCad	:= .F.
	// botoes padra
	Local lPadrao	:= .F.
	// exibe botao ok
	Local lHasOk	:= .F.
	// exibe walk
	Local lWalkThru	:= .F.
	// objeto da tela
	Local oDlgPedido
	Local cMsg		:= "Iniciar"
    Local cTemp 	:= GetNextAlias()
	// objeto pedido
	Private oPedido
	// pedido
	Private _cPed   := Space(TamSx3("C5_NUM")[1]) 

	Default _cPedido:= ""
	Default _cOper 	:= "INICIO"

	If !Empty(AllTrim(_cPedido))
		_cPed := _cPedido
	Endif

	If _cOper <> "INICIO"
		cMsg := "Finalizar"
	Endif

	DEFINE MSDIALOG oDlgPedido TITLE cMsg+" a produção do pedido" FROM 000, 000  TO 200, 325 PIXEL
		
		nLinha += 5
		@ nLinha, 004 GROUP TO 098, 161 PROMPT "" OF oDlgPedido PIXEL

		nLinha += 10
		@ nLinha	, 007 SAY "Pedido:" SIZE 025, 007 OF oDlgPedido PIXEL 
		@ nLinha -1	, 032 MSGET oPedido VAR _cPed SIZE 060, 010 OF oDlgPedido PIXEL valid VldPedido(_cPed,_cOper,cTemp)

	ACTIVATE MSDIALOG oDlgPedido CENTERED on init EnchoiceBar( oDlgPedido ,bOkb,bCancel,lMsgDel,aButtons,nRecno,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)

Return lRet 

Static Function VldPedido(cPedido,cOper,cTemp)
	Local lRet := .T.
	Processa({|| lRet := ValidarPedido(cPedido,cOper,cTemp),"Processando...","Aguarde..."})
Return lRet

Static Function ValidarPedido(cPedido,cOper,cTemp)
	Local aArea := GetArea()
	Local lRet	:= .T.
	Local cMsg	:= ""
	Local nPerso:= 0

 	If Empty(Alltrim(cPedido))
		Return .T.
	Endif

	If !existChave("SC5","C5_NUM",cPedido,"C5_FILIAL")
		cMsg := "Pedido "+cPedido+" não localizado."
		lRet := .F.
	Endif

	If lRet
		If cOper == "INICIO"
			// existe ordem de producao
			If existChave("SC2","C2_PEDIDO",cPedido,"C2_FILIAL")
				cMsg := "Ordem de produção "+AllTrim(SC2->C2_NUM)+" já foi criada para o pedido "+cPedido+"."
				lRet := .F.
			Endif

			If lRet 
				nPerso := StaticCall(KFATA13,qryItensPV,cPedido,cTemp,"B1_XOPKAP") 

				If Select(cTemp) > 0
					(cTemp)->(DbCloseArea())
				Endif

				If nPerso > 0
					ProcRegua(0)
					IncProc()
					IncProc()

					Begin Transaction
						lRet := U_KFATA13(cPedido)
					End Transaction

					If !lRet
						cMsg := "Erro na criação da ordem de produção. Verifique."
					Endif
				Else
					U_KFATR15("21",cPedido,,,,"SEM PERSONALIZADO")
				Endif

			Endif
		Else
			nPerso := StaticCall(KFATA13,qryItensPV,cPedido,cTemp,"B1_XOPKAP") 
			If Select(cTemp) > 0
				(cTemp)->(DbCloseArea())
			Endif

			If nPerso > 0
				// nao existe a ordem de producao
				If !existChave("SC2","C2_PEDIDO",cPedido,"C2_FILIAL")
					cMsg := "Ordem de produção ainda não foi criada para o pedido "+cPedido+"."
					lRet := .F.
				Endif

				// possui saldo
				If lRet .and. StaticCall(KFATR13,ordemPAberta,cPedido)
					cMsg := "Ordem de produção encerrada ou totalmente produzida."
					lRet := .F.
				Endif

				If lRet
					MV_PAR01 := cPedido
					MV_PAR02 := cPedido
					MV_PAR03 := ""
					MV_PAR04 := "ZZZZZZ"
					MV_PAR05 := Stod("20180101")
					MV_PAR06 := Stod("20491231")

					// define duas vezes pro compilador nao reclamar
					MV_PAR01 := cPedido
					MV_PAR02 := cPedido
					MV_PAR03 := ""
					MV_PAR04 := "ZZZZZZ"
					MV_PAR05 := Stod("20180101")
					MV_PAR06 := Stod("20491231")

					lRet := U_KFATA13A() == 1
					IF lRet 
						cMsg := "Erro ao realizar a produção do pedido. Verifique."
					Endif

				Endif
			Else
				U_KFATR15("22",cPedido,,,,"SEM PERSONALIZADO")
			Endif
		Endif
	Endif

	If !lRet 
		MsgStop(cMsg)
	Endif

	_cPed := Space(6)
	oPedido:SetFocus()

	RestArea(aArea)
Return lRet

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: existChave														                        	**/
/** DESCRICAO		: valida se o registro existe na tabela e caso exista deixa posicionado                    		**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static Function existChave(_cAlias,cChave,cChaveVlr,cCpoFil)
Return StaticCall(KPFATA06,existChave,_cAlias,cChave,cChaveVlr,cCpoFil)

