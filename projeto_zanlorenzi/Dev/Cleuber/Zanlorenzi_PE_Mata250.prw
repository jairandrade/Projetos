#INCLUDE "PROTHEUS.CH"                                                                                                                                               
#include 'parmtype.ch'
#include 'FWMVCDef.CH'

/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata250 - Apontamento de Produção Simples
-------------------------------------------------------------------------------
*/

/*/{Protheus.doc} A250ETRAN
Ponto de Entrada apos a gravação para atualizar campos 
@type function
@version  12.1.27
@author Carlos Cleuber
@since 25/01/2021
/*/
User Function A250ETRAN()
Local aSD3		:= GetArea()
Local nPrzVld	:= GetAdvFVal("SB1","B1_PRVALID",xFilial("SB1")+SD3->D3_COD,1)
Local cLoteOP	:= GetAdvFVal("SC2","C2_XLOTECT",xFilial("SC2")+SD3->D3_OP,1)

If !Empty(cLoteOP)
	RecLock("SD3",.F.)
	SD3->D3_LOTECTL:= cLoteOP
	SD3->D3_DTVALID:= dDataBase + nPrzVld
	SD3->(MsUnlock())
Endif

RestArea(aSD3)
Return
