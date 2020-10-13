#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetUnMed
//TODO Declaração do WebService GetUnMed
//Consumido pelo FLUIG retornando uma lista
//de unidades de medida cadastrada no Protheus.
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetUnMed DESCRIPTION "Madero - Unidades de medida - FLUIG"

	WSMETHOD POST DESCRIPTION "Lista de Unidades de medida para integração FLUIG" WSSYNTAX "/GetUnMed"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetUnMed
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE cdempresa, cdfilial WSSERVICE GetUnMed

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
			cResponse := WSFLUIG005(cdempresa, cdfilial)
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
//TODO Metodo para gerar JSON com lista de Unidades de medida.
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
			cJson +=	'"AH_UNIMED":"'+ ALLTRIM((cAlQry)->AH_UNIMED) +'",'
			cJson +=	'"AH_UMRES":"'+ ALLTRIM((cAlQry)->AH_UMRES) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson +=	'{}]}'  //Finaliza objeto Json

Return cJson


/*/{Protheus.doc} WSFLUIG005
//TODO Função para executar WS GetProdutos
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG005(cdempresa, cdfilial)
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
	
		cQuery := "	SELECT AH_UNIMED, AH_UMRES " + CRLF
		cQuery += "	FROM " + RetSqlName("SAH") + CRLF
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
			SetRestFault(602, "Unidades de medida não encontrados para esta empresa/filial.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
