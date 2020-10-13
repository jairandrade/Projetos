#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetGrupoCompras
//TODO Declaração do WebService GetGrupoCompras
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetGrupoCompras DESCRIPTION "Madero - Consulta grupos de compras - FLUIG"

	WSMETHOD POST DESCRIPTION "Consulta grupos de compras para integração FLUIG" WSSYNTAX "/GetGrupoCompras"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetGrupoCompras
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE cdempresa, cdfilial WSSERVICE GetGrupoCompras

	Local cResponse	:= ""
	Local idproduto := ""
	Local cBody
	Local oObj
	Local cdempresa := ""
	Local cdfilial := ""
	Local cELK 	:= ALLTRIM(SuperGetMV('ELK_EMP',,''))
	Local cELKCord 	:= ALLTRIM(SuperGetMV('ELK_COORD',,'-25.3941083,-49.1659181'))
	Local cErrMsg 	:= ""
	Local cErrCod 	:= 200
	
	::SetContentType("application/json")

	If !Empty(cELK)
		aZLH := {cELK,self:DESCRIPTION_SYNTAX_POST,self:CCALLMETHOD,cELKCord} //Emp, EndPoint, Method, Coord
    	CRec := U_saveELK(.T.,aZLH)
	EndIf
	
	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
		cdempresa := cValtoChar(oObj:cdempresa)
		cdfilial := cValtoChar(oObj:cdfilial) 
		
		If cdempresa == "" .Or. cdfilial == ""
			cResponse := "Error"	
			cErrCod := 600
			cErrMsg := 	"Parametros Incorretos"
		Else
			cResponse := WSFLUIG009(cdempresa, cdfilial)
		EndIf
	
	Else
	
		cResponse := "Error"		
		cErrCod := 600
		ErrMsg := 	"Parametros Incorretos"
	
	EndIf

	If !Empty(cELK)
		aZLH := {IIF(cResponse == "Error", "True", "False"),cValToChar(cErrMsg),cValToChar(cErrCod)}
    	U_saveELK(.F.,aZLH,CRec)
	EndIf

	If cResponse == "Error"
		SetRestFault(cErrCod, cErrMsg)
		Return .F.
	EndIf
	cResponse := EncodeUTF8(cResponse)
	::SetResponse(cResponse)
Return .T.

/*/{Protheus.doc} makeJson
//TODO Metodo para gerar JSON com lista de grupos de compra.
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
/*/
Static Function makeJson(cAlQry)

	Local cJson 	:= ""
	
	cJson += 	'{"grupos":[' //Inicia objeto Json
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"AJ_GRCOM":"'+ ALLTRIM((cAlQry)->AJ_GRCOM) +'",'
			cJson +=	'"AJ_DESC":"'+ ALLTRIM((cAlQry)->AJ_DESC) +'",'
			cJson +=	'"AJ_US2NAME":"'+ ALLTRIM((cAlQry)->AJ_US2NAME) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End	
	cJson := SUBSTR(cJson, 1, (LEN(cJson)-1))		
	cJson +=	']}' //Finaliza objeto Json.

Return cJson

/*/{Protheus.doc} WSFLUIG009
//TODO Função para executar WS GetGrupoCompras
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG009(cdempresa, cdfilial)
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
	
		cQuery := "	SELECT AJ_GRCOM, AJ_US2NAME, AJ_DESC " + CRLF
		cQuery += "	FROM " + RetSqlName("SAJ") + CRLF
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
			SetRestFault(602, "Posicisões de IPI não encontrados para esta empresa/filial.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
