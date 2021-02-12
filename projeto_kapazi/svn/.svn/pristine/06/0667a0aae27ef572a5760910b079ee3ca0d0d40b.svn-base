#include 'protheus.ch'
#include 'parmtype.ch'
#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
#define CRLF CHR(13)+CHR(10)
//==================================================================================================//
//	Programa: KP97EALS		|	Autor: Luis Paulo							|	Data: 29/07/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo envio de email com planilha para supplier					//
//																									//
//==================================================================================================//
User Function KP97EALS(lReenv)
//Controles

Private cServer 		:= GETMV("KP_SMTP2")
//Private cServer 		:= GETMV("MV_WFSMTP") Alterado o parametro para utilizar o SMTP normal e nao utilizar o sender.

Private cAccount 		:= GETMV("KP_WFSPACC")
Private cPassword		:= GETMV("KP_WFPASSP")
Private cFrom			:= GETMV("KP_SPCFROM")
Private cDest			:= GETMV("KP_MAILSUP")//GETMV("KP_MAILSAL")
Private lAuth  			:= .F.
Private lErro  			:= .T.
Private cError 			:= ""

//Corpo
Private cAviso
Private cItens
Private cCRLF			:= CRLF
Private cMsgMail		:= ""
Private cMail
Private ATTACHMENT		:= {}
Private cAssunto 		:= "Planilha Supplier - Alteracao de Limites"

If lReenv //Se reenvio
		Private cAnexoKP		:= "\Supplier\AlteracaoLimites\Enviados\"+cNmArq
	Else
		Private cAnexoKP		:= "\Supplier\AlteracaoLimites\"+cNmArq
EndIf

CONNECT SMTP SERVER cServer	ACCOUNT cAccount PASSWORD cPassword Result lErro //conecta no servidor de e-mail

If !lErro
	GET MAIL ERROR _cErro
	Alert('erro1'+_cErro)
	lErroE		:= .T.
EndIf

lErro	:= MailAuth(cAccount,cPassword)	//Autentica no servidor de e-mail

If !lErro
	GET MAIL ERROR _cErro
	Alert('erro2'+_cErro)
	lErroE		:= .T.
EndIf

MontaHtm() //Construção do HTML

//SEND MAIL FROM 	cAccount TO cDest CC cCopia SUBJECT cAssunto BODY cMsgMail RESULT lErro //BCC cCo
SEND MAIL FROM 	cAccount TO cDest SUBJECT cAssunto BODY cMsgMail Attachment cAnexoKP RESULT lErro //BCC cCo

If !lErro
	GET MAIL ERROR _cErro
	Alert('erro3'+_cErro)
	lErroE		:= .T.
EndIf

DISCONNECT SMTP SERVER

Return()


Static Function MontaHtm()
Local cCRLF		:= CRLF

cAviso  := ""
cItens  := ""
cItens	+= CRLF

//Aviso rodapé e-mail
cAviso += "<PRE>
cAviso += "----------------------------------------------------------------------------------"+ CRLF
cAviso += " Este e-mail foi gerado pelo ERP Protheus.                                        "+ CRLF
cAviso += "----------------------------------------------------------------------------------"
cAviso += "</PRE>"+ CRLF

cMsgMail += "<PRE>
cMsgMail += "Planilha Supplier - Alteracao de Limites"+ CRLF
cMsgMail += CRLF
cMsgMail += "Data.........: "+ DTOC(Date()) + CRLF
cMsgMail += "Hora.........: "+ Time() + CRLF
cMsgMail += "Id Kapazi....: "+cIdSP+  CRLF
cMsgMail += CRLF
cMsgMail += cItens
cMsgMail += "</PRE>" + CRLF
cMsgMail += cAviso

Return()
