#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: KP97A05		|	Autor: Luis Paulo							|	Data: 25/08/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por integrar PV para Supplier										//
//																									//
//==================================================================================================//
User Function KP97A05()
Local lRet		:= .T.
Local cMark		:= oMark:Mark()
Private nNLim	:= 0

If ValCliSe() 			//Valida se tem itens selecionados
	If ValClIMU() 		//Verifica se tem mais de uma raiz de CNPJ selecionada
		If ValCliSPP()	//Valida se o cliente pertence a Supplier
			Processa({||ApuraPDV()} ,"Processando pedidos de vendas","Aguarde...")  
		EndIf
	EndIf

EndIf
ClearOk(cMark)
oMark:Refresh()
Return()

//Valida se tem itens selecionados
Static Function ValCliSe()
Local cMarkKP	:= oMark:Mark()
Local lRet		:= .T.
Local nRegs		:= 0
Local cAliaSC5	:= GetNextAlias()

If Select("cAliaSC5")<>0
	DbSelectArea("cAliaSC5")
	DbCloseArea()
Endif

cQr := " SELECT *
cQr += " FROM "+ RetSqlName("SC5") +" "
cQr += " WHERE D_E_L_E_T_ = ''
cQr += "	AND	C5_FLAGSP2 = '"+cMarkKP+"'

// abre a query
TcQuery cQr new alias "cAliaSC5"
Count To nRegs

If nRegs == 0
	lRet		:= .F.
	MsgInfo("Nenhum Registro selecionado!!!","KAPAZI - PEDIDOS DE VENDAS SUPPLIER")
EndIf

cAliaSC5->(DbCloseArea())
Return(lRet)

//Verifica se tem mais de uma raiz de CNPJ selecionada
Static Function ValClIMU()
Local cQr 		:= ""
Local cAliaSC5	:= GetNextAlias()
Local lRet		:= .T.
Local nRegs		:= 0
Local cMarkKP	:= oMark:Mark()

If Select("cAliaSC5")<>0
	DbSelectArea("cAliaSC5")
	DbCloseArea()
Endif

cQr += " SELECT DISTINCT SUBSTRING(SA1.A1_CGC,1,8) AS RAIZCNPJ
cQr += " FROM "+ RetSqlName("SC5") +" SC5 " 
cQr += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ''
cQr += " WHERE SC5.D_E_L_E_T_ = ''
cQr += "	AND	SC5.C5_FLAGSP2 = '"+cMarkKP+"'
cQr += " ORDER BY RAIZCNPJ

// abre a query
TcQuery cQr new alias "cAliaSC5"
Count To nRegs

If nRegs > 1
	If !MsgYesNo("Existe mais de uma Raiz de CNPJ selecionada, Deseja continuar???","KAPAZI - PEDIDOS DE VENDAS SUPPLIER")
		lRet	:= .F.
	EndIf
EndIf

cAliaSC5->(DbCloseArea())
Return(lRet)


Static Function ApuraPDV()
Local cQr 		:= ""
Local cAliaSC5	:= GetNextAlias()
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

//Local cTxCli	:= SUPERGETMV("KP_TXSPCLI", .F., "2") //"2 = 2%"
//Local cTxAdPar	:= SUPERGETMV("KP_TXSPAPA", .F., "6")	//"6 = 6%"
//Local cTxPar	:= SUPERGETMV("KP_TXSPPAR", .F., "3")	//"3 = 3%"

Local cCondPGK 	:= ""	
Local aParcelas	:= {}
Local cDiaPPar	

If Select("cAliaSC5")<>0
	DbSelectArea("cAliaSC5")
	cAliaSC5->(DbCloseArea())
Endif

cQr += " SELECT	SC5.R_E_C_N_O_ AS RECOC5,*"+cCRLF
cQr += " FROM "+ RetSqlName("SC5")+" SC5 WITH (NOLOCK) "+cCRLF
cQr += " LEFT JOIN SA1010 SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' "+cCRLF
cQr += " WHERE SC5.D_E_L_E_T_ = '' "+cCRLF
cQr += "	AND SC5.C5_FLAGSP2 = '"+cMarkKP+"' "+cCRLF

Conout(cQr)

// abre a query
TcQuery cQr new alias "cAliaSC5"
Count to nRegs

DbSelectArea("cAliaSC5")
cAliaSC5->(DbGoTop())

ProcRegua(nRegs)
While !cAliaSC5->(EOF())
	
	nCount++
	IncProc('Processando.....  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	If Empty(cAliaSC5->C5_XSTSSPP) //C5_FLENVSP - Enviado para supplier
			//C5_FLRECSU - Processado e em posse de supplier
	
			cID		:= SUBSTR(cAliaSC5->A1_COD,1,4) +cEmpAnt + cAliaSC5->C5_FILIAL + cAliaSC5->C5_NUM //Definir depois o formato de parcelas
			
			cItem	:= GETSXENUM("ZS3","ZS3_ITEM")
			ConfirmSx8()
			
			aFil	:= FWArrFilAtu(cEmpAnt,cAliaSC5->C5_FILIAL)
			
			aParcelas	:= {}
			aParcelas	:=	Condicao(cAliaSC5->C5_XTOTMER,cAliaSC5->C5_CONDPAG,,dDataBase)
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
			ZS3->ZS3_FILORI	:= cEmpAnt+cAliaSC5->C5_FILIAL
			ZS3->ZS3_ITEM	:= cItem
			ZS3->ZS3_STATUS	:= "1"
			ZS3->ZS3_XIDINT	:= ""
			ZS3->ZS3_DATAIN := Date()
			ZS3->ZS3_HORAII	:= Time()
			ZS3->ZS3_NMARQI	:= ""
			ZS3->ZS3_CODSOL	:= "36"
			ZS3->ZS3_CGC	:= cAliaSC5->A1_CGC
			ZS3->ZS3_CGCK	:= aFil[18]		//Pega o CNPJ da Filial do pedido
			ZS3->ZS3_TIPOTR	:= "0" 			//Tipo de transacao - Preencher com o código descrito no item 8 do MAPA DE PARÂMETROS
			ZS3->ZS3_CODPVS	:= cID	
			ZS3->ZS3_VALPV	:= cAliaSC5->C5_XTOTMER
			ZS3->ZS3_QTDPAR	:= cValTochar(Len(aParcelas))			//Qtd de parcelas 					-- sera tratado
			ZS3->ZS3_DPRIVE	:= cValToChar((cDiaPPar+1))				//Dias para o primeiro vencimento	-- sera tratado
			ZS3->ZS3_CONDSP	:= "1"									//1 = Padrão ou 0 = Flex
			ZS3->ZS3_QTDDEP	:= ""									//Qtd de dias entre as parcelas		-- Somente flex
			ZS3->ZS3_TXCLI	:= cTxCli								//Verificar com a Supplier a TX Cliente - 13 caracteres
			ZS3->ZS3_TXAPAR	:= cTxAdPar								//Verificar com a Supplier a TX Antecipacao do parceiro - 13 caracteres
			ZS3->ZS3_TXPPAR	:= cTxAdmPa								//Verificar com a Supplier a TX do parceiro - 13 caracteres
			ZS3->ZS3_FORREC	:= "3"									//Preencher com o código descrito no item 9 do MAPA DE PARÂMETROS
			ZS3->ZS3_PRECPA	:= "D+1"								//"Quantidade de dias para recebimento da transação, previamente combinado com a Suppliercard.Vide item 9 do MAPA DE PARÂMETROS."
			ZS3->ZS3_OBS	:= ""
			ZS3->ZS3_RECSC5	:= cAliaSC5->RECOC5
			ZS3->(MsUnlock())
			XANREGA()
		Else
			MsgInfo("Pedido já integrado com a Supplier -> " + cAliaSC5->C5_FILIAL + "-" +cAliaSC5->C5_NUM,"KAPAZI - PEDIDOS DE VENDAS SUPPLIER")
			Conout("Pedido já integrado com a Supplier -> " + cAliaSC5->C5_FILIAL + "-" +cAliaSC5->C5_NUM)
	EndIf
	cAliaSC5->(DbSkip())
EndDo

cAliaSC5->(DbCloseArea())
Return()

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo C5_FLAGSP2.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SC5") "
cSql += " SET C5_FLAGSP2 = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND C5_FLAGSP2 	= '"+cMark+"'"

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
cQr += " FROM "+ RetSqlName("SC5") +" SC5 WITH (NOLOCK) 
cQr += " INNER JOIN "+ RetSqlName("SA1") +" SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' AND SA1.A1_FLAGSPC = 'S'
cQr += " WHERE SC5.D_E_L_E_T_ = '' 
cQr += "	AND SC5.C5_FLAGSP2 = '"+cMarkKP+"'

// abre a query
TcQuery cQr new alias "cAliasEA"

DbSelectArea("cAliasEA")
cAliasEA->(DbGoTop())

If cAliasEA->(EOF())
	lRet	:= .F.
	MsgInfo("Este cliente nao pertence a Supplier, favor verificar", "KAPAZI - PEDIDOS DE VENDAS SUPPLIER CARD")
EndIf

cAliasEA->(DbCloseArea())
Return(lRet)