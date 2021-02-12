#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: M415FSQL		|	Autor: Luis Paulo								|	Data: 24/05/2018//
//==================================================================================================//
//	Descrição: 	Pe Após a gravação em todas as opções (inclusão, alteração e exclusão)				//
//				O ParamIxb estará com o número da opção (1, 2 ou 3).								//
//==================================================================================================//
//Grava o vendedor do cliente
User Function M415GRV()
Local nParam	:= ParamIxb
Local aArea		:= GetArea()

If nParam[1] == 1 //1-Inc, 2-Alt, 3-Deleta 
	
	DbSelectArea("SCJ")
	// valida se o campo existe
	If SCJ->( FieldPos("CJ_XVENDED" ) ) > 0
		RecLock("SCJ",.F.)
			SCJ->CJ_XVENDED := POSICIONE("SA1",1,xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA ,"A1_VEND")
		SCJ->(MsUnlock())
	Endif
	
EndIf

RestArea(aArea) 	
Return()