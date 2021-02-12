#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: KP97A08		|	Autor: Luis Paulo							|	Data: 25/08/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por PEDIDOS DE VENDAS para supplier								//
//																									//
//==================================================================================================//
User Function KP97A08()
Local lRet		:= .T.
Local cMark		:= oMark:Mark()
Private nNLim	:= 0

If ValCliSe() 			//Valida se tem itens selecionados
	If ValClIMU() 		//Verifica se tem mais de uma raiz de CNPJ selecionada
		If !CarCli()
			While !cAliaCli->(EOF())
				Processa({||ApuraPDV()} ,"Processando pedidos de vendas","Aguarde...")  
				cAliaCli->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf
ClearOk(cMark)
oMark:Refresh()
Return()

//Carrega os clientes marcados
Static Function CarCli()
Local cMarkKP	:= oMark:Mark()
Local lRet		:= .T.
Local nRegs		:= 0
Local cAliaCli	:= GetNextAlias()

If Select("cAliaCli")<>0
	DbSelectArea("cAliaCli")
	cAliaCli->(DbCloseArea())
Endif

cQr := " SELECT A1_COD,A1_LOJA
cQr += " FROM "+ RetSqlName("SA1") +" "
cQr += " WHERE D_E_L_E_T_ = ''
cQr += "	AND	A1_FLAGSP2 = '"+cMarkKP+"'

// abre a query
TcQuery cQr new alias "cAliaCli"
cAliaCli->(DbGoTop())

Return(cAliaCli->(EOF()))

//Valida se tem itens selecionados
Static Function ValCliSe()
Local cMarkKP	:= oMark:Mark()
Local lRet		:= .T.
Local nRegs		:= 0
Local cAliaSA1	:= GetNextAlias()

If Select("cAliaSA1")<>0
	DbSelectArea("cAliaSA1")
	DbCloseArea()
Endif

cQr := " SELECT A1_COD,A1_LOJA
cQr += " FROM "+ RetSqlName("SA1") +" "
cQr += " WHERE D_E_L_E_T_ = ''
cQr += "	AND	A1_FLAGSP2 = '"+cMarkKP+"'

// abre a query
TcQuery cQr new alias "cAliaSA1"
Count To nRegs

If nRegs == 0
	lRet		:= .F.
	MsgInfo("Nenhum Registro selecionado!!!","KAPAZI - PEDIDOS DE VENDAS SUPPLIER")
EndIf

cAliaSA1->(DbCloseArea())
Return(lRet)

//Verifica se tem mais de uma raiz de CNPJ selecionada
Static Function ValClIMU()
Local cQr 		:= ""
Local cAliaSA1	:= GetNextAlias()
Local lRet		:= .T.
Local nRegs		:= 0
Local cMarkKP	:= oMark:Mark()

If Select("cAliaSA1")<>0
	DbSelectArea("cAliaSA1")
	DbCloseArea()
Endif

cQr += " SELECT DISTINCT SUBSTRING(SA1.A1_CGC,1,8) AS RAIZCNPJ
cQr += " FROM "+ RetSqlName("SA1") +" SA1 " 
cQr += " WHERE SA1.D_E_L_E_T_ = ''
cQr += "	AND	SA1.A1_FLAGSP2 = '"+cMarkKP+"'
cQr += " ORDER BY RAIZCNPJ

// abre a query
TcQuery cQr new alias "cAliaSA1"
Count To nRegs

If nRegs > 1
	If !MsgYesNo("Existe mais de uma Raiz de CNPJ selecionada!!!","KAPAZI - PEDIDOS DE VENDAS SUPPLIER")
		lRet	:= .F.
	EndIf
EndIf

cAliaSA1->(DbCloseArea())
Return(lRet)


Static Function ApuraPDV()
Local cQr 		:= ""
Local cAliaSA1	:= GetNextAlias()
Local cID		:= ""
Local nTan		:= 0
Local cMarkKP	:= oMark:Mark()
Local nCount	:= 0
Local nRegs		:= 0
Local cItem		:= ""
Local lContinu	:= .T.
Local aEmp		:= {}
Local aFil		:= {}
Local cTxCli	:= SUPERGETMV("KP_TXSPCLI", .F., "0") //"0 = 0%"
//Conforme informado pela Anna/Supplier(junto com a Adriana) em 28/11/18, a kapazi nao possui essa tx contra o cliente, devendo informar zero.

Local cTxAdPar	:= SUPERGETMV("KP_TXSPAPA", .F., "1.28")	//"6 = 6%"
//Página 14 do contrato
//Até o 12 meses da implantaçao será cobrado 1,28%, depois será conforme regra abaixo:
//Limite de crédito do associado(cliente)
//Limite maior ou igual  200.000 -> 1,28%
//Limite menor que 200.000 -> 1,40%

Local cTxAdmPa	:= SUPERGETMV("KP_TXSPADP", .F., "0")	
//"Taxa de administraçao será cobrada a partir do 5 mes

//Tabela A para o 5 e 6 meses contados a partir da 1 transacao
//Maior ou igual a 2.000.000 	->Isento
//Menor que 2.000.0000 			->R$ 5.000,00

//Tabela B para o 7, 8 e 9 meses da operacao
//Maior ou igual a 3.500.000 						->Isento
//Maior ou igual a 2.500.000 e menor que 3.500.000 	->R$ 5.0000
//Menor que R$ 2.500.000 							->R$ 10.000

//Tabela c para a partir do 10 mes
//Maior ou igual a 5.000.0000						->Isento
//Maior ou igual a 4.000.0000 e menor que 5.000.000	-> R$ 5.000,00
//Maior ou igual a 3.000.0000 e menor que 4.000.000	-> R$ 10.000,00
//Menor que 3.000.000 								-> R$ 15.000,00
Local cCondPGK 	:= ""	
Local aParcelas	:= {}
Local cDiaPPar	

If Select("cAliaSA1")<>0
	DbSelectArea("cAliaSA1")
	cAliaSA1->(DbCloseArea())
Endif

cQr += " SELECT	SC5.R_E_C_N_O_ AS RECOC5,*"+cCRLF
cQr += " FROM "+ RetSqlName("SC5")+" SC5 WITH (NOLOCK) "+cCRLF
cQr += " LEFT JOIN SA1010 SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' "+cCRLF
cQr += " WHERE SC5.D_E_L_E_T_ = '' "+cCRLF
cQr += " AND SC5.C5_CLIENTE = '"+cAliaCli->A1_COD+"' "+cCRLF
cQr += "	AND SC5.C5_LOJACLI = '"+cAliaCli->A1_LOJA+"' "+cCRLF
cQr += "	AND SC5.C5_NOTA = '' "+cCRLF
cQr += "	AND SC5.C5_XPVSPC = 'S' "+cCRLF //proposto para supplier
cQr += "	AND	SC5.C5_XSTSSPP = '' "+cCRLF //Controlado para supplier
Conout(cQr)

// abre a query
TcQuery cQr new alias "cAliaSA1"
Count to nRegs

DbSelectArea("cAliaSA1")
cAliaSA1->(DbGoTop())

ProcRegua(nRegs)
While !cAliaSA1->(EOF())
	
	nCount++
	IncProc('Processando.....  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	If Empty(cAliaSA1->C5_XSTSSPP) //C5_XSTSSPP - Enviado para supplier
			//C5_FLRECSU - Processado e em posse de supplier
	
			cID		:= SUBSTR(cAliaSA1->A1_COD,1,4) +cEmpAnt + cAliaSA1->C5_FILIAL + cAliaSA1->C5_NUM //Definir depois o formato de parcelas
			
			cItem	:= GETSXENUM("ZS3","ZS3_ITEM")
			ConfirmSx8()
			
			aFil	:= FWArrFilAtu(cEmpAnt,cAliaSA1->C5_FILIAL)
			
			aParcelas	:= {}
			aParcelas	:=	Condicao(cAliaSA1->C5_XTOTMER,cAliaSA1->C5_CONDPAG,,dDataBase)
			For nZ:=1 to Len(aParcelas)
				If nZ == 1
					cDiaPPar	:= aParcelas[1,1] - dDatabase
					//aParcelas[nZ,1]	//Data boa
					//aParcelas[nZ,2] //Valor do cheque/titulo
				EndIf
			Next nZ
			
			DbSelectArea("ZS3")
			ZS3->(DbSetOrder(5))
			ZS3->(DbGoTop())
			If ZS3->(DbSeek(xFilial("ZS3") + Space(15) + cID) ) //Valida se o registro já foi para tabela de integracao
					RecLock("ZS3",.F.)
					Conout("Registro Duplicado->"+cID)
				Else
					RecLock("ZS3",.T.)
			EndIf	
			ZS3->ZS3_FILIAL	:= ""
			ZS3->ZS3_FILORI	:= cEmpAnt+cAliaSA1->C5_FILIAL
			ZS3->ZS3_ITEM	:= cItem
			ZS3->ZS3_STATUS	:= "1"
			ZS3->ZS3_XIDINT	:= ""
			ZS3->ZS3_DATAIN := Date()
			ZS3->ZS3_HORAII	:= Time()
			ZS3->ZS3_NMARQI	:= ""
			ZS3->ZS3_CODSOL	:= "36"
			ZS3->ZS3_CGC	:= cAliaSA1->A1_CGC
			ZS3->ZS3_CGCK	:= aFil[18]		//Pega o CNPJ da Filial do pedido
			ZS3->ZS3_TIPOTR	:= "0" 			//Tipo de transacao - Preencher com o código descrito no item 8 do MAPA DE PARÂMETROS
			ZS3->ZS3_CODPVS	:= cID	
			ZS3->ZS3_VALPV	:= cAliaSA1->C5_XTOTMER
			ZS3->ZS3_QTDPAR	:= cValTochar(Len(aParcelas))			//Qtd de parcelas 					-- sera tratado
			ZS3->ZS3_DPRIVE	:= cValToChar(cDiaPPar)					//Dias para o primeiro vencimento	-- sera tratado
			ZS3->ZS3_CONDSP	:= "1"									//1 = Padrão ou 0 = Flex
			ZS3->ZS3_QTDDEP	:= ""									//Qtd de dias entre as parcelas		-- Somente flex
			ZS3->ZS3_TXCLI	:= cTxCli								//Verificar com a Supplier a TX Cliente - 13 caracteres
			ZS3->ZS3_TXAPAR	:= cTxAdPar								//Verificar com a Supplier a TX Antecipacao do parceiro - 13 caracteres
			ZS3->ZS3_TXPPAR	:= cTxAdmPa								//Verificar com a Supplier a TX do parceiro - 13 caracteres
			ZS3->ZS3_FORREC	:= "3"									//Preencher com o código descrito no item 9 do MAPA DE PARÂMETROS
			ZS3->ZS3_PRECPA	:= "D+1"								//"Quantidade de dias para recebimento da transação, previamente combinado com a Suppliercard.Vide item 9 do MAPA DE PARÂMETROS."
			ZS3->ZS3_OBS	:= "Teste"
			ZS3->ZS3_RECSC5	:= cAliaSA1->RECOC5
			ZS3->(MsUnlock())
			XANREGA()
		Else
			//MsgInfo("Pedido já integrado com a Supplier -> " + cAliaSA1->A1_FILIAL + "-" cAliaSA1->A1_NUM,"KAPAZI - PEDIDOS DE VENDAS SUPPLIER")
			Conout("Pedido já integrado com a Supplier -> " + cAliaSA1->C5_FILIAL + "-" +cAliaSA1->C5_NUM)
	EndIf
	cAliaSA1->(DbSkip())
EndDo

cAliaSA1->(DbCloseArea())
Return()

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo A1_FLAGSP2.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SA1") "
cSql += " SET A1_FLAGSP2 = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND A1_FLAGSP2 	= '"+cMark+"'"

If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

//Atualiza o status
Static Function XANREGA()
Local aAreaZ2	:= ZS3->(GetArea())
Local cCmpObA	:= "ZS3_CODSOL/ZS3_CGC/ZS3_CGCK/ZS3_TIPOTR/ZS3_CODPVS/ZS3_VALPV/ZS3_QTDPAR/ZS3_DPRIVE/ZS3_CONDSP/ZS3_TXCLI/ZS3_TXAPAR/ZS3_FORREC/ZS3_PRECPA"
//Local cCmpObB	:= "ZS3_DTFAT/ZS3_VLRTOT/ZS3_VENCPA/ZS3_VLRPAC/" //ZS3_DTPPAR/ZS3_VPPARC"
Local lStatusL	:= .T.
Local cCmp		:= ""

If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZS3->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZS3->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS3->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS3")
	RecLock("ZS3",.F.)
	If lStatusL //Atualiza o status da linha
			ZS3->ZS3_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS3->ZS3_STATUS := "1"
	EndIf
	ZS3->(MsUnlock())
EndIf

//Valida campos obrigatorios em caso de historico de compras
/*
If lStatusL .And. Alltrim(ZS3->ZS3_HISTCP) == "S" 
	// faz o loop sobre os campos
	For nI := 1 to ZS3->(FCount())
		If Alltrim(Field(nI)) $ cCmpObB //Campos obrigatorios em caso de movimentos
			
			cCmp	:= "ZS3->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS3->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS3")
	RecLock("ZS3",.F.)
	If lStatusL //Atualiza o status da linha
			ZS3->ZS3_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS3->ZS3_STATUS := "1"
	EndIf
	ZS3->(MsUnlock())
EndIf
*/	
RestArea(aAreaZ2)
Return()

