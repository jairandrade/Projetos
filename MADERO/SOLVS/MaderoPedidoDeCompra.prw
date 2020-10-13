#include 'protheus.ch'

user function _MDRYK3Y()
return


/*/{Protheus.doc} MaderoPedidoDeCompra
Classe para montar informações do pedido de compra para montar o e-mail de alçadas


@author Rafael Ricardo Vieceli
@since 12/09/2018
@version 1.0

@type class
/*/
class MaderoPedidoDeCompra from longClassName

	data cNumero
	data dEmissao

	data cCodigoFornecedor
	data cLojaFornecedor
	data cNomeFornecedor
	data cFilNome
	data cFilCod

	data cComprador

	data nVlrProdutos
	data nDescontos
	data nAcrescimos
	data nValorTotal

	data cObservacoes

	data aItems

	data nNext

	method load(cNumero) constructor
	method Numero()
	method Emissao()
	method Fornecedor()
	method Comprador()
	method FilNome()
	method FilCod()

	method ValorProdutos()
	method Descontos()
	method Acrescimos()
	method ValorTotal()

	method Observacoes()

	method proximo()
	method item()
	method temMaisItens()

	method clear()

endclass


/*/{Protheus.doc} load
Metodo para carregar o pedido inteiro

@author Rafael Ricardo Vieceli
@since 12/09/2018
@version 1.0
@param cNumero, characters, Numero do pedido
@type function
/*/
method load(cNumero) class MaderoPedidoDeCompra

	Local cAlias := getNextAlias()

	::clear()

	IF ! empty(cNumero) .And. SC7->C7_NUM != cNumero
		SC7->( dbSetOrder(1) )
		SC7->( msSeek( xFilial("SC7") + cNumero ) )
	EndIF

	::cNumero  := SC7->C7_NUM
	::dEmissao := SC7->C7_EMISSAO

	//fornecedor
	SA2->( dbSetOrder(1) )
	SA2->( msSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA ) )

	::cCodigoFornecedor := alltrim(SA2->A2_COD)
	::cLojaFornecedor   := alltrim(SA2->A2_LOJA)
	::cNomeFornecedor   := alltrim(SA2->A2_NOME)
	::cFilCod			:= alltrim(SC7->C7_FILIAL)

	//comprador
	::cComprador := UsrFullName(SC7->C7_USER)

	//Obter o nome da Filial
	dbSelectArea("ADK")
	DbOrderNickName("ADKXFILI")
	ADK->( msSeek( xFilial("ADK") + SC7->C7_FILIAL))
	
	::cFilNome := ADK->ADK_NOME

	BeginSQL Alias cAlias
		%noparser%

		// select
		// 	C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_UM, C7_QUANT, C7_PRECO, C7_TOTAL, C7_CC, C7_ITEMCTA, '' as C7_XOBS,
		// 	C7_VLDESC, C7_SEGURO, C7_DESPESA, C7_VALFRE, C7_OBS

		// from %table:SC7% SC7

		// where
		//     SC7.C7_FILIAL  = %xFilial:SC7%
		// and SC7.C7_NUM     = %Exp: self:cNumero %
		// and SC7.D_E_L_E_T_ = ' '

		SELECT
			C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_UM, C7_QUANT, C7_PRECO, C7_TOTAL, C7_CC, C7_ITEMCTA, C7_XOBS,
			C7_VLDESC, C7_SEGURO, C7_DESPESA, C7_VALFRE, C7_OBS, C7_NUM,CTT_DESC01, CTD_DESC01
		FROM %table:SC7% SC7
		LEFT JOIN %table:CTT% CTT ON CTT.CTT_CUSTO = SC7.C7_CC
		LEFT JOIN %table:CTD% CTD ON CTD.CTD_ITEM = SC7.C7_ITEMCTA
		WHERE SC7.C7_FILIAL  = %xFilial:SC7%
		AND SC7.C7_NUM     = %Exp: self:cNumero %
		AND SC7.D_E_L_E_T_ = ' '

	EndSQL

	While ! (cAlias)->( Eof() )

		::nVlrProdutos += (cAlias)->C7_TOTAL
		::nDescontos   += (cAlias)->C7_VLDESC
		::nAcrescimos  += (cAlias)->(C7_SEGURO+C7_DESPESA+C7_VALFRE)
		::nValorTotal  += (cAlias)->(C7_TOTAL+C7_SEGURO+C7_DESPESA+C7_VALFRE -C7_VLDESC)

		IF ! alltrim((cAlias)->C7_OBS) $ ::cObservacoes
			IF ! empty(::cObservacoes) .And. right(::cObservacoes,1) != "."
				::cObservacoes += '.'
			EndIF
			::cObservacoes += ' ' + alltrim((cAlias)->C7_OBS)
		EndIF

		aAdd( ::aItems, MaderoPedidoDeCompraItem():load(cAlias) )

		(cAlias)->(dbSkip())
	EndDO

	//fecha alias
	(cAlias)->( dbCloseArea() )

	::nValorTotal 	:= SCR->CR_TOTAL
	::nAcrescimos 	:= SCR->CR_TOTAL - ::nVlrProdutos
return


/*/{Protheus.doc} clear
Limpa o objeto

@author Rafael Ricardo Vieceli
@since 12/09/2018
@version 1.0

@type function
/*/
method clear() class MaderoPedidoDeCompra

	::cNumero := ''
	::dEmissao := stod('')
	::cCodigoFornecedor := ''
	::cLojaFornecedor := ''
	::cNomeFornecedor := ''
	::cComprador      := ''
	::nVlrProdutos := 0
	::nDescontos   := 0
	::nAcrescimos  := 0
	::nValorTotal  := 0
	::cObservacoes := ''
	::aItems       := {}
	::cFilNome			:= ''
	::cFilCod			:= ''

return

//retorna o numero do pedido
method Numero() class MaderoPedidoDeCompra
return ::cNumero

//retorna a emissao (se passa .T. já retorna caracter formatado)
method Emissao(lString) class MaderoPedidoDeCompra
default lString := .F.
return IIF(lString,FormDate(::dEmissao),::dEmissao)

//fornecedor, se passar
// 'CODIGO' => retorna o CODIGO
// 'LOJA'   => retorna a LOJA
// 'NOME'   => retorna o NOME
// nada     => CODIGO/LOJA NOME
method Fornecedor(cInfo) class MaderoPedidoDeCompra
	default cInfo := ''
	do case
		case upper(cInfo) == "CODIGO"
			return ::cCodigoFornecedor
		case upper(cInfo) == "LOJA"
			return ::cLojaFornecedor
		case upper(cInfo) == "NOME"
			return ::cNomeFornecedor
	endcase
return ::cCodigoFornecedor + "/" + ::cLojaFornecedor + " " + ::cNomeFornecedor

//comprador
method Comprador() class MaderoPedidoDeCompra
return alltrim(::cComprador)

//soma do valor dos produtos
method ValorProdutos() class MaderoPedidoDeCompra
return alltrim(transForm( ::nVlrProdutos, pesqPict('SC7','C7_TOTAL')))

//soma dos descontos
method Descontos() class MaderoPedidoDeCompra
return alltrim(transForm( ::nDescontos, pesqPict('SC7','C7_TOTAL')))

//soma dos acrescimos
method Acrescimos() class MaderoPedidoDeCompra
return alltrim(transForm( ::nAcrescimos, pesqPict('SC7','C7_TOTAL')))

//valor total
method ValorTotal() class MaderoPedidoDeCompra
return alltrim(transForm( ::nValorTotal, pesqPict('SC7','C7_TOTAL')))

//observações do pedido
method Observacoes() class MaderoPedidoDeCompra
return alltrim(::cObservacoes)

//Cod Filial
method FilNome() class MaderoPedidoDeCompra
return alltrim(::cFilNome)

//Nome Filial
method FilCod() class MaderoPedidoDeCompra
return alltrim(::cFilCod)

//controle para percorer os itens
method proximo() class MaderoPedidoDeCompra
	default ::nNext := 0
	::nNext ++
	IF (::nNext <= len(::aItems) )
		return .T.
	EndIF
	::nNext := nil
return .F.

//controle para retornar o item
method item(nItem) class MaderoPedidoDeCompra
	default nItem := ::nNext
return ::aItems[nItem]

//controle para verificar se tem mais itens
method temMaisItens() class MaderoPedidoDeCompra
	IF ::nNext == nil
		return .F.
	EndIF
return (::nNext + 1) <= len(::aItems)





/*/{Protheus.doc} MaderoPedidoDeCompraItem
Classe para montar as informações do item do pedido

@author Rafael Ricardo Vieceli
@since 12/09/2018
@version 1.0

@type class
/*/
class MaderoPedidoDeCompraItem from LongClassName

	data cItem
	data cProduto
	data cDescricao
	data cUnidadeMedida
	data nQuantidade
	data nValorUnitario
	data nValorTotal
	data cCentroDeCusto
	data cItemContabil
	data cObservacao

	method load(cAlias) constructor
	method Item()
	method Produto()
	method Descricao()
	method UnidadeMedida()
	method Quantidade()
	method ValorUnitario()
	method ValorTotal()
	method CentroDeCusto()
	method ItemContabil()
	method Observacao()

endclass


/*/{Protheus.doc} load
Metodo para carregar o item do pedido

@author Rafael Ricardo Vieceli
@since 12/09/2018
@version 1.0
@param cAlias, characters, Alias da consulta SQL ou da tabela
@type function
/*/
method load(cAlias) class MaderoPedidoDeCompraItem

	default cAlias := 'SC7'

	::cItem          := (cAlias)->C7_ITEM
	::cProduto       := (cAlias)->C7_PRODUTO
	::cDescricao     := (cAlias)->C7_DESCRI
	::cUnidadeMedida := (cAlias)->C7_UM
	::nQuantidade    := (cAlias)->C7_QUANT
	::nValorUnitario := (cAlias)->C7_PRECO
	::nValorTotal    := (cAlias)->C7_TOTAL
	::cCentroDeCusto := (cAlias)->C7_CC   + ' - ' + (cAlias)->CTT_DESC01
	::cItemContabil  := (cAlias)->C7_ITEMCTA + ' - ' +(cAlias)->CTD_DESC01
	::cObservacao    := (cAlias)->C7_XOBS

return

//retorna o item
method Item() class MaderoPedidoDeCompraItem
return alltrim(::cItem)

//retorna o produto
method Produto() class MaderoPedidoDeCompraItem
return alltrim(::cProduto)

//retorna a descrição
method Descricao() class MaderoPedidoDeCompraItem
return alltrim(::cDescricao)

//retorna a unidade de medida
method UnidadeMedida() class MaderoPedidoDeCompraItem
return alltrim(::cUnidadeMedida)

//retorna a quantidade formadata conforme o campo
method Quantidade() class MaderoPedidoDeCompraItem
return alltrim(transForm( ::nQuantidade, pesqPict('SC7','C7_QUANT')))

//retorna o valor unitario formadato conforme o campo
method ValorUnitario() class MaderoPedidoDeCompraItem
return alltrim(transForm( ::nValorUnitario, pesqPict('SC7','C7_PRECO')))

//retorna o valor total formadato conforme o campo
method ValorTotal() class MaderoPedidoDeCompraItem
return alltrim(transForm( ::nValorTotal, pesqPict('SC7','C7_TOTAL')))

//retorna o centro de custo
method CentroDeCusto() class MaderoPedidoDeCompraItem
return alltrim(::cCentroDeCusto)

//retorna o item contabil
method ItemContabil() class MaderoPedidoDeCompraItem
return alltrim(::cItemContabil)

//retorna a observação
method Observacao() class MaderoPedidoDeCompraItem
return alltrim(::cObservacao)