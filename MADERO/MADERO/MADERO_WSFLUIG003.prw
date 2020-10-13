#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetProdutos
//TODO Declaração do WebService GetProdutos consumido pelo FLUIG
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/

WSRESTFUL GetProdutos DESCRIPTION "Madero - Produtos - FLUIG"

	WSMETHOD POST DESCRIPTION "Lista de Produtos para integração FLUIG" WSSYNTAX "/GetProdutos || /GetProdutos/{id}"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetProdutos
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE cdempresa, cdfilial WSSERVICE GetProdutos

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
			If Len(::aURLParms) > 0 //Verifica se o parametro {id} foi passado na URL
				idproduto := ::aURLParms[1]
				cResponse := WSFLUIG003(cdempresa, cdfilial, idproduto)
			Else
				cResponse := WSFLUIG003(cdempresa, cdfilial)
			EndIf
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


/*/{Protheus.doc} makeProdutoJson
//TODO Metodo para gerar JSON com informações do produto
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno do WS
@param cAlQry, caracter, Alias com os dados a enviar
/*/
Static Function makeProdutoJson(cAlQry)

	Local cJson 	:= ""
	
	cJson += 	'{"produto":{' //inicia objeto Json
    cJson += 	'"B1_COD":"'+ ALLTRIM((cAlQry)->B1_COD) +'",'
    cJson += 	'"B1_XLOCAL":"'+ ALLTRIM((cAlQry)->B1_XLOCAL) +'",'
    cJson += 	'"B1_XTIPO":"'+ ALLTRIM((cAlQry)->B1_XTIPO) +'",'
    cJson += 	'"B1_TIPO":"'+ ALLTRIM((cAlQry)->B1_TIPO) +'",'
    cJson += 	'"B1_GRUPO":"'+ ALLTRIM((cAlQry)->B1_GRUPO) +'",'
    cJson += 	'"B1_DESC":"'+ ALLTRIM((cAlQry)->B1_DESC) +'",'
    cJson += 	'"B1_UM":"'+ ALLTRIM((cAlQry)->B1_UM) +'",'
    cJson += 	'"B1_SEGUM":"'+ ALLTRIM((cAlQry)->B1_SEGUM) +'",'
    cJson += 	'"B1_CONV":"'+ ALLTRIM((cAlQry)->B1_CONV) +'",'
    cJson += 	'"B1_TIPCONV":"'+ ALLTRIM((cAlQry)->B1_TIPCONV) +'",'
    cJson += 	'"B1_APROPRI":"'+ ALLTRIM((cAlQry)->B1_APROPRI) +'",'
    cJson += 	'"B1_XCLAS":"'+ ALLTRIM((cAlQry)->B1_XCLAS) +'",'
    cJson += 	'"B1_LOCPAD":"'+ ALLTRIM((cAlQry)->B1_LOCPAD) +'",'
    cJson += 	'"B1_LOCALIZ":"'+ ALLTRIM((cAlQry)->B1_LOCALIZ) +'",'
    cJson += 	'"B1_RASTRO":"'+ ALLTRIM((cAlQry)->B1_RASTRO) +'",'
    cJson += 	'"B1_POSIPI":"'+ ALLTRIM((cAlQry)->B1_POSIPI) +'",'
    cJson += 	'"B1_ORIGEM":"'+ ALLTRIM((cAlQry)->B1_ORIGEM) +'",'
    cJson += 	'"B1_GRUPCOM":"'+ ALLTRIM((cAlQry)->B1_GRUPCOM) +'",'
    cJson += 	'"B1_MCUSTD":"'+ ALLTRIM((cAlQry)->B1_MCUSTD) +'",'
    cJson += 	'"B1_XN1":"'+ ALLTRIM((cAlQry)->B1_XN1) +'",'
    cJson += 	'"B1_XN2":"'+ ALLTRIM((cAlQry)->B1_XN2) +'",'
    cJson += 	'"B1_XN3":"'+ ALLTRIM((cAlQry)->B1_XN3) +'",'
    cJson += 	'"B1_XN4":"'+ ALLTRIM((cAlQry)->B1_XN4) +'",'
    cJson += 	'"B1_IPI":"'+ ALLTRIM((cAlQry)->B1_IPI) +'",'
    cJson += 	'"B1_GRTRIB":"'+ ALLTRIM((cAlQry)->B1_GRTRIB) +'",'
    cJson += 	'"B1_IRRF":"'+ ALLTRIM((cAlQry)->B1_IRRF) +'",'
    cJson += 	'"B1_INSS":"'+ ALLTRIM((cAlQry)->B1_INSS) +'",'
    cJson += 	'"B1_REDPIS":"'+ ALLTRIM((cAlQry)->B1_REDPIS) +'",'
    cJson += 	'"B1_REDCOF":"'+ ALLTRIM((cAlQry)->B1_REDCOF) +'",'
    cJson += 	'"B1_PPIS":"'+ ALLTRIM((cAlQry)->B1_PPIS) +'",'
    cJson += 	'"B1_PCOFINS":"'+ ALLTRIM((cAlQry)->B1_PCOFINS) +'",'
    cJson += 	'"B1_CSLL":"'+ ALLTRIM((cAlQry)->B1_CSLL) +'",'
    cJson += 	'"B1_PCSLL":"'+ ALLTRIM((cAlQry)->B1_PCSLL) +'",'
    cJson += 	'"B1_CEST":"'+ ALLTRIM((cAlQry)->B1_CEST) +'",'
    cJson += 	'"B1_CONTA":"'+ ALLTRIM((cAlQry)->B1_CONTA) +'",'
    cJson += 	'"B1_CTAREC":"'+ ALLTRIM((cAlQry)->B1_CTAREC) +'",'
    cJson += 	'"B1_CTADESP":"'+ ALLTRIM((cAlQry)->B1_CTADESP) +'",'
    cJson += 	'"B1_CTACUST":"'+ ALLTRIM((cAlQry)->B1_CTACUST) +'",'
    cJson += 	'"B1_CTATRAN":"'+ ALLTRIM((cAlQry)->B1_CTATRAN) +'",'
    cJson += 	'"B1_EMIN":"'+ ALLTRIM((cAlQry)->B1_EMIN) +'",'
    //cJson += 	'"B1_XDIAES":"'+ ALLTRIM((cAlQry)->B1_XDIAES) +'",'
    cJson += 	'"B1_ESTSEG":"'+ ALLTRIM((cAlQry)->B1_ESTSEG) +'",'
    cJson += 	'"B1_PE":"'+ ALLTRIM((cAlQry)->B1_PE) +'",'
    cJson += 	'"B1_MRP":"'+ ALLTRIM((cAlQry)->B1_MRP) +'",'
    cJson += 	'"B1_EMAX":"'+ ALLTRIM((cAlQry)->B1_EMAX) +'",'
    cJson += 	'"B1_PRVALID":"'+ ALLTRIM((cAlQry)->B1_PRVALID) +'",'
    cJson += 	'"B1_TIPOCQ":"'+ ALLTRIM((cAlQry)->B1_TIPOCQ) +'",'
    cJson += 	'"B1_NUMCQPR":"'+ ALLTRIM((cAlQry)->B1_NUMCQPR) +'"'
    cJson += 	'}}'//Finaliza objeto Json

Return cJson

/*/{Protheus.doc} makeJson
//TODO Metodo para gerar JSON com lista de produtos
@author Paulo Gabriel F.Silva
@since 09/08/2018
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
			cJson +=	'},'
			
			(cAlQry)->(DbSkip())
	
	End
	cJson +=	'{}]}'//Finaliza objeto Json

Return cJson

/*/{Protheus.doc} WSFLUIG003
//TODO Função para executar WS GetProdutos
@author Paulo Gabriel F. e Silva
@since 09/08/2018
@version 1.0
@return cJson, Caracter, JSON de retorno
/*/
Static Function WSFLUIG003(cdempresa, cdfilial, idproduto)
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
		cJson := '{"message":"Empresa/Filial não encontrada."}'
		SetRestFault(400, "Bad Request")
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
	If !Empty(idproduto) //Se {id} foi passado na URL retorna detalhes do produto requisitado.
	
		cQuery := "	SELECT B1_COD, B1_XLOCAL, B1_XTIPO, B1_TIPO, B1_GRUPO, B1_DESC, B1_UM, B1_SEGUM, B1_CONV, B1_TIPCONV, B1_APROPRI, B1_XCLAS, B1_LOCPAD, B1_LOCALIZ, B1_RASTRO, B1_POSIPI, B1_ORIGEM, B1_GRUPCOM, B1_MCUSTD, B1_XN1, B1_XN2, B1_XN3, B1_XN4, B1_IPI, B1_GRTRIB, B1_IRRF, B1_INSS, B1_REDPIS, B1_REDCOF, B1_PPIS, B1_PCOFINS, B1_CSLL, B1_PCSLL, B1_CEST, B1_CONTA, B1_CTAREC, B1_CTADESP, B1_CTACUST, B1_CTATRAN, B1_EMIN, B1_ESTSEG, B1_PE, B1_MRP, B1_EMAX, B1_PRVALID, B1_TIPOCQ, B1_NUMCQPR " + CRLF
		cQuery += "	FROM " + RetSqlName("SB1") + CRLF
		cQuery += "	WHERE B1_COD = '" + idproduto + "' " + CRLF
		cQuery += "	AND D_E_L_E_T_ = ' '" +CRLF
		
		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)
	
		If (cAlQry)->(Eof())
			cAux := "Nao encontrado grupos de produtos. [BM_GRUPO > 500]"
			lCont := .F.
		EndIf
	
		If lCont
			cJson := makeProdutoJson(cAlQry)
		Else	
			SetRestFault(610, "Produtos não encontrados para esta empresa/filial.")
			cJson := "Error"
		EndIf
	
	Else
		cQuery := "	SELECT B1_COD, B1_DESC " + CRLF
		cQuery += "	FROM " + RetSqlName("SB1") + CRLF
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
			SetRestFault(610, "Produtos não encontrados para esta empresa/filial.")
			cJson := "Error"
		EndIf
	Endif
	
	(cAlQry)->(dbCloseArea())

Return cJson
