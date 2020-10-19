#include 'protheus.ch'


User Function MAcd001()

	Local bProcess
	Local oProcess

	Local cPerg := "MACD001"

	bProcess := {|oSelf| Executa(oSelf) }

	//cria as peguntas se não existe
	//CriaSX1(cPerg)
	Pergunte(cPerg,.F.)

	oProcess := tNewProcess():New("MAcd001","Endereçamento de Saldos Automatico",bProcess,"Endereçamento de saldos automaticos especifica para TCP. Na opção parametros",cPerg,,.F.,,,.T.,.F.)

Return


Static Function Executa(oProcess)

	Local nSaldoSB2 := 0
	Local nSaldoSBF := 0

	Local lContinua := .T.

	Local cCondic := "B1_ZLOCALI <> '' .And. B1_COD >= '"+mv_par01+"' .And. B1_COD <= '"+mv_par02+"'"

	Private nMostra := mv_par01
	Private cDirSalvar := mv_par02

	//verifica se o parametro mv_localiz esta configuração para Sim
	IF GetMV("MV_LOCALIZ") != "S"
		//se não estiver, avisa
		Aviso("Atenção", "O parametro MV_LOCALIZ está configuração para NÃO usar controle de localização (endereçamento). Altere para SIM antes de executar esta Rotina.", {"botao"}, tipo)
		//e sai fora
		Return
	EndIF

	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	SB1->( dbSetFilter( {|| &cCondic } , cCondic ))
	SB1->( dbGoTop() )

	oProcess:SetRegua1( SB1->( RecCount() ) )

	While !SB1->( Eof() )
		//regua dos produtos
		oProcess:IncRegua1( 'Produto ' + alltrim(SB1->B1_COD) + " " + alltrim(SB1->B1_DESC) )

		//regra de processamento de cada produto
		oProcess:SetRegua2( 10 )

		lContinua := .T.

		Begin Transaction

		//se o produto não controla localização
		IF SB1->B1_LOCALIZ != "S"
			oProcess:IncRegua2( 'Alterando produto para controlar localização' )
			//chama função para alterar para controlar localização
			lContinua := MudaParaControlar()
		EndIF

		IF lContinua

			SB2->( dbSetOrder(1) )
			SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD ) )

			oProcess:IncRegua2( 'Analisando armazens com saldo do produto' )

			//percore todos os armazens
			While !SB2->( Eof() ) .And. SB2->(B2_FILIAL+B2_COD) == xFilial("SB2")+SB1->B1_COD .And. lContinua

				oProcess:IncRegua2( 'Armazem ' + SB2->B2_LOCAL )

				IF SB2->B2_QEMP > 0
					IF Aviso("ATENÇÃO","Produto "+alltrim(SB1->B1_COD)+" com saldo empenhado de " + cValToChar(SB2->B2_QEMP) + "." + CRLF + "Deseja Continuar o Processo ?",{"Sim","Não"}) == 2
						lContinua := .F.
					EndIF
				EndIF

				IF lContinua
					nSaldoSB2 := SaldoSB2()
					//se tiver saldo
					IF nSaldoSB2 > 0

						oProcess:IncRegua2( 'Com Saldo, verificando se existe localização' + SB1->B1_ZLOCALI )

						//verifica se existe o endereço padrão (B1_ZLOCALI) no armazem com o saldo
						SBE->( dbSetOrder(1) )
						SBE->( dbSeek( xFilial("SBE") + SB2->B2_LOCAL + SB1->B1_ZLOCALI ) )

						IF SBE->( Found() )
							//pega o saldo endereçado no armazem
							nSaldoSBF := SaldoSBF(SB2->B2_LOCAL, Nil, SB1->B1_COD, Nil, , )

							oProcess:IncRegua2( 'Localização existe, verificando se vai gerar endereçamento')

							//se for diferente
							IF QtdComp(nSaldoSB2) > QtdComp(nSaldoSBF)
								oProcess:IncRegua2( 'Gerando endereçamento do produto')
								//faz o endereçamento
								EnderecaPorArmazem(QtdComp(nSaldoSB2-nSaldoSBF))
							EndIF
						Else
							Aviso("Atenção", "Localização " + alltrim(SB1->B1_ZLOCALI) + " não existe no armazém " + SB2->B2_LOCAL + ".", {"Ok"}, 2)
							lContinua := .F.
						EndIF
					EndIF
				EndIF
				SB2->( dbSkip() )
			EndDO
		EndIF

		IF ! lContinua
			DisarmTransaction()
		EndiF

		End Transaction

		SB1->( dbSkip() )
	EndDO

Return


Static Function EnderecaPorArmazem(nQuantidade)

	//aqui cria endereço
	//Cria registro de movimentacao por Localizacao (SDB)
	CriaSDB( SB1->B1_COD    ,; // Produto
			SB2->B2_LOCAL  ,; // Armazem
			nQuantidade    ,; // Quantidade
			SB1->B1_ZLOCALI,; // Localizacao
			Space(20)      ,; // Numero de Serie
			PadR(DtoS(dDataBase),9),;		// Doc
			"   ",;		// Serie
			"",;			// Cliente / Fornecedor
			"",;			// Loja
			"",;			// Tipo NF
			"ACE",;			// Origem do Movimento
			dDataBase,;		// Data
			"",;	// Lote
			"",; // Sub-Lote
			ProxNum(),;		// Numero Sequencial
			"499",;			// Tipo do Movimento
			"M",;			// Tipo do Movimento (Distribuicao/Movimento)
			StrZero(0,4),;		// Item
			.F.,;			// Flag que indica se e' mov. estorno
			0,;				// Quantidade empenhado
			0)		// Quantidade segunda UM

	GravaSBF("SDB")

Return


Static Function MudaParaControlar()

	Local lReturn := .F.

	RegToMemory("SB1",.F.,.F.,.F.)

	lReturn := AvalLocali(M->B1_COD,.F.)
	IF lReturn
		RecLock("SB1",.F.)
		SB1->B1_LOCALIZ := "S"
		SB1->( MsUnLock())
	EndIF

Return lReturn


/*
Static Function CriaSX1(cPerg)

	//PutSx1(cPerg,"01","Produto de? ","","","mv_ch1","C",15,00,0,"G","","SB1","","","mv_par01")
	//PutSx1(cPerg,"02","Produto ate?","","","mv_ch2","C",15,00,0,"G","","SB1","","","mv_par02")

Return*/