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
Local nProd   	 := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_COD'})
Local nArm   	 := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_LOCAL'})
Local nLocaliz 	 := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_LOCALIZ'})
Local cProduto	:= aCols[n,nProd]  //FWFldGet("D3_COD",nLin)
Local cArm		:= aCols[n,nArm]  //FWFldGet("D3_COD",nLin)
Local cLocaliz	:= aCols[n,nLocaliz] //FWFldGet("D3_LOCALIZ",nLin)
Local lRet:= .T.



Return lRet
