#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: KPEXCNFS		|	Autor: Luis Paulo							|	Data: 10/09/2019	//
//==================================================================================================//
//	Descrição: Funcao para deletar NF nfse por job/schd dentro da filial							//
//																									//
//	Alterações:																						//
//	-																								//
//==================================================================================================//
User Function KPEXCNFS(cIdNFSE)
Local aArea			:=  GetArea()
Local aCab 			:= {}
Local aAreaM0		:= {}
Local cEmpNew 		:= "04"
Local cFilNew		:= "01"
Local aArea			:= {}
Local lRet			:= .T.
Local lConec		:= .F.
Private lMsErroAuto	:= .F.
Default cIdNFSE		:= ""

Conout("Excluindo NF e Pedido de SV na 0401...")
Conout("cEmpNew = " + cEmpNew)
Conout("cFilNew = " + cFilNew)

//Seta a nova empresa
RpcClearEnv()
RpcSetType(3)
lConec := RpcSetEnv(cEmpNew, cFilNew,,,"FAT",,{"SF2"})

DbSelectArea("SF2")
DbOrderNickName("XINDNFMIST")
SF2->(DbGotop())
If SF2->(DbSeek(cIdNFse + '2'))
		
		Conout("")
		Conout("......................EXCLUINDO NFSE......................")
		Conout("")
		
		If SF2->F2_FILIAL != "01" .And. cTpNF == "2"
				Reclock("SF2",.F.)
				SF2->F2_XDELNFS := "S"
				SF2->(MsUnlock())
			Else
				aAdd(aCab,{"F2_DOC"  ,SF2->F2_DOC  ,nil})
		        aAdd(aCab,{"F2_SERIE",SF2->F2_SERIE,nil})
		        lMSHelpAuto := .T.
				lMsErroAuto := .F.
				MSExecAuto({|x| MATA520(x)},aCab)
				If lMsErroAuto 
				   		Conout("")
				   		Conout("Erro - Exclusao NFSE na 04!!!")
				   		cErro	:= MostraErro("\NFMistaErro\")
				   		Conout(cErro)
				   		Conout("")
				   		lRet := .F.
		        	Else
		        		Conout("Exclusao NFSE concluida com sucesso")
		        		If !xExcPedN(cIdNFSE)
		        			lRet := .F.
		        		EndIf
				EndIf
		EndIF
		
	Else
		MsgAlert("NFSE nao localizada!!!")
		lRet := .F.
EndIf

Conout("Fim do processo de EXCLUSAO DE NFSE E PV SV na 0401..."+cIdNFSE)
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)

Restarea(aArea)
RPCClearEnv()
Return(lRet)

//Exclui o pedido de NF Serviço
Static Function xExcPedN(cIdNFSE)
Local aCabPed		:={}
Local aLinhaPed		:={}
Local aItensPed		:={}
Local lRet			:= .T.
Private lMsErroAuto	:= .F.

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
			Conout("")
			cErro	:= MostraErro("\NFMistaErro\")
		   	Conout(cErro)
		   	Conout("")
		   	lRet	:= .F.
		EndIf
	EndIf
EndIf
	
Return(lRet)