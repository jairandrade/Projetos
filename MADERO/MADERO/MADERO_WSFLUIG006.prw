#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetSx5Info
//TODO Declaração do WebService GetSx5Info
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetSx5Info DESCRIPTION "Madero - Retorna informações de tabelas gravadas na SX5 - FLUIG"

	WSMETHOD POST DESCRIPTION "Retorna informações de tabelas gravadas na SX5 para integração FLUIG" WSSYNTAX "/GetSx5Info"

END WSRESTFUL

/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetSx5Info
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE cdempresa, cdfilial, cdtabela WSSERVICE GetSx5Info

	Local cResponse	:= ""
	Local idproduto := ""
	Local cBody
	Local oObj
	Local cdempresa := ""
	Local cdfilial := ""
	Local cdtabela := ""
	
	::SetContentType("application/json")
	
	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
	cdempresa := cValtoChar(oObj:cdempresa)
	cdfilial := cValtoChar(oObj:cdfilial) 
	cdtabela := cValtoChar(oObj:cdtabela) 
	
		If cdempresa == "" .Or. cdfilial == "" .Or. cdtabela == ""
			cResponse := "Error"		
			SetRestFault(600, "Parametros Incorretos")
		Else
			cResponse := WSFLUIG006(cdempresa, cdfilial, cdtabela)
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
//TODO Metodo para gerar JSON com lista de informações da tabela sx5.
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
/*/
Static Function makeJson(cAlQry)

	Local cJson 	:= ""
	
	cJson += 	'{"SX5info":[' // Inicia Objeto Json
	
	While !(cAlQry)->( Eof() )
	
			cJson +=	'{'
			cJson +=	'"X5_CHAVE":"'+ ALLTRIM((cAlQry)->X5_CHAVE) +'",'
			cJson +=	'"X5_DESCRI":"'+ ALLTRIM((cAlQry)->X5_DESCRI) +'"'
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson +=	'{}]}' //Finaliza objeto Json

Return cJson


/*/{Protheus.doc} WSFLUIG006
//TODO Função para executar WS GetSx5Info
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG006(cdempresa, cdfilial, cdtabela)
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
	
		cQuery := "	SELECT X5_CHAVE, X5_DESCRI " + CRLF
		cQuery += "	FROM " + RetSqlName("SX5") + CRLF
		cQuery += "	WHERE X5_TABELA = '"+ cdtabela +"'" + CRLF  
		cQuery += "	AND D_E_L_E_T_ = ' ' " + CRLF
		
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
			SetRestFault(602, "Erro na execução da query com os parametros informados.")
		EndIf
	
	(cAlQry)->(dbCloseArea())

Return cJson
