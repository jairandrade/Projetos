/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! FAT - FATURAMENTO                                       !
+------------------+---------------------------------------------------------+
!Nome              ! AFAT002                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Consulta de Estoque Personalizada                       !
!                  ! Pedido de Venda                                         !
+------------------+---------------------------------------------------------+
!Atualizacao       ! MARCIO A.SUGAHARA                                       !
+------------------+---------------------------------------------------------+
*/
#include "rwmake.ch"
#include "topconn.ch"
#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "ap5mail.ch"

User Function AFAT002()

Local aArea    := GetArea()
Local oSim     := LoadBitMap(GetResources(), "LBOK")
Local oNao     := LoadBitMap(GetResources(), "LBNO")

Local cUserOld
Local cPswOld

//salva ambiente atual
local cAmbinete := GetEnvServer()

Local oFont		:= TFont():New( "Arial",0,-16,,.T.,0,,700,.T.,.F.,,,,,, )
Local oFont2	:= TFont():New( "Arial",0,16,,.F.,0,,700,.T.,.F.,,,,,, )
//                  TFont():New( "Arial",16,16,,.F.,0,,   ,.T.,.F.)

Local nQtdDispo
Local nC6qtdVen

Private aEmpFil  := {}

//salva empresa e filial atual
Private cEmpOld  := cEmpAnt
Private cFilOld  := cFilAnt

Private oGet1
Private oGet2
Private oGet3
Private oGet4

Private oDlgCons
Private nQtdNeces
Private nSldNec
Private aProdSld  := {}
Private aCabec
Private cRetorno
Private cCnpjDes  //cliente
Private lTransf := .F.

Private nReduc := 100

//NÃO EXECUTAR PARA AS FILIAIS 03, 04, 05 E 06 DA EMPRESA 04
If !cEmpAnt + cFilAnt $ "0403#0404#0405#0406#"
	nregSM0  := SM0->(RecNo())
	ccNPJDes := SM0->M0_CGC
	SM0->(DbGoTop())
	
	While !SM0->(EOF())
		//EXCLUIR AS FILIAIS 03, 04, 05 E 06 DA EMPRESA 04
		If !SM0->M0_CODIGO + SM0->M0_CODFIL $ "0403#0404#0405#0406#"
			If cEmpAnt <> SM0->M0_CODIGO .or.cFilAnt <> SM0->M0_CODFIL
				AADD(aEmpFil,{SM0->M0_CODIGO+SM0->M0_CODFIL, ALLTRIM(SM0->M0_NOME), ALLTRIM(SM0->M0_FILIAL), SM0->M0_CGC })
			EndIf
		EndIf
		SM0->(DbSkip())
	End
	SM0->(DbGoTo(nregSM0))
	
	nQtdDispo := Saldo_Atu(TRXC9->C6_PRODUTO)
	nC6qtdVen := TRXC9->C6_QTDVEN
	nQtdNeces := nC6qtdVen - nQtdDispo
	nSldNec := nQtdNeces
	If nQtdDispo < nC6qtdVen
		
		For ni :=  1 to Len(aEmpFil)
			Saldos(TRXC9->C6_PRODUTO, aEmpFil[ni,1],aEmpFil[ni,2],aEmpFil[ni,3],aEmpFil[ni,4])
		Next
		
		DEFINE MSDIALOG oDlgCons TITLE "Consulta Estoque de Produtos" FROM 20, 0 TO 650, 1200 Pixel
		
		oGrpSld  := tGroup():New(005,005,275,570,"Selecione a origem da transferencia:",oDlgCons,CLR_HBLUE,,.T.)
		
		oBrwSld := TCBrowse():New(055,010,550,200,,,,oDlgCons,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		
		@ 020,010 SAY TRXC9->C6_PRODUTO + ' - ' + TRXC9->C6_DESCRI  FONT oFont  SIZE 200, 10 OF oDlgCons PIXEL
		
		@ 040,010 SAY '% Redução:'  SIZE 100, 10 OF oDlgCons PIXEL
		@ 040,060 MSGET oGet4 VAR nReduc  SIZE 060, 07 OF oDlgCons  PIXEL PICTURE '@E 999.99' valid (nReduc >0)
		
		@ 040,150 SAY 'Quant.do Pedido:'  SIZE 100, 10 OF oDlgCons PIXEL
		@ 040,200 MSGET oGet1 VAR nC6qtdVen SIZE 060, 10 OF oDlgCons  READONLY PIXEL PICTURE '@E 999,999,999.9999'
		
		@ 040,290 SAY 'Qtd. Disponivel:' SIZE 100, 10 OF oDlgCons PIXEL
		@ 040,330 MSGET oGet2 VAR nQtdDispo SIZE 060, 10 OF oDlgCons  READONLY PIXEL PICTURE '@E 999,999,999.9999'
		
		@ 040,420 SAY 'Necessidade:' SIZE 100, 10 OF oDlgCons PIXEL
		@ 040,460 MSGET oGet3 VAR nSldNec SIZE 060, 10 OF oDlgCons  READONLY PIXEL PICTURE '@E 999,999,999.9999'
		
		oBrwSld:AddColumn(TCColumn():New(" "                 , {|| If(aProdSld[oBrwSld:nAt,01],oSim,oNao) },,,,,,.T.,.F.,,,,.F., ) )
		oBrwSld:AddColumn(TCColumn():New("Empresa"           , {|| aProdSld[oBrwSld:nAt,02]},,,,, 45 ,.F.,.F.,,,,.F., ) )
		oBrwSld:AddColumn(TCColumn():New("Filial"            , {|| aProdSld[oBrwSld:nAt,03]},,,,, 45 ,.F.,.F.,,,,.F., ) )
		oBrwSld:AddColumn(TCColumn():New("Produto"           , {|| aProdSld[oBrwSld:nAt,04]},,,,, 25 ,.F.,.F.,,,,.F., ) )
		oBrwSld:AddColumn(TCColumn():New("Descricao"         , {|| aProdSld[oBrwSld:nAt,05]},,,,, 30 ,.F.,.F.,,,,.F., ) )
		oBrwSld:AddColumn(TCColumn():New("Saldo disponivel"  , {|| aProdSld[oBrwSld:nAt,06]},"@E 99,999.99",,,, 70,.F.,.F.,,,,.F., ) )
		oBrwSld:AddColumn(TCColumn():New("Local"             , {|| aProdSld[oBrwSld:nAt,10]},,,,, 70 ,.F.,.F.,,,,.F., ) )
		oBrwSld:AddColumn(TCColumn():New("Qtd.Transferencia" , {|| aProdSld[oBrwSld:nAt,07]},"@E 99,999.99",,,, 70,.F.,.F.,,,,.F., ) )
		oBrwSld:AddColumn(TCColumn():New("Cod.Emp;/Filial"   , {|| aProdSld[oBrwSld:nAt,08]},,,,"CENTER", 70,.F.,.F.,,,,.F., ) )
		oBrwSld:SetArray(aProdSld)
		
		oBrwSld:bWhen := { || Len(aProdSld) > 0 }
		
		//		oBrwSld:bLDblClick   := {|| aProdSld[oBrwSld:nAt,01] := !aProdSld[oBrwSld:nAt,01]  }
		oBrwSld:bLDblClick   := {|| SelOrig()  }
		
		//		oBrwSld:bHeaderClick := {|| fSelectAll() }
		
		oBtnOk     := tButton():New(290,400,"Transferir",oDlgCons, {|| GravaTransf() },40,12,,,,.T.,,,, { ||  },,)
		oBtnCancel := tButton():New(290,450,"Cancelar",oDlgCons, {|| ::End() },40,12,,,,.T.,,,, { ||  },,)
		
		ACTIVATE MSDIALOG oDlgCons CENTERED
		RestArea(aArea)
		
	EndIf
EndIf
Return(lTransf)

/*
+------------------+---------------------------------------------------------+
!Nome              ! SelOrig                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Seleciona a origem das transferencias.                  !
+------------------+---------------------------------------------------------+
*/
Static Function SelOrig()

If nSldNec > 0 .and. !aProdSld[oBrwSld:nAt,01]  //esta selecionando...
	If aProdSld[oBrwSld:nAt,06] >= nSldNec  //saldo da outra empresa/filial atende a necessidade
		aProdSld[oBrwSld:nAt,07] := aProdSld[oBrwSld:nAt,07] + nSldNec
		nSldNec := 0
	Else
		nSldNec := nSldNec - aProdSld[oBrwSld:nAt,06]
		aProdSld[oBrwSld:nAt,07] := aProdSld[oBrwSld:nAt,07] + aProdSld[oBrwSld:nAt,06]
	EndIf
	aProdSld[oBrwSld:nAt,01] := !aProdSld[oBrwSld:nAt,01]
ElseIf nSldNec >= 0 .and. aProdSld[oBrwSld:nAt,01]   //desfazendo a seleção
	nSldNec := nSldNec + aProdSld[oBrwSld:nAt,07]
	aProdSld[oBrwSld:nAt,07] := 0
	aProdSld[oBrwSld:nAt,01] := !aProdSld[oBrwSld:nAt,01]
Elseif nSldNec = 0 .and. !aProdSld[oBrwSld:nAt,01]   //selecionando... mas a necessidade ja´atendida.
	MsgAlert("Necessidade já foi atendida.")
EndIf
oGet3:Refresh()
Return()

/*
+------------------+---------------------------------------------------------+
!Nome              ! Saldo_Atu                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Calcula saldo atual do produto da empresa/ffilial       !
!                  ! corrente.                                               !
+------------------+---------------------------------------------------------+
!Parametros        ! cProd --> código do produto                             !
+------------------+---------------------------------------------------------+
*/
Static Function Saldo_Atu(cProd)
Local aSaldos := {}
Local lMark := .f.

cQuery := " SELECT sum(B2_QATU-B2_QEMP-B2_RESERVA) SALDO"
cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
cQuery += " WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
cQuery += " AND B2_COD    = '"+cProd+"' "
cQuery += " AND B2_QATU > 0 "
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "

If Select("TRBSB2")<>0
	DbSelectArea("TRBSB2")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSB2", .F., .T.)

return(TRBSB2->SALDO)

/*
+------------------+---------------------------------------------------------+
!Nome              ! Saldos                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Calcula saldo atual do produto de todas empresas e      !
!                  ! filiais.                                                !
+------------------+---------------------------------------------------------+
!Parametros        ! cProd    --> código do produto                          !
!                  ! cEmpFil  --> código da empresa e filial                 !
!                  ! cEmpOld  --> código da empresa origem                   !
!                  ! cFilOld  --> código da filial origem                    !
!                  ! cCnpjOri --> cnpj da  filial origem                     !
+------------------+---------------------------------------------------------+
*/
Static Function Saldos(cProd,cEmpFil,cNomeEmp, cNomeFil, cCnpjOri)

Local lMark := .f.
Local cM0_codigo := substr(cEmpFil,1,2)
Local cM0_codFil := substr(cEmpFil,3,2)

cQuery := " SELECT B2_COD, B1_DESC, B2_LOCAL, SUM(B2_CM1) CM1,sum(B2_QATU-B2_QEMP-B2_RESERVA) SALDO"
cQuery += " FROM SB2" + cM0_codigo + "0 SB2, "
cQuery +=            RetSqlName("SB1") + " SB1 "
cQuery += " WHERE B2_FILIAL = '" + cM0_codFil + "' "
cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += " AND B2_COD    = '"+cProd+"' "
cQuery += " AND B2_QATU > 0 "
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY B2_COD, B1_DESC, B2_LOCAL"

If Select("TRBSB2")<>0
	DbSelectArea("TRBSB2")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSB2", .F., .T.)

While !TRBSB2->(EOF())
	If TRBSB2->CM1 > 0
		AADD(aProdSld,{lMark,cNomeEmp, cNomeFil, cProd, TRBSB2->B1_DESC, TRBSB2->SALDO, 0,cM0_codigo+cM0_codFil, cCnpjOri, TRBSB2->B2_LOCAL })
	ENDiF
	TRBSB2->(DbSkip())
End

return()


/*
+------------------+---------------------------------------------------------+
!Nome              ! GravaTransf                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Gracva dados da transferencia.                          !
+------------------+---------------------------------------------------------+
!Parametros        !                                                         !
+------------------+---------------------------------------------------------+
*/
Static Function GravaTransf()
Local ni
Local cProdTr    //produto que será transferido
Local nQtdTr     //quantidade que será tranferido
Local cCnpjOri   //CNPJ do origem
Local cEmpfilTr  //emrpesa/filial origem

SZ1->(DbSetOrder(1))

For ni := 1 to Len(aProdSld)
	If aProdSld[ni,1]
		cProdTr   := aProdSld[ni,04]
		nQtdTr    := aProdSld[ni,07]
		cCnpjOri  := aProdSld[ni,09]
		cEmpfilTr := aProdSld[ni,08]
		cLocalEst := aProdSld[ni,10]
		cItPV := TRXC9->C6_ITEM
		If !SZ1->(DbSeek(xFilial("SZ1")+TRXC9->C6_NUM+cItPV+cProdTr))
			RecLock("SZ1",.T.)
			SZ1->Z1_FILIAL  := xFilial("SZ1")
			SZ1->Z1_PEDIDO  := TRXC9->C6_NUM
			SZ1->Z1_ITEMPV  := cItPV
			SZ1->Z1_PRODUTO := cProdTr
			SZ1->Z1_QUANT   := nQtdTr
			SZ1->Z1_LOCAL   := cLocalEst
			SZ1->Z1_ORIGEM  := cEmpfilTr
			SZ1->Z1_STATUS  := 'TR1'
			SZ1->Z1_CNPJDES := ccNPJDes   //clietne
			SZ1->Z1_CNPJORI := cCnpjOri   //fornecedor
			SZ1->Z1_LOG     := "TRANSFERENCIA INICIADA..."  + CHR(13)+CHR(10)
			SZ1->Z1_REDUC   := nReduc
			MsUnLock()
			lTransf := .T.
		EndIf
	EndIf
Next
oDlgCons:End()

Return()


/*
+------------------+---------------------------------------------------------+
!Nome              ! V_TRANSF                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Verifica se existe transferencia.                       !
!                  ! Usado no PE Mta410.                                     !
+------------------+---------------------------------------------------------+
!Parametros        !                                                         !
+------------------+---------------------------------------------------------+
*/

User function V_TRANSF()
//Local cC5Num := TRXC9->C6_NUM

Local cPV := ""
                    
DbSelectArea("SZ1")
set deleted off

ProcRegua(0)
IncProc("Efetuando as transferências....")
CONOUT("INICIA TRANSFERENCIA...")
//processa as transferencias
cQuery := " SELECT * "
cQuery += " FROM " + RetSqlName("SZ1") + " SZ1 "
cQuery += " WHERE Z1_FILIAL = '" + xFilial("SZ1") + "' "
//cQuery += " AND Z1_PEDIDO  = '"+cC5Num+"' "
cQuery += " AND Z1_STATUS  = 'TR1' "
cQuery += " AND SZ1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY Z1_PEDIDO,Z1_ORIGEM "

If Select("TRBSZ1")<>0
	DbSelectArea("TRBSZ1")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSZ1", .F., .T.)

While !TRBSZ1->(EOF())
	cOrigem := TRBSZ1->Z1_ORIGEM
	cNumPV := TRBSZ1->Z1_PEDIDO
	aProdTransf :={}
	If Empty(cPV)
		cPV := TRBSZ1->Z1_PEDIDO
	Else
		cPV += "/" + TRBSZ1->Z1_PEDIDO
	EndIf
	While !TRBSZ1->(EOF()) .and. cNumPV == TRBSZ1->Z1_PEDIDO .and. cOrigem == TRBSZ1->Z1_ORIGEM
		AADD(aProdTransf,{TRBSZ1->Z1_PRODUTO, TRBSZ1->Z1_QUANT, TRBSZ1->Z1_ORIGEM,TRBSZ1->Z1_CNPJDES, TRBSZ1->Z1_CNPJORI,TRBSZ1->Z1_PEDIDO, TRBSZ1->Z1_LOCAL, TRBSZ1->Z1_REDUC })
		TRBSZ1->(DbSkip())
	End
	TransfProd(aProdTransf, __cUserID)
End

//verifica se houve erro
cQuery := " SELECT *, R_E_C_N_O_ REC "
cQuery += " FROM " + RetSqlName("SZ1") + " SZ1 "
cQuery += " WHERE Z1_FILIAL = '" + xFilial("SZ1") + "' "
//cQuery += " AND Z1_PEDIDO  = '"+cC5Num+"' "
cQuery += " AND Z1_PEDIDO  IN  " + FormatIn(cPV, "/")
cQuery += " AND SUBSTRING(Z1_STATUS ,1,2)= 'ER' "

// ********
//********* NÃO FILTRA OS DELETADOS
//cQuery += " AND SZ1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY Z1_ORIGEM "

If Select("TRBSZ1")<>0
	DbSelectArea("TRBSZ1")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSZ1", .F., .T.)

While !TRbSZ1->(EOF())
	SZ1->(DbGoTo(TRBSZ1->REC))
	//estorna liberacao do pedido se ocorrer erro na inclusao do pedido
	If SZ1->Z1_STATUS = "ER1"
		EstornaPV(SZ1->Z1_PEDIDO)
	EndIf
	
	MsgAlert ("Ocorreu falha na Transferência."  + CHR(13)+CHR(10) +;
	"Log: " + SZ1->Z1_LOG )
	MostaFalha()
	
	//*****************	EnviaAviso(SZ1->Z1_LOG)
	
	TRBSZ1->(DbSkip())
End

DbSelectArea("SZ1")
set deleted on

Return()

/*
+------------------+---------------------------------------------------------+
!Nome              ! EstornaPV                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Estorno de pedido quando houver fallha.                 !
+------------------+---------------------------------------------------------+
!Parametros        !cPedido  - numero do pedido                              !
+------------------+---------------------------------------------------------+
*/
Static Function EstornaPV(cPedido)

Local aCabec := {}
Local aItens := {}
Local aLinha

cQuery := " SELECT * "
cQuery += " FROM  " + RetSqlName("SC5") + " SC5, "
cQuery +=             RetSqlName("SC6") + " SC6 "
cQuery += " WHERE C5_FILIAL  = '" + xFilial("SC5") + "' "
cQuery += " AND C6_FILIAL = '" + xFilial("SC6") + "' "
cQuery += " AND C5_NUM   = '"+cPedido+"' "
cQuery += " AND C5_NUM   = C6_NUM "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "


If Select("TRBSC5")<>0
	DbSelectArea("TRBSC5")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSC5", .F., .T.)

aadd(aCabec,{"C5_NUM"    ,TRBSC5->C5_NUM,Nil})
aadd(aCabec,{"C5_TIPO"   ,TRBSC5->C5_TIPO,Nil})
aadd(aCabec,{"C5_CLIENTE",TRBSC5->C5_CLIENTE,Nil})
aadd(aCabec,{"C5_LOJACLI",TRBSC5->C5_LOJACLI,Nil})
aadd(aCabec,{"C5_CLIENT" ,TRBSC5->C5_CLIENT,Nil})
aadd(aCabec,{"C5_LOJAENT",TRBSC5->C5_LOJAENT,Nil})
aadd(aCabec,{"C5_TIPOCLI",TRBSC5->C5_TIPOCLI,Nil})
aadd(aCabec,{"C5_TPFRETE",TRBSC5->C5_TPFRETE,Nil})
aadd(aCabec,{"C5_CONDPAG",TRBSC5->C5_CONDPAG,Nil})
aadd(aCabec,{"C5_USER"   ,TRBSC5->C5_USER,Nil})

conout(varinfo("aCabec",aCabec))

While !TRBSC5->(eof())
	
	SB1->(DbSeek(xFilial("SB1")+TRBSC5->C6_PRODUTO))
	SB2->(DbSeek(xFilial("SB2")+TRBSC5->C6_PRODUTO))
	SF4->(DbSeek(xFilial("SF4")+TRBSC5->C6_TES))
	
	aLinha := {}
	aadd(aLinha,{"C6_ITEM"   ,TRBSC5->C6_ITEM,Nil})
	aadd(aLinha,{"C6_PRODUTO",TRBSC5->C6_PRODUTO,Nil})
	aadd(aLinha,{"C6_QTDVEN" ,TRBSC5->C6_QTDVEN,Nil})
	aadd(aLinha,{"C6_OPER"   ,"",Nil})
	aadd(aLinha,{"C6_PRCVEN" ,TRBSC5->C6_PRCVEN,Nil})
	aadd(aLinha,{"C6_XPRECPC",TRBSC5->C6_XPRECPC,Nil})
	aadd(aLinha,{"C6_VALOR"  ,TRBSC5->C6_VALOR,Nil})
	aadd(aLinha,{"C6_PRUNIT" ,TRBSC5->C6_PRUNIT,Nil})
	aadd(aLinha,{"C6_TES"    ,TRBSC5->C6_TES,Nil})
	aadd(aLinha,{"C6_LOCAL"  ,TRBSC5->C6_LOCAL,Nil})
	
	aadd(aItens,aLinha)
	
	TRBSC5->(DbSkip())
End

conout(varinfo("aItens",aItens))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Teste de alteracao                                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MATA410(aCabec,aItens,4)

return()


/*
+------------------+---------------------------------------------------------+
!Nome              ! M410ABN                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Se o pedido nao for confirmado as trasnferencias sao    !
!                  ! canceladas tambem.                                      !
+------------------+---------------------------------------------------------+
!Parametros        !                                                         !
+------------------+---------------------------------------------------------+
*/
/*
User Function M410ABN()

cQuery := " SELECT R_E_C_N_O_ REC "
cQuery += " FROM " + RetSqlName("SZ1") + " SZ1 "
cQuery += " WHERE Z1_FILIAL = '" + xFilial("SZ1") + "' "
cQuery += " AND Z1_PEDIDO  = '"+TRXC9->C6_NUM+"' "
cQuery += " AND SZ1.D_E_L_E_T_ <> '*' "

If Select("TRBSZ1")<>0
DbSelectArea("TRBSZ1")
DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSZ1", .F., .T.)

While !TRBSZ1->(EOF())
SZ1->(DbGoTo(TRBSZ1->REC))
cLog := SZ1->Z1_LOG + "PEDIDO FOI CANCELADO." + CHR(13)+CHR(10)
RecLock("SZ1",.f.)
SZ1->Z1_LOG     := cLog
SZ1->Z1_STATUS := "CAN"
SZ1->(DbDelete())
MsUnLock()
TRBSZ1->(DbSkip())
End
Return()
*/
/*
+------------------+---------------------------------------------------------+
!Nome              ! TransfProd                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Incia JOB de transferencia (saida)                      !
+------------------+---------------------------------------------------------+
!Parametros         ! aProdTransf  --> Dados da transferencia                !
!                  !   [1] -  produto                                        !
!                  !   [2] -  quantidade                                     !
!                  !   [3] -  empresa/filial origem                          !
!                  !   [4] -  cnpj destino                                   !
!                  !   [5] -  cnpj Origem                                    !
!                  !   [6] -  pedido origem                                  !
!                  !   [7] -  Local                                          !
!                  !   [8] -  % reducao do Custo                             !
!                  !  cUserID - ID do usuário                                !
+------------------+---------------------------------------------------------+
*/
Static Function TransfProd(aProdTransf, cUserID)
Local aTransf := aProdTransf
StartJob("U_JTRANSF",GetEnvServer(), .T.,aTransf, cEmpAnt, cFilAnt, cUserId)

Return(.T.)


/*
+------------------+---------------------------------------------------------+
!Nome              ! JTransf                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Job que efetua a transferencia.                         !
!                  ! Gera Pedido de vendas e Documento de Saida.             !
+------------------+---------------------------------------------------------+
!Parametros         ! aProdTr --> Dados da transferencia                      !
!                  !   [1] -  produto                                        !
!                  !   [2] -  quantidade                                     !
!                  !   [3] -  empresa/filial origem                          !
!                  !   [4] -  cnpj destino                                   !
!                  !   [5] -  cnpj Origem                                    !
!                  !   [6] -  pedido Origem                                  !
!                  !   [7] -  Local                                          !
!                  !   [8] -  % reducao do Custo                             !
!                  ! cEmpEnt --> Empersa que ocorrera a aentrada             !
!                  ! CFilEnt --> filial que ocorrera a aentrada              !
!                  !  cUserID - ID do usuário                                !
+------------------+---------------------------------------------------------+
*/
User Function JTransf(aProdTr,cEmpEnt,CFilEnt, cUserId)

Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX     := 1
Local nY     := 0
Local cDoc   := ""
Local lOk    := .T.
Local cNewEmp
Local cNewFil
Local cProdTr
Local nQtdtr
Local ccNPJ
Local nI
Local cPvOrig

Local aPvlNfs    := {}
Local aBloqueio  := {{"","","","","","","",""}}
Local aNotas     := {}
Local aParam460  := Array(30)
Local aNotaFeita := {}
Local nTamSD2
Local cCondSE4
Local cTSSF4
Local cTpOpers

PRIVATE lMsErroAuto := .F.

CONOUT("INICIA JOB  JTransf...")

cNewEmp := substr(aProdTr[1,3],1,2)
cNewFil := substr(aProdTr[1,3],3,2)

RpcClearEnv()
RpcSetType( 3 )
RpcSetEnv( cNewEmp, cNewFil,"Transferencia","transf@2014","FAT")

cCondSE4   := GetNewPar("KA_CPTRNSF","001")   //Condicao de pagamento utilizada na transferencia
//cTSSF4     := GetNewPar("KA_TSTRNSF","543")   //tipo de saida  utilizada na transferencia

//se empresas diferentes busca Tipo Operacao do "KA_TPOPSAI"
If cNewEmp <> cEmpEnt
	cTpOpers   := GetNewPar("KA_TPOPSAI","01")    //tipo de operacao saida  utilizada na transferencia
	//se forem empresas iguais, usa tipo operacao "06"
Else
	cTpOpers := "06"
EndIf

nTamD2_DOC	  := TamSX3("D2_DOC")[1]
nTamD2_SERIE  := TamSX3("D2_SERIE")[1]

SX5->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SB2->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SA1->(dbSetOrder(3))   //filial + cnpj
SA2->(dbSetOrder(3))   //filial + cnpj
Sx6->(dbSetOrder(1))
SF2->(dbSetOrder(1))

cSerie  := GetNewPar("KA_SERIETR","1")  //SERIE DA NF DE TRANSFERENCIA
cNumero := ""

conout(varinfo("aProdTr",aProdTr))

CONOUT("cNumero: " + cNumero)
CONOUT("cSerie: " + cSerie)

If Pergunte("MT460A",.T.)
	For nx := 1 to 30
		aParam460[nx] := &("mv_par"+StrZero(nx,2))
	Next nx
EndIf

ccNPJ    := aProdTr[1,4] //CLIENTE
ccNPJFor := aProdTr[1,5] //fornecedor
cPvOrig  := aProdTr[1,6] //pedido origem
cAlmox   := aProdTr[1,7]

SE4->(DbSeek(xFilial("SE4")+cCondSE4))
SA1->(DbSeek(xFilial("SA1")+ccNPJ))

cDoc := GetSxeNum("SC5","C5_NUM")
aCabec := {}

aadd(aCabec,{"C5_NUM"   ,cDoc,Nil})
aadd(aCabec,{"C5_TIPO" ,"N",Nil})
aadd(aCabec,{"C5_CLIENTE",SA1->A1_COD,Nil})
aadd(aCabec,{"C5_LOJACLI",SA1->A1_LOJA,Nil})
aadd(aCabec,{"C5_CLIENT" ,SA1->A1_COD,Nil})
aadd(aCabec,{"C5_LOJAENT",SA1->A1_LOJA,Nil})
aadd(aCabec,{"C5_TIPOCLI","R",Nil})             //verificar
aadd(aCabec,{"C5_TPFRETE","F",Nil})
aadd(aCabec,{"C5_CONDPAG",SE4->E4_CODIGO,Nil})
aadd(aCabec,{"C5_USER",UsrRetName(cUserId),Nil})

conout(varinfo("aCabec",aCabec))

aItens := {}
For ni := 1 to len(aProdTr)
	
	cProdTr := aProdTr[ni,1]
	nQtdTr  := aProdTr[ni,2]
	nPRed   := aProdTr[ni,8]
	cTSSF4 := MaTesInt(2,cTpOpers,SA1->A1_COD,SA1->A1_LOJA,"C",cProdTr)
	
	SB1->(DbSeek(xFilial("SB1")+cProdTr))
	SB2->(DbSeek(xFilial("SB2")+cProdTr))
	SF4->(DbSeek(xFilial("SF4")+cTSSF4))        //verificar
	
	aLinha := {}
	aadd(aLinha,{"C6_ITEM"   ,StrZero(ni,2),Nil})
	aadd(aLinha,{"C6_PRODUTO",SB1->B1_COD,Nil})
	aadd(aLinha,{"C6_QTDVEN" ,nQtdTr,Nil})
	aadd(aLinha,{"C6_OPER"   ,cTpOpers,Nil})                //verificar
	aadd(aLinha,{"C6_PRCVEN" ,SB2->B2_CM1*nPRed/100,Nil})
	aadd(aLinha,{"C6_XPRECPC",SB2->B2_CM1*nPRed/100,Nil})
	aadd(aLinha,{"C6_VALOR"  ,round(nQtdTr*SB2->B2_CM1*nPRed/100,2),Nil})
	aadd(aLinha,{"C6_PRUNIT" ,SB2->B2_CM1*nPRed/100,Nil})
	aadd(aLinha,{"C6_TES"    ,SF4->F4_CODIGO,Nil})
	aadd(aLinha,{"C6_LOCAL"  ,CAlmox,Nil})
	
	aadd(aItens,aLinha)
	
Next

conout(varinfo("aItens",aItens))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Teste de Inclusao                                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MATA410(aCabec,aItens,3)

//Log na inclusão do pedido de transferencia
If lMSErroAuto
	cz1_LOG  := "Falha na inclusão do pedido " + cDoc + "." + CHR(13)+CHR(10) + ;
	MostraErro() +  CHR(13)+CHR(10)
	CONOUT("ERRO: " + MostraErro())
	cSt := "ER1"
	lCancTr := .T.
Else
	cz1_LOG  :=  "Sucesso na inclusão do pedido " + cDoc + "." +  CHR(13)+CHR(10)
	cSt := "TR2"
	lCancTr := .F.
EndIf

aLog := {cEmpEnt,cFilEnt,cPvOrig,aProdTr[1,3],cz1_LOG}
StartJob("U_JLOG",GetEnvServer(), .T.,aLog, "PV", cDoc, cSt, lCancTr)

If !lMSErroAuto
	
	// Confirma SX8
	//	ConfirmSX8()
	
	// Liberacao de pedido
	Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
	// Checa itens liberados
	Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
	// Caso tenha itens liberados manda faturar
	If Empty(aBloqueio) .And. !Empty(aPvlNfs)
		nItemNf  := a460NumIt(cSerie)
		aadd(aNotas,{})
		// Efetua as quebras de acordo com o numero de itens
		For nX := 1 To Len(aPvlNfs)
			If Len(aNotas[Len(aNotas)])>=nItemNf
				aadd(aNotas,{})
			EndIf
			aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
		Next nX
		// Gera as notas de acordo com a quebra
		For nX := 1 To Len(aNotas)
			cNotaFeita:=MaPvlNfs(aNotas[nX],cSerie,aParam460[01]==1,aParam460[02]==1,aParam460[03]==1,aParam460[04]==1,aParam460[05]==1,aParam460[07],aParam460[08],aParam460[15]==1,aParam460[16]==2)
			AADD(aNotaFeita,{PADR(cNotaFeita,nTamD2_DOC),PADR(cSerie,nTamD2_SERIE),cEmpAnt, xFilial("SD2"),cEmpEnt,cFilEnt, ccNPJFor,cPvOrig,.f.})
			
			//Log na geracao da NF de transferencia
			
			cz1_LOG := "Geracao de NF/Serie: " + PADR(cNotaFeita,nTamD2_DOC) + " / " + cSerie +  CHR(13)+CHR(10)
			cSt := "TR3"
			
			aLog := {cEmpEnt,cFilEnt,cPvOrig,aProdTr[1,3],cz1_LOG}
			StartJob("U_JLOG",GetEnvServer(), .T.,aLog, "NF",  PADR(cNotaFeita,nTamD2_DOC)+cSerie, cSt,.F.)
			
		Next nX
		
		conout(varinfo("aNotaFeita",aNotaFeita))
		conout("ENTRADA: " + cEmpEnt+cFilEnt)
		
		//transmite NF
		For nh := 1 to Len(aNotaFeita)
			
			conout("SAIDA: " + cNewEmp+cNewFil)
			
			//Log na transmissao de NF de transferencia
			DbSelectArea("SF2")
			AutoNfeEnv(cEmpAnt,cFilAnt,"1","1",aNotaFeita[nh,2],aNotaFeita[nh,1],aNotaFeita[nh,1])
			
			If SF2->F2_FIMP <> 'T'
				cLog := "Falha na transmissão da NF: "
				lret := .F.
				cSt := "ER2"
			Else
				cLog := "Sucesso na transmissão da NF: "
				lret := .T.
				cSt := "TR4"
			EndIf
			
			cz1_LOG := clog + PADR(cNotaFeita,nTamD2_DOC) + " / " + cSerie +  CHR(13)+CHR(10)
			
			aNotaFeita[nh,9] := lRet
			
			aLog := {cEmpEnt,cFilEnt,cPvOrig,aProdTr[1,3],cz1_LOG}
			StartJob("U_JLOG",GetEnvServer(), .T.,aLog,"","",cSt,.F.)
			
		Next
		
		RecProd(aNotaFeita)
		
	EndIf
	
EndIf

Return()


/*
+------------------+---------------------------------------------------------+
!Nome              ! RecProd                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Incia JOB de transferencia (entrada)                    !
+------------------+---------------------------------------------------------+
!Parametros         ! aProdRec  --> Dados da transferencia                    !
!                  !   [1] -  Numero da NF                                   !
!                  !   [2] -  Serie da NF                                    !
!                  !   [3] -  Empresa de origem da transferencia             !
!                  !   [4] -  Filial de origem da transferencia              !
!                  !   [5] -  Empersa que ocorrera a aentrada                !
!                  !   [6] -  filial que ocorrera a aentrada                 !
!                  !   [7] -  cnpj do fornecedor                             !
!                  !   [8] -  numero do pedido                               !
+------------------+---------------------------------------------------------+
*/

Static Function RecProd(aProdRec)
Local aRec := aProdRec
StartJob("U_JrECEBE",GetEnvServer(), .T.,aRec)
Return(.T.)


/*
+------------------+---------------------------------------------------------+
!Nome              ! JRecebe                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Job que efetua a transferencia.                         !
!                  ! Gera nota de entrada.                                   !
+------------------+---------------------------------------------------------+
!Parametros         ! aProdRec  --> Dados da transferencia                    !
!                  !   [1] -  Numero da NF                                   !
!                  !   [2] -  Serie da NF                                    !
!                  !   [3] -  Empresa  de origem da transferencia            !
!                  !   [4] -  Filial de origem da transferencia              !
!                  !   [5] -  Empersa que ocorrera a aentrada                !
!                  !   [6] -  filial que ocorrera a aentrada                 !
!                  !   [7] -  cnpj do fornecedor                             !
!                  !   [8] -  numero do pedido                               !
+------------------+---------------------------------------------------------+
*/
User Function JRecebe(aProdRec)
Local cEmpRec  := aProdRec[1,5]
Local cFilRec  := aProdRec[1,6]
local ccNPJFor := aProdRec[1,7]

Local cCondSE4
Local cTESF4
Local cTpOpers

Local cEmpSai  := aProdRec[1,3]

RpcClearEnv()
RpcSetType( 3 )
RpcSetEnv( cEmpRec, cFilRec,"Transferencia","transf@2014","COM")

SA2->(dbSetOrder(3))   //filial + cnpj
SF1->(dbSetOrder(1))
SD1->(dbSetOrder(1))

cCondSE4   := GetNewPar("KA_CPTRNSF","001")   //Condicao de pagamento utilizada na transferencia
//cTESF4     := GetNewPar("KA_TETRNSF","001")   //tipo de entrada  utilizada na transferencia

//se empresas direntes busca tipo opercado do "KA_TPOPENT"
If cEmpRec <> cEmpSai
	cTpOperE   := GetNewPar("KA_TPOPENT","51")   //tipo de operacao entrada  utilizada na transferencia
	//se forem empresas iguais, usa tipo operacao "06"
Else
	cTpOperE := "06"
EndIf

// Varre notas fiscais de saida geradas para gerar notas fiscais de entrada
For nx:=1 to Len(aProdRec)
	If aProdRec[nx,9]
		cQuery := " SELECT * "
		cQuery += " FROM SD2" + aProdRec[NX,3] + "0 SD2 "
		cQuery += " WHERE D2_FILIAL = '" + aProdRec[NX,4] + "' "
		cQuery += " AND D2_DOC    = '"+aProdRec[NX,1]+"' "
		cQuery += " AND D2_SERIE  = '"+aProdRec[NX,2]+"' "
		cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
		
		If Select("TRBSD2")<>0
			DbSelectArea("TRBSD2")
			DbCloseArea()
		Endif
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSD2", .F., .T.)
		
		SA2->(DbSeek(xFilial("SA2")+ccNPJFor))
		
		aCabec   := {}
		aadd(aCabec,{"F1_TIPO"   	,"N"})
		aadd(aCabec,{"F1_FORMUL" 	,"N"})
		aadd(aCabec,{"F1_DOC"    	,aProdRec[nx,1]})
		aadd(aCabec,{"F1_SERIE"  	,aProdRec[nx,2]})
		aadd(aCabec,{"F1_EMISSAO"	,dDataBase})
		aadd(aCabec,{"F1_FORNECE"	,SA2->A2_COD})
		aadd(aCabec,{"F1_LOJA"   	,SA2->A2_LOJA})
		aadd(aCabec,{"F1_ESPECIE"	,"NF"})      //VERIFICAR
		aadd(aCabec,{"F1_COND"		,cCondSE4})     //VERIFICAR
		aadd(aCabec,{"F1_EST"		,SA2->A2_EST})
		nItem := 1
		
		conout(varinfo("aCabec (SF1)",aCabec))
		
		aItens := {}
		While !TRBSD2->(EOF())
			cTESF4 := MaTesInt(1,cTpOperE,SA2->A2_COD,SA2->A2_LOJA,"F",TRBSD2->D2_COD)
			
			aLinha := {}
			SB1->(DbSeek(xFilial("SB1")+TRBSD2->D2_COD))
			aadd(aLinha,{"D1_ITEM"	,Strzero(nItem,4),Nil})
			aadd(aLinha,{"D1_COD"	,TRBSD2->D2_COD,Nil})
			aadd(aLinha,{"D1_QUANT"	,TRBSD2->D2_QUANT,Nil})
			aadd(aLinha,{"D1_VUNIT"	,TRBSD2->D2_PRCVEN,Nil})
			aadd(aLinha,{"D1_TOTAL"	,TRBSD2->D2_TOTAL,Nil})
			aadd(aLinha,{"D1_LOCAL"	,SB1->B1_LOCPAD,Nil})
			aadd(aLinha,{"D1_CC"	,"000000001",Nil})         //VERIFICAR
			
			aadd(aLinha,{"D1_OPER",cTpOperE,Nil})
			aadd(aLinha,{"D1_TES",cTESF4,Nil})
			// Checa se utiliza rastreabilidade
			If Rastro(TRBSD2->D2_COD,"L")
				aadd(aLinha,{"D1_LOTECTL",TRBSD2->D2_LOTECTL,Nil})
				aadd(aLinha,{"D1_DTVALID",TRBSD2->D2_DTVALID,Nil})
			EndIf
			If Rastro(TRBSD2->D2_COD,"S")
				aadd(aLinha,{"D1_LOTECTL",TRBSD2->D2_LOTECTL,Nil})
				aadd(aLinha,{"D1_NUMLOTE",TRBSD2->D2_NUMLOTE,Nil})
				aadd(aLinha,{"D1_DTVALID",TRBSD2->D2_DTVALID,Nil})
			EndIf
			
			aadd(aItens,aLinha)
			conout(varinfo("aItens (SD1)",aItens))
			nItem ++
			TRBSD2->(DbSkip())
		End
		lMsErroAuto :=.F.
		// Inclui nota de entrada
		MATA103(aCabec,aItens,3)
		
		//Log no recebimento da NF de transferencia
		If lMsErroAuto
			cz1_LOG   := "Falha no recebimento da NF/Serie: " + aProdRec[nx,1] + " / " + aProdRec[nx,2] +  CHR(13)+CHR(10) + ;
			MostraErro() + CHR(13)+CHR(10)
			CONOUT("ERRO NF ENTRADA: " + MostraErro())
			cSt := "ER3"
		Else
			cz1_LOG   := "Sucesso no recebimento da NF/Serie: " + aProdRec[nx,1] + " / " + aProdRec[nx,2] +  CHR(13)+CHR(10)
			cSt := "TR5"
		EndIf
		
		aLog := {cEmpRec,cFilRec,aProdRec[NX,8],aProdRec[NX,3]+aProdRec[NX,4],cz1_LOG}
		StartJob("U_JLOG",GetEnvServer(), .T.,aLog,"","",cSt,.F.)
	EndIf
Next

conout("FIM")
Return()

/*
+------------------+---------------------------------------------------------+
!Nome              ! JLOG                                                    !
+------------------+---------------------------------------------------------+
!Descricao         ! Job para gravar as ocorrencias.                         !
+------------------+---------------------------------------------------------+
!Parametros        ! alog  --> Dados do log                                  !
!                  !   [1] -  Emrpesa                                        !
!                  !   [2] -  Filial                                         !
!                  !   [3] -  numero do pedido de vendas                     !
!                  !   [4] -  empresa/filial origem                          !
!                  !   [5] -  log                                            !
!                  !  cTp  -  PV ou NF                                       !
!                  !  cSt  -  Status                                         !
!                  !          ER1 - Falha na inclusão do pedido              !
!                  !          ER2 - Falha na transmissão da NF               !
!                  !          ER3 - Falha no recebimento da NF               !
!                  !                                                         !
!                  !          TR1 - TRANSFERENCIA INICIADA                   !
!                  !          TR2 - Sucesso na inclusão do pedido            !
!                  !          TR3 - Geracao de NF                            !
!                  !          TR4 - Sucesso na transmissão da NF             !
!                  !          TR5 - Sucesso no recebimento da NF             !
!                  !   lCancTr - .T. cancela transferencia             !
+------------------+---------------------------------------------------------+
*/

User Function JLOG(alog, cTp, cNum, cSt,lCancTr)
Local cEmpLog := alog[1]
Local cFilLog := alog[2]
Local cPv     := alog[3]
Local cOrigem := alog[4]
Local cLog    := alog[5]

conout(varinfo("alog",alog))

RpcClearEnv()
RpcSetType( 3 )
RpcSetEnv( cEmpLog, cFilLog,"Transferencia","transf@2014","FAT")

SZ1->(dbSetOrder(1))

cQuery := " SELECT R_E_C_N_O_ REC "
cQuery += " FROM SZ1" +cEmpLog  + "0 SZ1 "
cQuery += " WHERE Z1_FILIAL = '" + cFilLog + "' "
cQuery += " AND Z1_PEDIDO  = '"+cPv+"' "
cQuery += " AND Z1_ORIGEM  = '"+cOrigem+"' "
cQuery += " AND SZ1.D_E_L_E_T_ <> '*' "

If Select("TRBSZ1")<>0
	DbSelectArea("TRBSZ1")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSZ1", .F., .T.)

conout("cQuery: " + cQuery)

While !TRBSz1->(EOF())
	SZ1->(DbGoto(TRBSZ1->REC))
	conout("SZ1->Z1_LOG: " + SZ1->Z1_LOG)
	conout("cLog: " + cLog)
	conout("cSt: " + cSt)
	cLog2 := SZ1->Z1_LOG + cLog
	RecLock("SZ1",.f.)
	SZ1->Z1_LOG := cLog2
	If cTp == "PV"
		SZ1->Z1_PVTRANS := cNum
	ElseIf cTp == "NF"
		SZ1->Z1_NFTRANS := cNum
	EndIf
	SZ1->Z1_STATUS := cSt
	If lCancTr
		SZ1->(DbDelete())
	EndIf
	
	MsUnLock()
	conout("SZ1->Z1_LOG: " + SZ1->Z1_LOG)
	TRBSZ1->(DbSkip())
End

Return()


/*
+------------------+---------------------------------------------------------+
!Nome              ! MostaFalha                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Apresenta as falhas ocorridas.                          !
+------------------+---------------------------------------------------------+
*/
Static Function MostaFalha()
Local aFalha := {}
local oDlgFalha

Local oSim := LoadBitmap( GetResources(), "BR_VERDE" )
Local oNao := LoadBitmap( GetResources(), "BR_VERMELHO" )

Local oFont		:= TFont():New( "Arial",0,-12,,.T.,0,,700,.T.,.F.,,,,,, )

While !TRBSZ1->(EOF())
	If SUBSTR(TRBSZ1->Z1_STATUS ,1,2)= 'ER'
		lFalha := .T.
	Else
		lFalha := .F.
	EndIf
	
	nregSM0  := SM0->(RecNo())
	SM0->(DbSeek(TRBSZ1->Z1_ORIGEM))
	
	AADD(aFalha,{lFalha,TRBSZ1->Z1_PEDIDO, TRBSZ1->Z1_ITEMPV, ;
	TRBSZ1->Z1_PRODUTO, TRBSZ1->Z1_ORIGEM, TRBSZ1->Z1_PVTRANS, ;
	TRBSZ1->Z1_NFTRANS, TRBSZ1->REC, SM0->M0_NOME,SM0->M0_FILIAL})
	TRBSZ1->(DbSkip())
	SM0->(DbGoTo(nregSM0))
	
End

DEFINE MSDIALOG oDlgFalha TITLE "Falha na transferência" FROM 20, 0 TO 350, 630 Pixel

@ 130,015 BITMAP oBmp RESNAME "BR_VERMELHO"	SIZE 16,16 NOBORDER		PIXEL
@ 130,025 SAY 'Falha'  FONT oFont SIZE 100, 07 OF oDlgFalha PIXEL
@ 145,015 BITMAP oBmp RESNAME "BR_VERDE"	SIZE 16,16 NOBORDER		PIXEL
@ 145,025 SAY 'Sucesso'  FONT oFont SIZE 100, 07 OF oDlgFalha PIXEL

oBrwFalha := TCBrowse():New(010,010,300,100,,,,oDlgFalha,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oBrwFalha:AddColumn(TCColumn():New(" "           , {|| If(!aFalha[oBrwFalha:nAt,01],oSim,oNao) },,,,,,.T.,.F.,,,,.F., ) )
oBrwFalha:AddColumn(TCColumn():New("Pedido"      , {|| aFalha[oBrwFalha:nAt,02]},,,,, 25 ,.F.,.F.,,,,.F., ) )
oBrwFalha:AddColumn(TCColumn():New("item PV"     , {|| aFalha[oBrwFalha:nAt,03]},,,,, 10 ,.F.,.F.,,,,.F., ) )
oBrwFalha:AddColumn(TCColumn():New("Produto"     , {|| aFalha[oBrwFalha:nAt,04]},,,,, 25 ,.F.,.F.,,,,.F., ) )
oBrwFalha:AddColumn(TCColumn():New("Origem"      , {|| aFalha[oBrwFalha:nAt,05]},,,,, 15 ,.F.,.F.,,,,.F., ) )
oBrwFalha:AddColumn(TCColumn():New("Empresa"     , {|| aFalha[oBrwFalha:nAt,09]},,,,, 30 ,.F.,.F.,,,,.F., ) )
oBrwFalha:AddColumn(TCColumn():New("Filial"      , {|| aFalha[oBrwFalha:nAt,10]},,,,, 30 ,.F.,.F.,,,,.F., ) )
oBrwFalha:AddColumn(TCColumn():New("Ped.Transf." , {|| aFalha[oBrwFalha:nAt,06]},,,,, 25 ,.F.,.F.,,,,.F., ) )
oBrwFalha:AddColumn(TCColumn():New("NF. Transf." , {|| aFalha[oBrwFalha:nAt,07]},,,,, 25 ,.F.,.F.,,,,.F., ) )
oBrwFalha:SetArray(aFalha)

oBrwFalha:bWhen := { || Len(aFalha) > 0 }

oBrwFalha:bLDblClick   := {|| Vis_sz1(aFalha[oBrwFalha:nAt,08])  }

oBtnOk     := tButton():New(120,200,"Detalhe",oDlgFalha, {|| DetFalha(aFalha[oBrwFalha:nAt,08]) },40,12,,,,.T.,,,, { ||  },,)
oBtnCancel := tButton():New(120,250,"Fechar",oDlgFalha, {|| ::End() },40,12,,,,.T.,,,, { ||  },,)

ACTIVATE MSDIALOG oDlgFalha CENTERED


Return()

/*
+------------------+---------------------------------------------------------+
!Nome              ! DetFalha                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Apresenta detalhes da transferencia.                    !
+------------------+---------------------------------------------------------+
!Parametro         ! nReg - Registro da tabela SZ1.                          !
+------------------+---------------------------------------------------------+
*/
Static Function DetFalha(nreg)
sZ1->(DbGoTo(nReg))
ccadastro  := "Detalhe da Transferencias"
AxVisual("SZ1",nReg,2)
Return()


/*
+------------------+---------------------------------------------------------+
!Nome              ! EnviaAviso                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Envia aviso quando ocorre falha na transferencia.       !
+------------------+---------------------------------------------------------+
!Parametro         ! cLog - mensagem do Log                                  !
+------------------+---------------------------------------------------------+
*/
Static Function EnviaAviso(cLog)

Local cServer
Local cPassword
Local cAccount
Local cEnvia
Local cMail1

Local cAssunto
Local cLinha
Local cAviso

cAviso := StrTran(cLog, CHR(13)+CHR(10), "<br>")

cServer   := alltrim(GetMV("MV_RELSERV")) //servidor SMTP
cPassword := alltrim(GetMV("MV_RELPSW "))  //senha da conta de email
cAccount  := alltrim(GetMV("MV_RELACNT"))   //conta de email
cEnvia    := alltrim(GetMV("MV_RELFROM"))   //conta que envia
cRecebe   := alltrim(GetMV("KA_RECEBE"))  //conta que recebe


cAssunto := "Aviso de falha na transferencia."

cLinha := 'Ocorreu falha na Transferência. <br>'
cLinha += cAviso

lConectou := .f.
If !lConectou
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou
	MailAuth(cAccount, cPassword)
EndIf
nCont := 0
While !lConectou .and. nCont <=20
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou
	MailAuth(cAccount, cPassword)
	nCont ++
End

conout("lConectou: " )
conout(lConectou)

If lConectou
	SEND MAIL FROM cEnvia TO cRecebe SUBJECT cAssunto BODY cLinha FORMAT TEXT RESULT lSendOk
	If !lSendOk
		//		MostraErro()
		conout("Erro SEND MAIL: " + MostraErro())
	EndIf
	
Else
	//+-------------------------------------------------------------
	//¦Erro na conexao com o SMTP Server
	//+-------------------------------------------------------------
	//	MostraErro()
	conout("Erro CONNECT SMTP: " + MostraErro())
EndIf
If lConectou
	DISCONNECT SMTP SERVER
EndIf


Return()


/*
+------------------+---------------------------------------------------------+
!Nome              ! A410CONS                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! PE-PARA INCLUIR UM BOTAO NA ENCHOICE DO PEDIDO DE VENDAS!
+------------------+---------------------------------------------------------+
!Parametro         !                                                         !
+------------------+---------------------------------------------------------+
*/
/*
Deve retornar um array com a seguinte estrutura 
aButtons[x][3], x determina o numero de botões a incluir e só está limitado pelo espaço na tela, e cada botão tem a seguintes propriedades :
aButtons[x][1] = String com o nome do bitmap padrão incluido nas dll padrões do SIGA. 
OBS : Só podem ser usados os bitmaps padrão, qualquer tentativa de incluir novos bitmaps, pode ocasionar problemas na DLL.
aButtons[x][2] = Bloco de codigo com a função a executar (pode ser um execblock, função SIGA,etc.).
aButtons[x][3] = Texto a ser exibido quando o mouse é posicionado acima do bitmap.
*/
User Function A410CONS()
Local aArea		:= GetArea()
Local aButtons := {}
Local alConteudo := ARRAY(1,15)
Private aA_SC5_1 := SC5->(GetArea())

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array contendo as informacoes de montagem do botao que ira abrir uma tela mostrando os estoques disponiveis nas empresas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
aAdd(aButtons,{'S4WB005N',{|| Iif (Empty(GdFieldGet("C6_PRODUTO")), AVISO("Atenção", "Selecione um produto nos itens de produto.", {"&Voltar"}), AFAT003() )},"Sld.Estoque"})

If (M->C5_XGERASV == 'S') .And. (ValNFM())//Se o Pedido possui algum item da NF Mista
	//aAdd(aButtons,{'PLANNFMIS',{|| U_PLANFNFM()},"Plan Fin NF Mista"})
EndIf

RestArea(aArea)
Return aButtons

/*
+------------------+---------------------------------------------------------+
!Nome              ! AFAT003                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Tela de cosnulta de saldo em estoque.                   !
+------------------+---------------------------------------------------------+
!Parametro         !                                                         !
+------------------+---------------------------------------------------------+
*/

Static Function AFAT003()

Local aArea    := GetArea()
Local oSim     := LoadBitMap(GetResources(), "LBOK")
Local oNao     := LoadBitMap(GetResources(), "LBNO")

Local cUserOld
Local cPswOld

//salva ambiente atual
local cAmbinete := GetEnvServer()

Local oFont		:= TFont():New( "Arial",0,-16,,.T.,0,,700,.T.,.F.,,,,,, )
Local oFont2	:= TFont():New( "Arial",0,16,,.F.,0,,700,.T.,.F.,,,,,, )


Local nQtdDispo
Local nC6qtdVen

Private aEmpFil  := {}

//salva empresa e filial atual
Private cEmpOld  := cEmpAnt
Private cFilOld  := cFilAnt

Private oGet1
Private oGet2
Private oGet3
Private oGet4

Private oDlgCons
Private nQtdNeces
Private nSldNec
Private aProdSld  := {}
Private aCabec
Private cRetorno
Private cCnpjDes  //cliente

Private nReduc := 100

//NÃO EXECUTAR PARA AS FILIAIS 03, 04, 05 E 06 DA EMPRESA 04
If !cEmpAnt + cFilAnt $ "0403#0404#0405#0406#"
	nregSM0  := SM0->(RecNo())
	ccNPJDes := SM0->M0_CGC
	SM0->(DbGoTop())
	
	While !SM0->(EOF())
		//EXCLUIR AS FILIAIS 03, 04, 05 E 06 DA EMPRESA 04
		If !SM0->M0_CODIGO + SM0->M0_CODFIL $ "0403#0404#0405#0406#"
			//				If cEmpAnt <> SM0->M0_CODIGO .or.cFilAnt <> SM0->M0_CODFIL
			AADD(aEmpFil,{SM0->M0_CODIGO+SM0->M0_CODFIL, ALLTRIM(SM0->M0_NOME), ALLTRIM(SM0->M0_FILIAL), SM0->M0_CGC })
			//				EndIf
		EndIf
		SM0->(DbSkip())
	EndDO
	SM0->(DbGoTo(nregSM0))
	
	
	nQtdDispo := Saldo_Atu(GdFieldGet("C6_PRODUTO"))
	nC6qtdVen := GdFieldGet("C6_QTDVEN")
	nQtdNeces := nC6qtdVen - nQtdDispo
	nSldNec := nQtdNeces
	
	For ni :=  1 to Len(aEmpFil)
		Saldos(GdFieldGet("C6_PRODUTO"), aEmpFil[ni,1],aEmpFil[ni,2],aEmpFil[ni,3],aEmpFil[ni,4])
	Next
	
	DEFINE MSDIALOG oDlgCons TITLE "Consulta Estoque de Produtos" FROM 20, 0 TO 650, 1200 Pixel
	
	oGrpSld  := tGroup():New(005,005,275,570,"Estoque:",oDlgCons,CLR_HBLUE,,.T.)
	
	oBrwSld := TCBrowse():New(055,010,550,200,,,,oDlgCons,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	
	@ 020,010 SAY GdFieldGet("C6_PRODUTO") + ' - ' + GdFieldGet("C6_DESCRI")  FONT oFont  SIZE 200, 10 OF oDlgCons PIXEL
	/*
	@ 040,010 SAY '% Redução:'  SIZE 100, 10 OF oDlgCons PIXEL
	@ 040,060 MSGET oGet4 VAR nReduc  SIZE 060, 07 OF oDlgCons  PIXEL PICTURE '@E 999.99' valid (nReduc >0)
	
	@ 040,150 SAY 'Quant.do Pedido:'  SIZE 100, 10 OF oDlgCons PIXEL
	@ 040,200 MSGET oGet1 VAR nC6qtdVen SIZE 060, 10 OF oDlgCons  READONLY PIXEL PICTURE '@E 999,999,999.9999'
	
	@ 040,290 SAY 'Qtd. Disponivel:' SIZE 100, 10 OF oDlgCons PIXEL
	@ 040,330 MSGET oGet2 VAR nQtdDispo SIZE 060, 10 OF oDlgCons  READONLY PIXEL PICTURE '@E 999,999,999.9999'
	
	@ 040,420 SAY 'Necessidade:' SIZE 100, 10 OF oDlgCons PIXEL
	@ 040,460 MSGET oGet3 VAR nSldNec SIZE 060, 10 OF oDlgCons  READONLY PIXEL PICTURE '@E 999,999,999.9999'
	*/
	//		oBrwSld:AddColumn(TCColumn():New(" "                 , {|| If(aProdSld[oBrwSld:nAt,01],oSim,oNao) },,,,,,.T.,.F.,,,,.F., ) )
	oBrwSld:AddColumn(TCColumn():New("Empresa"           , {|| aProdSld[oBrwSld:nAt,02]},,,,, 45 ,.F.,.F.,,,,.F., ) )
	oBrwSld:AddColumn(TCColumn():New("Filial"            , {|| aProdSld[oBrwSld:nAt,03]},,,,, 45 ,.F.,.F.,,,,.F., ) )
	oBrwSld:AddColumn(TCColumn():New("Produto"           , {|| aProdSld[oBrwSld:nAt,04]},,,,, 25 ,.F.,.F.,,,,.F., ) )
	oBrwSld:AddColumn(TCColumn():New("Descricao"         , {|| aProdSld[oBrwSld:nAt,05]},,,,, 30 ,.F.,.F.,,,,.F., ) )
	oBrwSld:AddColumn(TCColumn():New("Saldo disponivel"  , {|| aProdSld[oBrwSld:nAt,06]},"@E 99,999.99",,,, 70,.F.,.F.,,,,.F., ) )
	oBrwSld:AddColumn(TCColumn():New("Local"             , {|| aProdSld[oBrwSld:nAt,10]},,,,, 70 ,.F.,.F.,,,,.F., ) )
	//		oBrwSld:AddColumn(TCColumn():New("Qtd.Transferencia" , {|| aProdSld[oBrwSld:nAt,07]},"@E 99,999.99",,,, 70,.F.,.F.,,,,.F., ) )
	//		oBrwSld:AddColumn(TCColumn():New("Cod.Emp;/Filial"   , {|| aProdSld[oBrwSld:nAt,08]},,,,"CENTER", 70,.F.,.F.,,,,.F., ) )
	oBrwSld:SetArray(aProdSld)
	
	oBrwSld:bWhen := { || Len(aProdSld) > 0 }
	
	oBtnCancel := tButton():New(290,450,"Sair",oDlgCons, {|| ::End() },40,12,,,,.T.,,,, { ||  },,)
	
	ACTIVATE MSDIALOG oDlgCons CENTERED
	RestArea(aArea)
	
	
EndIf
Return()

/*
+------------------+---------------------------------------------------------+
!Nome              ! AFAT002B                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Consulta LOG das transferencias.                        !
+------------------+---------------------------------------------------------+
!Parametro         !                                                         !
+------------------+---------------------------------------------------------+
*/

User Function AFAT002B()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cCadastro := "Log das Transferencias"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta um aRotina proprio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
{"Visualizar","AxVisual",0,2} ,;
{"Legenda","U_Leadleg()",0,5}}

Private cString := "SZ1"

aCores :=   {{'substr(SZ1->Z1_STATUS,1,2)<>"ER" .AND. !DELETED()', 'ENABLE'},;
{'substr(SZ1->Z1_STATUS,1,2)="ER" .AND. !DELETED()', 'BR_VERMELHO' },;
{'DELETED()', 'BR_PRETO' }}


dbSelectArea("SZ1")
dbSetOrder(1)
set deleted off
dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,,,,,6,aCores)
set deleted On
Return()


User Function Leadleg()
aLegenda := {{"BR_VERDE", "sem falha"},;
{"BR_VERMELHO","Ocorreu falha"},;
{"BR_PRETO","Falha no pedido - deletedo"}}

BrwLegenda("Log transferencias","Legenda",aLegenda)
return()

//Valida o vinculo com NF Mista
Static Function ValNFM()
local cQr 		:= ""
local aArea 	:= GetArea()
local nCount 	:= 0
local lRet		:= .F.
local aCloAc	:= aClone(aCols) 
local nX		:= 1
local cProd		:= ""
local nPosCod  	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})  //Posição de C6_PRODUTO

For nX := 1	To Len(aCloAc)
	cProd += "'"+aCloAc[nX][nPosCod]+"',"
Next

If !Empty(cProd)
	
	cProd	:= Substr(cProd,1,(Len(cProd))-1)
	
	If Select("QVALNFM")<>0
		DbSelectArea("QVALNFM")
		QVALNFM->(DbCloseArea())
	Endif
	
	cQr := " SELECT B1_XGERASV,SA1.A1_XGERASV
	cQr += " FROM SB1010 SB1
	cQr += " INNER JOIN SA1010 SA1 ON SB1.B1_XGERASV = SA1.A1_XGERASV AND SA1.A1_COD = '"+M->C5_CLIENTE+"' AND SA1.A1_LOJA = '"+M->C5_LOJACLI+"'
	cQr += " WHERE SB1.D_E_L_E_T_ = ''
	cQr += "	AND SB1.B1_XGERASV = 'S'
	cQr += "	AND SB1.B1_COD IN ("+cProd+")
	
	// abre a query
	TcQuery cQr new alias "QVALNFM"
		
	QVALNFM->(DbGoTop())
	lRet := (!(QVALNFM->(EOF())))
	
	// retorna o resultado e fecha a query
	QVALNFM->(DbCloseArea())

EndIf

RestArea(aArea)
Return(lRet)