#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: DLNFSEKP		|	Autor: Luis Paulo							|	Data: 01/01/2019	//
//==================================================================================================//
//	Descrição: Funcao para deletar NF nfse por job/schd entre filiais								//
//																									//
//	Alterações:																						//
//	-																								//
//==================================================================================================//
User Function DLNFSEKP(cIdNFSE)
Local cEmpNew 		:= "04"
Local cFilNew		:= "01"
Local aArea			:= {}
Private lRet		:= .T.
Private cCondPGK	:= ""
Private lPedSpp		:= .F.
Private cErro		:= ""
Private cAliasF		
Default cIdNFSE		:= ""
	
Conout("Excluindo NF e Pedido de SV na 0401...")
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)

//Seta a nova empresa
RpcClearEnv()
RpcSetType(3)
lConec := RpcSetEnv(cEmpNew, cFilNew,,,"FAT",,{"SF2"})

aArea			:= GetArea()

If !BuscaNFKP() //Busca as NFSE para exclusao
		Conout("")
		Conout("Existem NFSE para exclusão!!")
		Conout("")
		While !(cAliasF)->(EOF())
			
			If !Empty((cAliasF)->F2_XIDVNFK)
				
				cIdNFSE		:= (cAliasF)->F2_XIDVNFK
				If xExCNFSE(cIdNFSE,"2") //Servico
						If !xExcPedN(cIdNFSE)  	//Exclui o PV de servico
							lRet := .F.
						EndIf
						
					Else
						lRet := .F.
				EndIf
				
			EndIf
			(cAliasF)->(DbSkip())
		EndDo
		
	Else
		lRet := .F.
		Conout("")
		Conout("Nao existem NFSE para exclusao!!")
		Conout("")
EndIf

Conout("Fim do processo de exclusao de NF na 0401...")
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)

(cAliasF)->(DbCloseArea())

RestArea(aArea)	
RPCClearEnv()
Return(lRet)

//Busca as NF pendentes de exclusao na 0401
Static Function BuscaNFKP()
Local cSql	:= ""

cAliasF	:= GetNextAlias()

cSql	+= " SELECT D_E_L_E_T_,F2_FILIAL,F2_XPVSPP,F2_XTIPONF,F2_XIDVNFK,R_E_C_N_O_ AS RECO,F2_XDELNFS,*
cSql	+= " FROM SF2040 WITH(NOLOCK)
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND F2_XDELNFS = 'S'
cSql	+= " AND F2_FILIAL = '01'
cSql	+= " ORDER BY R_E_C_N_O_

Conout("")
//Conout(cSql)
Conout("")

TCQuery cSql New Alias (cAliasF)		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea((cAliasF))
(cAliasF)->(DBGoTop())

Return(cAliasF)->(EOF())

//Excluir a NF MISTA NFSE
Static Function xExCNFSE(cIdNFse,cTpNF)
Local aArea			:= GetArea()
Local aAreaSM0		:= {}
Local aCab 			:= {}
Local lRet			:= .T.
Private lMsErroAuto	:= .F.

DbSelectArea("SF2")
DbOrderNickName("XINDNFMIST")
SF2->(DbGotop())
If SF2->(DbSeek(cIdNFse + cTpNF))
		
		//Reclock("SF2",.F.)
		//SF2->F2_XDELNFS := "S"
		//SF2->(MsUnlock())
		cFilant		:= 	SF2->F2_FILIAL					//Seta a filial correta
		aAreaSM0 	:= 	SM0->(GetArea())	//Bkp SM0
		SM0->( DbSeek( cEmpAnt + SF2->F2_FILIAL ) )		//Seta SM0 correta
				
		aAdd(aCab,{"F2_DOC"  ,SF2->F2_DOC  ,nil})
        aAdd(aCab,{"F2_SERIE",SF2->F2_SERIE,nil})
        lMSHelpAuto := .T.
		lMsErroAuto := .F.
		MSExecAuto({|x| MATA520(x)},aCab)
		If lMsErroAuto 
				Conout("")
		   		Conout("Erro - Exclusao NF!!!")
		   		cErro	:= MostraErro("\NFMistaErro\")
		   		Conout(cErro)
		   		Conout("")
		   		lRet := .F.
        	Else
        		Conout("Exclusao NFSE concluida com sucesso")
		EndIf
		
	Else
		Conout("NFSE nao localizada!!!")
		lRet := .F.
EndIf

Restarea(aAreaSM0)
Restarea(aArea)
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