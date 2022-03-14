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
Local nCod   	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_COD'})
Local nArm   	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_LOCAL'})
Local nLocaliz := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_LOCALIZ'})
Local cProduto	:= aCols[nLin,nCod]  //FWFldGet("D3_COD",nLin)
Local cArm		:= aCols[nLin,nArm]  //FWFldGet("D3_LOCAL",nLin)
Local cLocaliz	:= aCols[nLin,nLocaliz] //FWFldGet("D3_LOCALIZ",nLin)
Local cEndERP	:= alltrim(SuperGetMV("FZ_XENDERP"))
Local cEndWMS	:= alltrim(SuperGetMV("FZ_XENDWMS"))
Local cArmERP       := substr(cEndERP,1,2)
Local cArmWMS       := substr(cEndWMS,1,2)
Local lRet:= .T.

If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+cProduto,1) == "S" //Verifico se o produto tem integração com o WMS CyberLog
	Help( , , 'Codigo Produto' , , '[Linha'+ cvaltochar(nLin)+ '] - Produto esta configurado para integração com o WMS!', 1, 0, , , , , , {"Favor utilizar rotina especifica para movimentar esse produto!"})
	lRet:= .F.
Else

   If cArm $ cArmERP .or. cArm $ cArmWMS
      lRet :=.F.
      Help( , , 'Armazém Origem' , , '[Linha'+ cvaltochar(nLin)+ '] - Armazém invalido!!! Uso exclusivo com o WMS!', 1, 0, , , , , , {"Favor utilizar rotina especifica para movimentar esse produto!"})
   Endif

   If lRet .and. cLocaliz $ cEndERP .or. cLocaliz $ cEndWMS
      lRet :=.F.
      Help( , , 'Endereço ' , , '[Linha'+ cvaltochar(nLin)+ '] - Endereço invalido!!! Uso exclusivo com o WMS!', 1, 0, , , , , , {"Favor utilizar rotina especifica para movimentar esse produto!"})
   Endif
   
Endif

Return lRet
