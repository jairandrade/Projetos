#INCLUDE "PROTHEUS.CH"
#Include "topconn.ch"
//---------------------------------------------------------------------
/*/{Protheus.doc} CM010MNU
Inclus�o de chamada de menu na tabale de pre�o de compras

@author Felipe
@since 23/06/2017
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
User Function CM010MNU()
Local ExpA1 := PARAMIXB[1]

AADD(ExpA1,{ "Importar Tab. Pre�os","U_MCOM018"	,0,6,,.T.})

Return ExpA1