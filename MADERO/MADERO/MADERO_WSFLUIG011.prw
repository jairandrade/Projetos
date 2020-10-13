#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetTeknisa2
//TODO Declara��o do WebService GetTeknisa2
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetTeknisa2 DESCRIPTION "Madero - Consultar as informa��es do grupo Teknisa Nivel 2 - FLUIG"

	WSMETHOD POST DESCRIPTION "Consultar as informa��es do grupo Teknisa Nivel 2 para integra��o FLUIG" WSSYNTAX "/GetTeknisa2"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declara��o do Metodo GetTeknisa2
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE B1_XN1 WSSERVICE GetTeknisa2

	Local cResponse	:= ""
	Local idproduto := ""
	Local cBody
	Local oObj
	Local cdempresa := ""
	Local cdfilial := ""
	Local B1_XN1 := ""
	
	
	::SetContentType("application/json")
	
	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
	B1_XN1 :=  cValtoChar(oObj:B1_XN1)
	
		If B1_XN1 == ""
			cResponse := "Error"		
			SetRestFault(600, "Parametros Incorretos")
		Else
			cResponse := WSFLUIG011(B1_XN1)
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
//TODO Metodo para gerar JSON com Listas do Teknisa de N�vel 2.
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
@param B1_XN1, Caracter, Parametro obrigat�rio referente a Tabela Teknisa N�vel 1.
/*/
Static Function makeJson(cAlQry, B1_XN1)

	Local cJson 	:= ""
	
	cJson += 	'{"nivel1":"'+B1_XN1+'",' //Inicia Objeto Json
	cJson += 	'"nivel2":['
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"Z19_CODN2":"'+ ALLTRIM((cAlQry)->Z19_CODN2) +'",'
			cJson +=	'"Z19_DESCN2":"'+ ALLTRIM((cAlQry)->Z19_DESCN2) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson +=	'{}]}'//Finaliza Objeto Json

Return cJson

/*/{Protheus.doc} WSFLUIG011
//TODO Fun��o para executar WS GetTeknisa2
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
@param B1_XN1, Caracter, Parametro obrigat�rio referente a Tabela Teknisa N�vel 1.
/*/
Static Function WSFLUIG011(B1_XN1)
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
		SetRestFault(601, "Empresa/Filial n�o encontrada.")
		Return cJson
	EndIf

	If Select("QRY") > 0
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf
	
		cQuery := "	SELECT Z19_CODN2, Z19_DESCN2 " + CRLF
		cQuery += "	FROM Z19010"+ CRLF
		cQuery += " WHERE Z19_CODN1 ='"+B1_XN1+"'" + CRLF 
		cQuery += " ORDER BY Z19_CODN2 " + CRLF 
		
		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)
	
		If (cAlQry)->(Eof())
			cAux := "Nao encontrado grupos de produtos. [BM_GRUPO > 500]"
			lCont := .F.
		EndIf
	
		If lCont
			cJson := MakeJson(cAlQry, B1_XN1)
		Else	
			cJson := "Error"
			SetRestFault(602, "Erro ao consultar tabela Z19.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
