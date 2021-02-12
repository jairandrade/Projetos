#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: M410ABN		|	Autor: Luis Paulo							|	Data: 14/11/2019	//
//==================================================================================================//
//	Descrição: PE no cancelamento do pedido de venda												//
//                                                                                                  //
//==================================================================================================//
User Function M410ABN()
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaCTT	:= CTT->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())

If IsInCallStack("A410Devol") .And. cEmpAnt == "04"//é uma devolucao 
	//Faz o desbloqueio geral: Centro de custo, cliente e produto das devolucoes
	u_DesGeral(__cUserId,"MATA410")
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSA2)
RestArea(aAreaCTT)
RestArea(aAreaSA1)
RestArea(aArea)	
Return()