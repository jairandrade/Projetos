#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetProdutosApp
//TODO Declaração do WebService GetProdutosApp consumido pelo APP
@author Thiago Berna
@since 16/06/2020
@version 1.0
/*/

WSRESTFUL GetProdutosApp DESCRIPTION "Madero - Produtos - APP"

	WSMETHOD POST DESCRIPTION "Lista de Produtos para integração APP" WSSYNTAX "/GetProdutosApp || /GetProdutosApp/"

END WSRESTFUL

/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetProdutosApp
@author Thiago Berna
@since 16/06/2020
@version 1.0
/*/
WSMETHOD POST WSRECEIVE cdempresa, cdfilial WSSERVICE GetProdutosApp

	Local oObj
    Local cResponse	:= ""
    Local cBody     := ""
	Local cdempresa := ""
	Local cdfilial  := ""
	
	//::SetContentType("application/json")
	::SetContentType("application/json; charset=iso-8859-1")

    cBody := ::GetContent()
	
	If FWJsonDeserialize(cBody,@oObj)
        
        cdempresa   := cValtoChar(oObj:cdempresa)
        cdfilial    := cValtoChar(oObj:cdfilial) 
	
		If cdempresa == "" .Or. cdfilial == ""
			cResponse := "Error"		
			SetRestFault(600, "Parametros Incorretos")
            Return .F.
		Else
			cResponse := WSAPP001(cdempresa, cdfilial)
		EndIf
	
	Else
	
	    cResponse := "Error"		
	    SetRestFault(600, "Parametros Incorretos")
        Return .F.
	
	EndIf
	
	::SetResponse(cResponse)
Return .T.

/*/{Protheus.doc} makeJson
//TODO Metodo para gerar JSON com lista de produtos
@author Thiago Berna
@since 16/06/2020
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
/*/
Static Function makeJson(cAlQry)

	Local cJson 	:= ""
	
	cJson += 	'{"Produtos":['//inicia objeto Json
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"B1_COD":"'+ ALLTRIM((cAlQry)->B1_COD) +'",'
			cJson +=	'"B1_DESC":"'+ ALLTRIM((cAlQry)->B1_DESC) +'"'
			cJson +=	'}'
			
			(cAlQry)->(DbSkip())

			If !(cAlQry)->( Eof() )
				cJson +=	','
			EndIf
	
	End
	cJson +=	']}'//Finaliza objeto Json

Return cJson

/*/{Protheus.doc} WSAPP001
//TODO Função para executar WS GetProdutosApp
@author Thiago Berna
@since 16/06/2020
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSAPP001(cdempresa, cdfilial)
	Local cJson     := ""
	Local cQuery    := ""
	Local cAlQry	:= ""
	
	OpenSM0()
	SM0->(DBSetOrder(1))
	If SM0->(MSSeek(cdempresa+cdfilial))
		// -> Inicia o ambiente
    	RpcClearEnv()        
        RpcSetType(3) 
	    RpcSetEnv(cdempresa,cdfilial,,,'FAT',GetEnvServer())                           
    	OpenSm0(cdempresa,.f.)
	    nModulo:=2
	Else
		cJson := '{"message":"Empresa/Filial não encontrada."}'
		SetRestFault(400, "Bad Request")
		Return cJson
	EndIf

	cQuery := "	SELECT DISTINCT B1_COD, B1_DESC " + CRLF
	cQuery += "	FROM " + RetSqlName("SB1") + CRLF
	cQuery += "	WHERE " + CRLF  
	cQuery += "	D_E_L_E_T_ = ' ' " + CRLF
		
	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)
	
	If !(cAlQry)->(Eof())
		cJson := MakeJson(cAlQry)
	Else	
		SetRestFault(610, "Produtos não encontrados para esta empresa/filial.")
		cJson := "Error"
	EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
