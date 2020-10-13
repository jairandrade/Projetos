#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetTeknisa3
//TODO Declaração do WebService GetTeknisa3
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetTeknisa3 DESCRIPTION "Madero - Consultar as informações do grupo Teknisa Nivel 3 - FLUIG"

	WSMETHOD POST DESCRIPTION "Consultar as informações do grupo Teknisa Nivel 3 para integração FLUIG" WSSYNTAX "/GetTeknisa3"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetTeknisa3
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE B1_XN1, B1_XN2 WSSERVICE GetTeknisa3

	Local cResponse	:= ""
	Local idproduto := ""
	Local cBody
	Local oObj
	Local cdempresa := ""
	Local cdfilial := ""
	Local B1_XN1 := ""
	Local B1_XN2 := ""
	
	
	::SetContentType("application/json")
	
	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
	B1_XN1 :=  cValtoChar(oObj:B1_XN1)
	B1_XN2 :=  cValtoChar(oObj:B1_XN2)
	
		If B1_XN1 == "" .Or. B1_XN2 == ""
			cResponse := "Error"		
			SetRestFault(600, "Parametros Incorretos")
		Else
			cResponse := WSFLUIG011(B1_XN1, B1_XN2)
		EndIf
	
	Else
	
	cResponse := "Error"		
	SetRestFault(600, "Parametros Incorretos")
	
	EndIf
	
	If cResponse == "Error"
		Return .F.
	EndIf

	::SetResponse(cResponse)
Return .T.


/*/{Protheus.doc} makeJson
//TODO Metodo para gerar JSON com Listas do Teknisa de Nível 3.
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
@param B1_XN1, Caracter, Parametro obrigatório referente a Tabela Teknisa Nível 1.
@param B1_XN2, Caracter, Parametro obrigatório referente a Tabela Teknisa Nível 2.
/*/
Static Function makeJson(cAlQry, B1_XN1, B1_XN2)

	Local cJson 	:= ""
	
	cJson += 	'{"nivel1":"'+B1_XN1+'",'//Inicia objeto Json
	cJson += 	'"nivel2":"'+B1_XN2+'",'
	cJson += 	'"nivel3":['
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"Z20_CODN3":"'+ ALLTRIM((cAlQry)->Z20_CODN3) +'",'
			cJson +=	'"Z20_DESCN3":"'+ ALLTRIM((cAlQry)->Z20_DESCN3) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson +=	'{}]}'//Finaliza objeto Json

Return cJson

/*/{Protheus.doc} WSFLUIG012
//TODO Função para executar WS GetTeknisa3
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
@param B1_XN1, Caracter, Parametro obrigatório referente a Tabela Teknisa Nível 1.
@param B1_XN2, Caracter, Parametro obrigatório referente a Tabela Teknisa Nível 2.
/*/
Static Function WSFLUIG011(B1_XN1, B1_XN2)
	Local cJson := ""
	Local nPos := 1
	Local Filial := ""
	Local SM0_aux := ""
	Local lCont := .T.
	Local cQuery := ""
	Local cAlQry	:= ""
	Local cdempresa := "01"
	Local cdfilial	:= "01GDAD0001"
	
	
	OpenSM0()
	DBSelectArea("SM0")
	SM0->(DBSetOrder(1))
	If SM0->(MSSeek(cdempresa+cdfilial))
		// -> Inicia o ambiente
    	RpcClearEnv()        
        RpcSetType(3) 
	    RpcSetEnv(cdempresa,cdfilial,,,'FAT',GetEnvServer())                           
    	OpenSm0(cdempresa,.f.)
	    nModulo:=2
	Else
		cJson := "Error"
		SetRestFault(601, "Empresa/Filial não encontrada.")
		Return cJson
	EndIf

	If Select("QRY") > 0
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf
	
	
		cQuery := "	SELECT Z20_CODN3, Z20_DESCN3 " + CRLF
		cQuery += "	FROM Z20010"+ CRLF
		cQuery += " WHERE Z20_CODN1 ='"+B1_XN1+"'" + CRLF
		cQuery += " AND Z20_CODN2 ='"+B1_XN2+"'" + CRLF 
		cQuery += " ORDER BY Z20_CODN3 "+ CRLF 
		
		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)
	
		If (cAlQry)->(Eof())
			cAux := "Nao encontrado grupos de produtos. [BM_GRUPO > 500]"
			lCont := .F.
		EndIf
	
		If lCont
			cJson := MakeJson(cAlQry, B1_XN1, B1_XN2)
		Else	
			cJson := "Error"
			SetRestFault(602, "Erro ao consultar tabela Z20.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
