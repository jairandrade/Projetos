#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetFiliais
//TODO Declaração do WebService GetFiliais consumido pelo FLUIG
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetFiliais DESCRIPTION "Madero - Filiais - FLUIG"

	WSMETHOD GET DESCRIPTION "Lista de Filiais para integração FLUIG" WSSYNTAX "/GetFiliais/{id}"

END WSRESTFUL


/*/{Protheus.doc} GET
//TODO Declaração do Metodo GetFiliais
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD GET WSRECEIVE cdempresa WSSERVICE GetFiliais

	Local cResponse	:= ""
	Local cdempresa := ""
	::SetContentType("application/json")
	
	//Verifica se foi passado o {id} na URL
	If Len(::aURLParms) > 0
		cdempresa := ::aURLParms[1]
		
		cResponse := WSFLUIG002(cdempresa)
 
	Else
   		SetRestFault(600, "Parametros incorretos")
		Return .F.
	EndIf
	
	If cResponse == "Error"
		SetRestFault(600, "Parametros incorretos")
		Return .F.
	EndIf
	

	::SetResponse(cResponse)
Return .T.


/*/{Protheus.doc} makeJson
//TODO Metodo para gerar JSON do WS GetFiliais
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
	
	
	/*
	Table 	:= JsonObject():new()
	Table['GetFiliais']:= JsonObject():new()
	Table['GetFiliais']['Filiais']:= {}	
	*/	

	cJson += 	'{"cdempresa":"'+cAlQry+'",'//inicia objeto Json
	cJson +=	'"filiais":['
	
	While !SM0->( Eof() )
	
		/*
		Filial:=JsonObject():new()
		Filial['M0_CODFIL']:= SM0->M0_CODFIL
		Filial['M0_FILIAL']:= SM0->M0_FILIAL
		*/
		
		If SM0->M0_CODIGO == cAlQry
		
			/*aAdd(Table['GetFiliais']['Filiais'],Filial)*/
			
			cJson +=	'{'
			cJson +=	'"M0_CODFIL":"'+ ALLTRIM(SM0->M0_CODFIL) +'",'
			cJson +=	'"M0_FILIAL":"'+ ALLTRIM(SM0->M0_FILIAL) +'"'
			cJson +=	'},'
		
		EndIF
		
		SM0_aux := SM0->M0_CODIGO
		nPos++
		SM0->(DbSkip())
	
	End
	cJson +=	'{}]}'//Finaliza objeto Json

Return cJson

/*/{Protheus.doc} WSFLUIG002
//TODO Função para executar WS GetFiliais
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG002(cdempresa)
	Local cJson 	:= ""
	Local nPos 		:= 1
	Local Filial 	:= ""
	Local Table 	:= ""
	Local SM0_aux 	:= ""
	Local lCont		:= .T.

	dbCloseAll()
	cEmpAnt	:= cdempresa
	OpenSM0(cEmpAnt, .F.)
	DbSelectArea( "SM0" )
	SM0->( DbSetOrder(1) )
	SM0->( DbGoTop() )
	
	If SM0->( Eof())
		lCont 	:= .F.
	EndIf

	If lCont
	
		cJson := MakeJson(cdempresa)
		
	Else
		cJson 	:= "Error"
		SetRestFault(400, "Bad Request")
	EndIf
	
	SM0->(dbCloseArea())

Return cJson
