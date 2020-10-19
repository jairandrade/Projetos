#INCLUDE 'PROTHEUS.CH'               
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'FILEIO.CH'
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF chr(13) + chr(10)

/*---------------------------------------------------------------------------+
|                         FICHA TECNICA DO PROGRAMA                          |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Atualização                                             |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_WS003.PRW                                           |
+------------------+---------------------------------------------------------+
|Descricao         | WebServices Portal Confirmação de Cotações              |
+------------------+---------------------------------------------------------+
|Autor             | Lucas Jose Correa Chagas.                               |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 24/05/2013                                              |
+------------------+--------------------------------------------------------*/
User Function WS003( aChave )

Local aArea     := GetArea()
Local aRet      := {}
Local aCabec    := {}
Local aLinha    := {}
Local aItens    := {}
Local cCondicao := SuperGetMv('TCP_C8COND',.T.,'000')
Local cAlias    := ''//GetNextAlias()
Local cQuery    := ''
Local nCount    := 0
Local aEmails   := {}

// dados oriundos da pagina http
Local cId        := aChave[1]      // chave da cotação
Local cNumOrc    := aChave[2]      // Numero do orcamento enviado pelo fornecedor
Local cTipoFrete := aChave[3]      // tipo de frete
Local cProposta  := aChave[4]      // numero da proposta
Local aProdutos  := aChave[5]      // produtos da cotação           
Local cTipoPgto  := aChave[7]      // tipo do pagamento           
Local nFrete     := val(STRTRAN(STRTRAN(aChave[6] , '.' , '') , ',' , '.')) // valor do frete
Local nI         := 0
Local cCot       := substr(aChave[1], 1 , TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] )
Local cEmail     := ''
Local cFilialP   := substr(cId, 1, TamSx3('C8_FILIAL')[1]) 
Local cNum       := substr(cId, TamSx3('C8_FILIAL')[1] + 1, TamSx3('C8_NUM')[1])
Local cFornece   := substr(cId, TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] + 1, TamSx3('C8_FORNECE')[1])
Local cLoja      := substr(cId, TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] + TamSx3('C8_FORNECE')[1] + 1, TamSx3('C8_LOJA')[1])
Local cNumPro    := substr(cId, TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] + TamSx3('C8_FORNECE')[1] + TamSx3('C8_LOJA')[1] + 1)

Private PAramIxb := {}

dbSelectArea('SC8')
SC8->(dbSetOrder(1))

for nI := 1 to len(aProdutos)

	// valida o novo alias
	cAlias := ''
	while Empty(cAlias)
		cAlias := GetNextAlias()
		if Select(cAlias) > 0
			cAlias := ''
		endif
	enddo

	BeginSql Alias cAlias
		SELECT 
			SC8.R_E_C_N_O_ as RECNO 
		FROM 
			%table:SC8% SC8 
		WHERE 
			SC8.C8_FILIAL = %EXP:cFilialP%
			AND SC8.C8_NUM = %EXP:cNum%
			AND SC8.C8_FORNECE = %EXP:cFornece%
			AND SC8.C8_LOJA = %EXP:cLoja%
			AND SC8.C8_NUMPRO = %EXP:cNumPro%	
			AND SC8.C8_PRODUTO = %EXP:aProdutos[nI,1]%
			AND SC8.C8_ITEM = %EXP:aProdutos[nI,2]%	
			AND SC8.%NotDel%
		ORDER BY 
			SC8.C8_NUMPRO DESC
	endSql
	
	while !(cAlias)->(EOF())
         	
		nFrete := val(STRTRAN(STRTRAN(aProdutos[nI,9] , '.' , '') , ',' , '.')) // valor do frete
	
		SC8->(dbGoTop())
		SC8->(dbGoTo((cAlias)->RECNO))
		nQtdAux := val(STRTRAN(STRTRAN(aProdutos[nI,4] , '.' , '') , ',' , '.'))
		RecLock('SC8', .F.)
			SC8->C8_COND    := cCondicao		
			SC8->C8_PRODUTO := aProdutos[nI,1]            
			SC8->C8_ITEM    := aProdutos[nI,2]              
			SC8->C8_QUANT   := IIF(nQtdAux==0,SC8->C8_QUANT,nQtdAux)  
			SC8->C8_PRECO   := val(STRTRAN(STRTRAN(aProdutos[nI,3] , '.' , '') , ',' , '.'))
			SC8->C8_TOTAL   := SC8->C8_PRECO * SC8->C8_QUANT
			SC8->C8_VALFRE  := nFrete
			SC8->C8_TPFRETE := cTipoFrete
			SC8->C8_PRAZO   := val(aProdutos[nI,5])        
			SC8->C8_ALIIPI  := val(STRTRAN(STRTRAN(aProdutos[nI,6] , '.' , '') , ',' , '.'))
			SC8->C8_PICM    := val(STRTRAN(STRTRAN(aProdutos[nI,7] , '.' , '') , ',' , '.'))
			SC8->C8_XOBSWEB := aProdutos[nI,8]                                 
			SC8->C8_XRESP   := "S"
			SC8->C8_ORCFOR  := cNumOrc
			SC8->C8_ITEFOR  := aProdutos[nI,2]         
			SC8->C8_COND    := cTipoPgto
			SC8->C8_BASEICM := SC8->C8_TOTAL + nFrete
			SC8->C8_VALICM  := SC8->C8_TOTAL + nFrete * (SC8->C8_PICM / 100)
			SC8->C8_BASEIPI := SC8->C8_TOTAL
			SC8->C8_VALIPI  := SC8->C8_TOTAL * (SC8->C8_ALIIPI / 100) 		
			
			if (aProdutos[nI,10] == 'SIM')
				SC8->C8_XMOTIVO := 'Selecionado para não ser enviado pelo fornecedor.'
				SC8->C8_XHORA := TIME()
				SC8->C8_XDATAD := dDataBase
			endif
				
		SC8->(dbUnlock())
		(cAlias)->(dbSkip())
		nCount++		
	enddo
	dbCloseArea(cAlias)		
next nI

if (nCount == 0)
	// nao encontrou o cabecalho da da cotacao, retorna um soapFault
	aAdd(aRet,.F.)
	aAdd(aRet,'ERRO007')
	aAdd(aRet,'Cotacao nao encontrada na base de dados. / Quotation not found in the database.')	
else

	// loga o workflow como confirmado
	aAdd(ParamIxb, '')
	aAdd(ParamIxb, '')
	aAdd(ParamIxb, cId)
	aAdd(ParamIxb, 'Cotacao confirmada.')
	aAdd(ParamIxb, '3')
	U_ACOM0020( 'SZ0', -1, 3 )

	aAdd(aRet,.T.)
	aAdd(aRet,'Cotacao confirmada. / Quotation confirmed.')
	
	// valida o novo alias
	cAlias := ''
	while Empty(cAlias)
		cAlias := GetNextAlias()
		if Select(cAlias) > 0
			cAlias := ''
		endif
	enddo
	
	BeginSql Alias cAlias
		SELECT 
			COUNT(*) AS TOTAL 
		FROM 
			%table:SC8% SC8 
		WHERE 
			SC8.C8_FILIAL = %EXP:cFilialP%
			AND SC8.C8_NUM = %EXP:cNum%
			AND SC8.C8_FORNECE = %EXP:cFornece%
			AND SC8.C8_LOJA = %EXP:cLoja%
			AND SC8.C8_NUMPRO = %EXP:cNumPro%	
			AND SC8.C8_XRESP = %EXP:'S'%
			AND SC8.%NotDel%
		GROUP BY 
			SC8.C8_NUMPRO
		ORDER BY 
			SC8.C8_NUMPRO DESC
	endSql

	nCount := 0
	while !(cAliaS)->(EOF())
		nCount := (cAlias)->TOTAL
		(cAlias)->(dbSkip())
	enddo
	dbCloseArea(cAlias)
	
	if nCount >= SuperGetMv('TCP_MINCOT',.T.,999)
		cAlias := ''
		while Empty(cAlias)
			cAlias := GetNextAlias()
			if Select(cAlias) > 0
				cAlias := ''
			endif
		enddo
		BeginSql Alias cAlias
			SELECT 
				SRA.RA_EMAIL 
			FROM 
				%table:SC8% SC8 
			INNER JOIN %table:SC1% SC1 ON
				SC1.C1_FILIAL = %xFilial:SC1%
				AND SC1.C1_NUM = SC8.C8_NUMSC
				AND SC1.%NotDel% 
			INNER JOIN %table:SRA% SRA
				SRA.RA_FILIAL = %xFilial:SRA%
				AND SRA.RA_MAT = SC1.C1_REQUISI
				AND SRA.%NotDel% 
			WHERE 
				SC8.C8_FILIAL = %EXP:cFilialP%
				AND SC8.C8_NUM = %EXP:cNum%
				AND SC8.C8_XRESP = %EXP:'S'%
				AND SC8.%NotDel%	
			ORDER BY 
				SC8.C8_NUMPRO DESC
		endSql
	
		while !(cAliaS)->(EOF())
			cEmail := (cAlias)->RA_EMAIL
			(cAlias)->(dbSkip())
		enddo
		dbCloseArea(cAlias)
		
		if !Empty(cEmail)
			cHtml := '<html>' + CRLF
			cHtml += '	<head>' + CRLF 
			cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' + CRLF 
			cHtml += '		<title>Minimo de Cotações Atingido</title>' + CRLF 
			cHtml += '		<style type="text/css">' + CRLF 
			cHtml += '			.Arial {' + CRLF 
			cHtml += '				font-family: Arial, Helvetica, sans-serif;' + CRLF 
			cHtml += '				font-size: 20px;' + CRLF 
			cHtml += '			}' + CRLF 
			cHtml += '		</style>' + CRLF 
			cHtml += '	</head>' + CRLF 
			cHtml += '         ' + CRLF 
			cHtml += '	<body>' + CRLF
			cHtml += '		<p> Número mínimo de cotações atingido. </p>' + CRLF
			cHtml += '		<p></p>' + CRLF			
			cHtml += '		<p>(Não responder este e-mail.)</p>' + CRLF
			cHtml += '	</body>' + CRLF
			cHtml += '</html>' + CRLF
			
			aAdd(aEmails,{cMail, '', 'Minimo de Cotacoes Atingido', cHtml})
			U_MCOM002(aEmails)
			
			aRet := U_MCOM002(aClone(aEmails)) 
		endif
	endif
endif

RestArea(aArea)

Return aRet