/**********************************************************************************************************************************/
/** SIGAFAT - Faturamento                                                                                                        **/
/** RETONA IMPOSTOS                                                                                                              **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi Indústria Brasileira Ltda.                                                                                            **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 25/05/2015 | Marcos Sulivan                 | Criação da rotina/procedimento.                                                **/
/** 04/07/2019 | Luiz Henrique Jacinto          | Correcao do calculo para ficar igual ao planilha.                              **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/**********************************************************************************************************************************/
/** user function CalcImp                                                                                                        **/
/**********************************************************************************************************************************/
User Function CalcImp(cPedidoV)
Local aArea		:=	GetArea()
Local aImp 		:= {0,0,0,0,0,0,0,0,0,0,0,0}
Local aTransp	:= {"",""}
Local nBasICM	:= 0
Local nValICM	:= 0
Local nValIPI	:= 0
Local nAlqICM	:= 0
Local nAlqIPI	:= 0
Local nValSol	:= 0
Local nBasSol	:= 0
Local nPrcUniSol:= 0
Local nTotSol	:= 0
Local nTotalST	:= 0
Local nTotIPI	:= 0
Local nValorTot	:= 0
Local nTotFrete	:= 0
Local nTotVal	:= 0
Local nItAtu	:= 0

SC5->(DBSeek(xFilial("SC5")+cPedidoV))

SA4->(dbSetOrder(1))
If SA4->(dbSeek(xFilial("SA4")+SC5->C5_TRANSP))
	aTransp[01] := SA4->A4_EST
	aTransp[02] := Iif(SA4->(FieldPos("A4_TPTRANS")) > 0,SA4->A4_TPTRANS,"")
Endif

MaFisIni(	SC5->C5_CLIENTE,;                   	 // 01 - Codigo Cliente/Fornecedor
			SC5->C5_LOJACLI,;                        // 02 - Loja do Cliente/Fornecedor
			Iif(SC5->C5_TIPO $ "D;B", "F", "C"),;    // 03 - C:Cliente , F:Fornecedor
			SC5->C5_TIPO,;                           // 04 - Tipo da NF
			SC5->C5_TIPOCLI,;                        // 05 - Tipo do Cliente/Fornecedor
			MaFisRelImp("MT100", {"SF2", "SD2"}),;   // 06 - Relacao de Impostos que suportados no arquivo
			,;                                       // 07 - Tipo de complemento
			,;                                       // 08 - Permite Incluir Impostos no Rodape .T./.F.
			"SB1",;                                  // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			"MATA461")                               // 10 - Nome da rotina que esta utilizando a funcao
		
nItAtu := 0
//Enquanto houver itens
SC6->(MsSeek(FWxFilial('SC6') + SC5->C5_NUM))
While ! SC6->(EoF()) .And. SC6->C6_NUM == SC5->C5_NUM
	nItAtu++
	//Adiciona o item nos tratamentos de impostos
	SB1->(MsSeek(FWxFilial("SB1")+SC6->C6_PRODUTO))
	MaFisAdd(	SC6->C6_PRODUTO,;         // 01 - Codigo do Produto                    ( Obrigatorio )
				SC6->C6_TES,;             // 02 - Codigo do TES                        ( Opcional )
				SC6->C6_QTDVEN,;          // 03 - Quantidade                           ( Obrigatorio )
				SC6->C6_PRCVEN,;          // 04 - Preco Unitario                       ( Obrigatorio )
				SC6->C6_VALDESC,;         // 05 - Desconto
				SC6->C6_NFORI,;           // 06 - Numero da NF Original                ( Devolucao/Benef )
				SC6->C6_SERIORI,;         // 07 - Serie da NF Original                 ( Devolucao/Benef )
				0,;                       // 08 - RecNo da NF Original no arq SD1/SD2
				0,;                       // 09 - Valor do Frete do Item               ( Opcional )
				0,;                       // 10 - Valor da Despesa do item             ( Opcional )
				0,;                       // 11 - Valor do Seguro do item              ( Opcional )
				0,;                       // 12 - Valor do Frete Autonomo              ( Opcional )
				SC6->C6_VALOR,;           // 13 - Valor da Mercadoria                  ( Obrigatorio )
				0,;                       // 14 - Valor da Embalagem                   ( Opcional )
				SB1->(RecNo()),;          // 15 - RecNo do SB1
				0)                        // 16 - RecNo do SF4
	
	MaFisLoad("IT_VALMERC", SC6->C6_VALOR, nItAtu)                
	//MaFisAlt("IT_PESO", nQtdPeso, nItAtu)
	
	SC6->(DbSkip())
EndDo
		
//Altera dados do cabeçalho
MaFisAlt("NF_FRETE"		, SC5->C5_FRETE		)
MaFisAlt("NF_SEGURO"	, SC5->C5_SEGURO	)
MaFisAlt("NF_DESPESA"	, SC5->C5_DESPESA	) 
MaFisAlt("NF_AUTONOMO"	, SC5->C5_FRETAUT	)

If SC5->C5_DESCONT > 0
	MaFisAlt("NF_DESCONTO", Min(MaFisRet(, "NF_VALMERC")-0.01, SC5->C5_DESCONT+MaFisRet(, "NF_DESCONTO")) )
EndIf

If SC5->C5_PDESCAB > 0
	MaFisAlt("NF_DESCONTO", A410Arred(MaFisRet(, "NF_VALMERC")*SC5->C5_PDESCAB/100, "C6_VALOR") + MaFisRet(, "NF_DESCONTO"))
EndIf

nItAtu 		:= 0
nTotalST	:= 0
nTotIPI		:= 0
nValorTot	:= 0
//Agora reposiciona nos itens para poder pegar os dados
SC6->(DbGoTop())
SC6->(MsSeek(FWxFilial('SC6') + SC5->C5_NUM))
While ! SC6->(EoF()) .And. SC6->C6_NUM == SC5->C5_NUM                
	nItAtu++
	//Pega os valores
	nBasICM    := MaFisRet(nItAtu, "IT_BASEICM")
	nValICM    := MaFisRet(nItAtu, "IT_VALICM")
	nValIPI    := MaFisRet(nItAtu, "IT_VALIPI")
	nAlqICM    := MaFisRet(nItAtu, "IT_ALIQICM")
	nAlqIPI    := MaFisRet(nItAtu, "IT_ALIQIPI")
	nValSol    := (MaFisRet(nItAtu, "IT_VALSOL") / SC6->C6_QTDVEN) 
	nBasSol    := MaFisRet(nItAtu, "IT_BASESOL")
	nPrcUniSol := SC6->C6_PRCVEN + nValSol
	nTotSol    := nPrcUniSol * SC6->C6_QTDVEN
	nTotalST   += MaFisRet(nItAtu, "IT_VALSOL")
	nTotIPI    += nValIPI
	nValorTot  += SC6->C6_VALOR
	
	aImp[3] := nBasSol + aImp[3]
	aImp[4] := nBasICM + aImp[4]

	SC6->(DbSkip())
EndDo

nTotFrete 	:= MaFisRet(, "NF_FRETE")
nTotVal 	:= MaFisRet(, "NF_TOTAL")

MaFisEnd()

// ICMS ST
aImp[1] := nTotalST 
// IPI
aImp[2] := nTotIPI 
// total do pedido
aImp[5] := nTotVal

RestArea(aArea)
Return (aImp)

// funcao usada para fazer teste dos pedidos
User function KPFATV03T()
	Local aRet := {}
	Local lEnv := .F.

	lEnv := StaticCall(KAP_WF03,environmentActions,1,"01","01",,,"SIGAFAT",{"SB1"})

	// 01 01 060772
	// icms st = 1078.28
	// total = 6900.25
	aRet := U_CalcImp("060772")
	// aRet[1] == 1078.28
	// aRet[5] == 6900.26
	If lEnv
		StaticCall(KAP_WF03,environmentActions,2)
	Endif

	lEnv := StaticCall(KAP_WF03,environmentActions,1,"04","01",,,"SIGAFAT",{"SB1"})

	// 04 01 291219 
	// icms st = 105.29
	// total = 769.29
	aRet := {}
	aRet := U_CalcImp("291219")
	// aRet[1] == 105.29
	// aRet[5] == 769.29
	If lEnv
		StaticCall(KAP_WF03,environmentActions,2)
	Endif

	aRet := {}
Return
