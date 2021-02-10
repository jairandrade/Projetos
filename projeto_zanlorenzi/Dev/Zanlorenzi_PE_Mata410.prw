#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata410 - Pedidos de Venda
-------------------------------------------------------------------------------
*/

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MA410MNU
Ponto de Entrada para adicionar novas fun��es no Bot�o Outras A��es do Browser
@type function
@author Carlos CLeuber
@since 09/12/2020
@version 1.0
/*/
User Function MA410MNU

    AAdd(aRotina, {"Exporta WMS CyberLog", "EECVIEW( U_fGrJson(GetMv('FZ_WSWMS5')) )", 0, 2, 0, NIL})
	
Return 

/*/{Protheus.doc} M410ALOK
Ponto de Entrada para bloquear a Altera��o do Pedido
@type function
@version 1.0
@author Jair Andrade
@since 16/12/2020
@return return_type, return_description
/*/
User Function M410ALOK()
	Local lRet := .T.
	SC9->(DbSetOrder(1))
	If SC9->(MsSeek(xFilial("SC9")+SC5->C5_NUM))
		While SC9->(!Eof()) .And. SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM
			//If !Empty(SC9->C9_CARGA)
				dbSelectArea("ZA7")
				ZA7->(DbSetOrder(3))
				If ZA7->(dbSeek(xFilial("ZA7")+SC9->C9_PEDIDO+SC9->C9_ITEM))//VERIFICA SE A CARGA ESTA MONTADA E SE O STATUS � 3-ENVIADO A TRANSPORTADORA
				//	If ZA7->ZA7_STATUS$"3,4,5"
						lRet := .F.
						Aviso("ATEN��O",'Pedido j� liberado com EDI para transportadora. N�o � permitido altera��o',{"Ok"})
						Exit
				//	EndIf
				EndIf
			//Endif
			SC9->(dbSkip())
		EndDo
	Endif

Return lRet

