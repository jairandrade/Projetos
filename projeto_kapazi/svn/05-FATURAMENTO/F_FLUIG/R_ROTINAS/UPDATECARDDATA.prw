#include 'protheus.ch'
#include 'parmtype.ch'

#define enter chr(13) + chr(10)

/*/{Protheus.doc} UPDATECARDDATA
//TODO Altera os campos de um formulário..
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
/*/
user function UPDCARDTA(nCompanyId, cUser, cPassword, nCardId, oCardData)

	Local oWs 	:= WSECMCardServiceService():New()
	Local lRet	:= .T.
	Local nRet 	:= 0
	Local cMsg	:= ""

	aAdd(oWs:oWSupdateCardDatacardData:oWsItem, ECMCardServiceService_cardFieldDto():New())
	nItem := len(oWs:oWSupdateCardDatacardData:oWsItem)		
	oWs:oWSupdateCardDatacardData:oWsItem[nItem]:cfield := oCardData[1]
	oWs:oWSupdateCardDatacardData:oWsItem[nItem]:cvalue := oCardData[2]
	
	if len(oCarddata) == 4
		aAdd(oWs:oWSupdateCardDatacardData:oWsItem, ECMCardServiceService_cardFieldDto():New())
		nItem := len(oWs:oWSupdateCardDatacardData:oWsItem)		
		oWs:oWSupdateCardDatacardData:oWsItem[nItem]:cfield := oCardData[3]
		oWs:oWSupdateCardDatacardData:oWsItem[nItem]:cvalue := oCardData[4]
	EndIf

	If !oWs:updateCardData(nCompanyId, cUser, cPassword, nCardId)

		cMsg := enter+ "Erro na criacao do processo :" + getWSCError()
		MessageBox(cMsg,"",16)
		lRet := .F.	
	endIf

Return lRet