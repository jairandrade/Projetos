#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: KP97A01		|	Autor: Luis Paulo							|	Data: 20/05/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por integrar CLIENTE SEM MOVIMENTO para integracao da supplier	//
//																									//
//==================================================================================================//
User Function KP97A01()
Local 		aParamBox 	:= {}
Local		lConti		:= .T.
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private 	cCRLF		:= CRLF
Private 	cAlias
Private 	_cPerg1
Private 	_cPerg2
Private 	nRegs		:= 0
Private		nCount		:= 0
	
aAdd(aParamBox,	{ 1,"Cliente"			,Space(6)		,"","","SA1","",0,.F.})
aAdd(aParamBox,	{ 1,"Loja"				,Space(2)		,"","","","",0,.F.})//Número do Instrumento de Transferência
While lConti
	If ParamBox(aParamBox,"CLIENTES SEM MOVIMENTOS", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas
			If lValCLI() //Valida se foi marcada mais de uma apuracao
				
				If ValZSSP()
						GravaCli()
					Else
						If MsgYesNo("Cliente já integrado anteriormente, tem certeza que deseja importar novamente???","KAPAZI - SUPPLIER CARD")
							GravaCli()
						EndIf
				EndIf
			EndIf
			cAliasA1->(DbCloseArea())
		Else
			lConti := .F.
	Endif
EndDo
oMark:ReFresh()
	
Return()


//Valida se realmente o cliente nao possui movimentos
Static Function lValCLI()
Local cQr		:= ""
Local cAliasA1
Local nRegs		:= 0
Local lRet		:= .T.

If Select("cAliasA1")<>0
	DbSelectArea("cAliasA1")
	DbCloseArea()
Endif

_cPerg1	:= MV_PAR01
_cPerg2	:= MV_PAR02

cQr += " SELECT SA1.A1_COD,ISNULL(SE1.E1_NUM,'') AS TITULO,SA1.A1_PESSOA,SA1.A1_NOME,SA1.A1_CGC,SA1.A1_DTNASC,'N' TPSOL,SA1.A1_END,SA1.A1_NR_END,SA1.A1_COMPLEM,SA1.A1_BAIRRO,SA1.A1_CEP,SA1.A1_CODMUN,SA1.A1_MUN, "+cCRLF
cQr += "		SA1.A1_EST,SA1.A1_CONTATO,SA1.A1_DDD,SA1.A1_TEL,SA1.A1_EMAIL,'' XDDDCEL,'' XCEL,SA1.A1_DTCAD, '0000' TPCLI, 0  LIM_ATU, 'S' HIST_CP "+cCRLF
cQr += " FROM "+ RetSqlName("SA1") +" SA1 "+cCRLF
cQr += " LEFT JOIN "+ RetSqlName("SE1") +" SE1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA AND SE1.E1_TIPO <> 'RA' AND SE1.D_E_L_E_T_ = '' AND SE1.E1_EMISSAO >= '"+ DTOS( ( DATE() - 365) ) +"' "+cCRLF
cQr += " WHERE SA1.D_E_L_E_T_ = '' "+cCRLF
cQr += "	AND SA1.A1_COD = '"+_cPerg1+"' "+cCRLF
cQr += "	AND SA1.A1_LOJA = '"+_cPerg2+"'"+cCRLF

Conout(cQr)

// abre a query
TcQuery cQr new alias "cAliasA1"
Count To nRegs

cAliasA1->(DbGoTop())

If nRegs == 0
		lRet		:= .F.
		MsgAlert("Cliente nao existe na base, favor verificar!!!","KAPAZI - INTEGRACAO SUPPLIER")
	
	ElseIf nRegs >= 1 .And. !Empty(cAliasA1->TITULO)
		lRet		:= .F.
		MsgAlert("Cliente possui titulos na base, favor verificar!!!","KAPAZI - INTEGRACAO SUPPLIER")
EndIf

Return(lRet)

//Grava o movimento de cliente sem movimentos
Static Function GravaCli()
Local cItem	:= ""
	
	cItem	:= GETSXENUM("ZS1","ZS1_ITEM")
	ConfirmSx8()
	
	DbSelectArea("ZS1")
	RecLock("ZS1",.T.)
	ZS1->ZS1_FILIAL	:= ''
	ZS1->ZS1_FILORI	:= cEmpAnt+cFilAnt
	ZS1->ZS1_ITEM	:= cItem
	ZS1->ZS1_STATUS	:= '2'
	ZS1->ZS1_XIDINT	:= ''
	ZS1->ZS1_DATAIN	:= Date()
	ZS1->ZS1_HORAII	:= Time()
	ZS1->ZS1_NMARQI	:= ''
	ZS1->ZS1_TPPESS	:= "P"+cAliasA1->A1_PESSOA
	ZS1->ZS1_CGC	:= cAliasA1->A1_CGC
	ZS1->ZS1_NOME	:= cAliasA1->A1_NOME
	ZS1->ZS1_DTNASC	:= STOD(cAliasA1->A1_DTNASC)
	ZS1->ZS1_TPSOLI	:= cAliasA1->TPSOL
	ZS1->ZS1_RUA	:= cAliasA1->A1_END
	ZS1->ZS1_NUMERO	:= cAliasA1->A1_NR_END
	ZS1->ZS1_COMPLE	:= cAliasA1->A1_COMPLEM
	ZS1->ZS1_BAIRRO	:= cAliasA1->A1_BAIRRO
	ZS1->ZS1_CEP	:= cAliasA1->A1_CEP
	ZS1->ZS1_CIDADE	:= cAliasA1->A1_MUN
	ZS1->ZS1_UF		:= cAliasA1->A1_EST
	ZS1->ZS1_NMCONT	:= cAliasA1->A1_CONTATO
	ZS1->ZS1_DDD	:= cAliasA1->A1_DDD
	ZS1->ZS1_TEL	:= cAliasA1->A1_TEL
	ZS1->ZS1_RAMAL	:= ''
	ZS1->ZS1_EMAIL	:= cAliasA1->A1_EMAIL
	ZS1->ZS1_DDDCEL	:= cAliasA1->XDDDCEL
	ZS1->ZS1_TELCEL	:= cAliasA1->XCEL
	ZS1->ZS1_EMAILC	:= cAliasA1->A1_EMAIL
	ZS1->ZS1_CDESDE	:= STOD(cAliasA1->A1_DTCAD)
	ZS1->ZS1_TPCLIE	:= cAliasA1->TPCLI
	ZS1->ZS1_INFCOM	:= ''
	ZS1->ZS1_LIMATU	:= cAliasA1->LIM_ATU
	ZS1->ZS1_PHISTC	:= 'N'
	ZS1->(MsUnLock())
Return()

//Valida se já teve integracao
Static Function ValZSSP()
Local cQr		:= ""
Local cAliasA2

If Select("cAliasA2")<>0
	DbSelectArea("cAliasA2")
	DbCloseArea()
Endif

_cPerg1	:= MV_PAR01
_cPerg2	:= MV_PAR02

cQr += " SELECT ZS1_CGC,A1_CGC "+cCRLF
cQr += " FROM SA1010 SA1 "+cCRLF
cQr += " INNER JOIN ZS1040 ZS1 ON ZS1.ZS1_FILIAL = '' AND SA1.A1_CGC = ZS1.ZS1_CGC AND ZS1.D_E_L_E_T_ = '' "+cCRLF
cQr += " WHERE SA1.D_E_L_E_T_ = ''
cQr += "	AND SA1.A1_COD = '"+_cPerg1+"' "+cCRLF
cQr += "	AND SA1.A1_LOJA = '"+_cPerg2+"'"+cCRLF

// abre a query
TcQuery cQr new alias "cAliasA2"

DbSelectArea("cAliasA2")
cAliasA2->(DbGoTop())

Return(cAliasA2->(EOF()))