#INCLUDE "PROTHEUS.CH"                                                                                                                                               
#include 'parmtype.ch'
#include 'FWMVCDef.CH'

/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata680 - Apontamento de Produ��o Mod.1
-------------------------------------------------------------------------------
*/

/*/{Protheus.doc} MA680INC
Ponto de Entrada apos a grava��o para atualizar campos 
@type function
@version  12.1.27
@author Carlos Cleuber
@since 25/01/2021
/*/
User Function MA680INC()
Local aSH6		:= GetArea()
Local nOpca 	:= PARAMIXB[1]
Local nPrzVld	:= GetAdvFVal("SB1","B1_PRVALID",xFilial("SB1")+SH6->H6_PRODUTO,1)
Local cLoteOP	:= GetAdvFVal("SC2","C2_XLOTECT",xFilial("SC2")+SH6->H6_OP,1)

If nOpca== 1 .and. !Empty(cLoteOP) 
	RecLock("SH6",.F.)
	SH6->H6_LOTECTL:= cLoteOP
	SH6->H6_DTVALID:= dDataBase + nPrzVld
	SH6->(MsUnlock())
Endif

RestArea(aSH6)
Return
