#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata410 - Pedidos de Venda
-------------------------------------------------------------------------------
*/

/*/{Protheus.doc} M410ALOK
Ponto de Entrada para bloquear a Alteração do Pedido
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
				If ZA7->(dbSeek(xFilial("ZA7")+SC9->C9_PEDIDO+SC9->C9_ITEM))//VERIFICA SE A CARGA ESTA MONTADA E SE O STATUS É 3-ENVIADO A TRANSPORTADORA
				//	If ZA7->ZA7_STATUS$"3,4,5"
						lRet := .F.
						Aviso("ATENÇÃO",'Pedido já liberado com EDI para transportadora. Não é permitido alteração',{"Ok"})
						Exit
				//	EndIf
				EndIf
			//Endif
			SC9->(dbSkip())
		EndDo
	Endif

Return lRet
