#include 'protheus.ch'

user function _MDRP9XTW()
return

#define posParcela    1
#define posVencimento 2
#define posValor      3


/*/{Protheus.doc} MaderoDocumentoDeEntrada
Classe para montar informações da nota de entrada de compra para montar o e-mail de alçadas


@author Rafael Ricardo Vieceli
@since 12/09/2018
@version 1.0

@type class
/*/
class MaderoDocumentoDeEntrada from longClassName

	data cDocumento
	data cSerie
	data dEmissao
	data dDigitacao
	data cFilNome
	data cFilCod

	data cCodigoFornecedor
	data cLojaFornecedor
	data cNomeFornecedor

	data cComprador

	data nValorTotal

	data aParcelas

	data nNext

	method load(cDocumento,cSerie,cFornecedor,cLoja) constructor
	method Documento()
	method Serie()
	method Emissao()
	method Digitacao()
	method Fornecedor()
	method Comprador()
	method FilNome()
	method FilCod()

	method ValorTotal()

	method proximo()
	method Parcela(nItem)
	method Vencimento(nItem,lString)
	method Valor(nItem)
	method temMaisItens()

	method clear()

endclass


/*/{Protheus.doc} load
Metodo para carregar a nota com pas parcelas

@author Rafael Ricardo Vieceli
@since 12/09/2018
@version 1.0
@param cDocumento, characters, Documento
@param cSerie, characters, Serie
@param cFornecedor, characters, Fornecedor
@param cLoja, characters, Loja
@type function
/*/
method load(cDocumento, cSerie, cFornecedor, cLoja) class MaderoDocumentoDeEntrada

	::clear()

	IF ! empty(cDocumento) .And. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) != (cDocumento + cSerie + cFornecedor + cLoja)
		SF1->( dbSetOrder(1) )
		SF1->( msSeek( xFilial("SF1") + cDocumento + cSerie + cFornecedor + cLoja ) )
	EndIF

	::cDocumento := SF1->F1_DOC
	::cSerie     := SF1->F1_SERIE
	::dEmissao   := SF1->F1_EMISSAO
	::dDigitacao   := SF1->F1_DTDIGIT
	::cFilCod := SF1->F1_FILIAL

	//Obter o nome da Filial
	dbSelectArea("ADK")
	DbOrderNickName("ADKXFILI")
	ADK->( msSeek( xFilial("ADK") + SF1->F1_FILIAL))
	
	::cFilNome := ADK->ADK_NOME

	//fornecedor
	SA2->( dbSetOrder(1) )
	SA2->( msSeek( xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA ) )

	::cCodigoFornecedor := alltrim(SA2->A2_COD)
	::cLojaFornecedor   := alltrim(SA2->A2_LOJA)
	::cNomeFornecedor   := alltrim(SA2->A2_NOME)


	//comprador
	::cComprador := getCompradores()

	Z35->( dbSetOrder(1) )
	Z35->( dbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ) )

	While ! Z35->( Eof() ) .And. Z35->(Z35_FILIAL+Z35_DOC+Z35_SERIE+Z35_FORNEC+Z35_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

		aAdd( ::aParcelas, { Z35->Z35_PARCEL ,Z35->Z35_VENCTO,Z35->Z35_VALOR})

		::nValorTotal += Z35->Z35_VALOR

		//proximo
		Z35->(dbSkip())
	EndDO


	::nValorTotal := SCR->CR_TOTAL
return


static function getCompradores()

	Local cNome
	Local cComprador := ''

	//posiciono no primeiro item do pedido
	SD1->( dbSetOrder(1) )
	SD1->( dbSeek( SF1->( F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) ) )

	While ! SD1->( Eof() ) .And. SD1->( D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ) == SF1->( F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )
		IF ! empty( SD1->D1_PEDIDO )

			SC7->( dbSetOrder(1) )
			SC7->( msSeek( xFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC ) )

			//pega o nome do comprador
			cNome := UsrFullName(SC7->C7_USER)
			IF !cNome $ cComprador
				IF ! empty(cComprador)
					cComprador += ', '
				EndIF
				cComprador += cNome
			EndIF
		EndIF

		SD1->(dbSkip())
	EndDO


return cComprador


/*/{Protheus.doc} clear
Limpa o objeto

@author Rafael Ricardo Vieceli
@since 12/09/2018
@version 1.0

@type function
/*/
method clear() class MaderoDocumentoDeEntrada

	::cDocumento        := ''
	::cSerie            := ''
	::dEmissao          := stod('')
	::dDigitacao        := stod('')
	::cCodigoFornecedor := ''
	::cLojaFornecedor   := ''
	::cNomeFornecedor   := ''
	::cComprador        := ''
	::nValorTotal       := 0
	::aParcelas         := {}
	::cFilNome			:= ''
	::cFilCod			:= ''

return

//retorna o numero da nota
method Documento() class MaderoDocumentoDeEntrada
return alltrim(::cDocumento)

//retorna a serie da nota
method Serie() class MaderoDocumentoDeEntrada
return alltrim(::cSerie)

//retorna a emissao (se passa .T. já retorna caracter formatado)
method Emissao(lString) class MaderoDocumentoDeEntrada
default lString := .F.
return IIF(lString,FormDate(::dEmissao),::dEmissao)

//retorna a emissao (se passa .T. já retorna caracter formatado)
method Digitacao(lString) class MaderoDocumentoDeEntrada
default lString := .F.
return IIF(lString,FormDate(::dDigitacao),::dDigitacao)

//fornecedor, se passar
// 'CODIGO' => retorna o CODIGO
// 'LOJA'   => retorna a LOJA
// 'NOME'   => retorna o NOME
// nada     => CODIGO/LOJA NOME
method Fornecedor(cInfo) class MaderoDocumentoDeEntrada
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
method Comprador() class MaderoDocumentoDeEntrada
return alltrim(::cComprador)

//Cod Filial
method FilNome() class MaderoDocumentoDeEntrada
return alltrim(::cFilNome)

//Nome Filial
method FilCod() class MaderoDocumentoDeEntrada
return alltrim(::cFilCod)

//valor total
method ValorTotal() class MaderoDocumentoDeEntrada
return alltrim(transForm( ::nValorTotal, pesqPict('SF1','F1_VALBRUT')))

//controle para percorer os itens
method proximo() class MaderoDocumentoDeEntrada
	default ::nNext := 0
	::nNext ++
	IF (::nNext <= len(::aParcelas) )
		return .T.
	EndIF
	::nNext := nil
return .F.

//controle para retornar o item
method Parcela(nItem) class MaderoDocumentoDeEntrada
	default nItem := ::nNext
return ::aParcelas[nItem][posParcela]

//controle para retornar o item
method Vencimento(nItem,lString) class MaderoDocumentoDeEntrada
	default lString := .F.
	default nItem := ::nNext
return IIF(lString,FormDate(::aParcelas[nItem][posVencimento]),::aParcelas[nItem][posVencimento])

//controle para retornar o item
method Valor(nItem) class MaderoDocumentoDeEntrada
	default nItem := ::nNext
return alltrim(transForm( ::aParcelas[nItem][posValor], pesqPict('SE1','E1_VALOR')))


//controle para verificar se tem mais itens
method temMaisItens() class MaderoDocumentoDeEntrada
	IF ::nNext == nil
		return .F.
	EndIF
return (::nNext + 1) <= len(::aParcelas)