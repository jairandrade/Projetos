#include 'protheus.ch'
#include 'parmtype.ch'

//==================================================================================================//
//	Programa: MTGEROPI		|	Autor: Luis Paulo								|	Data: 22/01/2018//
//==================================================================================================//
//	Descrição:Função recursiva que permite a seleção de opcionais. EM QUE PONTO: O ponto de entrada //
//é chamado na verificação recursiva de opcionais. Tem como objetivo inibir (.F.) ou exibir (.T.) a //
//tela de seleção de opcionais do produto, caso o produto não seja produzido.						//
//																									//
//==================================================================================================//
//Solução de contorno para o problema no pedido de venda
User function MTGEROPI()
Local aArea		:= GetArea()
Local lRet	:= .T.	

If IsInCallStack("MATA410")
	lRet	:= .F.
EndIf

RestArea(aArea)
Return(lRet)