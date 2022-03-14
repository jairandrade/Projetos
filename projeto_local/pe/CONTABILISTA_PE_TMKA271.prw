#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} TK271ROTM
Este ponto de entrada permite a personalização de novas rotinas no browse inicial da rotina de atendimento Call Center.
@author Mario L. B. Faria
@since 03/01/2019
@version 1.0
@return aRet, array, Novas rotinas para o menu do Browse
/*/
User Function TK271ROTM()

	Local aRotUser := {}
	Local aRotAux  := {}

	AAdd(aRotAux ,{ "Histórico de Alçada *" , "U_HISALCA()", 0, 7})
	If U_MTML01RO()
		aAdd( aRotAux, { "Imprimir Cotação *"	 ,"U_MCOT01VC()", 0 , 7 })
		Aadd( aRotAux, {'Banco de Conhecimento *',"MsDocument('SUA',SUA->(RecNo()), 4)"  ,0,4,0,NIL})
	EndIf
	AAdd(aRotUser, {"Especificos *", aRotAux, 0, 7})

Return aRotUser


/*/{Protheus.doc} TMKBARLA
O ponto de entrada TMKBARLA é chamado na criação da tela do Atendimento do Call Center, com o objetivo de incluir botões de usuário na toolbar lateral.
@author Mario L. B. Faria
@since 25/03/2019
@version 1.0
@return aBtnLat, array, Botões a serem utilizados.
@param aBotao, array, Botões padrão
@param aTitulo, array, Titulo da rotina
/*/
//User Function TMKBARLA(aBotao, aTitulo)
//
//	Local lIntGFE	:= SuperGetMV("MV_INTGFE",.F.,.F.)
//
//	If TkGetTipoAte() == "2"
////		If lIntGFE
////			aAdd(aBotao,{"BUDGETY"  , { || U_AFAT07SF() } ,"Simula Frete"})	
////			aAdd(aBotao,{"BUDGETY"  , { || U_ANEG01NG() } ,"Negociação"})	
////		EndIf
//	EndIf
//
//Return aBotao



/*/{Protheus.doc} TK271BOK
Esse ponto de entrada é chamado no botão "OK" da barra de ferramentas da tela de atendimento do Call Center, antes da função de gravação.
@author Mario L. B. Faria
@since 24/06/2019
@version 1.0
@return .T. ou .F.
/*/
User Function TK271BOK()

	Local lRet	:= .T.
	Local lCliBl:= GetAdvFVal("SA1","A1_MSBLQL"	,FWxFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA,1,"") == '1'

	If lCliBl //Verifica se o Cliente esta Bloqueado
		Alert("Cliente Bloqueado por Regra de Alteração de Cadastro." + CRLF + CRLF + "Aguardando Aprovação !!!")
		lRet:= .F.
	Else
		//Chama rotina para verificar se possui Solicitação Pendente
		lRet := U_AALCGABP()

		If lRet
			U_AFOR004()
		EndIf
	Endif

	//Verifica o bloqueio de alçadas
	If lRet
		lRet := U_AALCGABL()
	EndIf

Return lRet


/*/{Protheus.doc} TK271BOK
Ponto de entrada executado no final da gravação, ao dar o OK na tela de atendimento
@author Mario L. B. Faria
@since 24/06/2019
@version 1.0
/*/
User Function TK271END()

	Local aArea      := GetArea()

/*/
	Integração do campo UA_XAGRPV com C5_XAGRPV
	Integração do campo UA_XPEDCLI com C5_XPEDCLI
	Integração do campo UB_NUMPCOM com C6_PEDCOM
	Integração do campo UB_ITEMPC com C6_ITPC
	@author Erivalton Oliveira
	@since 12/05/2020
	@version 1.0
	
	Integração do campo UB_OPER com C6_OPER
	@author Elias Ricardo Kuchak
	@since 24/07/2020
/*/
	If FunName() == "TMKA271" .and. SUA->UA_OPER=='1'

		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		if dbSeek(xFilial("SC5")+SUA->UA_NUMSC5)

			RecLock("SC5",.F.)
			SC5->C5_XAGRPV	:= SUA->UA_XAGRPV
			SC5->C5_XPEDCLI	:= SUA->UA_XPEDCLI
			// SC5->C5_XNUMSUA	:= SUA->UA_NUM
			SC5->(MsUnlock())

		endif

		SC5->(DbCloseArea())

		DbSelectArea("SUB")
		SUB->( dbSetOrder(1) )
		SUB->( dbSeek( xFilial("SUB") + SUA->UA_NUM ) )
		while !SUB->(Eof()) .and. xFilial("SUB") + SUB->UB_NUM == xFilial("SUB") + SUA->UA_NUM

			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			if dbSeek(xFilial("SC6")+SUB->(UB_NUMPV+UB_ITEMPV+UB_PRODUTO))
				while !SC6->(eof()) .and. SC6->C6_NUM==SUB->UB_NUMPV .and. SC6->C6_ITEM==SUB->UB_ITEMPV .and. SC6->C6_PRODUTO==SUB->UB_PRODUTO
					RecLock("SC6",.F.)
					SC6->C6_NUMPCOM	:= SUB->UB_NUMPCOM
					SC6->C6_ITEMPC 	:= SUB->UB_ITEMPC
					SC6->C6_OPER    := SUB->UB_OPER  //Elias Ricardo Kuchak
					SC6->(MsUnlock())
					SC6->(dbSkip())
				enddo
			endif

			SUB->(dbSkip())
		enddo

		SC6->(DbCloseArea())

	Endif

	RestArea( aArea )

Return

/*/{Protheus.doc} Tk271Cor
Esse ponto de entrada permite a customização das cores de identificação das linhas do mbrowse, de acordo com as regras do cliente.
@author Jackson Molleri
@since 04/12/2020
@version 1.0
/*/
User Function Tk271Cor(cPasta)

	Local aArea  := GetArea()
	Local aCores := {}
	
	//Televendas
	If cPasta == '2' 
		aCores    := {  {"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. Empty(SUA->UA_DOC))" , "BR_VERDE"   },;
						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. !Empty(SUA->UA_DOC))", "BR_VERMELHO"},;
						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('ZFI',4,XFILIAL('ZFI')+SUA->UA_NUM+SUA->UA_CLIENTE+SUA->UA_LOJA,'ZFI_STATUS')=='P')"	, "BR_AMARELO" },;
						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('ZFI',4,XFILIAL('ZFI')+SUA->UA_NUM+SUA->UA_CLIENTE+SUA->UA_LOJA,'ZFI_STATUS')=='R')"	, "BR_CANCEL" },;
						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('ZFI',4,XFILIAL('ZFI')+SUA->UA_NUM+SUA->UA_CLIENTE+SUA->UA_LOJA,'ZFI_STATUS')=='A')"	, "BR_PINK" },;
						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('SC9',2,XFILIAL('SC9')+SUA->UA_CLIENTE+SUA->UA_LOJA+SUA->UA_NUMSC5,'C9_BLCRED')$'01/04/05')", "BR_BRANCO" },;
						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('SC9',2,XFILIAL('SC9')+SUA->UA_CLIENTE+SUA->UA_LOJA+SUA->UA_NUMSC5,'C9_BLEST')$'02/03')", "BR_CINZA" },;
   						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2)", "BR_AZUL"   },;
   						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 3)", "BR_MARRON" },;
   						{"(!EMPTY(SUA->UA_CODCANC))", "BR_PRETO" } }
	EndIf
	
	RestArea(aArea)
	
Return aCores

/*/{Protheus.doc} TK271Leg
Esse ponto de entrada foi criado para a alteração do texto e das cores da Legenda do Browse de Atendimento da rotina de 'Chamadas'.
@author Jackson Molleri
@since 04/12/2020
@version 1.0
/*/
User Function TK271Leg(cPasta)

	Local aArea  := GetArea()
	Local aCores := {}
	
	//Televendas
	If cPasta == '2' 
		aCores    := {  {"BR_VERDE"		, "Faturamento" },;
						{"BR_VERMELHO"	, "Nf. Emitida" },;
						{"BR_AMARELO"	, "Pendente Alçada"},;
						{"BR_CANCEL"	, "Reprovado Alçada"},;
						{"BR_PINK"		, "Liberado Alçada" },;
						{"BR_MARROM"	, "Com Controle Reserva" },;
						{"BR_VIOLETA"	, "Sem Controle Reserva" },;
   						{"BR_BRANCO"	, "Pedido Bloq. Crédito" },;
						{"BR_CINZA"		, "Pedido Bloq. Estoque" },;
   						{"BR_AZUL"		, "Orçamento" },;
   						{"BR_MARRON"	, "Ate ndimento" },;
   						{"BR_PRETO"		, "Cancelado" }}
	EndIf
	
	RestArea(aArea)
	
Return aCores

/*/{Protheus.doc} TemBlqGrv
Vetifica se possui bloqueio existente
@author Mario L. B. Faria
@since 06/07/2019
@version 1.0
/*/
Static Function TemBlqGrv(cTipo)

	Local lRet		:= .F.
	Local cQuery	:= ""
	Local cAlAlc	:= ""	

	Default cTipo := ""

	cQuery := " SELECT TOP 1 " + CRLF
	cQuery += " 	ZFI_CODBLQ, ZFI_STATUS, MAX(ZFI_DTPROC + ZFI_HRPROC) ULTIMO " + CRLF
	cQuery += " FROM " + RetSqlName("ZFI") + " ZFI " + CRLF 
	cQuery += " WHERE " + CRLF  
	cQuery += " 		ZFI_FILIAL = '" + xFilial("ZFI") + "' " + CRLF 
	cQuery += " 	AND ZFI_TIPO = '1' " + CRLF 
	cQuery += " 	AND ZFI_NUMATE ='" + M->UA_NUM + "' " + CRLF 
	cQuery += " 	AND ZFI.D_E_L_E_T_ = ' ' " + CRLF 
	If cTipo == "P"
		cQuery += " 	AND ZFI_STATUS = '" + cTipo + "' " + CRLF
	EndIf
	cQuery += " GROUP BY ZFI_CODBLQ,ZFI_STATUS " + CRLF

	cQuery := ChangeQuery(cQuery)
	cAlAlc := MPSysOpenQuery(cQuery)	

	If !(cAlAlc)->(Eof())
		If cTipo == "P"
			lRet := .T.
		ElseIf (cAlAlc)->ZFI_STATUS == "B"
			lRet := .T.
		EndIf
	EndIf

	(cAlAlc)->(dbCloseArea())

Return lRet
