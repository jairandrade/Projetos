#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PR00		|	Autor: Luis Paulo							|	Data: 20/05/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo reenvio de email com planilha para supplier					//
//	Concessao de limites																			//
//==================================================================================================//
User Function KP97PR00()
Private cNmArq	:= Alltrim(ZS1->ZS1_NOMARQ)
Private CIDSP	:= ZS1->ZS1_XIDINT
Private cEnviou	:= ZS1->ZS1_ENVEMA
Private lErroE	:= .F.

If cEnviou == 'S'
		If MsgYesNo("Esse arquivo já foi enviado, tem certeza que deseja reenviar o  ID "+CIDSP+" novamente?"," KAPAZI - SUPPLIER CARD")
			U_KP97ECLS(.T.)
			If lErroE
					GrvRetEm(.F.)
					MsgInfo("Aconteceu um erro na autenticacao do e-mail, informe ao TI e tente REENVIAR novamente mais tarde!!","KAPAZI - SUPPLIER CARD")
				Else
					GrvRetEm(.T.)
					MsgInfo("Processo finalizado!!","KAPAZI - SUPPLIER CARD")
			EndIf
		EndIf
	Else
		If MsgYesNo("Tem certeza que deseja reenviar o  ID "+CIDSP+"?"," KAPAZI - SUPPLIER CARD")
			U_KP97ECLS(.T.)
			If lErroE
					GrvRetEm(.F.)
					MsgInfo("Aconteceu um erro na autenticacao do e-mail, informe ao TI e tente REENVIAR novamente mais tarde!!","KAPAZI - SUPPLIER CARD")
				Else
					GrvRetEm(.T.)
					MsgInfo("Processo finalizado!!","KAPAZI - SUPPLIER CARD")
			EndIf
		EndIf
EndIf

Return()

//Grava o retorno do email
Static Function GrvRetEm(lRet)
Local cSql	:= ""

cSql	:= " UPDATE "+ RetSqlName("ZS1") +" "
If lRet
		cSql	+= " SET ZS1_NOMARQ = '"+cNmArq+"', ZS1_ENVEMA = 'S' "
	Else
		cSql	+= " SET ZS1_NOMARQ = '"+cNmArq+"', ZS1_ENVEMA = 'N' "
EndIf
cSql	+= " WHERE ZS1_XIDINT = '"+cIdSP+"' "

Conout(cSql)
If TCSqlExec(cSql) < 0
	Conout("TCSQLError() " + TCSQLError())
Endif

Return()