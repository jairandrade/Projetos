#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Lançamentos Padrões (compensação a pagar e receber)                                                                                    |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 04/09/2015                                                                                                                       |
| Descricao: Contabilizar os valores de juros, multas, descontos e correção monetárias nas compensações                                  |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function ACTB001(tipo)

aArea := GetArea()

Private nCtbVlr := 0

cInfCpo	:= TamSX3("E5_CLIFOR")[1]

//CPag LP 597 E 589 = E5_FORNECE , CRec LP 596 E 588 = E5_CLIENTE

If Empty(SE5->E5_CLIENTE)
	cInfCpo	:= "E5_FORNECE"
ElseIf Empty(SE5->E5_FORNECE)
	cInfCpo	:= "E5_CLIENTE"
EndIf

cQuery := "SELECT E5_VLJUROS, E5_VLMULTA, E5_VLCORRE, E5_VLDESCO, E5_VLACRES, E5_VLDECRE, E5_FILORIG "
cQuery += "FROM " + RetSQLName("SE5") + " AS SE5 "
cQuery += "WHERE D_E_L_E_T_ != '*' "
cQuery += "AND E5_DATA = '"+DTOS(SE5->E5_DATA)+"' "
cQuery += "AND E5_FILIAL = '"+SE5->E5_FILIAL+"' "

If Empty(SE5->E5_FORNECE)
	cQuery += "AND E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_LOJA = '"+RTRIM(SE5->E5_DOCUMEN)+"' "
	cQuery += "AND " + cInfCpo + "+E5_LOJA = '"+SE5->E5_FORNADT+SE5->E5_LOJAADT+"' "
Else
	cQuery += "AND E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA = '"+RTRIM(SE5->E5_DOCUMEN)+"' "
EndIf

cQuery += "AND E5_SEQ = '"+SE5->E5_SEQ+"' "

TcQuery cQuery New Alias "E5VLRS"

If E5VLRS->(!Eof())
	
	If tipo = "JUROS"
		nCtbVlr	:= E5_VLJUROS
	ElseIf tipo = "MULTA"
		nCtbVlr	:= E5_VLMULTA
	ElseIf tipo = "CORRECAO"
		nCtbVlr	:= E5_VLCORRE
	ElseIf tipo = "DESCONTO"
		nCtbVlr	:= E5_VLDESCO
	ElseIf tipo = "ACRESC"
		nCtbVlr	:= E5_VLACRES
	ElseIf tipo = "DECRESC"
		nCtbVlr	:= E5_VLDECRE
	ElseIf tipo = "FILORIG"
		nCtbVlr	:= E5_FILORIG
	Endif
	
Endif

dbCloseArea("E5VLRS")

RestArea(aArea)

Return(nCtbVlr)
