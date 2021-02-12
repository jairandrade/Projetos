#include "protheus.ch"
#include "topconn.ch"

#define ENTER chr(13)+chr(10)

/*/{Protheus.doc} KFATR24
Rotina que identifica se algum produto ficou sem saldo e bloqueia a venda pelo app
@type function
@version 
@author luizh
@since 18/05/2020
@param cPedido, character, Número do Pedido
@param nOper, numeric, Operacao M410STTS (3 - Inclusão, 4 - Alteração, 5 - Exclusão, 6 - Cópia, 7 - Devolução de Compras)
@return nil, nada
/*/
User Function KFATR24(cPedido,nOper)
	Local aArea		:= GetArea()
	Local aProds	:= {}
	Local nPProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"	})
	Local nPos		:= 0
	Local nX		:= 0
	Local cProd		:= ""

	If nOper >= 3 .and. nOper <= 6
		For nX := 1 To Len(aCols)
			cProd := aCols[nX][nPProd]

			if (nPos := aScan(aProds,cProd)) == 0
				aadd(aProds,cProd)
			Endif
		Next

		For nX := 1 to Len(aProds)
			cProd := aProds[nX]

			AnaliseSaldo(cProd)
		Next
	Endif

	RestArea(aArea)
Return

Static Function AnaliseSaldo(cProduto)
	Local nSaldo := GetSaldo(cProduto)

	If nSaldo <= 0
		ManipularBloqueio(cProduto,"S")
	Else
		ManipularBloqueio(cProduto,"N")
	Endif

Return

Static Function ManipularBloqueio(cProduto,cStatus)
	Local aArea 	:= GetArea()
	Local lExiste	:= .F.
	Local cCampo	:= "Z3_EMP"
	Local _cEmp		:= Substr(cEmpAnt,2,1)
	Local nPos		:= 0

	if cEmpAnt == "99"
		_cEmp		:= Substr("04",2,1)
	Endif

	cCampo += _cEmp + "_" + cFilAnt

	If ( nPos := SZ3->(FieldPos(cCampo)) ) > 0

		SZ3->( DbSetOrder(1) )
		lExiste := SZ3->( MsSeek(xFilial("SZ3")+cProduto))
		
		If !(!lExiste .and. cStatus == "N") .or. cStatus == "S"
			Begin Transaction
				RecLock("SZ3",!lExiste)
					SZ3->Z3_FILIAL	:= xFilial("SZ3")
					SZ3->Z3_CODPROD	:= cProduto
					SZ3->( FieldPut(nPos,cStatus) )
				MsUnLock("SZ3")
			End Transaction
		Endif
	Endif

	RestArea(aArea)
Return 

/*
	Obtem o saldo a partir da view 
*/
Static Function GetSaldo(cProduto)
	Local aArea		:= GetArea()	
	Local nRet		:= 0
	Local cQuery	:= ""
	Local cTemp		:= GetNextAlias()
	Local cArmVenda	:= "04"

	cQuery += "SELECT "+ENTER
	cQuery += "	FILIAL_CODIGO "+ENTER
	cQuery += "	,PRODUTO_CODIGO "+ENTER
	cQuery += "	,QUANTIDADE_DISPONIVEL "+ENTER
	cQuery += "	,ISNULL(B2_QPEDVEN,0) B2_QPEDVEN "+ENTER
	cQuery += "	,QUANTIDADE_DISPONIVEL - ISNULL(B2_QPEDVEN,0) SALDO "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM VW_PRODUTO_ESTOQUE "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SB2")+" SB2 ON SB2.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND B2_FILIAL = FILIAL_CODIGO "+ENTER
	cQuery += "		AND B2_COD = PRODUTO_CODIGO "+ENTER
	cQuery += "		AND B2_LOCAL = '"+cArmVenda+"' "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		FILIAL_CODIGO='"+xFilial("SB2")+"' "+ENTER
	cQuery += "	AND PRODUTO_CODIGO='"+cProduto+"' "+ENTER

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif

	TcQuery cQuery New Alias (cTemp)

	If !(cTemp)->(EOF())
		nRet := (cTemp)->SALDO
	Endif

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif

	RestArea(aArea)
Return nRet
