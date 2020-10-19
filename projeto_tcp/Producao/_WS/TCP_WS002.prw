#INCLUDE 'PROTHEUS.CH'               
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'FILEIO.CH'
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

/*---------------------------------------------------------------------------+
|                         FICHA TECNICA DO PROGRAMA                          |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Atualização                                             |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_WS002.PRW                                           |
+------------------+---------------------------------------------------------+
|Descricao         | Busca os produtos da cotação                            |
+------------------+---------------------------------------------------------+
|Autor             | Lucas Jose Correa Chagas.                               |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 21/05/2013                                              |
+------------------+--------------------------------------------------------*/
User Function WS002( cChave )

Local aArea    := GetArea()
Local aRet     := {}
Local aDet     := {}
Local aLinha   := {}
Local cAlias   := getNextAlias()
Local cQuery   := ''
Local cFilialP := substr(cChave, 1, TamSx3('C8_FILIAL')[1]) 
Local cNum     := substr(cChave, TamSx3('C8_FILIAL')[1] + 1, TamSx3('C8_NUM')[1])
Local cFornece := substr(cChave, TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] + 1, TamSx3('C8_FORNECE')[1])
Local cLoja    := substr(cChave, TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] + TamSx3('C8_FORNECE')[1] + 1, TamSx3('C8_LOJA')[1])
Local cNumPro  := substr(cChave, TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] + TamSx3('C8_FORNECE')[1] + TamSx3('C8_LOJA')[1] + 1)

BeginSql Alias cAlias
	SELECT 
		SC8.C8_ITEM, SC8.C8_PRODUTO, SC8.C8_QUANT, SC8.C8_PRAZO,
		SC8.C8_ALIIPI, SC8.C8_PICM, SB1.B1_DESC
		//CASE 
		//	WHEN RTRIM(LTRIM(SB5.B5_CEME)) <> '' THEN SB5.B5_CEME
		//	ELSE SB1.B1_DESC
		//END AS B1_DESC 
	FROM 
		%table:SC8% SC8
	INNER JOIN %table:SB1% SB1 ON 
		SB1.B1_FILIAL = %xFilial:SB1%
		AND SB1.B1_COD = SC8.C8_PRODUTO 
		AND SB1.%NotDel%
//	LEFT JOIN %table:SB5% SB5 ON 
//		SB5.B5_FILIAL = %xFilial:SB5%
//		AND SB5.B5_COD = SB1.B1_COD 
//		AND SB5.%NotDel%
	WHERE 
		SC8.C8_FILIAL = %EXP:cFilialP%
		AND SC8.C8_NUM = %EXP:cNum%
		AND SC8.C8_FORNECE = %EXP:cFornece%
		AND SC8.C8_LOJA = %EXP:cLoja%
		AND SC8.C8_NUMPRO = %EXP:cNumPro%	
		AND SC8.C8_XHOMFOR NOT IN ('VE','NH')
		AND SC8.%NotDel%         
endSql

While (cAlias)->(!EOF())

	SB5->( dbSetOrder(1) )
	SB5->( dbSeek( xFilial("SB5") + (cAlias)->C8_PRODUTO ) )

	aLinha := {}
	aAdd(aLinha,(cAlias)->C8_ITEM                                          )
	aAdd(aLinha,(cAlias)->C8_PRODUTO                                       )
	aAdd(aLinha,AllTrim(IIF(!Empty(SB5->B5_DCOMPR),SB5->B5_DCOMPR,IIF(!Empty(SB5->B5_CEME),SB5->B5_CEME,(cAlias)->B1_DESC)))                                 )
	//aAdd(aLinha,AllTrim((cAlias)->B1_DESC)                                 )
	aAdd(aLinha,Transform((cAlias)->C8_QUANT , PesqPict("SC8","C8_QUANT" )))
	
	aAdd(aDet, aLinha)

	(cAlias)->(DbSkip())
EndDo

dbCloseArea(cAlias)

// verifica se foi achado algum detalhe para retorno
if (len(aDet) > 0)
	// define a primeira posição do array como true, indicando que foi encontrado algum registro
	aAdd(aRet, .T.)
	aAdd(aRet, aClone(aDet))
else
	// adiciona o retorno falso como padrão - indica que nenhum registro foi encontrado
	aAdd(aRet,.F.)
	aAdd(aRet,'ERRO005')
	aAdd(aRet,'Itens da cotação não encontrados. / Items quotation not found.')	
endif

RestArea(aArea)

Return aRet
