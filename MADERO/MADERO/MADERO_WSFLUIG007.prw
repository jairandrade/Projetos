#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} GetSx5Info
//TODO Declaração do WebService GetArmEst
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetArmEst DESCRIPTION "Madero - Locais de Armazém e Estoque - FLUIG"

	WSMETHOD POST DESCRIPTION "Lista de Locais de Armazém e Estoque para integração FLUIG" WSSYNTAX "/GetArmEst"

END WSRESTFUL

/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetArmEst
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSSERVICE GetArmEst

	Local cResponse	:= ""
	Local idproduto := ""
	Local cBody
	Local oObj
	
	::SetContentType("application/json")

	cResponse := WSFLUIG007()

	If cResponse == "Error"
		Return .F.
	EndIf
	
	cResponse := EncodeUTF8(cResponse)
	
	::SetResponse(cResponse)

Return .T.

/*/{Protheus.doc} makeJson
//TODO Metodo para gerar JSON com lista de Armazéns e estoque.
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
/*/
Static Function makeJson(cAlQry)

	Local cJson 	:= ""
	
	cJson += 	'{"ArmEst":[' //Inicia objeto Json.
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"NNR_CODIGO":"'+ ALLTRIM((cAlQry)->NNR_CODIGO) +'",'
			cJson +=	'"NNR_DESCRI":"'+ ALLTRIM((cAlQry)->NNR_DESCRI) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson := LEFT(cJson, (LEN(cJson)-1))
	cJson +=	']}' // Finaliza objeto Json

Return cJson

/*/{Protheus.doc} WSFLUIG007
//TODO Função para executar WS GetArmEst
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG007()
	Local cJson := ""
	Local cQuery := ""
	Local cAlQry	:= ""


	If Select("QRY") > 0
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf
	
		cQuery := "	SELECT NNR_CODIGO, NNR_DESCRI 			" 	+ CRLF
		cQuery += "	FROM " + RetSqlName("NNR") 					+ CRLF
		cQuery += "	WHERE 									" 	+ CRLF  
		cQuery += "	NNR_FILIAL = '"+xFilial("NNR")+"' AND 	" 	+ CRLF  
		cQuery += "	D_E_L_E_T_ = ' ' 						" 	+ CRLF
		
		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)
	
		If (cAlQry)->(Eof())
			cJson := "Error"
			SetRestFault(602, EncodeUTF8("Nenhum local de estoque encontrado com os parâmetros informados"))
		Else
			cJson := MakeJson(cAlQry)
		EndIf
	
	(cAlQry)->(dbCloseArea())
Return cJson