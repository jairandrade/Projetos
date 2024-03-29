#include "protheus.ch"
#include "topconn.ch"

        
/*/{Protheus.doc} MT100LOK
Ponto de Entrada para verificar se o Produte tem integra��o com o WMS, e se o mesmo foi enviado ao WMS
@type function
@version 12.1.27 
@author Carlos Cleuber
@since 03/02/2021
/*/          
User Function MT100LOK()

Local lRet	:= .T.
Local nPCod		:= GdFieldPos("D1_COD")
Local nPStWMS	:= GdFieldPos("D1_XSTAWMS")
Local cCodProd	:= aCols[n,nPCOD]
Local cStaWMS	:= aCols[n,nPStWMS]

If !GdDeleted(n) 

	If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+cCodProd,1) == "S"
		If cStaWMS != "O"
			Aviso("Aten��o - MT100LOK","Produto " + cCodProd + " Linha " + strzero(n,3) + CRLF +  "Produto com integra��o com o WMS!!! " + CRLF +  "Produto n�o foi integrado ou o retorno com erro.",{"OK"})
			lRet:= .F.
		Endif
	Endif

endif

Return lRet
