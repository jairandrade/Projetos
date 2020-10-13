#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetContasContabeis
//TODO Declaração do WebService GetContasContabeis
@author Mario L. B. Faria
@since 12/07/2018
@version 1.0
/*/

WSRESTFUL GetContasContabeis DESCRIPTION "Madero - Consulta de Contas Contábeis - FLUIG"

	WSMETHOD POST DESCRIPTION "Consulta de Contas Contábeis para integração FLUIG" WSSYNTAX "/GetContasContabeis"

END WSRESTFUL

WSMETHOD POST WSRECEIVE cdempresa, cdfilial WSSERVICE GetContasContabeis

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
			cResponse := WSFLUIG014(cdempresa, cdfilial)
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
	
	cJson += 	'{"contascontabeis":[' //Inicia objeto Json
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"CT1_CONTA":"'+ ALLTRIM((cAlQry)->CT1_CONTA) +'",'
			cJson +=	'"CT1_DESC01":"'+ ALLTRIM((cAlQry)->CT1_DESC01) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson +=	'{}]}' //Finaliza objeto Json

Return cJson


Static Function WSFLUIG014(cdempresa, cdfilial)
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
	
		cQuery := "	SELECT CT1_CONTA, CT1_DESC01 " + CRLF
		cQuery += "	FROM " + RetSqlName("CT1") + CRLF
		cQuery += "	WHERE " + CRLF  
		cQuery += "	D_E_L_E_T_ = ' ' " + CRLF 
		cQuery += "	ORDER BY CT1_CONTA " + CRLF
		
		
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
			SetRestFault(602, "Contas contabeis não encontrados para esta empresa/filial.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
