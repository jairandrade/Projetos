#include 'protheus.ch'




/*/{Protheus.doc} MDRCalcHoraApto
	Gatilho para o campo H6_QTDPROD atualizar o campo H6_TEMPO com base no tempo padrão do roteiro

	u_MDRCalcHoraApto(M->H6_OP, M->H6_PRODUTO, M->H6_OPERAC, M->H6_QTDPROD)

@author Rafael Ricardo Vieceli
@since 14/04/2018
@version 1.0
@return ${return}, Quantidade de horas
@param cOrdemProducao, characters, Numero da ordem de produção
@param cOperacao, characters, numero da operação
@param nQuantidade, numeric, Quantidade produzida
@type function
/*/
user function MDRCalcHoraApto(cOrdemProducao, cOperacao, nQuantidade)

	Local aArea  := {}
	Local nTempo := 0

	//salva as areas
	aEval({"SC2","SB1","SG2"},{|alias| aAdd( aArea, getArea(alias) ) })

	//posiciona no OP
	SC2->( dbSetOrder(1) )
	SC2->( dbSeek( xFilial("SC2") + cOrdemProducao ) )

	//procura o roteiro
	IF a630SeekSG2(1, SC2->C2_PRODUTO, xFilial('SG2') + SC2->C2_PRODUTO + SC2->C2_ROTEIRO + cOperacao)

		//tempo padrão para 1 unidade
		nTempo := SG2->G2_TEMPAD

		//se for definido um lote, então o tempo é para uma determinada quantidade
		IF SG2->G2_LOTEPAD > 0
			//então temos que dividir o tempo pelo lote, para acharmos o tempo padrão para 1 unidade
			nTempo /= SG2->G2_LOTEPAD
		EndIF

		//e multiplica pela quantidade produzida para chegar no tempo total
		//ou seja, quantidade * tempo padrão para 1 unidade = tempo total
		nTempo *= nQuantidade

	EndIF

	//volta posições dos alias usados
	aEval(aArea,{|area| restArea(area) })

return convertTo(nTempo)



static function convertTo(nTempo)

	Local nZeros   := At(":", PesqPict("SH6", "H6_TEMPO")) - 1
	Local cTime    := intToHora(nTempo, nZeros, .T.)
	Local cTpHr    := SuperGetMv("MV_TPHR")
	Local cForHora := IIF( IsInCallStack("A680Inclui") .And. mv_par03 == 1, "N", "C")

return A680ConvHora(cTime, cTpHr, cForHora)