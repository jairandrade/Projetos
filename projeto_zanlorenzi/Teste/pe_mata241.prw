#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata241 - Movimentação Interna Multipla
-------------------------------------------------------------------------------
*/

/*/{Protheus.doc} MT241LOK 
Responsável por validar a inclusão dos movimentos internos
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
User Function MT241LOK
Local nLin 		:= ParamIxb[1]
Local cProduto	:= FWFldGet("D3_COD",nLin)
Local cArm		:= FWFldGet("D3_LOCAL",nLin)
Local cLocaliz	:= FWFldGet("D3_LOCALIZ",nLin)
Local lRet:= .T.



Return lRet
