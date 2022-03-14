#include 'protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata260 - Transferencia Mod2
-------------------------------------------------------------------------------
*/

/*/{Protheus.doc} MA261LIN
P.E. para validar a linha da transferencia( modelo 2 ) com a integração WMS
@type function
@version  12.1.27
@author Carlos Cleuber
@since 27/01/2021
/*/
User Function MA260LIN
Local lRet := .T.

Local cOrigem	:= ''
Local cEndERP	:= alltrim(SuperGetMV("FZ_XENDERP"))
Local cEndWMS	:= alltrim(SuperGetMV("FZ_XENDWMS"))

If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+cCodOrig,1) == "S"

	Help( , , 'Codido Produto' , , '[Linha'+ cvaltochar(nLin)+ '] - Produto esta configurado para integração com o WMS!', 1, 0, , , , , , {"Favor utilizar rotina especifica para movimentar esse produto!"})
	lRet:= .F.

Else

	If alltrim(cLoclzOrig) $ cEndERP  .or. alltrim(cLoclzOrig) $ cEndWMS 
		Help( , , 'Codido Produto' , , '[Linha'+ cvaltochar(nLin)+ '] - Produto NAO tem integração com o WMS!', 1, 0, , , , , , {"Favor um endereço que não esteja configuradopara o WMS!"})
		lRet := .f.
	Endif		

	If lRet .and. (alltrim(cLoclzDest) $ cEndERP  .or. alltrim(cLoclzDest) $ cEndWMS )
		Help( , , 'Codido Produto' , , '[Linha'+ cvaltochar(nLin)+ '] - Produto NAO tem integração com o WMS!', 1, 0, , , , , , {"Favor um endereço que não esteja configuradopara o WMS!"})
		lRet := .f.
	Endif		

Endif


Return lRet
