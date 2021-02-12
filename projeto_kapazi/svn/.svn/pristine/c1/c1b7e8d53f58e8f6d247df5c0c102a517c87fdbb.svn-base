#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PR01		|	Autor: Luis Paulo							|	Data: 20/05/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo reenvio de email com planilha para supplier					//
//																									//
//==================================================================================================//
User Function KP97PR01()
Private cNmArq	:= Alltrim(ZS2->ZS2_NMARQI)
Private CIDSP	:= ZS2->ZS2_XIDINT
Private cEnviou	:= ZS2->ZS2_ENVEMA
Private lErroE	:= .F.

If cEnviou == 'S'
		If MsgYesNo("Esse arquivo de alteração de limites já foi enviado, tem certeza que deseja reenviar o  ID "+CIDSP+" novamente?"," KAPAZI - ALT LIMITES SUPPLIER CARD")
			U_KP97EALS(.T.)
			If lErroE
					GrvRetEm(.F.)
					MsgInfo("Aconteceu um erro na autenticacao do e-mail, informe ao TI e tente REENVIAR novamente mais tarde!!","KAPAZI - ALT LIMITES SUPPLIER CARD")
				Else
					GrvRetEm(.T.)
					MsgInfo("Envio de Alteracao de Limites Finalizado com Sucesso!!","KAPAZI - ALT LIMITES SUPPLIER CARD")
			EndIf
		EndIf
	Else
		If MsgYesNo("Tem certeza que deseja reenviar o  ID "+CIDSP+"?"," KAPAZI - ALT LIMITES SUPPLIER CARD")
			U_KP97EALS(.T.)
			If lErroE
					GrvRetEm(.F.)
					MsgInfo("Aconteceu um erro na autenticacao do e-mail, informe ao TI e tente REENVIAR novamente mais tarde!!","KAPAZI - ALT LIMITES SUPPLIER CARD")
				Else
					GrvRetEm(.T.)
					MsgInfo("Envio de Alteracao de Limites Finalizado com Sucesso!!","KAPAZI - ALT LIMITES SUPPLIER CARD")
			EndIf
		EndIf
EndIf

Return()

//Grava o retorno do email
Static Function GrvRetEm(lRet)
Local cSql	:= ""

cSql	:= " UPDATE "+ RetSqlName("ZS2") +" "
If lRet
		cSql	+= " SET ZS2_NMARQI = '"+cNmArq+"', ZS2_ENVEMA = 'S' "
	Else
		cSql	+= " SET ZS2_NMARQI = '"+cNmArq+"', ZS2_ENVEMA = 'N' "
EndIf
cSql	+= " WHERE ZS2_XIDINT = '"+cIdSP+"' "

Conout(cSql)
If TCSqlExec(cSql) < 0
	Conout("TCSQLError() " + TCSQLError())
Endif

Return()