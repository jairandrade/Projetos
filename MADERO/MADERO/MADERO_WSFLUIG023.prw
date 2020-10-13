#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetTabelaPrecos
//TODO Declaração do WebService GetTabelaPrecos
@author Jair Matos de Andrade
@since 16/08/2019
@version 1.0
/*/

WSRESTFUL GetTabelaPrecos DESCRIPTION "Madero - Consulta de Tabelas de Preços - FLUIG"

	WSMETHOD POST DESCRIPTION "Consulta de Tabelas de Preços para integração FLUIG" WSSYNTAX "/GetTabelaPrecos"

END WSRESTFUL

WSMETHOD POST WSRECEIVE cdempresa, cdfilial WSSERVICE GetTabelaPrecos

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
			cResponse := WSFLUIG020(cdempresa, cdfilial)
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



Static Function makeJson(cAlQry)

	Local cJson 	:= ""
	
	cJson += 	'{"tabelasprecos":[' //Inicia objeto Json
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"DA0_CODTAB":"'+ ALLTRIM((cAlQry)->DA0_CODTAB) +'",'
			cJson +=	'"DA0_DESCRI":"'+ ALLTRIM((cAlQry)->DA0_DESCRI) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson +=	'{}]}' //Finaliza objeto Json

Return cJson


Static Function WSFLUIG020(cdempresa, cdfilial)
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
	
		cQuery := "	SELECT DA0_CODTAB, DA0_DESCRI " + CRLF
		cQuery += "	FROM " + RetSqlName("DA0") + CRLF
		cQuery += "	WHERE " + CRLF  
		cQuery += "	D_E_L_E_T_ = ' ' " + CRLF 
		cQuery += "	ORDER BY DA0_CODTAB " + CRLF
		
		
		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)
	
		If (cAlQry)->(Eof())
			cAux := "Nao encontrado tabela de precos."
			lCont := .F.
		EndIf
	
		If lCont
			cJson := MakeJson(cAlQry)
		Else	
			cJson := "Error"
			SetRestFault(602, "Tabelas de Precos não encontrados para esta empresa/filial.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
