#include 'protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata261 - Transferencia Mod2
-------------------------------------------------------------------------------
*/

/*/{Protheus.doc} MA261LIN
P.E. para validar a linha da transferencia( modelo 2 ) com a integra��o WMS
@type function
@version  12.1.27
@author Carlos Cleuber
@since 27/01/2021
/*/
User Function MA261LIN
Local lRet := .T.

Local cEndERP	:= alltrim(SuperGetMV("FZ_XENDERP"))
Local cEndWMS	:= alltrim(SuperGetMV("FZ_XENDWMS"))

Local nPosCod := aScan( aHeader, { |x| alltrim(upper(x[2]))== 'D3_COD' } )
Local nPEndOri := aScan( aHeader, { |x| alltrim(upper(x[2]))== 'D3_LOCALIZ' }	, nPosCod+4 )
Local nPEndDes := aScan( aHeader, { |x| alltrim(upper(x[2]))== 'D3_LOCALIZ' } 	, nPosCod+9 )

Default lWSCyberLog:= .F. // Variavel do Tipo private definida no WebService do CyberLog ZANLORENZI_WSWMS.PRW Metodo RecMInterno

If ! lWSCyberLog 

	If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+aCols[oGet:oBrowse:nAt][nPosCod],1) == "S"

		Help( , , 'Codigo Produto' , , 'Produto esta configurado para integra��o com o WMS!', 1, 0, , , , , , {"Favor utilizar rotina especifica para movimentar esse produto!"})
		lRet:= .F.

	Else

		If alltrim(aCols[oGet:oBrowse:nAt][nPEndOri]) $ cEndERP  .or. alltrim(aCols[oGet:oBrowse:nAt][nPEndOri]) $ cEndWMS 
			Aviso("Integra��o WMS","Produto NAO tem integra��o com WMS Cyberlog. N�o podera ser informado endere�os do WMS de Origem para esta opera��o.",{'OK'},2,"Aten��o !!!")
			lRet := .f.
			Return lRet	
		Endif		

		If alltrim(aCols[oGet:oBrowse:nAt][nPEndDes]) $ cEndERP  .or. alltrim(aCols[oGet:oBrowse:nAt][nPEndDes]) $ cEndWMS 
			Aviso("Integra��o WMS","Produto NAO tem integra��o com WMS Cyberlog. N�o podera ser informado endere�os do WMS de DESTINO para esta opera��o.",{'OK'},2,"Aten��o !!!")
			lRet := .f.
			Return lRet	
		Endif	
	Endif

Endif


Return lRet
