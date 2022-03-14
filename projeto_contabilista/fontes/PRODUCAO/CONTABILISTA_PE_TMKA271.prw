#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} TK271ROTM
Este ponto de entrada permite a personaliza��o de novas rotinas no browse inicial da rotina de atendimento Call Center.
@author Mario L. B. Faria
@since 03/01/2019
@version 1.0
@return aRet, array, Novas rotinas para o menu do Browse
/*/
User Function TK271ROTM()

	Local aRotUser := {}
	Local aRotAux  := {}

	AAdd(aRotAux ,{ "Hist�rico de Al�ada *" , "U_HISALCA()", 0, 7})
	If U_MTML01RO()
		aAdd( aRotAux, { "Imprimir Cota��es *"	  ,"U_MCOT01VC()"                       , 0, 7 })
		Aadd( aRotAux, { 'Banco de Conhecimento *',"MsDocument('SUA',SUA->(RecNo()), 4)", 0, 4,0,NIL})
	EndIf
	AAdd(aRotUser, {"Especificos *", aRotAux, 0, 7})

Return aRotUser

//-------------------------------------------------
/*/{Protheus.doc} TK271BOK
Esse ponto de entrada é chamado no bot�o "OK" da barra de ferramentas da tela de atendimento do Call Center, antes da fun��o de grava��o.

@type function
@version 1.0
@author Mario L. B. Faria

@since 24/06/2019

@return Logical, Verdadeiro ou falso

@see https://tdn.totvs.com/pages/releaseview.action?pageId=6787730

@history 14/12/2020, Lucas Chagas, Versao 2.0 > Adicionado tratamento para o campo customizado UA_XDTVAL
/*/
//-------------------------------------------------
User Function TK271BOK()

	Local lRet	:= .T.
	Local lCliBl:= GetAdvFVal("SA1","A1_MSBLQL"	,FWxFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA,1,"") == '1'

	If lCliBl //Verifica se o Cliente esta Bloqueado
		Alert("Cliente Bloqueado por Regra de Altera��o de Cadastro." + CRLF + CRLF + "Aguardando Aprova��o !!!")
		lRet:= .F.
	Else
		//Chama rotina para verificar se possui Solicita��o Pendente
		If findfunction('U_AALCGABP')
			lRet := U_AALCGABP()
		endif

		If lRet .and. findfunction('U_AFOR004')
			U_AFOR004()
		EndIf
	Endif

	//Verifica o bloqueio de alçadas
	If lRet .and. findfunction('U_AALCGABL')
		lRet := U_AALCGABL()
	EndIf

	/*if empty(M->UA_XDTVAL)
		M->UA_XDTVAL := DDATABASE + SUPERGETMV('MV_PZRESER', .F., 10)
endif*/

	M->UA_XDTVAL := DDATABASE + SUPERGETMV('MV_PZRESER', .F., 10)

Return lRet


//-------------------------------------------------
/*/{Protheus.doc} TK271END
Ponto de entrada executado no final da grava��o, ao dar o OK na tela de atendimento.

@type function
@version 5.0
@author Mario L. B. Faria

@since 24/06/2019

@see https://tdn.totvs.com/display/public/PROT/TK271END+-+Tela+de+atendimento

@history 12/05/2020, Erivalton Oliveira, Vers�o 2.0 > Integra��o dos campos UA_XAGRPV com C5_XAGRPV, UA_XPEDCLI com C5_XPEDCLI, UB_NUMPCOM com C6_PEDCOM e UB_ITEMPC com C6_ITPC
@history 24/07/2020, Elias Ricardo Kuchak, Vers�o 3.0 > Integra��o do campo UB_OPER com C6_OPER
@history 28/10/2020, Lucas Chagas, Vers�o 4.0 > Compatbiliza��o do fonte, extraindo do arquivo CONTABILISTA_PE_TMKA271.prw para fonte pr�prio. Adicionado chamada para cria��o de reserva.
@history 27/01/2021, Lucas Chagas, Vers�o 5.0 > Ajustes -- em teste do webconta, execauto n�o executa o ponto de entrada. Tratado para identificar a fun��o que esta executando o ponto de entrada.
/*/
//-------------------------------------------------
User Function TK271END()

	Local Area     as Array
	Local oReserva as Object
	Local Funcao   as Logical
	Local i        as Numeric

	/*/
	Integra��o do campo UA_XAGRPV com C5_XAGRPV
	Integra��o do campo UA_XPEDCLI com C5_XPEDCLI
	Integra��o do campo UB_NUMPCOM com C6_PEDCOM
	Integra��o do campo UB_ITEMPC com C6_ITPC
	@author Erivalton Oliveira
	@since 12/05/2020
	@version 1.0

	Integra��o do campo UB_OPER com C6_OPER
	@author Elias Ricardo Kuchak
	@since 24/07/2020
	/*/

	Area := GetArea()

	u_GrvRota()//Jair 11-03-2021 iniciar com esta rotina. ela carrega o campo SUA->UA_XROTA
	funcao := (FunName() == "TMKA271")
	if !funcao
		i := 0
		while (i <= Len(ProcName())) .and. !funcao
			funcao := (lower(procname(i)) == "gravacall")

			i++
		enddo
	endif

	if Findfunction('U_AALCGABL') .and. !isBlind()//Verifica o bloqueio de al�adas
		U_AALCGABL()
	endif

	if FindClass('TReservas')
		oReserva := TReservas():New()
		oReserva:SetFilial( SUA->UA_FILIAL )
		oReserva:SetNumTmk( SUA->UA_NUM )

		if !oReserva:ReservaOrcamento( funcao )
			if !isBlind()
				MSGALERT( oReserva:GetLastError(), 'Reservas do Or�amento' )
			else
				conOut( oReserva:GetLastError() )
			endif
		endif
		oReserva := FreeObj(oReserva)
	endif

	If ((funcao) .and. (SUA->UA_OPER=='1'))
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		if SC5->(dbSeek(xFilial("SC5") + SUA->UA_NUMSC5))
			RecLock("SC5",.F.)
			SC5->C5_XAGRPV	:= SUA->UA_XAGRPV
			SC5->C5_XPEDCLI	:= SUA->UA_XPEDCLI
			SC5->C5_XROTA	:= SUA->UA_XROTA//JAIR
			SC5->(MsUnlock())

		endif
		DbSelectArea("SUB")
		SUB->( dbSetOrder(1) )
		if SUB->( dbSeek( xFilial("SUB") + SUA->UA_NUM ) )
			while !SUB->(Eof()) .and. ((xFilial("SUB") + SUB->UB_NUM) == (xFilial("SUB") + SUA->UA_NUM))

				DbSelectArea("SC6")
				SC6->(DbSetOrder(1))
				if SC6->(dbSeek(xFilial("SC6")+SUB->(UB_NUMPV+UB_ITEMPV+UB_PRODUTO)))
					while !SC6->(eof()) .and. (SC6->C6_NUM == SUB->UB_NUMPV) .and. (SC6->C6_ITEM == SUB->UB_ITEMPV) .and. (SC6->C6_PRODUTO == SUB->UB_PRODUTO)
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
		endif
	Endif

	RestArea( Area )

Return

/*/{Protheus.doc} Tk271Cor
Esse ponto de entrada permite a customiza��o das cores de identifica��o das linhas do mbrowse, de acordo com as regras do cliente.
@author Jackson Molleri
@since 04/12/2020
@version 1.0
/*/
User Function Tk271Cor(cPasta)

	Local aArea  := GetArea()
	Local aCores := {}

	//Televendas
	If cPasta == '2'
		aCores    := {  {"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. Empty(SUA->UA_DOC))" , "BR_VERDE"   },; // Faturamento - VERDE
		{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. !Empty(SUA->UA_DOC))", "BR_VERMELHO"},; // Faturado - VERMELHO
		{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('ZFI',4,XFILIAL('ZFI')+SUA->UA_NUM+SUA->UA_CLIENTE+SUA->UA_LOJA,'ZFI_STATUS')=='P')"	, "BR_AMARELO" },; 		// Orcamento p/ Alçada - AMARELO
		{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('ZFI',4,XFILIAL('ZFI')+SUA->UA_NUM+SUA->UA_CLIENTE+SUA->UA_LOJA,'ZFI_STATUS')=='R')"	, "BR_PINK" },; 		// Orcamento p/ Alçada - PINK
		{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('ZFI',4,XFILIAL('ZFI')+SUA->UA_NUM+SUA->UA_CLIENTE+SUA->UA_LOJA,'ZFI_STATUS')=='A')"	, "BR_VERDE_ESCURO" },;	// Orcamento p/ Alçada - BR_VERDE_ESCURO
		{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('SC9',2,XFILIAL('SC9')+SUA->UA_CLIENTE+SUA->UA_LOJA+SUA->UA_NUMSC5,'C9_BLCRED')$'01/04/05')", "BR_BRANCO" },;		// Orcamento p/ Alçada - BR_VERDE_ESCURO
		{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .AND. POSICIONE('SC9',2,XFILIAL('SC9')+SUA->UA_CLIENTE+SUA->UA_LOJA+SUA->UA_NUMSC5,'C9_BLEST')$'02/03')", "BR_CINZA" },;		// Orcamento p/ Alçada - BR_VERDE_ESCURO
		{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2)", "BR_AZUL"   },;						 // Orcamento - AZUL
		{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 3)", "BR_MARRON" },; 						 // Atendimento - MARRON
		{"(!EMPTY(SUA->UA_CODCANC))", "BR_PRETO"	}}
	EndIf

	RestArea(aArea)

Return aCores

/*/{Protheus.doc} TK271Leg
Esse ponto de entrada foi criado para a altera��o do texto e das cores da Legenda do Browse de Atendimento da rotina de 'Chamadas'.
@author Jackson Molleri
@since 04/12/2020
@version 1.0
/*/
User Function TK271Leg(cPasta)

	Local aArea  := GetArea()
	Local aCores := {}

	//Televendas
	If cPasta == '2'
		aCores    := {  {"BR_VERDE", "Faturamento" },;
			{"BR_VERMELHO", "Nf. Emitida" },;
			{"BR_AMARELO", "Pendente Alçada"},;
			{"BR_PINK", "Reprovado Alçada"},;
			{"BR_VERDE_ESCURO", "Liberado Alçada" },;
			{"BR_MARROM", "Com Controle Reserva" },;
			{"BR_VIOLETA", "Sem Controle Reserva" },;
			{"BR_BRANCO", "Pedido Bloq. Crédito" },;
			{"BR_CINZA", "Pedido Bloq. Estoque" },;
			{"BR_AZUL", "Orçamento" },;
			{"BR_MARRON", "Ate ndimento" },;
			{"BR_PRETO", "Cancelado" }}
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

/*/{Protheus.doc} GrvRota()
Grava o campo UA_XROTA
@author Jair Andrade	
@since 10/03/2021
@version 1.0
/*/
User function GrvRota()
	Local cQuery	:= ""
	Local cRota :=""
	Local cCepSA1 := SA1->A1_CEP
	// Verifica qual � a transportadora que est� no campo UA_TRANSP e vai na SA4 e valida se A4_XROTFIX=1.
	// Caso sim traz a rota da transportadora terceira, Caso nao traz o padrao.
	If SA4->A4_XROTFIX =="1"
		//pega o codigo da transportadora
		RecLock("SUA",.F.)
		SUA->UA_XROTA :=SA4->A4_XROTA
		SUA->(MsUnlock())
	Else
		//Verifica qual � o CEP do cliente e faz uma pesquisa para saber a cidade e o bairro
		cQuery := " SELECT DA9_ROTEIR FROM " + RetSqlName("DA7") + " DA7 "
		cQuery += " JOIN " + RetSqlName("DA9") + " DA9 ON DA9_FILIAL = DA7_FILIAL "
		cQuery += " AND DA9_PERCUR = DA7_PERCUR AND DA9_ROTA = DA7_ROTA  AND DA9.D_E_L_E_T_<> '*' "
		cQuery += " WHERE '"+cCepSA1+"' BETWEEN DA7_CEPDE AND DA7_CEPATE "
		cQuery += " AND DA7_FILIAL = '"+xFilial("DA7")+"'"
		cQuery += " AND DA7.D_E_L_E_T_ <> '*' "
		//Memowrite("c:\temp\cRota.TXT",cQuery)
		cQuery := ChangeQuery(cQuery)
		cRota := MPSysOpenQuery(cQuery)

		If !(cRota)->(Eof())
			RecLock("SUA",.F.)
			SUA->UA_XROTA :=(cRota)->DA9_ROTEIR
			SUA->(MsUnlock())
		Else
			RecLock("SUA",.F.)
			SUA->UA_XROTA :="S/ROTA"
			SUA->(MsUnlock())
		EndIf

		(cRota)->(dbCloseArea())
	EndIf

Return
