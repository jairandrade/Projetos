#INCLUDE "PROTHEUS.CH"
#Include "topconn.ch"
//---------------------------------------------------------------------
/*/{Protheus.doc} CTA120MNU
Inclusão de chamada de menu na tabale de preço de compras

@author Felipe
@since 23/06/2017
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
User Function CTA120MNU()

aAdd(aRotina,{ "Informações Rateio", "U_AGCT004"	, 0, 6, 0, nil}) 
aAdd(aRotina,{ "Banco de Conhecimento", "U_TCPGED"	, 0, 6, 0, nil}) 

Return