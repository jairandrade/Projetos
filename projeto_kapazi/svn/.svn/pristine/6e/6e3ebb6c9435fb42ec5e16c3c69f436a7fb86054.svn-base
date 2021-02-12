#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: KP97A03		|	Autor: Luis Paulo							|	Data: 08/05/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por integrar titulos do CR para ALT LIMITES da supplier			//
//																									//
//==================================================================================================//
User Function KP97A03()
Local lRet		:= .T.
Local cMark		:= oMark:Mark()
Private nNLim	:= 0

//Valida se tem itens selecionados
If ValCliSe()
	
	If ValClIMU() 		//Verifica se tem mais de uma raiz de CNPJ selecionada
		If ValTitM() 	//Valida se tem titulos diferentes de NF/FT
			If ValCliSPP()
				VlrLimt(cMark) // validacao final e informacao do novo limite
			EndIf
		EndIf
	EndIf

EndIf

oMark:Refresh()
Return()

Static Function VlrLimt(cMark)
Local nQtd	 		:= 0
Local cCRLF			:= CRLF
Local nBtoOk		:= 0
Local nVlrLAtu		:= POSICIONE("SA1",1,xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA,"A1_LC")
Private _cPerg1
Private _cPerg2
Private _cPerg3
Private aFiltros 	:= {}

aAdd(aFiltros,nVlrLAtu)
aAdd(aFiltros,Val("0.0")) 	//Estava Stod("")
aAdd(aFiltros,Space(250)) 			//Estava Val("0.0")

oFont12 := TFont():New('Arial',,-12,,.F.)

Define MsDialog oDlg TITLE "Informações adicionais de Limites"  From 001,001 to 330,935 Pixel							

oGrpFil := TGroup():New(055,005,040,700,"Inf Adicionais",oDlg,CLR_HBLUE,,.T.)

oSayAtr := tSay():New(050,010,{|| "Limite Atual"  },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetAtr := tGet():New(060,010,{|u| if(PCount()>0,aFiltros[1]:=u,aFiltros[1])}, oGrpFil,60,9,'@E 999,999,999.99', {|| },,,,,,.T.,,, { ||  } ,,,,.F.,,,'aFiltros[1]')
oSayAtr := tSay():New(090,010,{|| "Novo Limite"  },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetAtr := tGet():New(100,010,{|u| if(PCount()>0,aFiltros[2]:=u,aFiltros[2])}, oGrpFil,60,9,'@E 999,999,999.99', {|| },,,,,,.T.,,, { ||  } ,,,,.F.,,,'aFiltros[2]')
oSayAtr := tSay():New(130,010,{|| "Observação"   },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,30,9)
oGetAtr := tGet():New(140,010,{|u| if(PCount()>0,aFiltros[3]:=u,aFiltros[3])}, oGrpFil,450,9,'@!',,,,,,,.T.,,,,,,,.F.,,'','aFiltros[3]')

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR( oDlg,{ || nBtoOk := 1, oDlg:End() },{ || nBtoOk := 0, oDlg:End() } )

If nBtoOk == 0
		MsgAlert("Cancelado pelo usuário")
		Return .T.
	Else
		_cPerg2 := aFiltros[2]
		_cPerg3 := aFiltros[3]
		If !Empty(_cPerg2)
				Processa({||ApuraTIT()} ,"Processando Titulos - Alteracao de Limites","Aguarde...") 
				ClearOk(cMark)
			Else
				MsgAlert("Informe um novo valor de limite para o cliente desejado!","Kapazi")
		EndIf
EndIf

Return()


//Valida se tem mais de um cliente selecionado
Static Function ValCliSe()
Local cMarkKP	:= oMark:Mark()
Local lRet		:= .T.
Local nRegs		:= 0
Local cAliasE1	:= GetNextAlias()

If Select("cAliasE1")<>0
	DbSelectArea("cAliasE1")
	DbCloseArea()
Endif

cQr := " SELECT *
cQr += " FROM "+ RetSqlName("SE1") +" "
cQr += " WHERE D_E_L_E_T_ = ''
cQr += "	AND	E1_FLAGSP2 = '"+cMarkKP+"'

// abre a query
TcQuery cQr new alias "cAliasE1"
Count To nRegs

If nRegs == 0
	lRet		:= .F.
	MsgInfo("Nenhum Registro selecionado!!!","KAPAZI - ALT LIMITES SUPPLIER")
EndIf

cAliasE1->(DbCloseArea())
Return(lRet)

//Verifica se tem mais de uma raiz de CNPJ selecionada
Static Function ValClIMU()
Local cQr 		:= ""
Local cAliasE1	:= GetNextAlias()
Local lRet		:= .T.
Local nRegs		:= 0
Local cMarkKP	:= oMark:Mark()

If Select("cAliasE1")<>0
	DbSelectArea("cAliasE1")
	DbCloseArea()
Endif

cQr += " SELECT DISTINCT SUBSTRING(SA1.A1_CGC,1,8) AS RAIZCNPJ
cQr += " FROM "+ RetSqlName("SE1") +" SE1 " 
cQr += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ''
cQr += " WHERE SE1.D_E_L_E_T_ = ''
cQr += "	AND	SE1.E1_FLAGSP2 = '"+cMarkKP+"'
cQr += " ORDER BY RAIZCNPJ

// abre a query
TcQuery cQr new alias "cAliasE1"
Count To nRegs

If nRegs > 1
	MsgInfo("Existe mais de uma Raiz de CNPJ selecionada, Deseja continuar???","KAPAZI - ALT LIMITES SUPPLIER")
	lRet	:= .F.
EndIf

cAliasE1->(DbCloseArea())
Return(lRet)


Static Function ApuraTIT()
Local cQr 		:= ""
Local cAliasE1	:= GetNextAlias()
Local cID		:= ""
Local nTan		:= 0
Local cMarkKP	:= oMark:Mark()
Local nCount	:= 0
Local nRegs		:= 0
Local cItem		:= ""
Local lContinu	:= .T.

If Select("cAliasE1")<>0
	DbSelectArea("cAliasE1")
	cAliasE1->(DbCloseArea())
Endif

/*
cQr += " SELECT	SA1.A1_PESSOA,SA1.A1_NOME,SA1.A1_CGC,SA1.A1_DTNASC,'N' TPSOL,SA1.A1_END,SA1.A1_NR_END,SA1.A1_COMPLEM,SA1.A1_BAIRRO,SA1.A1_CEP,SA1.A1_CODMUN,SA1.A1_MUN, "+cCRLF
cQr += "		SA1.A1_EST,SA1.A1_CONTATO,SA1.A1_DDD,SA1.A1_TEL,SA1.A1_EMAIL,'' XDDDCEL,'' XCEL,SA1.A1_DTCAD, '0000' TPCLI,SA1.A1_LC LIM_ATU,SA1.A1_SALPEDL SLDPVLIB,SA1.A1_SALPED SLDPV, 'S' HIST_CP, "+cCRLF
cQr += "		SE1.E1_FILIAL+ RTRIM(RTRIM(SE1.E1_PARCELA))+SE1.E1_NUM AS IDCOMPRA,SF2.F2_EMISSAO,SF2.F2_VALBRUT,SF2.F2_DAUTNFE,SF2.F2_CHVNFE, "+cCRLF
cQr += "		SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_BAIXA,SE1.E1_VALLIQ,SE1.E1_PARCELA,SE1.E1_FILIAL,SE1.E1_NUM "+cCRLF
*/
cQr += " SELECT	SA1.A1_PESSOA,SA1.A1_NOME,SA1.A1_CGC,SA1.A1_DTNASC,'N' TPSOL,SA1.A1_END,SA1.A1_NR_END,SA1.A1_COMPLEM,SA1.A1_BAIRRO,SA1.A1_CEP,SA1.A1_CODMUN,SA1.A1_MUN, "+cCRLF
cQr += "		SA1.A1_EST,SA1.A1_CONTATO,SA1.A1_DDD,SA1.A1_TEL,SA1.A1_EMAIL,'' XDDDCEL,'' XCEL,SA1.A1_DTCAD, '0000' TPCLI,SA1.A1_LC LIM_ATU, 'S' HIST_CP, "+cCRLF
cQr += "		SE1.E1_FILIAL+ RTRIM(RTRIM(SE1.E1_PARCELA))+SE1.E1_NUM AS IDCOMPRA,SF2.F2_EMISSAO,SF2.F2_VALBRUT,SF2.F2_DAUTNFE,SF2.F2_CHVNFE, "+cCRLF
cQr += "		SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_BAIXA,SE1.E1_VALLIQ, SE1.E1_EMISSAO, SE1.E1_PARCELA,SE1.E1_NUM,SE1.E1_FILIAL,SE1.R_E_C_N_O_ AS RECOSE1, "+cCRLF
cQr += "		SE1.E1_TIPO,SE1.E1_PREFIXO,																									"+cCRLF
cQr += "		ISNULL((SELECT SUM(F2_VALBRUT) FROM SF2040 WHERE D_E_L_E_T_ = '' AND F2_XIDVNFK = SE1.E1_XIDVNFK AND F2_XIDVNFK <> ''),0) AS VALBFT, "+cCRLF
cQr += "		(SELECT TOP 1 F2_EMISSAO FROM SF2040 WHERE F2_CLIENTE = SE1.E1_CLIENTE AND F2_LOJA = SE1.E1_LOJA ORDER BY F2_EMISSAO) AS DTPRICP  "+cCRLF

cQr += " FROM "+ RetSqlName("SE1")+" SE1 WITH (NOLOCK) "+cCRLF
cQr += " LEFT JOIN "+ RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON SE1.E1_FILIAL = SF2.F2_FILIAL AND SE1.E1_PREFIXO = SF2.F2_SERIE AND SE1.E1_NUM = SF2.F2_DOC AND SF2.D_E_L_E_T_ = '' "+cCRLF
cQr += " LEFT JOIN SA1010 SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' "+cCRLF
cQr += " WHERE SE1.D_E_L_E_T_ = '' "+cCRLF
cQr += "	AND SE1.E1_FLAGSP2 = '"+cMarkKP+"' "+cCRLF

Conout(cQr)

// abre a query
TcQuery cQr new alias "cAliasE1"
Count to nRegs

DbSelectArea("cAliasE1")
cAliasE1->(DbGoTop())

ProcRegua(nRegs)
While !cAliasE1->(EOF())
	
	nCount++
	IncProc('Processando titulos  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	lInclui	:= .T.
	
	If Empty(cAliasE1->E1_PARCELA) 
			cID	:= "2"+cAliasE1->E1_FILIAL+"01"+cAliasE1->E1_NUM
		Else
			cID	:= "2"+cAliasE1->E1_FILIAL+cAliasE1->E1_PARCELA+cAliasE1->E1_NUM
	EndIF
	
	cItem	:= GETSXENUM("ZS2","ZS2_ITEM")
	ConfirmSx8()
	
	DbSelectArea("ZS2")
	ZS2->(DbSetOrder(7))
	ZS2->(DbGoTop())
	If (!ZS2->(DbSeek(xFilial("ZS2") + Space(15) + cID) )) //Verificar todas as possibilidades dentro da tabela
			RecLock("ZS2",.T.)
			ZS2->ZS2_FILIAL	:= ''
			ZS2->ZS2_FILORI	:= cEmpAnt+cAliasE1->E1_FILIAL
			ZS2->ZS2_ITEM	:=  cItem
			ZS2->ZS2_STATUS	:= '2'
			ZS2->ZS2_XIDINT	:= ''
			ZS2->ZS2_DATAIN	:= Date()
			ZS2->ZS2_HORAII	:= Time()
			ZS2->ZS2_NMARQI	:= ''
			ZS2->ZS2_TPPESS	:= "P"+cAliasE1->A1_PESSOA
			ZS2->ZS2_CGC	:= cAliasE1->A1_CGC
			ZS2->ZS2_NOME	:= cAliasE1->A1_NOME
			ZS2->ZS2_DTNASC	:= STOD(cAliasE1->A1_DTNASC)
			ZS2->ZS2_TPSOLI	:= cAliasE1->TPSOL
			ZS2->ZS2_RUA	:= StrTran(cAliasE1->A1_END, ";", "-" ) 
			ZS2->ZS2_NUMERO	:= StrTran(cAliasE1->A1_NR_END, ";", "-" ) 
			ZS2->ZS2_COMPLE	:= StrTran(cAliasE1->A1_COMPLEM, ";", "-" )
			ZS2->ZS2_BAIRRO	:= StrTran(cAliasE1->A1_BAIRRO, ";", "-" )
			ZS2->ZS2_CEP	:= cAliasE1->A1_CEP
			ZS2->ZS2_CIDADE	:= StrTran(cAliasE1->A1_MUN, ";", "-" )
			ZS2->ZS2_UF		:= cAliasE1->A1_EST
			ZS2->ZS2_NMCONT	:= StrTran(cAliasE1->A1_CONTATO, ";", "-" )
			ZS2->ZS2_DDD	:= cAliasE1->A1_DDD
			ZS2->ZS2_TEL	:= cAliasE1->A1_TEL
			ZS2->ZS2_RAMAL	:= ''
			ZS2->ZS2_EMAIL	:= cAliasE1->A1_EMAIL
			ZS2->ZS2_DDDCEL	:= cAliasE1->XDDDCEL
			ZS2->ZS2_TELCEL	:= cAliasE1->XCEL
			ZS2->ZS2_EMAILC	:= cAliasE1->A1_EMAIL
			ZS2->ZS2_CDESDE	:= IIF( Empty(cAliasE1->A1_DTCAD),STOD(cAliasE1->DTPRICP),STOD(cAliasE1->A1_DTCAD))  
			ZS2->ZS2_TPCLIE	:= cAliasE1->TPCLI
			ZS2->ZS2_INFCOM	:= _cPerg3
			ZS2->ZS2_LIMATU	:= cAliasE1->LIM_ATU
			ZS2->ZS2_PHISTC	:= cAliasE1->HIST_CP
			ZS2->ZS2_CODCOM	:= cID
			ZS2->ZS2_DTFATU	:= STOD(cAliasE1->E1_EMISSAO)
			ZS2->ZS2_VLRTOR	:= IIF( Alltrim(cAliasE1->E1_TIPO) == "FT",cAliasE1->VALBFT,cAliasE1->F2_VALBRUT)
			ZS2->ZS2_DTVENC	:= STOD(cAliasE1->E1_VENCREA)
			ZS2->ZS2_VLRPAR	:= cAliasE1->E1_VALOR
			ZS2->ZS2_DTPGPA	:= STOD(cAliasE1->E1_BAIXA)
			ZS2->ZS2_VPGPAR	:= cAliasE1->E1_VALLIQ
			ZS2->ZS2_TPPSOC	:= ''			//Dados do socio
			ZS2->ZS2_CGCSO	:= '' 
			ZS2->ZS2_NOMESO	:= ''
			ZS2->ZS2_RECOE1	:= cAliasE1->RECOSE1
			ZS2->ZS2_NEWLIM	:= _cPerg2
			//ZS2->ZS2_DTNSOC	:= CTOD('//')
			ZS2->(MsUnlock())
			
			XANREGA()
		Else
			Conout("Já processado->"+cID)
	EndIf
	
 cAliasE1->(DbSkip())
EndDo

cAliasE1->(DbCloseArea())
Return()

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo E1_FLAGSP2.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SE1") "
cSql += " SET E1_FLAGSP2 = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND E1_FLAGSP2 	= '"+cMark+"'"

If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

//Atualiza o status
Static Function XANREGA()
Local aAreaZ1	:= ZS2->(GetArea())
Local cCmpObA	:= "ZS2_TPPESS/ZS2_CGC/ZS2_NOME/ZS2_TPSOLI/ZS2_RUA/ZS2_NUMERO/ZS2_BAIRRO/ZS2_CEP/ZS2_CIDADE/ZS2_UF/ZS2_NMCONT/ZS2_DDD/ZS2_TEL/ZS2_CDESDE/ZS2_TPCLIE/"
Local cCmpObB	:= "ZS2_PHISTC/ZS2_CODCOM/ZS2_DTFATU/ZS2_VLRTOR/ZS2_DTVENC/ZS2_VLRPAR"
Local lStatusL	:= .T.
Local cCmp		:= ""

If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZS2->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZS2->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS2->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS2")
	RecLock("ZS2",.F.)
	If lStatusL //Atualiza o status da linha
			ZS2->ZS2_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS2->ZS2_STATUS := "1"
	EndIf
	ZS2->(MsUnlock())
EndIf

//Valida campos obrigatorios em caso de historico de compras
If lStatusL .And. Alltrim(ZS2->ZS2_PHISTC) == "S" 
	// faz o loop sobre os campos
	For nI := 1 to ZS2->(FCount())
		If Alltrim(Field(nI)) $ cCmpObB //Campos obrigatorios em caso de movimentos
			
			cCmp	:= "ZS2->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS2->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS2")
	RecLock("ZS2",.F.)
	If lStatusL //Atualiza o status da linha
			ZS2->ZS2_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS2->ZS2_STATUS := "1"
	EndIf
	ZS2->(MsUnlock())
EndIf
	
RestArea(aAreaZ1)
Return()

//Valida se tem titulos diferentes de NF/FT
Static Function ValTitM()
Local cQr 		:= ""
Local cAliasE5	:= GetNextAlias()
Local lRet		:= .T.
Local nRegs		:= 0
Local cMarkKP	:= oMark:Mark()

If Select("cAliasE5")<>0
	DbSelectArea("cAliasE5")
	DbCloseArea()
Endif

cQr += " SELECT E1_FILIAL,E1_NUM
cQr += " FROM "+ RetSqlName("SE1") +" SE1 " 
cQr += " WHERE SE1.D_E_L_E_T_ = ''
cQr += " 	AND	SE1.E1_FLAGSP2 = '"+cMarkKP+"'
cQr += " 	AND SE1.E1_TIPO NOT IN ('NF','FT')

// abre a query
TcQuery cQr new alias "cAliasE5"
Count To nRegs

If nRegs > 1
	lRet		:= .F.
	MsgInfo("Existem titulos diferentes de NF e FT selecionados, favor verificar!!!","KAPAZI - ALT LIMITES SUPPLIER")
EndIf

cAliasE5->(DbCloseArea())
Return(lRet)

//Valida se o cliente pertence a Supplier
Static Function ValCliSPP()
Local lRet	:= .T.
Local cQr 		:= ""
Local cAliasEA	:= GetNextAlias()
Local nRegs		:= 0
Local cMarkKP	:= oMark:Mark()

If Select("cAliasEA")<>0
	DbSelectArea("cAliasEA")
	DbCloseArea()
EndIf


cQr += " SELECT	DISTINCT SA1.A1_COD,SA1.A1_LOJA
cQr += " FROM "+ RetSqlName("SE1") +" SE1 WITH (NOLOCK) 
cQr += " INNER JOIN "+ RetSqlName("SA1") +" SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' AND SA1.A1_FLAGSPC = 'S'
cQr += " WHERE SE1.D_E_L_E_T_ = '' 
cQr += "	AND SE1.E1_FLAGSP2 = '"+cMarkKP+"'

// abre a query
TcQuery cQr new alias "cAliasEA"

DbSelectArea("cAliasEA")
cAliasEA->(DbGoTop())

If cAliasEA->(EOF())
	lRet	:= .F.
	MsgInfo("Este cliente nao pertence a Supplier, favor verificar", "KAPAZI - ALT LIMITES SUPPLIER CARD")
EndIf

cAliasEA->(DbCloseArea())
Return(lRet)
