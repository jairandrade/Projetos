#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetPosIPI
//TODO Declaração do WebService GetPosIPI
@author Mario L. B. Faria
@since 12/07/2018
@version 1.0
/*/

WSRESTFUL GetPosIPI DESCRIPTION "Madero - Posições de IPI - FLUIG"

	WSMETHOD POST DESCRIPTION "Lista de Posições de IPI para integração FLUIG" WSSYNTAX "/GetPosIPI"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetPosIPI
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE cdempresa, cdfilial WSSERVICE GetPosIPI

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
			cResponse := WSFLUIG008(cdempresa, cdfilial)
		EndIf
	
	Else
	
	cResponse := "Error"		
	SetRestFault(600, "Parametros Incorretos")
	
	EndIf
	
	If cResponse == "Error"
		Return .F.
	EndIf
	//cResponse := EncodeUTF8(cResponse)
	::SetResponse(cResponse)
Return .T.

/*/{Protheus.doc} makeJson
//TODO Metodo para gerar JSON com lista de Posições de IPI.
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
/*/
Static Function makeJson(cAlQry)

	Local cJson 	:= ""
	
	cJson += 	'{"posicoes":[' //Inicia objeto Json 
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"YD_TEC":"'+ ALLTRIM((cAlQry)->YD_TEC) +'",'
			cJson +=	'"YD_DESC_P":"'+ ALLTRIM((cAlQry)->YD_DESC_P) +'",'
			cJson +=	'"YD_PER_IPI":'+ cValToChar((cAlQry)->YD_PER_IPI)
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson := SUBSTR(cJson, 1, (LEN(cJson)-1))
	cJson +=	']}' // Finaliza objeto Json

Return cJson

/*/{Protheus.doc} WSFLUIG008
//TODO Função para executar WS GetPosIPI
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG008(cdempresa, cdfilial)
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
	    nModulo:=5 
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
	
		cQuery := "	SELECT YD_TEC, YD_DESC_P, YD_PER_IPI" + CRLF
		cQuery += "	FROM " + RetSqlName("SYD") + CRLF
		cQuery += "	WHERE " + CRLF  
		cQuery += "	D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "	ORDER BY YD_TEC " + CRLF
		
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
			SetRestFault(602, "Posicisões de IPI não encontrados para esta empresa/filial.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
