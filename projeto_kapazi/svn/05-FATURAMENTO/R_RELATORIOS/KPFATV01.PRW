/**********************************************************************************************************************************/
/** Faturamento                                                                                                                   **/
/** Pedido de Venda                                                                                                          			**/
/** Envio de email para representante e cliente - valida tes para envio ou n�o 
)                              																										**/
/** RSAC Solu��es Ltda.                                                                                                           **/
/** Kapazi                                                                                                                    		**/
/**********************************************************************************************************************************/
/** Data       | Respons�vel                    | Descri��o                                                                      	**/
/**********************************************************************************************************************************/
/** 14/04/2015| Marcos Sulivan          | Cria��o da rotina/procedimento.                                                					**/
/**********************************************************************************************************************************/
#include "protheus.ch"
#include "topconn.ch"
/**********************************************************************************************************************************/
/** user function KPFATV01()                                                                                  										**/
/**********************************************************************************************************************************/
user function KPFATV01()
Local	lRet 	:= .T. 
Local nI 		:= 1
Local aTes 		:= STRTOKARR(GetNewPar("MV_NFCOMPK",""),',')
Private nTesCom	:= aScan(aHeader, { |x| Alltrim(x[2])=="C6_TES"})

For nI := 1	To Len (aCols)

	For nX := 1 To Len(aTes)
	
		If ( aCols[nI][nTesCom] == aTes[nX] )
 			lRet := .F.
 			Return lRet
  	    EndIf
	Next

Next

Return(lRet)
	