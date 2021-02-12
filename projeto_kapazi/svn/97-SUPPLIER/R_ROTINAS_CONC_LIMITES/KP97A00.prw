#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: KP97A00		|	Autor: Luis Paulo							|	Data: 20/05/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por integrar titulos do CR para integracao da supplier			//
//	Concessao de limites																			//
//==================================================================================================//
User Function KP97A00()
Local lRet	:= .T.
Local cMark	:= oMark:Mark()
//Valida se tem itens selecionados
If ValCliSe()
	If ValCGCKP() //Valida se o cliente é pessoa fisica os juridica
			If ValClIMU() 		//Verifica se tem mais de uma raiz de CNPJ selecionada
					If ValTitM() 	//Valida se tem titulos diferentes de NF/FT
						Processa({||ApuraTIT()} ,"Processando titulos","Aguarde...") 
						ClearOk(cMark)
					EndIf
				Else
					ClearOk(cMark)
			EndIf
		Else
			ClearOk(cMark)
	EndIf
EndIf

oMark:Refresh()
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
cQr += "	AND	E1_FLAGSPC = '"+cMarkKP+"'

// abre a query
TcQuery cQr new alias "cAliasE1"
Count To nRegs

If nRegs == 0
	lRet		:= .F.
	MsgAlert("Nenhum Registro selecionado!!!","KAPAZI - INTEGRACAO SUPPLIER")
EndIf

cAliasE1->(DbCloseArea())
Return(lRet)

//Validacao se tem cliente pessoa fisica selecionado
Static Function ValCGCKP()
Local cMarkKP	:= oMark:Mark()
Local lRet		:= .T.
Local nRegs		:= 0
Local cAliasE1	:= GetNextAlias()
Local cPessoa	:= ""

If Select("cAliasE1")<>0
	DbSelectArea("cAliasE1")
	DbCloseArea()
Endif

cQr := " SELECT DISTINCT E1_CLIENTE,E1_LOJA "
cQr += " FROM "+ RetSqlName("SE1") +" "
cQr += " WHERE D_E_L_E_T_ = ''
cQr += "	AND	E1_FLAGSPC = '"+cMarkKP+"'"

// abre a query
TcQuery cQr new alias "cAliasE1"

cAliasE1->(DbGoTop())
While !cAliasE1->(EOF())
	
	cPessoa	:= POSICIONE("SA1",1,xFilial("SA1") + cAliasE1->E1_CLIENTE + cAliasE1->E1_LOJA,"A1_PESSOA")
	
	If Empty(cPessoa) .OR. cPessoa == 'F'
		lRet		:= .F.
	EndIf
	
	cAliasE1->(DbSkip())
EndDo

If !lRet
	MsgAlert("Existem pessoal fisicas selecionadas, favor selecionar apenas pessoas jurídicas!!!","KAPAZI - INTEGRACAO SUPPLIER")
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
cQr += "	AND	SE1.E1_FLAGSPC = '"+cMarkKP+"'
cQr += " ORDER BY RAIZCNPJ

// abre a query
TcQuery cQr new alias "cAliasE1"
Count To nRegs

If nRegs > 1
	If MsgYesNo("Existe mais de uma Raiz de CNPJ selecionada, Deseja continuar???","KAPAZI - INTEGRACAO SUPPLIER")
			lRet	:= .T.
		Else
			lRet	:= .F.
	EndIf
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
Local cId		:= ""
Local lInclui	:= .T.

If Select("cAliasE1")<>0
	DbSelectArea("cAliasE1")
	cAliasE1->(DbCloseArea())
Endif

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
cQr += "	AND SE1.E1_FLAGSPC = '"+cMarkKP+"' "+cCRLF
cQr += "	ORDER BY SE1.E1_CLIENTE,SE1.E1_LOJA "+cCRLF

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
	
	cItem	:= GETSXENUM("ZS1","ZS1_ITEM")
	ConfirmSx8()
	
	DbSelectArea("ZS1")
	ZS1->(DbSetOrder(7))
	ZS1->(DbGoTop())
	If (!ZS1->(DbSeek(xFilial("ZS1") + Space(15) + cID) )) //Verificar todas as possibilidades dentro da tabela
			RecLock("ZS1",.T.)
			ZS1->ZS1_FILIAL	:= ''
			ZS1->ZS1_FILORI	:= cEmpAnt+cAliasE1->E1_FILIAL
			ZS1->ZS1_ITEM	:=  cItem
			ZS1->ZS1_STATUS	:= '2'
			ZS1->ZS1_XIDINT	:= ''
			ZS1->ZS1_DATAIN	:= Date()
			ZS1->ZS1_HORAII	:= Time()
			ZS1->ZS1_NMARQI	:= ''
			ZS1->ZS1_TPPESS	:= "P"+cAliasE1->A1_PESSOA
			ZS1->ZS1_CGC	:= cAliasE1->A1_CGC
			ZS1->ZS1_NOME	:= cAliasE1->A1_NOME
			ZS1->ZS1_DTNASC	:= STOD(cAliasE1->A1_DTNASC)
			ZS1->ZS1_TPSOLI	:= cAliasE1->TPSOL
			ZS1->ZS1_RUA	:= StrTran(cAliasE1->A1_END, ";", "-" ) 
			ZS1->ZS1_NUMERO	:= StrTran(cAliasE1->A1_NR_END, ";", "-" ) 
			ZS1->ZS1_COMPLE	:= StrTran(cAliasE1->A1_COMPLEM, ";", "-" )
			ZS1->ZS1_BAIRRO	:= StrTran(cAliasE1->A1_BAIRRO, ";", "-" )
			ZS1->ZS1_CEP	:= cAliasE1->A1_CEP
			ZS1->ZS1_CIDADE	:= StrTran(cAliasE1->A1_MUN, ";", "-" )
			ZS1->ZS1_UF		:= cAliasE1->A1_EST
			ZS1->ZS1_NMCONT	:= StrTran(cAliasE1->A1_CONTATO, ";", "-" )
			ZS1->ZS1_DDD	:= cAliasE1->A1_DDD
			ZS1->ZS1_TEL	:= cAliasE1->A1_TEL
			ZS1->ZS1_RAMAL	:= ''
			ZS1->ZS1_EMAIL	:= cAliasE1->A1_EMAIL
			ZS1->ZS1_DDDCEL	:= cAliasE1->XDDDCEL
			ZS1->ZS1_TELCEL	:= cAliasE1->XCEL
			ZS1->ZS1_EMAILC	:= cAliasE1->A1_EMAIL
			ZS1->ZS1_CDESDE	:= IIF( Empty(cAliasE1->A1_DTCAD),STOD(cAliasE1->DTPRICP),STOD(cAliasE1->A1_DTCAD))  
			ZS1->ZS1_TPCLIE	:= cAliasE1->TPCLI
			ZS1->ZS1_INFCOM	:= ''
			ZS1->ZS1_LIMATU	:= cAliasE1->LIM_ATU
			ZS1->ZS1_PHISTC	:= cAliasE1->HIST_CP
			ZS1->ZS1_CODCOM	:= cID
			ZS1->ZS1_DTFATU	:= STOD(cAliasE1->E1_EMISSAO)
			ZS1->ZS1_VLRTOR	:= IIF( Alltrim(cAliasE1->E1_TIPO) == "FT",cAliasE1->VALBFT,cAliasE1->F2_VALBRUT)
			ZS1->ZS1_DTVENC	:= STOD(cAliasE1->E1_VENCREA)
			ZS1->ZS1_VLRPAR	:= cAliasE1->E1_VALOR
			ZS1->ZS1_DTPGPA	:= STOD(cAliasE1->E1_BAIXA)
			ZS1->ZS1_VPGPAR	:= cAliasE1->E1_VALLIQ
			ZS1->ZS1_TPPSOC	:= ''			//Dados do socio
			ZS1->ZS1_CGCSO	:= '' 
			ZS1->ZS1_NOMESO	:= ''
			ZS1->ZS1_RECOE1	:= cAliasE1->RECOSE1
			//ZS1->ZS1_DTNSOC	:= CTOD('//')
			ZS1->(MsUnlock())
			
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
! Descricao ! Limpa o campo E1_FLAGSPC.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SE1") "
cSql += " SET E1_FLAGSPC = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND E1_FLAGSPC 	= '"+cMark+"'"

If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

//Atualiza o status
Static Function XANREGA()
Local aAreaZ1	:= ZS1->(GetArea())
Local cCmpObA	:= "ZS1_TPPESS/ZS1_CGC/ZS1_NOME/ZS1_TPSOLI/ZS1_RUA/ZS1_NUMERO/ZS1_BAIRRO/ZS1_CEP/ZS1_CIDADE/ZS1_UF/ZS1_NMCONT/ZS1_DDD/ZS1_TEL/ZS1_CDESDE/ZS1_TPCLIE/"
Local cCmpObB	:= "ZS1_PHISTC/ZS1_CODCOM/ZS1_DTFATU/ZS1_VLRTOR/ZS1_DTVENC/ZS1_VLRPAR"
Local lStatusL	:= .T.
Local cCmp		:= ""

If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZS1->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZS1->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS1->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS1")
	RecLock("ZS1",.F.)
	If lStatusL //Atualiza o status da linha
			ZS1->ZS1_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS1->ZS1_STATUS := "1"
	EndIf
	ZS1->(MsUnlock())
EndIf

//Valida campos obrigatorios em caso de historico de compras
If lStatusL .And. Alltrim(ZS1->ZS1_PHISTC) == "S" 
	// faz o loop sobre os campos
	For nI := 1 to ZS1->(FCount())
		If Alltrim(Field(nI)) $ cCmpObB //Campos obrigatorios em caso de movimentos
			
			cCmp	:= "ZS1->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS1->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS1")
	RecLock("ZS1",.F.)
	If lStatusL //Atualiza o status da linha
			ZS1->ZS1_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS1->ZS1_STATUS := "1"
	EndIf
	ZS1->(MsUnlock())
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
cQr += " 	AND	SE1.E1_FLAGSPC = '"+cMarkKP+"'
cQr += " 	AND SE1.E1_TIPO NOT IN ('NF','FT')

// abre a query
TcQuery cQr new alias "cAliasE5"
Count To nRegs

If nRegs > 1
	lRet		:= .F.
	MsgAlert("Existem titulos diferentes de NF e FT selecionados, favor verificar!!!","KAPAZI - INTEGRACAO SUPPLIER")
EndIf

cAliasE5->(DbCloseArea())
Return(lRet)