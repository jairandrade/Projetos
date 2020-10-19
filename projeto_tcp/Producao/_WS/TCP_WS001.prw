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
|Nome              | TCP_WS001.PRW                                           |
+------------------+---------------------------------------------------------+
|Descricao         | WebServices Portal Confirmação de Cotações              |
+------------------+---------------------------------------------------------+
|Autor             | Lucas Jose Correa Chagas.                               |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 21/05/2013                                              |
+------------------+--------------------------------------------------------*/
User Function WS001( cChave )

Local aArea    := GetArea()
Local aRet     := {}
Local aEmp     := {}
Local aCot     := {}
Local aDet     := {}
Local aTp      := {}
Local cAlias   := ''
Local cQuery   := ''
Local cCnpj    := '' 
Local cCot     := ''
Local cProp    := ''
Local cFilialP := substr(cChave, 1, TamSx3('C8_FILIAL')[1]) 
Local cNum     := substr(cChave, TamSx3('C8_FILIAL')[1] + 1, TamSx3('C8_NUM')[1])
Local cFornece := substr(cChave, TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] + 1, TamSx3('C8_FORNECE')[1])
Local cLoja    := substr(cChave, TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] + TamSx3('C8_FORNECE')[1] + 1, TamSx3('C8_LOJA')[1])
Local cNumPro  := substr(cChave, TamSx3('C8_FILIAL')[1] + TamSx3('C8_NUM')[1] + TamSx3('C8_FORNECE')[1] + TamSx3('C8_LOJA')[1] + 1)
Local nI       := 0

cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT 
		SC8.R_E_C_N_O_ AS RECNO, SC8.C8_NUMPRO, SA2.A2_NOME, SA2.A2_EMAIL, 
		SA2.A2_EST, SA2.A2_CGC 
	FROM 
		%table:SC8% SC8 
	INNER JOIN %table:SA2% SA2 ON 
		SA2.A2_FILIAL = %xFilial:SA2%
		AND SA2.A2_COD = SC8.C8_FORNECE 
		AND SA2.A2_LOJA = SC8.C8_LOJA 
		AND SA2.%NotDel%
	WHERE 
		SC8.C8_FILIAL = %EXP:cFilialP%
		AND SC8.C8_NUM = %EXP:cNum%
		AND SC8.C8_FORNECE = %EXP:cFornece%
		AND SC8.C8_LOJA = %EXP:cLoja%
		AND SC8.C8_NUMPRO = %EXP:cNumPro%		
		AND SC8.%NotDel%
	ORDER BY 
		SC8.C8_NUMPRO DESC
endSql

dbSelectArea('SC8')
SC8->(dbSetOrder(1))

nI := 1
While (cAlias)->(!EOF()) .and. nI == 1

	SC8->(dbGoTop())
	SC8->(dbGoTo((cAlias)->RECNO))

	if (!(SC8->(FieldPos('C8_ACCNUM'))>0 .And.;
		!Empty(SC8->C8_ACCNUM) .And.;
		Empty(SC8->C8_NUMPED)) .And.;
	    (SC8->C8_PRECO == 0) .And.;
	    (Empty(SC8->C8_NUMPED)) .and. ;
	    (empty(SC8->C8_XHORA)) .and. (Empty(SC8->C8_XDATAD)))
	    
	    // vai verificar se já não foi cancelada
	    if (Empty(SC8->C8_MOTCAN) .AND. Empty(SC8->C8_USUCAN) .AND. Empty(SC8->C8_DTCANC))
	
			if (len(AllTrim((cAlias)->A2_CGC)) > 11)
				cCNPJ := ALLTRIM(TRANSFORM((cAlias)->A2_CGC, "@R 99.999.999/9999-99"))
			else
				cCNPJ := ALLTRIM(TRANSFORM((cAlias)->A2_CGC, "@R 999.999.999-99"))
			endif
	
			aAdd(aEmp,SM0->M0_NOME   )
			aAdd(aEmp,SM0->M0_NOMECOM)
			aAdd(aEmp,SM0->M0_ENDCOB )
			aAdd(aEmp,SM0->M0_CIDCOB )
			aAdd(aEmp,SM0->M0_ESTCOB )
			aAdd(aEmp,SM0->M0_CEPCOB )
			aAdd(aEmp,SM0->M0_CGC    )
			aAdd(aEmp,SM0->M0_INSC   )
			aAdd(aEmp,SM0->M0_TEL    )
		
			aAdd(aDet, SC8->C8_FORNECE  )
			aAdd(aDet, SC8->C8_LOJA     )
			aAdd(aDet,(cAlias)->A2_NOME )
			aAdd(aDet,(cAlias)->A2_EMAIL)
			aAdd(aDet,(cAlias)->A2_EST  )
			aAdd(aDet,cCNPJ             )
		
			aAdd(aCot, SC8->C8_NUM   )
			aAdd(aCot, SC8->C8_VALIDA)
			aAdd(aCot, SC8->C8_NUMPRO)
		
			aAdd(aRet, .T.         ) 
			aAdd(aRet, aClone(aEmp))
			aAdd(aRet, aClone(aCot))
			aAdd(aRet, aClone(aDet))
		else
			aAdd(aRet,.F.)
			aAdd(aRet,'ERRO009')
			aAdd(aRet,'A cotação ' + cChave + ' foi cancelada! / The price ' + cChave + ' was canceled!')
		endif
	else
		cCot := SC8->C8_NUM
		cProp := SC8->C8_NUMPRO
		aAdd(aRet,.F.)
		aAdd(aRet,'ERRO003')
		aAdd(aRet,'A cotação ' + cCot + ' - ' + cProp + ' não esta disponível para retorno! / The price ' + cCot + ' - ' + cProp + ' is not available for return!')
	endif

	(cAlias)->(DbSkip())
	nI++
enddo

dbCloseArea(cAlias)

// busca as condições de pagamento
cQuery := "SELECT " 
cQuery += "	SE4.E4_CODIGO, SE4.E4_DESCRI "
cQuery += "FROM " + RetSqlName('SE4') + " SE4 "
cQuery += "WHERE "
cQuery += "	SE4.E4_FILIAL = '" + xFilial('SE4') + "'"
cQuery += "	AND SE4.D_E_L_E_T_ <> '*' "    
cQuery += "	AND SE4.E4_SITE = 'S' "  
cQuery += "ORDER BY "
cQuery += "	SE4.E4_CODIGO"
cAlias := GetNextAlias()
TcQuery cQuery New Alias (cAlias)

While (cAlias)->(!EOF())
	aAdd(aTp, {(cAlias)->E4_CODIGO, (cAlias)->E4_DESCRI})
	(cAlias)->(DbSkip())
enddo
dbCloseArea(cAlias)

if (len(aRet) == 0)
	aAdd(aRet,.F.)
	aAdd(aRet,'ERRO002')
	aAdd(aRet,'Cotação não encontrada com a chave repassada! / Quote not found with the key passed!')
else
	aAdd(aRet, aClone(aTp))
endif

RestArea(aArea)

Return aRet
