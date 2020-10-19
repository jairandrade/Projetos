#include 'protheus.ch'

//------------------------------
/*/{Protheus.doc} WS004
Rotina implementa o processo de Declínio do workflow de compras da TCP.

@author Lucas
@since 12/06/2014
@version 1.0

@param aDados, array, Dados para o processamento.

@return aRet Array com o retorno do processamento
/*/
//------------------------------
User Function WS004( aDados )

	Local aArea    := SaveArea1({"SC8","SA2"})
	Local aRet     := {}

	Local nTamFilial := TamSx3('C8_FILIAL')[1]
	Local nTamCotacao := TamSx3('C8_NUM')[1]
	Local nTamFornecedor := TamSx3('C8_FORNECE')[1]
	Local nTamLoja := TamSx3('C8_LOJA')[1]

	Local cFilialP     := substr(aDados[1], 1, nTamFilial)
	Local cNumCotacao  := substr(aDados[1], nTamFilial + 1, nTamCotacao)
	Local cFornecedor  := substr(aDados[1], nTamFilial + nTamCotacao + 1, nTamFornecedor)
	Local cLoja        := substr(aDados[1], nTamFilial + nTamCotacao + nTamFornecedor + 1, nTamLoja)
	Local cNumProposta := substr(aDados[1], nTamFilial + nTamCotacao + nTamFornecedor + nTamLoja + 1)

	Local aErro := {}
	Local cErro := ""

	SC8->( dbSetOrder(1) ) 
	SC8->( DbSeek( xFilial("SC8") + cNumCotacao  + cFornecedor + cLoja ) )  		

	while !SC8->(Eof()) .And. SC8->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA) == xFilial("SC8") + cNumCotacao  + cFornecedor + cLoja

		RecLock("SC8",.F.)
		SC8->(dbDelete())
		SC8->(MaAvalCot("SC8",3))
		SC8->(MsUnLock())
		
		SC8->(dbSkip())
	EndDO

	aRet := {.T., "Processo executado com sucesso!"}

	RestArea1(aArea)

Return aRet