#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: ESTPVNFM		|	Autor: Luis Paulo							|	Data: 05/07/2018	//
//==================================================================================================//
//	Descrição: Funcao para estorno do pedido da NF MISTA											//
//																									//
//	Alterações:																						//
//	-																								//
//==================================================================================================//
User Function ESTPVNFM()
Private cPedido	:= SC5->C5_NUM
Private cFilKp	:= SC5->C5_FILIAL
Private cTipoPv	:= SC5->C5_XTIPONF 	//Tipo pedido
Private cXId	:= SC5->C5_XIDVNFK	//Id Nf Mista
Private cGerSv	:= SC5->C5_XGERASV	//GeraSv S/N?
Private cNota	:= SC5->C5_NOTA

If cEmpAnt == "04" .And. cFilKp == "01"
		If cGerSv == "N"
				MsgInfo("Este pedido esta parametrizado para não gerar serviço","KAPAZI NFSE")
				return
					
			ElseIf	Empty(cXId)
				MsgInfo("Este pedido ainda não gerou NF Mista","KAPAZI NFSE")
				return
				
			ElseIf cTipoPv == "2"
				MsgInfo("Este pedido é de serviço, posícione no pedido de produto","KAPAZI NFSE")
				return
			
			ElseIf !Empty(cNota)
				MsgInfo("Este pedido possui nota!!!","KAPAZI NFSE")
				return
				
			Else
				EstPvNM()
		EndIf
		
	Else
		MsgInfo("Rotina disponível apenas na Kapazi Industria!!!","KAPAZI NFSE")
EndIf
	
Return()

//Estorno dos pedidos Pedido de venda
Static Function EstPvNM()

//Posiciona no pedido de serviço e exclui
xExcPedN(cXId)

//Recompoe o pedido de produto
xReCompP(cXId)

Return()


//Exclui o pedido de NF Serviço
Static Function xExcPedN(cIdNFSE)
Local aCabPed		:={}
Local aLinhaPed		:={}
Local aItensPed		:={}
Private lMsErroAuto	:= .F.

DbSelectArea("SC5")
SC5->(DbOrderNickName("XIDNFSE"))
SC5->(DbGoTop())
If SC5->(DbSeek(xFilial("SC5")+ cIdNFSE  + "2")) //__NFMIST
	
	cPedido	:= SC5->C5_NUM
	If U_NFMESTPV(cPedido,cIdNFSE)//Estorna o pedido da SC9
		Conout("Pedido estornado - SC9")
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
Private lMsErroAuto	:= .F.

If Type("_AItensB") == "U" 
		Public _AItensB	:= {}
	ElseIf Type("_AItensB") == "A"
		_AItensB	:= {}
EndIf

DbSelectArea("SC5")
SC5->(DbOrderNickName("XIDNFSE"))
SC5->(DbGoTop())
If SC5->(DbSeek(xFilial("SC5") + cIdNFSE + "1" )) //Posiciona no pedido de produto
	cPedido	:= SC5->C5_NUM
	
	cMsgCli 	:= SC5->C5_MSGCLI
	cMsgPdv		:= SC5->C5_MSGNOTA
	
	
	aAdd(aPedCab,{'C5_NUM'    , SC5->C5_NUM 	, Nil}) //Numero do Pedido
	aAdd(aPedCab,{'C5_TIPO'   , SC5->C5_TIPO   	, Nil}) //Tipo do Pedido
	aAdd(aPedCab,{'C5_CLIENTE', SC5->C5_CLIENTE	, Nil}) //Codigo do Cliente
	aAdd(aPedCab,{'C5_LOJACLI', SC5->C5_LOJACLI	, Nil}) //Loja do Cliente
	aAdd(aPedCab,{'C5_TIPOCLI', SC5->C5_TIPOCLI	, Nil}) //Tipo do Cliente
	aAdd(aPedCab,{'C5_EMISSAO', SC5->C5_EMISSAO , Nil}) //Data de Emissao
	aAdd(aPedCab,{'C5_CONDPAG', SC5->C5_CONDPAG	, Nil}) //Condicao de Pagamanto
	aAdd(aPedCab,{'C5_XIDVNFK', SPACE(15)		, Nil}) //Condicao de Pagamanto
	//aAdd(aPedCab,{'C5_LIBEROK', 'S'            , Nil}) //Liberacao Total
	
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