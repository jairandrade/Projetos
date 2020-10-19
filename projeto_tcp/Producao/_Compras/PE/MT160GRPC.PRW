#include "protheus.ch"


/*/{Protheus.doc} MT160GRPC
Ponto de entrada na Analise da Cotação
Funcao : Gravar a natureza na tabela SC7(Pedido de Compras)
a partir  da tabela SC8 (Cotação)

@author Edilson Marques
@since 06/11/2012
@version 2.0
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6085534
/*/
User Function MT160GRPC()

	//Array contendo os fornecedores vencedores da cotação
	Local aVencedor := ParamIXB[1]
	//Array contendo as informações dos fornecedores
	Local aSC8      := ParamIXB[2]

	Local aSaveArea := SaveArea1({"SED"})

	//atualiza o campo de natureza com a natureza digitada na cotação
	SC7->C7_XNATURE := SC8->C8_XNATURE
	SC7->C7_XGARANT := SC8->C8_XGARANT
	SC7->C7_XDESCGA := SC8->C8_XDESCGA
	SC7->C7_XTERMOS  := SC8->C8_XTERMOS
	SC7->C7_XCAPEX   := SC8->C8_XCAPEX 
	SC7->C7_XTMPGAR := SC8->C8_XTMPGAR 

	//preencher a conta contabil com a conta padrão da Natureza
	//se exitir (vinda da solicitação), sobrepoem
	SED->( dbSetOrder(1) )
	SED->( dbSeek( xFilial("SED") + SC8->C8_XNATURE ) )

	//se achar a natureza
	IF SED->( Found() )
		//se a conta estiver preenchida
		IF !Empty(SED->ED_CONTA)
			//altera/sobrepoem
			SC7->C7_CONTA := SED->ED_CONTA
		EndIF
	EndIF

	RestArea1(aSaveArea)

Return NIL