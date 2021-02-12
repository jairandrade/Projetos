#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE CRLF CHR(13)+CHR(10)
#define DATETIME DTOC(DATE()) + " " + TIME()
#define LINHA    CRLF + REPLICATE("-", 99) + CRLF

USER FUNCTION BETHAENV(cURL,cOper,cSoap,oXML)

LOCAL lRet    := Nil
LOCAL oWsdl   := Nil
LOCAL cMsgRet := ""
local aTmp1 := {}
local aTmp2 := {}
local cSoapPrefix := ""

local cSBMsg := ""

cURL := Alltrim(GetMV("KP_URL",,"http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/"))+cURL


Begin Sequence   

	/*******
	Cria metodo webservice
	***********************/
	oWsdl := TWsdlManager():New()

	
	
	/*******
	Realiza o parse do wsdl para recuperar os metodos //conout(DecodeUTF8(cMsgRet))
	*******************************************************************************/
	lRet := oWsdl:ParseURL(cURL)
	If lRet == .F.
	   cMsgRet := "Erro ParseURL: " + oWsdl:cError
	   cSBMsg += DATETIME + CRLF + DecodeUTF8(cMsgRet) + LINHA
	   Break
	EndIf
	
	/*******
	Realiza autenticação
	*******************************************************************************/
	/*oWsdl:SetAuthentication(cUser,cPWD)
	lRet := oWsdl:GetAuthentication(cUser,cPWD)
	If lRet == .F.
	   cMsgRet := "Erro GetAuthentication: " + oWsdl:cError
	   cSBMsg += DATETIME + CRLF + DecodeUTF8(cMsgRet) + LINHA
	   Break
	EndIf		*/
	
	/*******
	Define a operação
	*********************************/
	lRet := oWsdl:SetOperation(cOper)
	If lRet == .F.
	   cMsgRet := "Erro SetOperation: " + oWsdl:cError
	   cSBMsg += DATETIME + CRLF + DecodeUTF8(cMsgRet) + LINHA

	   Break
	EndIf
	

	/*
	Envia uma mensagem SOAP personalizada ao servidor
	**************************************************/
	
//	oXmlRet := U_BETACALL(	oWsdl,cSoap,	"",	"DOCUMENT","http://www.betha.com.br/e-nota-contribuinte-ws",,,	"http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/recepcionarLoteRps")
//	uRet := U_BETACALL("https://e-gov.betha.com.br/e-nota-contribuinte-test-ws/recepcionarLoteRps",cOper,cSoap)

//	oWsdl:lVerbose := .T.
	
	lRet := oWsdl:SendSoapMsg( cSOAP )
/*	If lRet == .F.
	   cMsgRet := "Erro SendSoapMsg: " + oWsdl:cError + CRLF + "Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode
	   cSBMsg += DATETIME + CRLF + DecodeUTF8(cMsgRet) + LINHA

//	   Break
	EndIf*/
	
	        
	/*
	Recupera o xml de retorno do serviço
	*************************************/
	cMsgRet := DecodeUTF8(oWsdl:GetSoapResponse())
	If !Empty(cMsgRet)
	   cSBMsg += DATETIME + CRLF + "Teste de conexão OK." + LINHA

	EndIf
	

cError:=""
cWarning := ""	
/*		
cResp := oWsdl:GetParsedResponse() 
cRespost := oWsdl:GetSoapResponse() 
oXml := XmlParser( cRespost, "_", @cError, @cWarning ) 
//MsgInfo(cRespost , "Conteudo" ) 	
aSimple := oWsdl:SimpleInput()
aComplex := oWsdl:NextComplex()
*/	

//msginfo(cMsgRet)

cRespost := oWsdl:GetSoapResponse() 
oXml := XmlParser( cRespost, "_", @cError, @cWarning ) 

If Empty(aTmp1 := ClassDataArr(oXML))
	aTmp1 := NIL
	cSBMsg += DATETIME + CRLF + 'WSCERR056 / Invalid XML-Soap Server Response : soap-envelope not found.' + LINHA
Endif

If empty(cEnvSoap := aTmp1[1][1])
	aTmp1 := NIL
	cSBMsg += DATETIME + CRLF + 'WSCERR057 / Invalid XML-Soap Server Response : soap-envelope empty.' + LINHA
Endif

// Limpa a variável temporária
aTmp1 := NIL

// Elimina este node, re-atribuindo o Objeto
oXML := xGetInfo( oXML, cEnvSoap  )

If valtype(oXML) <> 'O'
	cSBMsg += DATETIME + CRLF + 'WSCERR058 / Invalid XML-Soap Server Response : Invalid soap-envelope ['+cEnvSoap+'] object as valtype ['+valtype(oXML)+']' + LINHA
Endif

If Empty(aTmp2 := ClassDataArr(oXML))
	aTmp2 := NIL 
	cSBMsg += DATETIME + CRLF + 'WSCERR059 / Invalid XML-Soap Server Response : soap-body not found.' + LINHA
Endif

If empty(cEnvBody := aTmp2[1][1])
	aTmp2 := NIL 
	cSBMsg += DATETIME + CRLF + 'WSCERR060 / Invalid XML-Soap Server Response : soap-body envelope empty.' + LINHA
Endif

// Limpa a variável temporária
aTmp2 := NIL 

// Elimina este node, re-atribuindo o Objeto
oXML := xGetInfo( oXML, cEnvBody )

If valtype(oXML) <> 'O'
	cSBMsg += DATETIME + CRLF + 'WSCERR061 / Invalid XML-Soap Server Response : Invalid soap-body ['+cEnvBody+'] object as valtype ['+valtype(oXML)+']' + LINHA
Endif

cSoapPrefix := substr(cEnvSoap,1,rat("_",cEnvSoap)-1)

If Empty(cSoapPrefix)
	cSBMsg += DATETIME + CRLF + 'WSCERR062 / Invalid XML-Soap Server Response : Unable to determine Soap Prefix of Envelope ['+cEnvSoap+']' + LINHA
Endif

/*
ESTRUTURA DE SOAP FAULT 1.2

<soap:Fault>
	<faultcode></faultcode>
	<faultstring></faultstring>
	<faultactor></faultactor>
	<detail></detail>
</soap:Fault>
*/

If xGetInfo( oXML ,cSoapPrefix+"_FAULT:TEXT" ) != NIL
	// Se achou um soap_fault....
	
	cFaultString := xGetInfo( oXML ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
	
	If !empty(cFaultString)		
		// OPA, protocolo soap 1.0 ou 1.1	
		cFaultCode := xGetInfo( oXML ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
		cFaultString := xGetInfo( oXML ,cSoapPrefix+"_FAULT:_FAULTSTRING:TEXT" )
	Else 
		// caso contrario, trato como soap 1.2		  
		cFaultCode := xGetInfo( oXML ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )	
		If Empty(cFaultCode)
			cFaultCode := xGetInfo( oXML ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_CODE:TEXT" )
		Else
			cFaultCode += " [FACTOR] " + xGetInfo( oXML ,cSoapPrefix+"_FAULT:_FAULTACTOR:TEXT" )
		EndIf		
		DEFAULT cFaultCode := ""
		cFaultString := xGetInfo( oXML ,cSoapPrefix+"_FAULT:_DETAIL:TEXT" )
		If !Empty(cFaultString)
			cFaultString := xGetInfo( oXML ,cSoapPrefix+"_FAULT:_FAULTSTRING:TEXT" ) + " [DETAIL] " + cFaultString
		Else
			cFaultString :=  xGetInfo( oXML ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_REASON:"+cSoapPrefix+"_TEXT:TEXT" )
			DEFAULT cFaultString := ""
			cFaultString += " [DETAIL] " + xGetInfo( oXML ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_DETAIL:TEXT" )
			DEFAULT cFaultString := ""
		Endif
	Endif
	
	
	// Aborta processamento atual com EXCEPTION
	cSBMsg += DATETIME + CRLF + 'WSCERR048 / SOAP FAULT '+cFaultCode+' ( POST em '+cURL+' ) : ['+cFaultString+']' + LINHA
	Msginfo(cFaultString)
	
Endif

If Empty(aTmp1 := ClassDataArr(oXML))
	aTmp1 := NIL
	cSBMsg += DATETIME + CRLF + 'WSCERR056 / Invalid XML-Soap Server Response : soap-envelope not found.' + LINHA
Endif

If empty(cEnvSoap := aTmp1[1][1])
	aTmp1 := NIL
	cSBMsg += DATETIME + CRLF + 'WSCERR057 / Invalid XML-Soap Server Response : soap-envelope empty.' + LINHA
Endif

// Limpa a variável temporária
aTmp1 := NIL

// Elimina este node, re-atribuindo o Objeto
oXML := xGetInfo( oXML, cEnvSoap  )


If Empty(aTmp2 := ClassDataArr(oXML))
	aTmp2 := NIL 
	cSBMsg += DATETIME + CRLF + 'WSCERR059 / Invalid XML-Soap Server Response : soap-body not found.' + LINHA
Endif

If empty(cEnvBody := aTmp2[1][1])
	aTmp2 := NIL 
	cSBMsg += DATETIME + CRLF + 'WSCERR060 / Invalid XML-Soap Server Response : soap-body envelope empty.' + LINHA
Endif

// Limpa a variável temporária
aTmp2 := NIL 

// Elimina este node, re-atribuindo o Objeto
oXML := xGetInfo( oXML, cEnvBody )

If valtype(oXML) <> 'O'
	cSBMsg += DATETIME + CRLF + 'WSCERR061 / Invalid XML-Soap Server Response : Invalid soap-body ['+cEnvBody+'] object as valtype ['+valtype(oXML)+']' + LINHA
Endif



	
End Sequence

return lRet