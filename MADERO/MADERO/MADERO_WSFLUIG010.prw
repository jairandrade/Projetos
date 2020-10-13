#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetTeknisa1
//TODO Declaração do WebService GetTeknisa1
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetTeknisa1 DESCRIPTION "Madero - Consultar as informações do grupo Teknisa Nivel 1 - FLUIG"

	WSMETHOD POST DESCRIPTION "Consultar as informações do grupo Teknisa Nivel 1 para integração FLUIG" WSSYNTAX "/GetTeknisa1"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetTeknisa1
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE GetTeknisa1

	Local cResponse	:= ""
	Local idproduto := ""
	Local cBody
	Local oObj
	Local cdfilial := ""
	
	::SetContentType("application/json")
	
	cBody := ::GetContent()


	cResponse := WSFLUIG010()

	::SetResponse(cResponse)
Return .T.


/*/{Protheus.doc} makeJson
//TODO Metodo para gerar JSON com Listas do Teknisa de Nível 1.
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
/*/
Static Function makeJson(cAlQry)

	Local cJson 	:= ""
	
	cJson += 	'{"nivel1":[' //Inicia objeto Json
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"Z18_COD":"'+ ALLTRIM((cAlQry)->Z18_COD) +'",'
			cJson +=	'"Z18_DESCN1":"'+ ALLTRIM((cAlQry)->Z18_DESCN1) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson +=	'{}]}' //Finaliza objeto Json

Return cJson

/*/{Protheus.doc} WSFLUIG010
//TODO Função para executar WS GetTeknisa1
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG010()
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
	
	/*
	{
	"cdempresa":"01",
	"cdfilial":"01GDAD0001"
	}
	*/
	
		cQuery := "	SELECT Z18_COD, Z18_DESCN1 " + CRLF
		cQuery += "	FROM Z18010" + CRLF  
		cQuery += " ORDER BY Z18_COD " + CRLF  
		
		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)
	
		If (cAlQry)->(Eof())
			cAux := "Nao encontrado grupos de produtos. [BM_GRUPO > 500]"
			lCont := .F.
		EndIf
	
		If lCont
			cJson := MakeJson(cAlQry)
		Else	
			cJson := "Error"
			SetRestFault(602, "Erro ao consultar tabela Z18.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
