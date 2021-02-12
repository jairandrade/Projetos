#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: LIBPVNFM		|	Autor: Luis Paulo							|	Data: 02/04/2018	//
//==================================================================================================//
//	Descrição: funcao para liberacao do pedido de venda de servico									//
//																									//
//==================================================================================================//
User Function LIBPVNFM(cIdNFSE,aPvlNfs,aBloqueio)
Local aAreaC5	:= SC5->(GetArea())
Local aAreaC6	:= SC6->(GetArea())
Local aAreaC9	:= SC9->(GetArea())

Default aBloqueio	:= {}
Default aPvlNfs		:= {}

DbSelectArea("SC5")
SC5->(DbOrderNickName("XIDNFSE"))
SC5->(DbGoTop())
If SC5->(DbSeek(xFilial("SC5") + cIdNFSE + "2" )) //Posiciona no pedido de serviço
	
	// Liberacao de pedido
	Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
	// Checa itens liberados
	Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
	
	RECLOCK("SC5", .F.)  
	SC5->C5_XSITLIB := "6"
	SC5->(MSUnlock())
	
EndIf

RestArea(aAreaC5)
RestArea(aAreaC6)
RestArea(aAreaC9)
	
Return()