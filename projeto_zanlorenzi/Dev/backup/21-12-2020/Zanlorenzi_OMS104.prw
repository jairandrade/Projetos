#include "tbiconn.ch"
#Include "protheus.ch"

/*/{Protheus.doc} OMS104
Modelo 2 EM mvc para cadastro de REGIOES x transportadoras na tabela ZA5
@author Jair Andrade
@since 09/12/2020
@version 1.0
    @return Nil, Fun��o n�o tem retorno
    @example
/*/

User Function OMS104()
	Local aCab      := {}   // Array do Cabe�alho da Carga
	Local aItem     := {}   // Array dos Pedidos da Carga
	Local cTransp   := ""
	Local cPedido   := ""

	PREPARE ENVIRONMENT EMPRESA cEmpant FILIAL cFilant MODULO "OMS"

	Private lMsHelpAuto := .T. //Variavel de controle interno do ExecAuto
	Private lMsErroAuto := .F. //Variavel que informa a ocorr�ncia de erros no ExecAuto

	aCab := {{"DAK_FILIAL", xFilial("DAK"),        Nil},;
		{"DAK_COD"   , GETSX8NUM("DAK","DAK_COD"), Nil},; //Campo com inicializador padr�o para pegar GESX8NUM
	    {"DAK_SEQCAR", "01",                       Nil},;
		{"DAK_ROTEIR", "999999",                   Nil},;
		{"DAK_CAMINH", "",                         Nil},;
		{"DAK_MOTORI", "",                         Nil},;
		{"DAK_PESO"  , 0,                          Nil},; // Calculado pelo OMSA200
	    {"DAK_DATA"  , DATE(),                     Nil},;
		{"DAK_HORA"  , TIME(),                     Nil},;
		{"DAK_JUNTOU", "Manual",                   Nil},;
		{"DAK_ACECAR", "2",                        Nil},;
		{"DAK_ACEVAS", "2",                        Nil},;
		{"DAK_ACEFIN", "2",                        Nil},;
		{"DAK_FLGUNI", "2",                        Nil},; //Campo com inicializador padr�o  - 2
	    {"DAK_TRANSP", cTransp,                    Nil}}

	// Posiciona no primeiro pedido de venda
	cPedido := "000013"
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+cPedido))
	// Posiciona no cliente do primeiro pedido
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE))
	// Informa��es do primeiro pedido
	// Este array n�o tem o formato padr�o de execu��es autom�ticas
	Aadd(aItem, {aCab[2,2],; // 01 - C�digo da carga
        "999999" ,; // 02 - C�digo da Rota - 999999 (Gen�rica)
        "999999" ,; // 03 - C�digo da Zona - 999999 (Gen�rica)
        "999999" ,; // 04-  C�digo do Setor - 999999 (Gen�rico)
        SC5->C5_NUM   ,; // 05 - C�digo do Pedido Venda
        SA1->A1_COD   ,; // 06 - C�digo do Cliente
        SA1->A1_LOJA  ,; // 07 - Loja do Cliente
        SA1->A1_NOME  ,; // 08 - Nome do Cliente
        SA1->A1_BAIRRO,; // 09 - Bairro do Cliente
        SA1->A1_MUN   ,; // 10 - Munic�pio do Cliente
        SA1->A1_EST   ,; // 11 - Estado do Cliente
        SC5->C5_FILIAL,; // 12 - Filial do Pedido Venda
        SA1->A1_FILIAL,; // 13 - Filial do Cliente
        0             ,; // 14 - Peso Total dos Itens
        0             ,; // 15 - Volume Total dos Itens
        "08:00"       ,; // 16 - Hora Chegada
        "0001:00"     ,; // 17 - Time Service
        Nil           ,; // 18 - N�o Usado
        dDatabase     ,; // 19 - Data Chegada
        dDatabase     ,; // 20 - Data Sa�da
        Nil           ,; // 21 - N�o Usado
        Nil           ,; // 22 - N�o Usado
        0             ,; // 23 - Valor do Frete
        0             ,; // 24- Frete Autonomo
        0             ,; // 25 - Valor Total dos Itens (Calculado pelo OMSA200)
        0             ,; // 26 - Quantidade Total dos Itens (Calculado pelo OMSA200)
        Nil           ,; // 27 - N�o usado
        "000002"      }) // 28 - Transportadora redespachante (n�o obrigat�rio)

	// Posiciona no segundo pedido de venda
	cPedido := "000013"
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+cPedido))
	// Posiciona no cliente do segundo pedido
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE))
	// Informa��es do segundo pedido
	// Este array n�o tem o formato padr�o de execu��es autom�ticas
	Aadd(aItem, {aCab[2,2],; // 01 - C�digo da carga
        "999999" ,; // 02 - C�digo da Rota - 999999 (Gen�rica)
        "999999" ,; // 03 - C�digo da Zona - 999999 (Gen�rica)
        "999999" ,; // 04-  C�digo do Setor - 999999 (Gen�rico)
        SC5->C5_NUM   ,; // 05 - C�digo do Pedido Venda
        SA1->A1_COD   ,; // 06 - C�digo do Cliente
        SA1->A1_LOJA  ,; // 07 - Loja do Cliente
        SA1->A1_NOME  ,; // 08 - Nome do Cliente
        SA1->A1_BAIRRO,; // 09 - Bairro do Cliente
        SA1->A1_MUN   ,; // 10 - Munic�pio do Cliente
        SA1->A1_EST   ,; // 11 - Estado do Cliente
        SC5->C5_FILIAL,; // 12 - Filial do Pedido Venda
        SA1->A1_FILIAL,; // 13 - Filial do Cliente
        0             ,; // 14 - Peso Total dos Itens (Calculado pelo OMSA200)
        0             ,; // 15 - Volume Total dos Itens (Calculado pelo OMSA200)
        "08:00"       ,; // 16 - Hora Chegada
        "0001:00"     ,; // 17 - Time Service
        Nil           ,; // 18 - N�o Usado
        dDatabase     ,; // 19 - Data Chegada
        dDatabase     ,; // 20 - Data Sa�da
        Nil           ,; // 21 - N�o Usado
        Nil           ,; // 22 - N�o Usado
        0             ,; // 23 - Valor do Frete
        0             ,; // 24 - Frete Autonomo
        0             ,; // 25 - Valor Total dos Itens (Calculado pelo OMSA200)
        0             ,; // 26 - Quantidade Total dos Itens (Calculado pelo OMSA200)
        Nil           ,; // 27 - N�o usado
        "000002"      }) // 28 - Transportadora redespachante (n�o obrigat�rio)

	SetFunName("OMSA200")

	MSExecAuto( { |x, y, z| OMSA200(x, y, z) }, aCab, aItem, 3 )

	If lMsErroAuto
		Alert("Erro no ExecAuto do OMSA200")
		cMsgErro := MostraErro()
		DisarmTransaction()
		Alert(cMsgErro)
	Else
		Alert("Sucesso na execu��o do ExecAuto OMSA200")
	EndIf

	RESET ENVIRONMENT

Return
