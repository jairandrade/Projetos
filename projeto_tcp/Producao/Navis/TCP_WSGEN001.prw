#Include 'Protheus.ch'
#INCLUDE "fileio.ch"        
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} WSGEN001
Funcao generica para gravar log de integracao

@author Luiz Fernando
@since 12/04/2016
@param ${Processo}, ${Mensagem}
/*/
User Function WSGEN001(cProcesso,cMsg)

LOCAL cTbl := GetNewPar("TCP_TBWSL","ZAA")

DBSelectArea(cTbl)
RecLock(cTbl,.T.)
(cTbl)->ZAA_FILIAL := xFilial(cTbl)
(cTbl)->ZAA_DATA   := Date()
(cTbl)->ZAA_HORA   := Time()
(cTbl)->ZAA_ROTINA := cProcesso
(cTbl)->ZAA_MSG    := cMsg
MSUnLock()

Return

/*/{Protheus.doc} WSGENT01
Funcao generica para montar tela de consulta para os logs.

@author Luiz Fernando
@since 12/04/2016

/*/
User Function WSGENT01

//+----------------------------------------------------------------------------+
//! Declaracao de variaveis...                                                 !
//+----------------------------------------------------------------------------+
LOCAL   cTbl      := GetNewPar("TCP_TBWSL","ZAA")
PRIVATE cCadastro := "Log de Integracao."
PRIVATE aRotina   := {}

//+----------------------------------------------------------------------------+
//! Inclusao de opcoes para navegacao...                                       !
//+----------------------------------------------------------------------------+
AADD( aRotina, {"Pesquisar" ,"AxPesqui" ,0,1})
AADD( aRotina, {"Visualizar" ,'AxVisual',0,2})
DBSelectArea(cTbl)
//+----------------------------------------------------------------------------+
//! Monta a interface.                                                         !
//+----------------------------------------------------------------------------+
MBrowse(006,001,022,075,cTbl)

Return

/*/{Protheus.doc} WGENFIN1
Função para integração com sistema Navis, enviando informações sobre titulos.
Status
Aberto = 1,Baixado = 2,BaixadoParcialmente = 3,Protestado = 4
@type function
@author luizf
@since 20/06/2016
/*/

User Function WGENFIN1(cNumTit,cStatus,nSaldo,cRotina)

//http://vdev-win-dev:9004/N4FATUR-747/api/StatusPagamentoTitulo?CodigoTituloProtheus=322&IdStatusPagamento=2&SaldoTitulo=123
LOCAL cEndUrl  := GetNewPar("CP_URLINT","http://vdev-win-dev:9004/N4FATUR-747/api/")
LOCAL cJSonRet
LOCAL lRetorno := .T.
LOCAL oObjRet
LOCAL cUrl     := AllTrim(cEndUrl)+"AtualizarStatusPagamentoTitulo?CodigoTituloProtheus="+Escape(Alltrim(cNumTit))
cUrl+=  "&IdStatusPagamento="+Escape(cStatus)
cUrl+= "&SaldoTitulo="+Escape(cValToChar(nSaldo))

//cJSonRet := Httpsget(cEndUrl,"\certs\tcpcert.pem","\certs\tcpkey.pem","123456@a","AtualizarStatusPagamentoTitulo?CodigoTituloProtheus="+Escape(Alltrim(cNumTit))+"&IdStatusPagamento="+Escape(cStatus)+"&SaldoTitulo="+Escape(cValToChar(nSaldo)))
cJSonRet := Httpget(cUrl)
If FWJsonDeserialize(cJSonRet,@oObjRet)//Estrutura de retorno esperado: "{"Mensagens":[{"Codigo":"001","Mensagem":"TÃ­tulo nÃ£o encontrado"}],"Status":2,"Objeto":null}
	If ValType(oObjRet) == "O"
		If xGetInfo( oObjRet ,"STATUS" ) != NIL .and. ValType(oObjRet:STATUS) == "N"//1= Sucesso; 2=Erro
			If oObjRet:STATUS == 1
				cJSonRet+= " SUCESSO : "
			Else
				cJSonRet+= " ERRO : "
				lRetorno:= .F.
			EndIf
		Else
			cJSonRet+= " - (WGENFIN1) Retorno JSON não esperado. Método invalido: oObjRet:STATUS"
			lRetorno:= .F.
		EndIf
	EndIf
Else
	If valtype(cJSonRet) != "C"
		cJSonRet := ""
	EndIf
	cJSonRet+= " - (WGENFIN1) Retorno JSON não esperado. "
	lRetorno:= .F.
	
Endif
U_WSGEN001(cRotina,cJSonRet+" - URL: "+cUrl)

Return lRetorno

Static Function ConStatus(_cNumTit,_cNfPref,_cProtocolo,_cStatus,_nSaldo,_cRotina)
//ConStatus(cNFPref,cProtocolo,cStatus,cMSGPref,cRotina)
Local _lOk := .T.
local cQuery := ""  	

cQuery := " SELECT MAX(ZAC_DATA),MAX(ZAC_HORA),ZAC_STATUS "
cQuery += " FROM "+RetSqlName('ZAC')+" ZAC "
cQuery += "	WHERE ZAC_NUMNF = '"+_cNumTit+"'"
cQuery += " AND ZAC_OK = '1' "                                                          	
cQuery += " AND ZAC_STATUS = '"+_cStatus+"'  "
cQuery += " AND D_E_L_E_T_ != '*' "
cQuery += " GROUP BY ZAC_STATUS "

TCQUERY cQuery NEW ALIAS "QZAC"
DbSelectArea("QZAC")
QZAC->(DbGoTop())

IF QZAC->(EOF())
	//Se fim de arquivo, significa que o titulo nunca foi integrado com o status atual, e continua integração.  
	QZAC->(DBCLOSEAREA())
	Return .T.
	
Else
	//Caso traga resultados na tabela, significa que o titulo ja foi integrado com sucesso.
	_lOk := .F.
EndIf
              
QZAC->(DBCLOSEAREA())
Return _lOk
/*
User Function WGENFIN1(cNumTit,cStatus,nSaldo,cRotina)

//http://vdev-win-dev:9004/N4FATUR-747/api/StatusPagamentoTitulo?CodigoTituloProtheus=322&IdStatusPagamento=2&SaldoTitulo=123
LOCAL cEndUrl  := GetNewPar("CP_URLINT","http://vdev-win-dev:9004/N4FATUR-747/api/")
//LOCAL cUrl     	:= AllTrim(cEndUrl)+"AtualizarStatusPagamentoTitulo?CodigoTituloProtheus="+Escape(Alltrim(cNumTit))
LOCAL cUrl     	:= AllTrim(cEndUrl)+"StatusPagamentoTitulo"
LOCAL cJSonRet := ""
LOCAL lRetorno := .T.
LOCAL oObjRet
Local nTimeOut := 120
Local aHeadOut := {}
Local cHeadRet := ""
Local sPostRet := ""
Local _cSend := ""
//	U_WGENFIN1("996458132","2",0,"FINA070")


//cUrl+=  "&IdStatusPagamento="+Escape(cStatus)
//cUrl+= "&SaldoTitulo="+Escape(cValToChar(nSaldo))


aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
aadd(aHeadOut,'Content-Type: application/x-www-form-urlencoded; charset=utf-8')

_cSend := "CodigoTituloProtheus="+Escape(Alltrim(cNumTit))
_cSend+=  "&IdStatusPagamento="+Escape(cStatus)
_cSend+= "&SaldoTitulo="+Escape(cValToChar(nSaldo))

sPostRet := HttpPost(cUrl,"",_cSend,nTimeOut,aHeadOut,@cHeadRet)

If At('"Status":1',sPostRet) > 0
cJSonRet+= " SUCESSO : "
lRetorno:= .T.
Else
cJSonRet+= " ERRO : "
lRetorno:= .F.
EndIf


//cJSonRet := Httpget(cUrl)
//If FWJsonDeserialize(cJSonRet,@oObjRet)//Estrutura de retorno esperado: "{"Mensagens":[{"Codigo":"001","Mensagem":"TÃ­tulo nÃ£o encontrado"}],"Status":2,"Objeto":null}
//	If ValType(oObjRet) == "O"
//	    If xGetInfo( oObjRet ,"STATUS" ) != NIL .and. ValType(oObjRet:STATUS) == "N"//1= Sucesso; 2=Erro
//			If oObjRet:STATUS == 1
//			 	cJSonRet+= " SUCESSO : "
//			Else
//				cJSonRet+= " ERRO : "
//				lRetorno:= .F.
//			EndIf
//		Else
//			cJSonRet+= " - (WGENFIN1) Retorno JSON não esperado. Método invalido: oObjRet:STATUS"
//			lRetorno:= .F.
//	    EndIf
//	EndIf
//Else
//	  If valtype(cJSonRet) != "C"
//	   cJSonRet := ""
//	  EndIf
//	cJSonRet+= " - (WGENFIN1) Retorno JSON não esperado. "
//	lRetorno:= .F.
//Endif

U_WSGEN001(cRotina,cJSonRet+" - URL: "+cUrl)

Return lRetorno
*/


/*/{Protheus.doc} WGENFAT1
Função para integração com sistema Navis, enviando informações sobre Status da NF.
Status
AguardandoTransmissao = 1,
AguardandoRetorno = 2,
Autorizada = 3,
Rejeitada = 4,
Cancelada = 5,
@type function
@author luizf
@since 22/06/2016
/*/
/*
User Function WGENFAT1(cNumDoc,cNFPref,cProtocolo,cMSGPref,cStatus,cRotina)

//http://vdev-win-dev:9004/N4FATUR-470/api/StatusGerarNotaFiscal?numeroNotaFiscal={0}&numeroNotaFiscalPrefeitura={1}&numeroProtocolo={2}&mensagemRetorno={3}&idStatusFatura={4}
//http://vdev-win-dev:9004/N4FATUR-747/api/StatusGerarNotaFiscal?idfatura=1&numerofaturaPrefeitura=1&numeroProtocolo=1&mensagemRetorno=bla&idStatusfatura=1
LOCAL cEndUrl  := GetNewPar("CP_URLINT","http://vdev-win-dev:9004/N4FATUR-747/api/")
LOCAL cJSonRet
LOCAL lRetorno := .T.
LOCAL oObjRet
LOCAL cUrl     := AllTrim(cEndUrl)+"StatusGerarNotaFiscal?"
cUrl+="idfatura="+Escape(cNumDoc)
cUrl+="&numerofaturaPrefeitura="+Escape(cNFPref)
cUrl+="&numeroProtocolo="+Escape(cProtocolo)
cUrl+="&mensagemRetorno="+Escape(NoAcento(StrTran(cMSGPref,"ç","c")))
cUrl+="&idStatusfatura="+Escape(cStatus)

cJSonRet := Httpget(cUrl)
If FWJsonDeserialize(cJSonRet,@oObjRet)//Estrutura de retorno esperado: "{"Mensagens":[{"Codigo":"001","Mensagem":"TÃ­tulo nÃ£o encontrado"}],"Status":2,"Objeto":null}
If ValType(oObjRet) == "O"
If xGetInfo( oObjRet ,"STATUS" ) != NIL .and. ValType(oObjRet:STATUS) == "N"//1= Sucesso; 2=Erro
If oObjRet:STATUS == 1
cJSonRet+= " SUCESSO : "
Else
cJSonRet+= " ERRO : "
lRetorno:= .F.
EndIf
Else
If xGetInfo( oObjRet ,"MESSAGE" ) != NIL
cJSonRet+= " - (WGENFAT1) ERRO de integracao: "+oObjRet:MESSAGE
Else
cJSonRet+= " - (WGENFAT1) Retorno JSON não esperado. Método invalido: oObjRet:STATUS"
EndIf

lRetorno:= .F.
EndIf
EndIf
Else
If valtype(cJSonRet) != "C"
cJSonRet := ""
EndIf
cJSonRet+= " - (WGENFAT1) Retorno JSON não esperado. "
lRetorno:= .F.
Endif

//U_WSGEN001(cRotina,cJSonRet+" - URL: "+cUrl)
fGrvLog(cRotina+" - "+cJSonRet+" - URL: "+cUrl)//Grava Log em TXT

Return lRetorno
*/

User Function WGENFAT1(cNumDoc,cNFPref,cProtocolo,cMSGPref,cStatus,cRotina,cXMLNFSe,cNumNFSE,cSerieNFSe,cDtNFSe,cHoraNFSe)

//http://vdev-win-dev:9004/N4FATUR-470/api/StatusGerarNotaFiscal?numeroNotaFiscal={0}&numeroNotaFiscalPrefeitura={1}&numeroProtocolo={2}&mensagemRetorno={3}&idStatusFatura={4}
//http://vdev-win-dev:9004/N4FATUR-747/api/StatusGerarNotaFiscal?idfatura=1&numerofaturaPrefeitura=1&numeroProtocolo=1&mensagemRetorno=bla&idStatusfatura=1
LOCAL cEndUrl  := GetNewPar("CP_URLINT","http://vdev-win-dev:9004/N4FATUR-747/api/")
LOCAL cJSonRet := ""
LOCAL lRetorno := .T.
LOCAL cUrl     := AllTrim(cEndUrl)+"StatusGerarNotaFiscal"
Local nTimeOut := 120
Local aHeadOut := {}
Local cHeadRet := ""
Local sPostRet := ""
Local _cSend   := ""
Local nPosHRet := 0
Local lZAC     := .T.
//cUrl+="idfatura="+Escape(cNumDoc)
//cUrl+="&numerofaturaPrefeitura="+Escape(cNFPref)
//cUrl+="&numeroProtocolo="+Escape(cProtocolo)
//cUrl+="&mensagemRetorno="+Escape(NoAcento(StrTran(cMSGPref,"ç","c")))
//cUrl+="&idStatusfatura="+Escape(cStatus)

ZAC->(DBSETORDER(1))
lZac := ConStatus(cNumDoc,cNFPref,cProtocolo,cStatus,cMSGPref,cRotina)

if lZAC
	
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aadd(aHeadOut,'Content-Type: application/x-www-form-urlencoded; charset=utf-8')
	
	_cSend:="Idfatura="+Escape(cNumDoc)
	_cSend+="&NumerofaturaPrefeitura="+Escape(cNFPref)
	_cSend+="&NumeroProtocolo="+Escape(cProtocolo)
	_cSend+="&MensagemRetorno="+Escape(NoAcento(StrTran(cMSGPref,"ç","c")))
	_cSend+="&IdStatusfatura="+Escape(cStatus)
	If cStatus == "3"
		//Willian Kaneta - Adicionado para envio XML
		_cSend+="&XmlSerializado="+Escape(NoAcento(StrTran(cXMLNFSe,"ç","c")))
		_cSend+="&NumeroNfse="+Escape(cNumNFSE)
		_cSend+="&SerieNfse="+Escape(cSerieNFSe)
		_cSend+="&DataNfse="+Escape(cDtNFSe)
		_cSend+="&HoraNfse="+Escape(cHoraNFSe)
	EndIf
	sPostRet := HttpPost(cUrl,"",_cSend,nTimeOut,aHeadOut,@cHeadRet)
	nPosHRet := At(Chr(13)+Chr(10),cHeadRet)

	If At('"Status":1',sPostRet) > 0
		
		cJSonRet+= " SUCESSO : "
		lRetorno:= .T.

		Reclock("ZAC",.T.)
		ZAC->ZAC_STATUS := cStatus
		ZAC->ZAC_OK		:= "1"
		ZAC->ZAC_DATA 	:= DATE()
		ZAC->ZAC_HORA 	:= TIME()
		ZAC->ZAC_ROTINA := cRotina
		ZAC->ZAC_NUMNF 	:= cNumDoc
		ZAC->ZAC_OBS  	:= "NF INTEGRADA COM SUCESSO - PROTOCOLO '"+cProtocolo+"' num NF  '"+cNfPref+"' "
		ZAC->ZAC_JSONSE := _cSend
		ZAC->ZAC_RETINT	:= sPostRet
		ZAC->ZAC_URL	:= cUrl
		If nPosHRet != 0
			ZAC->ZAC_HEADRT := SUBSTR(cHeadRet,1,nPosHRet)
		EndIf
		Msunlock()
	Else
		cJSonRet+= " ERRO : "
		lRetorno:= .F.
		Reclock("ZAC",.T.)
		ZAC->ZAC_STATUS := cStatus
		ZAC->ZAC_OK		:= "2"
		ZAC->ZAC_DATA 	:= date()
		ZAC->ZAC_HORA 	:= TIME()
		ZAC->ZAC_ROTINA := cRotina
		ZAC->ZAC_NUMNF 	:= cNumDoc
		ZAC->ZAC_OBS  	:= "FALHA NA INTEGRACAO DA NF '"+cProtocolo+"' "
		ZAC->ZAC_JSONSE := _cSend
		ZAC->ZAC_RETINT	:= sPostRet
		ZAC->ZAC_URL	:= cUrl
		If nPosHRet != 0
			ZAC->ZAC_HEADRT := SUBSTR(cHeadRet,1,nPosHRet)
		EndIf
		Msunlock()
	EndIf
	
else
	Reclock("ZAC",.T.)
	ZAC->ZAC_STATUS := cStatus
	ZAC->ZAC_OK	:= "2"
	ZAC->ZAC_DATA := date()
	ZAC->ZAC_HORA := TIME()
	ZAC->ZAC_ROTINA := cRotina
	ZAC->ZAC_NUMNF := cNumDoc
	ZAC->ZAC_OBS  := "NF JA INTEGRADA E SEM MUDANCA DE STATUS - PROTOCOLO '"+cProtocolo+"' "
	Msunlock()
EndIf

ZAC->(DBCLOSEAREA())
Return lRetorno
