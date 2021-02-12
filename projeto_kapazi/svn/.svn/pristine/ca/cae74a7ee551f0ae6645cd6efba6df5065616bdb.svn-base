/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! FAT - Faturamento                                       !
+------------------+---------------------------------------------------------+
!Nome              ! SF2520E                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. Exclusao de nota fiscal                            !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             !                                                         !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 16/07/2014                                              !
+------------------+---------------------------------------------------------+
*/

#Include "rwmake.ch"
#Include "topconn.ch"
#Include "PROTHEUS.ch"

#Define ENTER chr(13)+chr(10)

User Function SF2520E()
//em 02/06/2016
//Local cFilNew := Substr(GetMv("MV_EMPINT"), 3, 2)
//Local cEmpNew := Substr(GetMv("MV_EMPINT"), 1, 2)
Local cFilNew 	:= "01" //fixo 01 - sempre matriz
Local cEmpNew 	:= ""

Local cQuery  	:= ""
Local aPVOrig 	:= {}
Local cIdNFSE	:= ""

Local aAreaE1	:= {}
Local aAreaF2	:= {}
Local aAreaD2	:= {}
Local aAreaC5	:= {}
Local aAreaC6	:= {}
Local aAreaC9	:= {}

Public __NfMista	:= .T.

If ExistBlock("KFATR15")
	GrvLog()
Endif

If cEmpAnt <> '06'
	//PEDIDOS DA NOTA
	cQuery := " SELECT DISTINCT D2_PEDIDO "
	cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += " WHERE D2_FILIAL = '" + xFilial("SD2") + "' "
	cQuery += " AND D2_DOC    = '"+SF2->F2_DOC+"' "
	cQuery += " AND D2_SERIE  = '"+SF2->F2_SERIE+"' "
	cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
	
	If Select("TRBSD2")<>0
		DbSelectArea("TRBSD2")
		DbCloseArea()
	Endif
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSD2", .F., .T.)
	
	While !TRBSD2->(EOF())
		//pedido
		cQuery := " SELECT * "
		cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
		cQuery += " WHERE C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery += " AND C5_NUM    = '"+TRBSD2->D2_PEDIDO+"' "
		cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
		
		If Select("TRBSC5")<>0
			DbSelectArea("TRBSC5")
			DbCloseArea()
		Endif
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSC5", .F., .T.)
		
		//Verifica a houve intagíveis no pedido
		If (TRBSC5->C5_K_INTAN > 0)
			Aadd(aPVOrig, {cEmpAnt+TRBSC5->C5_FILIAL+TRBSC5->C5_NUM})
			cEmpNew := TRBSC5->C5_EMPDEST
		endif
		
		TRBSD2->(DbSkip())
	End
	
	Conout("JOB EXCLUSAO")
	conout(varinfo("aPVOrig",aPVOrig))
	
	If Empty(SF2->F2_XIDVNFK)
		StartJob("U_KFATJ001", GetEnvServer(), .F., aPVOrig, cEmpNew, cFilNew)
	EndIf
	//u_KFATJ001(aPVOrig, cEmpNew, cFilNew)
EndIf      

// ---------------------------------------------------
// INTREGRACAOO MADEIRAMADEIRA - -golive
// ---------------------------------------------------
If ExistBlock("M050208")
	U_M050208()
EndIf

If !Empty(SF2->F2_XIDVNFK) .And. cEmpAnt == "04" .And. cFilAnt == "01" .And. Alltrim(SF2->F2_XTIPONF) == "1"//Validacao para NFMista
	
		__NfMista	:= .T.
		
		cIdNFSE	:= SF2->F2_XIDVNFK
		
		aAreaE1	:= SE1->(GetArea())
		aAreaF2	:= SF2->(GetArea())
		aAreaD2	:= SD2->(GetArea())
		aAreaC5	:= SC5->(GetArea())
		aAreaC6	:= SC6->(GetArea())
		aAreaC9	:= SC9->(GetArea())
		
		/*
		If !StartJob("U_KPEXCNFS", GetEnvServer(), .T., cIdNFSE)
				MsgInfo("NF Mista não excluida (ID-> "+cIdNFSE+")!!! informe o TI!!!!","KAPAZI")
			Else
				
		EndIf
		*/
		
		/*Comentando, pois passou a usar o Job Antetior - Luis 10/09/2019*/
		xExCNFSE(cIdNFSE,"2") //Servico
		xExcPedN(cIdNFSE)
		
		RestArea(aAreaE1)
		RestArea(aAreaF2)
		RestArea(aAreaD2)
		RestArea(aAreaC5)
		RestArea(aAreaC6)
		RestArea(aAreaC9)
		xExCNFSE(cIdNFSE,"1") //Produto
		xReCompP(cIdNFSE)
		
	ElseIf !Empty(SF2->F2_XIDVNFK) .And. cEmpAnt == "04" .And. cFilAnt != "01" .And. Alltrim(SF2->F2_XTIPONF) == "1"
		
		__NfMista	:= .T.
		cIdNFSE	:= SF2->F2_XIDVNFK
		
		aAreaE1	:= SE1->(GetArea())
		aAreaF2	:= SF2->(GetArea())
		aAreaD2	:= SD2->(GetArea())
		aAreaC5	:= SC5->(GetArea())
		aAreaC6	:= SC6->(GetArea())
		aAreaC9	:= SC9->(GetArea())
		xExCNFSE(cIdNFSE,"2") //Chama a exclusao da NF de Servico para somente marcar para deletar, podendo o job buscar a NFSE
		xExcPedN(cIdNFSE,"01")
		
		RestArea(aAreaE1)
		RestArea(aAreaF2)
		RestArea(aAreaD2)
		RestArea(aAreaC5)
		RestArea(aAreaC6)
		RestArea(aAreaC9)
		xExCNFSE(cIdNFSE,"1") //Produto
		xReCompP(cIdNFSE)
		
		/*
		Conout("Excluindo NFSE do processo entre filiais da 04")
		If !StartJob("U_DLNFSEKP", GetEnvServer(), .T., cIdNFSE)
				MsgInfo("NF Mista entre filiais nao Excluida(ID -> "+cIdNFSE+")!!! informe o TI","KAPAZI")
				RestArea(aAreaE1)
				RestArea(aAreaF2)
				RestArea(aAreaD2)
				RestArea(aAreaC5)
				RestArea(aAreaC6)
				RestArea(aAreaC9)
			
			Else
				RestArea(aAreaE1)
				RestArea(aAreaF2)
				RestArea(aAreaD2)
				RestArea(aAreaC5)
				RestArea(aAreaC6)
				RestArea(aAreaC9)
				xExCNFSE(cIdNFSE,"1") //Produto
				xReCompP(cIdNFSE)	
		EndIf
		*/
	
	ElseIf Empty(SF2->F2_XIDVNFK)
		__NfMista	:= .F.
		
EndIf

If cEmpAnt == "04" .And. cFilAnt == "01" 
	If Empty(SF2->F2_XIDVNFK) .And. Alltrim(SF2->F2_XPVSPP) == "S" //NF SUPPLIER --Estorno da fatura
			//RecLimS1() //Recompe o limite de pedidos normais - 18-11-18 Os limites sao contados a partir da inclusao do PV
		
		ElseIf !Empty(SF2->F2_XIDVNFK) .And. Alltrim(SF2->F2_XPVSPP) == "S"
			//RecLimS2() //Recompoe o limite de pedidos NF mista Os limites sao contados a partir da inclusao do PV
	EndIf
EndIf

If Empty(SF2->F2_XIDVNFK) .And. SF2->F2_SERIE == 'NFS' .And. cEmpAnt == "04" .And. cFilAnt == "01" .And. Alltrim(SF2->F2_XTIPONF) == "2"
	AtuPedO() //Volta o pedido para o tipo produto
EndIf

Return()

//user function tstkap()
//local aPVOrig := {}
//Aadd(aPVOrig, {"01024017"})
//u_KFATJ001(aPVOrig, "06", "01")
//Return()


User Function KFATJ001(aPVOrig, cEmpNew, cFilNew)
Local cQuery := ""
Local ni
ccadastro := "Exclusao Pedido de Vendas"
inclui := .f.
altera := .f.

//conout("cEmpNew = " + cEmpNew)
//conout("cFilNew = " + cFilNew)

//Seta a nova empresa
RpcClearEnv()
RpcSetType(3)
lConec := RpcSetEnv(cEmpNew, cFilNew,"Transferencia","transf@2014","FAT")

For ni := 1 to Len(aPVOrig)
	
	cQuery := " SELECT *, R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " WHERE C5_FILIAL = '" + xFilial("SC5") + "' "
	cQuery += " AND C5_K_PO    = '"+aPVOrig[ni,1]+"' "
	cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
	
	conout("cQuery = " + cQuery)
	
	If Select("TRBSC5B")<>0
		DbSelectArea("TRBSC5B")
		DbCloseArea()
	Endif
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSC5B", .F., .T.)
	
	SC5->(DbSetOrder(1))
	SC6->(DbSetOrder(1))
	SC9->(DbSetOrder(1))
	
	SC5->(DbGoTo(TRBSC5B->R_E_C_N_O_))
	SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
	
	aSC5 := {}
	aSC6 := {}
	aItens := {}
	
	If (SC5->C5_K_INTAN > 0)
		
		aadd(aSC5,{"C5_NUM"    ,SC5->C5_NUM,Nil})
		aadd(aSC5,{"C5_TIPO"   ,SC5->C5_TIPO,Nil})
		aadd(aSC5,{"C5_CLIENTE",SC5->C5_CLIENTE,Nil})
		aadd(aSC5,{"C5_LOJACLI",SC5->C5_LOJACLI,Nil})
		aadd(aSC5,{"C5_CLIENT" ,SC5->C5_CLIENT,Nil})
		aadd(aSC5,{"C5_LOJAENT",SC5->C5_LOJAENT,Nil})
		aadd(aSC5,{"C5_TIPOCLI",SC5->C5_TIPOçCLI,Nil})
		aadd(aSC5,{"C5_TPFRETE",SC5->C5_TPFRETE,Nil})
		aadd(aSC5,{"C5_CONDPAG",SC5->C5_CONDPAG,Nil})
		aadd(aSC5,{"C5_USER"   ,SC5->C5_USER,Nil})
		
		
		While (!SC6->(Eof()) .AND. SC6->C6_NUM == SC5->C5_NUM)
			
			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
			SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
			
			aadd(aSC6,{"C6_ITEM"   ,SC6->C6_ITEM,Nil})
			aadd(aSC6,{"C6_PRODUTO",SC6->C6_PRODUTO,Nil})
			aadd(aSC6,{"C6_QTDVEN" ,SC6->C6_QTDVEN,Nil})
			//			aadd(aSC6,{"C6_OPER"   ,"",Nil})
			aadd(aSC6,{"C6_PRCVEN" ,SC6->C6_PRCVEN,Nil})
			aadd(aSC6,{"C6_XPRECPC",SC6->C6_XPRECPC,Nil})
			//			aadd(aSC6,{"C6_VALOR"  ,SC6->C6_QTDVEN*SC6->C6_PRCVEN,Nil})
			aadd(aSC6,{"C6_PRUNIT" ,SC6->C6_PRUNIT,Nil})
			aadd(aSC6,{"C6_TES"    ,SC6->C6_TES,Nil})
			//			aadd(aSC6,{"C6_LOCAL"  ,SC6->C6_LOCAL,Nil})
			
			Aadd(aItens, aSC6)
			
			aSC6 := {}
			SC6->(DbSkip())
		EndDo
		
	EndIf
	
	conout(varinfo("aSC5",aSC5))
	conout(varinfo("aItens",aItens))
	
	conout("altera pedido para estornar libereações")
	
	//altera pedido para estornar libereações.
	lMsErroAuto := .F.
	//	MSExecAuto({|x,y,z| Mata410(x,y,z)}, aSC5, aItens, 4)
	MATA410(aSC5,aItens,4)
	if lMsErroAuto
		conout("MostraErro()" + MostraErro())
	EndIf
	
	conout("exclui pedido")
	
	//exclui pedido
	lMsErroAuto := .F.
	//	MSExecAuto({|x,y,z| Mata410(x,y,z)}, aSC5, aItens, 5)
	MATA410(aSC5,aItens,5)
	if lMsErroAuto
		conout("MostraErro()" + MostraErro())
	EndIf
	
Next

conout("FIM")

Return()


//Excluir a NF MISTA NFSE
Static Function xExCNFSE(cIdNFse,cTpNF)
Local aArea			:=  GetArea()
Local aCab 			:= {}
Local aAreaSM0		:= {}
Local cFilAtu		:= xFilial("SF2")
Private lMsErroAuto	:= .F.

DbSelectArea("SF2")
DbOrderNickName("XINDNFMIST")
SF2->(DbGotop())
If SF2->(DbSeek(cIdNFse + cTpNF))
		
		If xFilial("SF2") != "01" .And. cTpNF == "2" //Filia diferente de adm
				Reclock("SF2",.F.)
				SF2->F2_XDELNFS := "S"
				SF2->(MsUnlock())
				
				cFilant		:= 	SF2->F2_FILIAL					//Seta a filial correta
				aAreaSM0 	:= 	SM0->(GetArea())	//Bkp SM0
				SM0->( DbSeek( cEmpAnt + SF2->F2_FILIAL ) )		//Seta SM0 correta
				
				aAdd(aCab,{"F2_DOC"  ,SF2->F2_DOC  ,nil})
		        aAdd(aCab,{"F2_SERIE",SF2->F2_SERIE,nil})
		        lMSHelpAuto := .T.
				lMsErroAuto := .F.
				MSExecAuto({|x| MATA520(x)},aCab)
				If lMsErroAuto 
				   		MsgAlert("Erro - Exclusao NFSE ENTRE FILIAIS!!!")
				   		MsgInfo(MostraErro())
		        	Else
		        		Conout("Exclusao NFSE ENTRE FILIAIS concluida com sucesso")
				EndIf
				
				cFilAnt	:= cFilAtu
				Restarea(aAreaSM0)
				
			Else
				aAdd(aCab,{"F2_DOC"  ,SF2->F2_DOC  ,nil})
		        aAdd(aCab,{"F2_SERIE",SF2->F2_SERIE,nil})
		        lMSHelpAuto := .T.
				lMsErroAuto := .F.
				MSExecAuto({|x| MATA520(x)},aCab)
				If lMsErroAuto 
				   		MsgAlert("Erro - Exclusao NF!!!")
				   		MsgInfo(MostraErro())
		        	Else
		        		Conout("Exclusao NFSE concluida com sucesso")
				EndIf
		EndIF
		
	Else
		MsgAlert("NFSE nao localizada!!!")
EndIf

Restarea(aArea)
Return()

//Exclui o pedido de NF Serviço
Static Function xExcPedN(cIdNFSE,cFilExcl)
Local aCabPed		:={}
Local aLinhaPed		:={}
Local aItensPed		:={}
Local cFilAtu		:= xFilial("SF2")
Private lMsErroAuto	:= .F.

Default cFilExcl	:= ""

If !Empty(cFilExcl)
	cFilant		:= 	cFilExcl					//Seta a filial correta
	aAreaSM0 	:= 	SM0->(GetArea())			//Bkp SM0
	SM0->( DbSeek( cEmpAnt + cFilExcl ) )		//Seta SM0 correta
EndIf

DbSelectArea("SC5")
SC5->(DbOrderNickName("XIDNFSE"))
SC5->(DbGoTop())
If SC5->(DbSeek(xFilial("SC5")+ cIdNFSE  + "2")) //__NFMIST
	
	cPedido	:= SC5->C5_NUM
	If U_NFMESTPV(cPedido,cIdNFSE)//Estorna o pedido da SC9
		Conout("Pedido liberado - SC9")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda o Cabecalho do Pedido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aCabPed, {"C5_NUM"		,SC5->C5_NUM		,Nil})  // Nro.do Pedido
	aAdd(aCabPed, {"C5_CLIENTE"	,SC5->C5_CLIENTE	,Nil})  // Cod. Cliente
	aAdd(aCabPed, {"C5_LOJACLI"	,SC5->C5_LOJACLI	,Nil})  // Loja Cliente

	DbSelectArea("SC6")
	DbSetOrder(1)	//Filial + Pedido
	If DbSeek(SC5->C5_FILIAL + SC5->C5_NUM)

		While !SC6->(Eof()) .AND. SC5->C5_FILIAL + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Guarda os Itens do Pedido   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd(aLinhaPed,{"C6_ITEM"	,SC6->C6_ITEM		,NIL })
			Aadd(aLinhaPed,{"C6_PRODUTO",SC6->C6_PRODUTO	,NIL })
			aAdd(aLinhaPed,{"C6_NUM"	,SC6->C6_NUM		,NiL}) // Pedido
			aAdd(aLinhaPed,{"C6_PRODUTO",SC6->C6_PRODUTO	,Nil}) // Cod.Item
			aAdd(aLinhaPed,{"C6_UM"		,SC6->C6_UM			,Nil}) // Unidade
			aAdd(aLinhaPed,{"C6_QTDVEN"	,SC6->C6_QTDVEN		,Nil}) // Quantidade
			aAdd(aLinhaPed,{"C6_PRCVEN"	,SC6->C6_PRCVEN		,Nil}) // Preco Unit.
			aAdd(aLinhaPed,{"C6_PRUNIT"	,SC6->C6_PRUNIT		,Nil}) // Preco Unit.
			aAdd(aLinhaPed,{"C6_VALOR"	,SC6->C6_VALOR		,Nil}) // Valor Tot.
			aAdd(aLinhaPed,{"C6_TES"	,SC6->C6_TES		,Nil}) // Tipo de Saida
			aAdd(aLinhaPed,{"C6_LOCAL"	,SC6->C6_LOCAL		,Nil}) // Almoxarifado
			Aadd(aItensPed, aLinhaPed)
			aLinhaPed := {}
			SC6->(DbSkip())
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³exclui o Pedido de Venda.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SC5")
	SC5->(DbOrderNickName("XIDNFSE"))
	SC5->(DbGoTop())
	If SC5->(DbSeek(xFilial("SC5")+cIdNFSE + "2"))
	
		MSExecAuto( {|x,y,z| Mata410(x,y,z)} , aCabPed, aItensPed, 5) //"Excluindo Pedido"
		If lMsErroAuto
			MostraErro()
		EndIf
	EndIf
EndIf

If !Empty(cFilExcl)
	cFilAnt	:= cFilAtu
	Restarea(aAreaSM0)
EndIf

Return()


//Funcao responsavel por alterar o pedido original de produto
Static Function xReCompP(cIdNFSE)
Local aPedCab	:= {}
Local aPedIte	:= {}
Local aPedIts	:= {}
Local nValTot	:= 0
Local cPedido	:= ""
Local aAreaC5	:= SC5->(GetArea())
Local aAreaC6	:= SC6->(GetArea())
Local aAreaC9	:= SC9->(GetArea())
Local aAItens	:= {}
Local lAchou	:= .F.
Local cUm		:= ""
Local cMsgCli		:= ""
Local cMsgPdv		:= ""
Local cPedC9		:= ""
Local cFilC9		:= ""
Private lMsErroAuto	:= .F.
Public _AItensB	:= {}

DbSelectArea("SC5")
SC5->(DbOrderNickName("XIDNFSE"))
SC5->(DbGoTop())
If SC5->(DbSeek(xFilial("SC5") + cIdNFSE + "1" )) //Posiciona no pedido de produto
	cPedido	:= SC5->C5_NUM
	
	cMsgCli 	:= SC5->C5_MSGCLI
	cMsgPdv		:= SC5->C5_MSGNOTA
	
	cPedC9		:= SC5->C5_NUM
	cFilC9		:= SC5->C5_FILIAL
	
	aAdd(aPedCab,{'C5_NUM'    , SC5->C5_NUM 	, Nil}) //Numero do Pedido
	aAdd(aPedCab,{'C5_TIPO'   , SC5->C5_TIPO   	, Nil}) //Tipo do Pedido
	aAdd(aPedCab,{'C5_CLIENTE', SC5->C5_CLIENTE	, Nil}) //Codigo do Cliente
	aAdd(aPedCab,{'C5_LOJACLI', SC5->C5_LOJACLI	, Nil}) //Loja do Cliente
	aAdd(aPedCab,{'C5_TIPOCLI', SC5->C5_TIPOCLI	, Nil}) //Tipo do Cliente
	aAdd(aPedCab,{'C5_EMISSAO', SC5->C5_EMISSAO , Nil}) //Data de Emissao
	aAdd(aPedCab,{'C5_CONDPAG', SC5->C5_CONDPAG	, Nil}) //Condicao de Pagamanto
	aAdd(aPedCab,{'C5_XIDVNFK', SPACE(15)		, Nil}) //Condicao de Pagamanto
	//aAdd(aPedCab,{'C5_LIBEROK', 'S'            , Nil}) //Liberacao Total
	aAdd(aPedCab,{'C5_XTPPED' , SC5->C5_XTPPED	, Nil}) 
	
	DbSelectArea("SC6")
	DbSetOrder(1) //C6_FILIAL+C6_NUM
	SC6->(DbGoTop())
	If DbSeek(xFilial("SC6")+cPedido)
		
		While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cPedido .And. !SC6->(EOF())
			
			aAdd(_AItensB,{SC6->C6_ITEM,SC6->C6_XLARG,SC6->C6_XCOMPRI,SC6->C6_XQTDPC,SC6->C6_QTDVEN})
			
			cUm		:= SC6->C6_UM
			lAchou	:= .T.
			aPedIte	:= {}
			aadd(aPedIte,{"C6_ITEM"		,SC6->C6_ITEM		,Nil})
			aadd(aPedIte,{"C6_PRODUTO"	,SC6->C6_PRODUTO	,Nil})
			
			If Alltrim(cUm) == "M2"
					aadd(aPedIte,{"C6_XLARG	"	,SC6->C6_XLARG		,Nil})
					aadd(aPedIte,{"C6_XCOMPRI"	,SC6->C6_XCOMPRI	,Nil})
					aadd(aPedIte,{"C6_XQTDPC"	,SC6->C6_XQTDPC		,Nil})
					aadd(aPedIte,{"C6_QTDVEN"	,SC6->C6_QTDVEN		,Nil})
				Else
					aadd(aPedIte,{"C6_QTDVEN"	,SC6->C6_QTDVEN		,Nil})
			EndIf
			
			//aadd(aPedIte,{"C6_OPER"		,cOP			,Nil})
			
			aadd(aPedIte,{"C6_PRCVEN"	,SC6->C6_XVLRRNF	,Nil})
			aadd(aPedIte,{"C6_PRUNIT"	,SC6->C6_XVLRRNF	,Nil})
			aadd(aPedIte,{"C6_XPRECPC"	,SC6->C6_XVLRRNF	,Nil})
			//aadd(aPedIte,{"C6_X_PRCVE"	,Round(cAliasPV->VLRVEND, 4 )	,Nil})
			
			aadd(aPedIte,{"C6_TES"		,SC6->C6_TES		,Nil})
			aadd(aPedIte,{"C6_X_OBSPR"	,SC6->C6_X_OBSPR	,Nil})  
			aadd(aPedIte,{"C6_XVLRRNF"	,SC6->C6_XVLRRNF	,Nil})
			aadd(aPedIte,{"C6_QTDLIB"	,0					,Nil})  
			aAdd(aPedIts, aPedIte)
					
			SC6->(DbSkip())
		EndDo
		
		If lAchou
			//Conout("")
			//VARINFO ("aPedIts",aPedIts)
			//Conout("")
						
			MSExecAuto({|x,y,z|Mata410(x,y,z)}, aPedCab, aPedIts, 4) //Opção para Alteração
			If lMsErroAuto
					MostraErro()
				Else
					//xDelSCLib(cFilC9,cPedC9) //Lib 
					MsgInfo("Pedido(Produto/NFSE) alterado com sucesso-> "+SC5->C5_NUM)
			EndIf
			
			RecLock("SC5",.F.)
			SC5->C5_MSGNOTA := cMsgPdv
			SC5->C5_MSGCLI	:= cMsgCli  
			SC5->(MsUnLock())

		EndIf
	EndIf
EndIf

RestArea(aAreaC5)
RestArea(aAreaC6)
RestArea(aAreaC9)
Return()

Static Function AtuPedO()
Local cQr 	:= ""
Local aArea	:= GetArea()

cQr := " UPDATE TOP(1) " + RetSqlName("SC5") + " SET C5_XTIPONF = '1'
cQr += " FROM " + RetSqlName("SC5") + " SC5 "
cQr += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON  SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NOTA = SF2.F2_DOC AND SC5.C5_SERIE = SF2.F2_SERIE AND SF2.D_E_L_E_T_ = ''
cQr += "  WHERE SC5.D_E_L_E_T_ = ''
cQr += " 		AND SC5.C5_XTIPONF = '2'
cQr += " 		AND SC5.C5_XIDVNFK = ''
cQr += " 		AND SC5.C5_FILIAL = '01'
cQr += " 		AND SC5.C5_NOTA = '"+SF2->F2_DOC+"'
cQr += " 		AND SC5.C5_SERIE = 'NFS'

If TcSqlExec(cQr) < 0
   Conout("TCSQLError() " + TCSQLError())
Endif

RestArea(aArea)
Return()

//Deleta SC9 
//Hoje a rotina automatica nao exclui a liberacao da SC9 - 21/08/18
Static Function xDelSCLib(cFilC9,cPedC9)
Local cQr 	:= ""
Local aArea	:= GetArea()

cQr := " UPDATE " + RetSqlName("SC9") + ""
cQr += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cQr += " WHERE D_E_L_E_T_ = '' "
cQr += "		AND C9_FILIAL = '"+cFilC9+"' "
cQr += "		AND C9_PEDIDO = '"+cPedC9+"' "

If TcSqlExec(cQr) < 0
   Conout("TCSQLError() " + TCSQLError())
Endif

RestArea(aArea)
Return()


Static Function GrvLog()
	Local aArea	:= GetArea()
	Local cQuery:= ""
	Local cTemp	:= GetNextAlias()
	
	cQuery += "SELECT DISTINCT "+ENTER
	cQuery += "	D2_PEDIDO "+ENTER
	cQuery += "FROM "+RetSqlName("SD2")+" SD2 "+ENTER

	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND D2_FILIAL	='"+xFilial("SD2")	+"' "+ENTER
	cQuery += "	AND D2_DOC		='"+SF2->F2_DOC		+"' "+ENTER
	cQuery += "	AND D2_SERIE	='"+SF2->F2_SERIE	+"' "+ENTER
	
	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	While !(cTemp)->( EOF() )
	
		U_KFATR15("07",(cTemp)->D2_PEDIDO,,SF2->F2_DOC,SF2->F2_SERIE)
		(cTemp)->( DbSkip() )
	Enddo
	
	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif
	
	RestArea(aArea)
Return


