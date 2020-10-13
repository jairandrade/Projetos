#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetEmpresas
//TODO Declaração do WebService GetEmpresas consumido pelo FLUIG
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetEmpresas DESCRIPTION "Madero - Empresas - FLUIG"

	WSMETHOD GET DESCRIPTION "Lista de Empresas para integração FLUIG" WSSYNTAX "/GetEmpresas"

END WSRESTFUL


/*/{Protheus.doc} GET
//TODO Declaração do Metodo GetEmpresas
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD GET WSRECEIVE NULLPARAM WSSERVICE GetEmpresas

	Local cResponse	:= ""

	::SetContentType("application/json")
	
	cResponse := WSFLUIG001()
	
	If cResponse == "Error"
		Return .F.
	EndIf
	
	::SetResponse(cResponse)
Return .T.


/*/{Protheus.doc} makeJson
//TODO Metodo para gerar JSON do WS GetEmpresas
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
/*/
Static Function makeJson(cAlQry)

	Local cJson 	:= ""
	Local SM0_aux 	:= ""
	Local nPos		:= 0
	
	/*/
	//Disponível apenas para P12 build 131227a a partir da versão 13.2.3.6.
	Table 	:= JsonObject():new()
	Table['GetEmpresas']:= JsonObject():new()
	Table['GetEmpresas']['Empresas']:= {}
	/*/	

	cJson += 	'{"empresas":[' //inicia objeto Json
	
	While !SM0->( Eof() )
		/*/
		Empresa:=JsonObject():new()
		Empresa['M0_CODIGO']:= SM0->M0_CODIGO
		Empresa['M0_NOME']:= SM0->M0_NOME
		/*/
		If SM0->M0_CODIGO != SM0_aux
			/*aAdd(Table['GetEmpresas']['Empresas'],Empresa)*/
			cJson +=	'{'
			cJson +=	'"M0_CODIGO":"'+ SM0->M0_CODIGO +'",'
			cJson +=	'"M0_NOME":"'+ ALLTRIM(SM0->M0_NOME) +'"'
			cJson +=	'},'
		EndIF
		
		SM0_aux := SM0->M0_CODIGO
		nPos++
		SM0->(DbSkip())
	End
	
	cJson +=	'{}]}'//Finaliza objeto Json

Return cJson



/*/{Protheus.doc} WSFLUIG001
//TODO Função para executar WS GetEmpresas
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG001()
	Local cJson 	:= ""
	Local nPos 		:= 1
	Local cQuery	:= ""
	Local lCont		:= .T.

	dbCloseAll()
	OpenSM0(cEmpAnt, .F.)
	DbSelectArea( "SM0" )
	SM0->( DbSetOrder(1) )
	SM0->( DbGoTop() )

	If SM0->( Eof())
		lCont 	:= .F.
	EndIf

	If lCont
	
		cJson := MakeJson()
		
	Else
		SetRestFault(600, "Não foram encontradas empresas no protheus.")
		cJson := "Error"
	EndIf
	
	SM0->(dbCloseArea())

Return cJson
