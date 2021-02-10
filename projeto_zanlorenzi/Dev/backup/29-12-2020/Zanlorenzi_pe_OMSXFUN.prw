#include "protheus.ch"

/*/{Protheus.doc} OMSPEDCG
//O ponto de entrada OMSPEDCG está localizada na função que verifica se o pedido consta em uma carga montada.
Exemplo: Na alteração de um pedido com carga, caso o retorno do ponto de entrada seja Falso, 
o assistente de Help 'A410CARGA- Existe carga montada para itens do pedido' não será apresentado.	
@author Jair Andrade    
@since 15/12/2020
@version version
/*/


User Function OMSPEDCG()
	Local cPedido   := PARAMIXB[1]
	Local lRet      := PARAMIXB[2]
	SC9->(DbSetOrder(1))
	If SC9->(MsSeek(xFilial("SC9")+cPedido))
		While SC9->(!Eof()) .And. SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == cPedido //.And. !lRet
			If !Empty(SC9->C9_CARGA)
				lRet := .T.
                Exit
			EndIf
			SC9->(dbSkip())
		EndDo
	EndIf
Return lRet
