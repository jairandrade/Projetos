#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetGrupos
//TODO Declaração do WebService GetProdutos consumido pelo FLUIG
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetGrupos DESCRIPTION "Madero - Grupos - FLUIG"

	WSMETHOD POST DESCRIPTION "Lista de Grupos para integração FLUIG" WSSYNTAX "/GetGrupos"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetGrupos
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE cdempresa, cdfilial WSSERVICE GetGrupos

	Local cResponse	:= ""
	Local idproduto := ""
	Local cBody
	Local oObj
	Local cdempresa := ""
	Local cdfilial := ""
	
	::SetContentType("application/json")
	
	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
	cdempresa := cValtoChar(oObj:cdempresa)
	cdfilial := cValtoChar(oObj:cdfilial) 
	
		If cdempresa == "" .Or. cdfilial == ""
			cResponse := "Error"		
			SetRestFault(600, "Parametros Incorretos")
		Else
			cResponse := WSFLUIG004(cdempresa, cdfilial)
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
//TODO Metodo para gerar JSON com lista de grupos
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
/*/
Static Function makeJson(cAlQry)

	Local cJson 	:= ""
	
	cJson += 	'{"Grupos":[' //Inicia objeto Json
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"BM_GRUPO":"'+ ALLTRIM((cAlQry)->BM_GRUPO) +'",'
			cJson +=	'"BM_DESC":"'+ ALLTRIM((cAlQry)->BM_DESC) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson +=	'{}]}'  //Finaliza objeto Json

Return cJson

/*/{Protheus.doc} WSFLUIG004
//TODO Função para executar WS GetProdutos
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG004(cdempresa, cdfilial)
	Local cJson := ""
	Local nPos := 1
	Local Filial := ""
	Local SM0_aux := ""
	Local lCont := .T.
	Local cQuery := ""
	Local cAlQry	:= ""
	
	
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
	
		cQuery := "	SELECT BM_GRUPO, BM_DESC " + CRLF
		cQuery += "	FROM " + RetSqlName("SBM") + CRLF
		cQuery += "	WHERE " + CRLF  
		cQuery += "	D_E_L_E_T_ = ' ' " + CRLF
		
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
			SetRestFault(602, "Grupos não encontrados para esta empresa/filial.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
