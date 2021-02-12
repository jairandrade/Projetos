#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"

#Define ENTER chr(13)+chr(10)

// cmainho para o arquivo de log quando atualizar o saldo do cliente
Static _cLogfile := "\logs\MT440AT.LOG"

/**********************************************************************************************************************************/
/** SIGAFAT - Faturamento                                                                                                        **/
/** AJUSTA HISTORICO DE CLIENTE                                                                                                  **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi Indústria Brasileira Ltda.                                                                                            **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 10/07/2017| Marcos Sulivan          | Criação da rotina/procedimento.                                     			         **/
/**********************************************************************************************************************************/
User function MT440AT()
	// variaveis auxiliares
	Local aArea 	:= GetArea()
	Local aAreaC5	:= SC5->(GetArea())
	Local aAreaC6	:= SC6->(GetArea())
	Local aAreaC9	:= SC9->(GetArea())
	Local lReserva 	:= GetMv("KA_RESATV",,.F.)
	Local lDadosCli	:= StaticCall(M521CART,TGetMv,"  ","KA_LIBCREC","L",.T.,"MT440AT - Exibe mensagem na tela sobre inconsistencia nos campos de saldo de credito do cliente" )
	Local lRet		:= .T.
	// deve validar se ja teve alguma liberacao hoje?
	Local lFinAtiv	:= StaticCall(M521CART,TGetMv,"  ","KA_PROCFIN","L",.T.,"MT440AT - Executa o refaz saldo financeiro do cliente uma vez ao dia?" )
	// executa processamento saldos financeiros?
	Local lProcFin	:= .T.

	if lReserva .and. AllTrim(SC5->C5_XSITLIB) == "00"
		MsgStop("O pedido não pode se liberado enquanto estiver no status de 'Aguadando revisão de reservas'. Confirme as reservas para poder liberar.")
		Return .F.
	Endif
	
	If cEmpAnt == "04"
		If SC5->C5_XPVSPC  == 'S' .And. (Empty(SC5->C5_XSTSSPP) .OR. SC5->C5_XSTSSPP == 'A') .And. Alltrim(SC5->C5_XTIPONF) == "1"
			MsgInfo("Este pedido não foi enviado para supplier, favor verificar!","KAPAZICRED")
			Return .F.
		EndIf
	EndIf

	// chama a funcao para corrigir o campo C6_QTDEMP/C6_QTDENT negativo
	libNegat(SC5->C5_NUM)

	// verificar se ja houve alguma liberacao do pedido hoje
	If lFinAtiv
		// se ja houve pedidos liberados para o cliente hoje nao executa a liberacao novamente
		lProcFin := !LiberHj(SC5->C5_CLIENTE)
	Endif
	
	// se executa processamento financeiro
	If lProcFin
		// ajusta os parametros da rotina
		Pergunte("AFI410", .F.)
		mv_par01 := 2
		mv_par02 := 1
		mv_par03 := SC5->C5_CLIENTE
		mv_par04 := SC5->C5_CLIENTE
		mv_par05 := ""
		mv_par06 := "ZZZZZZ"
		//"Atualizacao OK" - Fina410 Linha 232 - Chama a procedure Refaz Clientes/Fornecedores da FIN003 - Luis 02-06-2018
		//Essa rotina atualiza os arquivos de Clientes e Fornecedores, refazendo, se necessário, seus acumulados. Deve ser utilizada para verificar e corrigir os dados financeiros inconsistentes.
		/*Os arquivos e campos avaliados, recalculados e corrigidos são:
			•	Saldo financeiro e de duplicatas de Cliente/Fornecedor em real.
			•	Saldo financeiro e de duplicatas de Cliente/Fornecedor em moeda forte.
			•	Dados sobre pagamentos e eventuais atrasos dos clientes.
		*/
		
		If isBlind()
			fa410Processa(.T.) //Reprocessamento arquivos de cliente/fornecedor
		Else
			MsgRun("Reprocessando saldos financeiros do cliente/fornecedor","Aguarde...",{|| fa410Processa(.T.) })
		Endif
	Endif
	
	If lDadosCli .and. !isBlind()
		AvalCli(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_NUM)
	Endif

	// restaura a area
	RestArea(aArea)
	RestArea(aAreaC5)
	RestArea(aAreaC6)
	RestArea(aAreaC9)

Return(lRet)

/**********************************************************************************************************************************/
/** Funcao libNegat                                                                                                              **/
/** Tratativa para o campo C6_QTDEMP negativo que causa duplicidade na liberacao de estoque e faturamento                        **/
/**********************************************************************************************************************************/
Static Function libNegat(_cPedido)
	// area atual
	Local aArea		:= GetArea()
	// area atual sc6
	Local aAreaC6	:= SC6->(GetArea())
	// query
	Local cQuery 	:= ""
	// area temporaria
	Local cTemp		:= ""
	// processo ativado
	Local lAtivado	:= .F. 
	// descricao do parametro
	Local cDescr	:= "MT440AT - Corrigir campo C6_QTDEMP negativo antes do inicio da liberacao do pedido de venda"

	// valor padrao
	Default _cPedido:= ""

	// cria o parametro 
	criaSX6(xFilial("SA1"),"KA_EMPNEGA","L",.T.,cDescr)

	// atualiza o parametro
	lAtivado := GetMv("KA_EMPNEGA",,.F.)

	// se processo nao ativado ou pedido em branco
	If !lAtivado .or. Empty( AllTrim( _cPedido ) )
		// sai da funcao sem alterar
		Return
	Endif

	// area temporaria
	cTemp	:= GetNextAlias()

	// monta a query de itens pendentes do pedido com qtd empenhada negativa
	cQuery += "SELECT "+ENTER
	cQuery += "	C6_FILIAL "+ENTER
	cQuery += "	,C6_NUM "+ENTER
	cQuery += "	,C6_ITEM "+ENTER
	cQuery += "	,C6_QTDVEN "+ENTER
	cQuery += "	,C6_QTDENT "+ENTER
	cQuery += "	,C6_QTDEMP "+ENTER
	cQuery += "	,R_E_C_N_O_ SC6REGNO "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SC6")+" (nolock) "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND C6_FILIAL = '"+xFilial("SC6")	+"' "+ENTER
	cQuery += "	AND C6_NUM    = '"+_cPedido			+"' "+ENTER
	cQuery += "	AND C6_QTDVEN > C6_QTDENT "+ENTER
	cQuery += "	AND C6_BLQ <> 'R' "+ENTER
	cQuery += "	AND (C6_QTDEMP < 0 OR C6_QTDENT < 0) "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY  "+ENTER
	cQuery += "	C6_NUM "+ENTER
	cQuery += "	,C6_ITEM "+ENTER

	// area aberta
	If Select(cTemp)>0
		// fecha a area
		(cTemp)->( DBCloseArea() )
	Endif

	// executa a query
	TcQuery cQuery New Alias (cTemp)

	// se retornou algo
	If !(cTemp)->( EOF() )
		// faz loop nos registros
		While !(cTemp)->( EOF() )
			// posiciona no registro da sc6
			SC6->( DbGoTo( (cTemp)->SC6REGNO ) )
			// valida se posicionou corretamente
			IF SC6->( Recno() ) == (cTemp)->SC6REGNO
				// trava o registro
				RecLock("SC6",.F.) 
				// se quantidade empenhada negativa
				IF SC6->C6_QTDEMP < 0
					// atualiza com a quantidade liberada
					SC6->C6_QTDEMP := QtdLib(SC6->C6_NUM,SC6->C6_ITEM)
				Endif

				// se quantidade entregue negativa
				If SC6->C6_QTDENT < 0
					// atualiza com a quantidade ja faturada
					SC6->C6_QTDENT := QtdFat(SC6->C6_NUM,SC6->C6_ITEM)
				Endif
				// detrava o registro
				MsUnLock("SC6")
			Endif
			// proximo registro
			(cTemp)->( DbSkip() )
		Enddo
	Endif

	// area aberta
	If Select(cTemp)>0
		// fecha a area
		(cTemp)->( DBCloseArea() )
	Endif

	// restaura a area
	RestArea(aArea)
	// restaura a area 
	RestArea(aAreaC6)
	// retorna
Return


/**********************************************************************************************************************************/
/** Funcao QtdLib                                                                                                                **/
/** Retorna a quantidade total liberada para o pedido de venda                                                                   **/
/**********************************************************************************************************************************/
Static Function QtdLib(cPedido,cItem)
	// area atua
	Local aArea		:= GetArea()
	// retorno
	Local nRet		:= 0
	// alias temporario
	Local cTemp		:= GetNextAlias()
	// query
	Local cQuery	:= ""

	// valor padrao
	Default cPedido := SC6->C6_NUM
	// valor padrao
	Default cItem	:= SC6->C6_ITEM

	// monta a query para recuperar a quantidade ja liberada
	cQuery += "SELECT ISNULL(SUM(C9_QTDLIB),0) C9_QTDLIB "+ENTER
	cQuery += "FROM "+RetSqlName("SC9")+" (nolock) "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C9_FILIAL ='"+xFilial("SC9")	+"' "+ENTER
	cQuery += "AND C9_PEDIDO ='"+cPedido		+"' "+ENTER
	cQuery += "AND C9_ITEM   ='"+cItem			+"' "+ENTER
	cQuery += "AND C9_NFISCAL='' "+ENTER

	// area aberta
	If Select(cTemp) > 0
		// fecha a area
		(cTemp)->( DBCloseArea() )
	Endif

	// executa a query
	TcQuery cQuery New Alias (cTemp)

	// atualiza o retorno
	nRet := IIF( (cTemp)->C9_QTDLIB > 0, (cTemp)->C9_QTDLIB, 0 )

	// area aberta
	If Select(cTemp) > 0
		// fecha a area
		(cTemp)->( DBCloseArea() )
	Endif

	// restaura a area
	RestArea(aArea)
	// retorna
Return nRet

/**********************************************************************************************************************************/
/** Funcao QtdLib                                                                                                                **/
/** Retorna a quantidade total liberada para o pedido de venda                                                                   **/
/**********************************************************************************************************************************/
Static Function QtdFat(cPedido,cItem)
	// area atua
	Local aArea		:= GetArea()
	// retorno
	Local nRet		:= 0
	// alias temporario
	Local cTemp		:= GetNextAlias()
	// query
	Local cQuery	:= ""

	// valor padrao
	Default cPedido := SC6->C6_NUM
	// valor padrao
	Default cItem	:= SC6->C6_ITEM

	// monta a query para recuperar a quantidade ja liberada
	cQuery += "SELECT ISNULL(SUM(D2_QUANT),0) D2_QUANT "+ENTER
	cQuery += "FROM "+RetSqlName("SD2")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND D2_FILIAL='"+xFilial("SD2")	+"' "+ENTER
	cQuery += "	AND D2_PEDIDO='"+cPedido		+"' "+ENTER
	cQuery += "	AND D2_ITEMPV='"+cItem			+"' "+ENTER

	// area aberta
	If Select(cTemp) > 0
		// fecha a area
		(cTemp)->( DBCloseArea() )
	Endif

	// executa a query
	TcQuery cQuery New Alias (cTemp)

	// atualiza o retorno
	nRet := IIF( (cTemp)->D2_QUANT > 0, (cTemp)->D2_QUANT, 0 )

	// area aberta
	If Select(cTemp) > 0
		// fecha a area
		(cTemp)->( DBCloseArea() )
	Endif

	// restaura a area
	RestArea(aArea)
	// retorna
Return nRet


static Function criaSX6(_cFil,_cPar,_cTipo,xValor,cDescr)
	Local aArea 	:= GetArea()
	Local cDesc1	:= ""
	Local cDesc2	:= ""
	Local cDesc3	:= ""

	cDesc1	:= Substr(cDescr,001,50)
	If Len(cDescr) > 50
		cDesc2	:= Substr(cDescr,051,50)
	Endif

	If Len(cDescr) > 100 
		cDesc3	:= Substr(cDescr,101,50)
	Endif

	SX6->( DbSetOrder(1) )
	If !SX6->( MsSeek(_cFil+_cPar,.T.))
		RecLock("SX6",.T.)
		SX6->X6_FIL 	:= _cFil
		SX6->X6_VAR		:= _cPar
		SX6->X6_TIPO	:= _cTipo
		SX6->X6_CONTEUD	:= cValToChar(xValor)
		SX6->X6_CONTSPA	:= cValToChar(xValor)
		SX6->X6_CONTENG	:= cValToChar(xValor)
		SX6->X6_PROPRI	:= "U"
		SX6->X6_PYME	:= ""
		SX6->X6_DESCRIC	:= cDesc1
		SX6->X6_DESC1	:= cDesc2
		SX6->X6_DESC2	:= cDesc3
		SX6->X6_DSCSPA	:= cDesc1
		SX6->X6_DSCSPA1	:= cDesc2
		SX6->X6_DSCSPA2	:= cDesc3
		SX6->X6_DSCENG	:= cDesc1
		SX6->X6_DSCENG1	:= cDesc2
		SX6->X6_DSCENG2	:= cDesc3
		MsUnLock("SX6")
	Endif

	RestArea(aArea)
Return

Static Function AvalCli(cCliente,cLoja,cPedido)
	Local 	aArea 	:= GetArea()
	Local 	aAreaA	:= GetArea("SA1")
	Local 	lRet 	:= .T.
	Local 	cMsg	:= "" 
	Local 	lAtu	:= StaticCall(M521CART,TGetMv,"  ","KA_SALDPEL","L",.T.,"MT440AT - Corrige o saldo do campo A1_SALPEDL para o cliente atual?" ) 
	Local 	nSaldo	:= 0
	Default cCliente:= ""
	Default cLoja	:= ""
	Default cPedido	:= ""

	If Empty(Alltrim(cCliente))
		Return
	Endif

	SA1->( DbSetOrder(1) )
	If SA1->( MsSeek(xFilial("SA1")+cCliente+cLoja))
		If SA1->A1_SALPEDL < 0
			If !lAtu
				lRet := .F.
				cMsg := "O cliente "+SA1->A1_COD+" está com o saldo de pedidos liberados inconsistente (A1_SALPEDL = "+cValToChar(SA1->A1_SALPEDL)+") no cadastro, a análise de crédito pode apresentar problemas. Informe o departamento de TI sobre esse caso. Pedido "+cPedido+"."
			Else
				nSaldo := getSaldo(SA1->A1_COD,SA1->A1_LOJA)

				cMsg := AllTrim(SA1->A1_COD)
				cMsg += "|"+AllTrim(SA1->A1_LOJA)
				cMsg += "|"+AllTrim(SA1->A1_NOME)
				cMsg += "|"+cValToChar(SA1->A1_SALPEDL)
				cMsg += "|"+cValToChar(nSaldo)

				WriteLog(cMsg)
				RecLock("SA1",.F.)
				SA1->A1_SALPEDL := nSaldo
				MsUnLock("SA1") 
			Endif
		Endif
	Endif

	If !lRet
		MsgInfo(cMsg)
	Endif

	RestArea(aAreaA)
	RestArea(aArea)
Return


Static Function getSaldo(_cCod,_cLoj)
	Local nRet 	:= 0
	Local cTemp	:= GetNextAlias()
	Local aArea	:= GetArea() 
	Local cQuery:= ""

	cQuery += "SELECT ISNULL(SUM(C9_PRCVEN*C9_QTDLIB),0) SALDO "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SC9")+" SC9 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C6_FILIAL = C9_FILIAL "+ENTER
	cQuery += "		AND C6_NUM = C9_PEDIDO "+ENTER
	cQuery += "		AND C6_ITEM = C9_ITEM "+ENTER
	cQuery += "		AND C6_PRODUTO = C9_PRODUTO "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_<>'*'	 "+ENTER
	cQuery += "		AND F4_FILIAL = C6_FILIAL "+ENTER
	cQuery += "		AND F4_CODIGO = C6_TES "+ENTER
	cQuery += "		AND F4_ESTOQUE = 'S' "+ENTER
	cQuery += "		 "+ENTER
	cQuery += "WHERE SC9.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C9_BLCRED='' "+ENTER
	cQuery += "AND C9_NFISCAL='' "+ENTER
	cQuery += "AND C9_CLIENTE='"+_cCod+"' "+ENTER
	cQuery += "AND C9_LOJA='"+_cloj+"' "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	TcQuery cQuery New Alias (cTemp)

	If !(cTemp)->( EOF() )
		nSaldo := (cTemp)->SALDO
	Endif

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	RestArea(aArea)
Return nRet


/**********************************************************************************************************************************/
/** static function WriteLog()                                                                                                   **/
/** escreve o texto no log.                                                                                                      **/
/**********************************************************************************************************************************/
Static Function WriteLog(cTexto)
	// handle do arquivo
	Local nHdlLog	:= -1
	// retorno
	Local lRet		:= .F.

	// cria a pasta do arquivo
	StaticCall(KFATA06,CriaPasta,_cLogfile )

	// adiciona data e hora ao texto
	cTexto := StaticCall(KFATA06,cdateTime)+"|"+cTexto
	// exibe o texto no console
	conout(cTexto)

	// se arquivo de log informado
	If !Empty(AllTrim(_cLogfile ))

		// se o arquivo existe
		If fIle (_cLogfile )
			// abre o arquivo
			nHdlLog	:= fOpen(_cLogfile ,FO_READWRITE	)
			// se nao existe
		Else
			// cria o arquivo
			nHdlLog	:= fCreate(_cLogfile ,FC_NORMAL	)
			// se abriu o arquivo
			If nHdlLog > -1	
				// vai pro final do arquivo
				FSEEK(nHdlLog,0,FS_END)
				// grava o texto do cabecalho do log
				lRet := FWrite(nHdlLog,"Data|Hora|Codigo|Loja|Nome|Valor anterior|Valor corrigido" + ENTER)
			Endif
		Endif

	Endif

	// se abriu o arquivo
	If nHdlLog > -1	
		// vai pro final do arquivo
		FSEEK(nHdlLog,0,FS_END)
		// grava o texto
		lRet := FWrite(nHdlLog, cTexto + ENTER)
		// fecha o arquivo
		fClose(nHdlLog)
	Endif

	// retorna
Return lRet

/*
Retorna se já houveram liberacoes do para o cliente hoje
*/
Static Function LiberHj(cCli)
	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Local cQuery	:= ""
	Local cTemp		:= GetNextAlias()
	
	cQuery += "SELECT COUNT(*) LIBERADOS "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SC9")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "    D_E_L_E_T_<>'*' "+ENTER
	cQuery += "    AND C9_FILIAL='"+cFilAnt+"' "+ENTER
	cQuery += "    AND C9_CLIENTE='"+cCli+"' "+ENTER
	cQuery += "    AND C9_DATALIB='"+DtoS(dDataBase)+"' "+ENTER
	
	If Select(cTemp)>0
		(cTemp)->(DbCloseArea())
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	lRet := (cTemp)->LIBERADOS > 0
	
	If Select(cTemp)>0
		(cTemp)->(DbCloseArea())
	Endif
	
	RestArea(aArea)
Return lRet







