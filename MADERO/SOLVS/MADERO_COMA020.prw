#include 'protheus.ch'


/*/{Protheus.doc} MDRAvalToler
Função baseada na função MAAvalToler do fonte coma020.prw fazendo a tratativa esperada pelo madero

@author Rafael Ricardo Vieceli
@since 29/06/2018
@version 1.0
@return logical, se bloqueia
@param cFornece, characters, codigo de fornecedor
@param cLoja, characters, loja do fornecedor
@param cProduto, characters, Codigo do produto
@param nQtde, numeric, Quantidade avaliada
@param nQtdeOri, numeric, Quantidade Original
@param nPreco, numeric, Preço avaliada
@param nPrecoOri, numeric, Preço Original
@param lHelp, logical, Gera help
@param lQtde, logical, Avalia quantidade
@param lPreco, logical, Avalia Preço
@type function
/*/

//#TB20190418 Thiago Berna - Log Erro T01 - Quantidade e T02 - Valor
//user function MDRAvalToler(cFornece,cLoja,cProduto, nQtde, nQtdeOri, nPreco, nPrecoOri, lHelp, lQtde, lPreco )
User function MDRAvalToler(cFornece,cLoja,cProduto, nQtde, nQtdeOri, nPreco, nPrecoOri, lHelp, lQtde, lPreco, nPQtde, nPPreco ) 

	Local lAchou    := .F.
	Local lBloqueio := .F.
	Local lBLQTolNeg:= .F.
	
	//#TB20190418 Thiago Berna - Log Erro T01 - Quantidade e T02 - Valor
	//Local nPQtde    := 0
	//Local nPPreco   := 0
	
	Local lTolerNeg := GetMV("MV_TOLENEG",.F.,.F.)
	Local cGrpPrd

	DEFAULT nQtde    := 0
	DEFAULT nQtdeOri := 0
	DEFAULT nPreco   := 0
	DEFAULT nPrecoOri:= 0
	DEFAULT lHelp	 := .F.
	//#TB20190911 Thiago Berna - Ajuste para considerar as variaveis Default como .T.
	//Default lQtde	 := .F.
	//Default lPreco := .F.
	Default lQtde	 := .T.
	Default lPreco	 := .T.
	Default nPQtde   := 0
	Default nPPreco  := 0

	//Verifica o grupo do produto
	SB1->( dbSetOrder(1) )
	SB1->( msSeek( xFilial("SB1") + cProduto ) )

	cGrpPrd := SB1->B1_GRUPO

	//Pesquisa por todas as regras validas para este caso
	//AIC_FILIAL+AIC_FORNEC+AIC_LOJA+AIC_PRODUT+AIC_GRUPO
	AIC->( dbSetOrder(2) )

	// 1 procura por fornecedor + loja + produto
	//ou seja, tolerancia do produto para o forencedor especifico
	lAchou := AIC->( msSeek( xFilial("AIC") + cFornece + cLoja + cProduto ) )

	// 2 procura por Forencedor sem loja + Produto
	//ou seja, tolerancia do produto para os forencedores com o mesmo codigo
	IF ! lAchou
		lAchou := AIC->( msSeek(xFilial("AIC") + cFornece + sl(cLoja) + cProduto ) )
	EndIF

	// 3 procura por Forencedor + Loja + grupo de produtos
	//ou seja, tolerancia do grupo de produto para o forencedor especifico
	IF ! lAchou .And. ! Empty(cGrpPrd)
		lAchou := AIC->( msSeek( xFilial("AIC") + cFornece + cLoja + sl(cProduto) + cGrpPrd ) )
	EndIF

	// 4 procura por Forencedor sem Loja + grupo de produtos
	//ou seja, tolerancia do grupo de produto para os forencedores com o mesmo codigo
	IF ! lAchou .And. ! Empty(cGrpPrd)
		lAchou := AIC->( msSeek( xFilial("AIC") + cFornece + sl(cLoja) + sl(cProduto) + cGrpPrd ) )
	EndIF

	// 5 procura por Forencedor + Loja sem produto e sem grupo de produtos
	//ou seja, tolerancia de todos os produtos para o forencedor especifico
	IF ! lAchou
		lAchou := AIC->( msSeek( xFilial("AIC") + cFornece + cLoja + sl(cProduto) + sl(cGrpPrd) ) )
	EndIF

	// 6 procura por Forencedor sem Loja, sem produto e sem grupo de produtos
	//ou seja, tolerancia de todos os produtos para os forencedores com o mesmo codigo
	IF ! lAchou
		lAchou := AIC->( msSeek( xFilial("AIC") + cFornece + sl(cLoja) + sl(cProduto) + sl(cGrpPrd) ) )
	EndIF

	// 7 procura sem Forencedor e Loja, o produto, sem grupo de produtos
	//ou seja, tolerancia para o produto, indenpedente do Fornecedor
	IF ! lAchou
		lAchou := AIC->( msSeek( xFilial("AIC") + sl(cFornece+cLoja) + cProduto + sl(cGrpPrd) ) )
	EndIF

	// 8 procura sem Forencedor e Loja, sem o produto, o grupo de produtos
	//ou seja, tolerancia para o grupo de produto, indenpedente do Fornecedor
	IF ! lAchou .And. ! Empty(cGrpPrd)
		lAchou := AIC->( msSeek( xFilial("AIC") + sl(cFornece+cLoja) + sl(cProduto) + cGrpPrd ) )
	EndIF

	// 9 procura um vazio difinindo tolerancia geral
	//ou seja, é um valor padrão que não seja zero a tolerancia
	IF ! lAchou
		lAchou := AIC->( msSeek( xFilial("AIC") + sl(cFornece+cLoja) + sl(cProduto) + sl(cGrpPrd) ) )
	EndIF
     
	//Pesquisa por todas as regras validas para este caso
	IF ! AIC->( Eof() ) .And. lAchou
		nPPreco := AIC->AIC_PPRECO
		nPQtde  := AIC->AIC_PQTDE

		//#TB20190717 Thiago Berna - executa somente se encontrou
		//If lAchou
	
		//Se o parametro MV_TOLENEG estiver .T. o percentual de tolerancia
		//do preco e da quantidade passam a validar tambem os valores da
		//NFE que estiverem a menor que o PC aplicando o bloqueio quando os
		//valores ultrapassarem o percentual estabelecido da qtd e do Preco
		IF (nQtde+nQtdeOri) > 0 .Or. (nPreco+nPrecoOri) > 0
			IF lTolerNeg
				IF lQtde
					IF ABS(((nQtde / nQtdeOri) -1) * 100) > nPQtde
						lBLQTolNeg := .T.
					EndIF
				EndIF
				IF lPreco
					IF ABS(((nPreco / nPrecoOri) -1)*100) > nPPreco
						lBLQTolNeg := .T.
					EndIF
				EndIF
			EndIF
		EndIF

		IF lQtde .and.  lTolerNeg
			IF (nQtde+nQtdeOri) > 0
				IF ABS(((nQtde / nQtdeOri) -1)*100) > nPQtde .Or. lBLQTolNeg
					IF lHelp
						Help(" ",1,"QTDLIBMAI")
					EndIF
					lBloqueio := .T.
				EndIF
			EndIF
		ElseIf !lTolerNeg //27.01.2020 Validado
			//#TB20190703 Thiago Berna - Ajuste para quando o saldo for negativ
			If ABS(((nQtde / nQtdeOri) -1)*100) > nPQtde .And. nQtde > nQtdeOri .And. !lTolerNeg //27.01.2020 Validado
				IF lHelp
					Help(" ",1,"QTDLIBMAI")
				EndIF
				lBloqueio := .T.
			EndIf
		EndIF

		IF !lBloqueio .and. lPreco 
			If nPreco > nPrecoOri .and. !lTolerNeg //27.01.2020 Validado
				IF (nPreco+nPrecoOri) > 0
					IF ABS(((nPreco / nPrecoOri) -1)*100) > nPPreco .and. nPreco > nPrecoOri .Or. lBLQTolNeg
						IF lHelp
							Help(" ",1,"PRCLIBMAI")
						EndIF
						lBloqueio := .T.
					EndIF
				EndIF
			ElseIf lTolerNeg  //27.01.2020 Validado
				IF (nPreco+nPrecoOri) > 0
					IF ABS(((nPreco / nPrecoOri) -1)*100) > nPPreco //.Or. ABS(((nPreco / nPrecoOri) -1)*100) < nPPreco
						IF lHelp
							Help(" ",1,"PRCLIBMAI")
						EndIF
						lBloqueio := .T.
					EndIF
				EndIF
			Endif 
		EndIF 

	Endif


return lBloqueio

static function sl(value)
return space(len(value))